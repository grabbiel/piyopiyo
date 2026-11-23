"""Build signed iOS and notarized Mac artifacts in an ephemeral CI keychain."""
import base64, datetime, hashlib, json, os, pathlib, plistlib, re, secrets, shlex, shutil, subprocess, tempfile
root=pathlib.Path.cwd()
version=os.environ['RELEASE_VERSION']
if not re.fullmatch(r'[0-9]+\.[0-9]+\.[0-9]+',version): raise SystemExit('Use a three-component numeric release version')
build=str(100+int(os.environ['GITHUB_RUN_NUMBER']))
output=root/'artifacts/apple-release';output.mkdir(parents=True,exist_ok=True)
logs=root/'.agent/apple-logs';logs.mkdir(parents=True,exist_ok=True)
proof={'version':version,'build':build,'commit':os.environ['GITHUB_SHA'],'artifacts':[],'notarization':{}}
def quiet(args, **kwargs):
    result=subprocess.run(args,capture_output=True,text=True,**kwargs)
    if result.returncode: raise RuntimeError(f'{args[0]} credential/signing operation failed (exit {result.returncode}); no secrets logged')
    return result.stdout

def logged(name,args,**kwargs):
    print(f'Running {name}',flush=True)
    with (logs/(name+'.log')).open('w') as handle:
        result=subprocess.run(args,stdout=handle,stderr=subprocess.STDOUT,**kwargs)
    if result.returncode:
        # Build output has no credentials; credential commands use quiet() exclusively.
        print('\n'.join((logs/(name+'.log')).read_text().splitlines()[-80:]))
        raise RuntimeError(f'{name} failed')

with tempfile.TemporaryDirectory(prefix='piyopiyo-signing-',dir=os.environ.get('RUNNER_TEMP')) as temporary:
    private=pathlib.Path(temporary);private.chmod(0o700)
    keychain=private/'signing.keychain-db';password=secrets.token_urlsafe(32)
    previous=shlex.split(quiet(['security','list-keychains','-d','user']))
    profile_paths=[];created=False
    try:
        quiet(['security','create-keychain','-p',password,str(keychain)]);created=True
        quiet(['security','set-keychain-settings','-lut','21600',str(keychain)])
        quiet(['security','unlock-keychain','-p',password,str(keychain)])
        quiet(['security','list-keychains','-d','user','-s',str(keychain),*previous])
        for stem in ['IOS_DISTRIBUTION','DEVELOPER_ID']:
            print('Importing '+stem+' signing identity',flush=True)
            p12=private/(stem+'.p12');p12.write_bytes(base64.b64decode(os.environ[stem+'_P12_BASE64'],validate=True));p12.chmod(0o600)
            quiet(['security','import',str(p12),'-k',str(keychain),'-P',os.environ[stem+'_PASSWORD'],'-T','/usr/bin/codesign','-T','/usr/bin/security'])
        quiet(['security','set-key-partition-list','-S','apple-tool:,apple:,codesign:','-k',password,str(keychain)])
        identities=quiet(['security','find-identity','-v','-p','codesigning',str(keychain)])
        def identity(label):
            match=re.search(r'([A-F0-9]{40}) "'+re.escape(label)+r'[^"\n]*"',identities)
            if not match:raise RuntimeError('Required valid signing identity missing: '+label)
            return match.group(1)
        ios_identity=identity('Apple Distribution:');mac_identity=identity('Developer ID Application:')
        profile=private/'iphone.mobileprovision';profile.write_bytes(base64.b64decode(os.environ['IOS_PROFILE_BASE64'],validate=True));profile.chmod(0o600)
        profile_info=plistlib.loads(subprocess.check_output(['security','cms','-D','-i',str(profile)]))
        if profile_info['ExpirationDate']<datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None):raise RuntimeError('Provisioning profile has expired')
        if profile_info['Entitlements']['application-identifier']!=os.environ['APPLE_TEAM_ID']+'.app.piyopiyo.iphone':raise RuntimeError('Unexpected provisioning profile bundle')
        for directory in [pathlib.Path.home()/'Library/MobileDevice/Provisioning Profiles',pathlib.Path.home()/'Library/Developer/Xcode/UserData/Provisioning Profiles']:
            directory.mkdir(parents=True,exist_ok=True);destination=directory/(profile_info['UUID']+'.mobileprovision')
            if destination.exists():raise RuntimeError('Refusing to replace an existing provisioning profile')
            shutil.copy2(profile,destination);profile_paths.append(destination)
        key=private/('AuthKey_'+os.environ['ASC_KEY_ID']+'.p8');key.write_text(os.environ['ASC_PRIVATE_KEY']);key.chmod(0o600)
        logged('generate',['xcodegen','generate','--spec','PiyoPiyo/project.yml'])
        settings=[f'MARKETING_VERSION={version}',f'CURRENT_PROJECT_VERSION={build}',f'DEVELOPMENT_TEAM={os.environ["APPLE_TEAM_ID"]}']
        archive=output/'PiyoPiyo.xcarchive'
        logged('ios-archive',['xcodebuild','-project','PiyoPiyo/PiyoPiyo.xcodeproj','-scheme','PiyoPiyo-iOS','-configuration','Release','-sdk','iphoneos','-destination','generic/platform=iOS','-archivePath',str(archive),'-derivedDataPath',str(root/'DerivedData/apple-ios'),*settings,'CODE_SIGN_STYLE=Manual',f'CODE_SIGN_IDENTITY={ios_identity}',f'PIYOPIYO_IOS_PROFILE={profile_info["Name"]}','archive'])
        export={'method':'app-store-connect','destination':'export','signingStyle':'manual','teamID':os.environ['APPLE_TEAM_ID'],'signingCertificate':ios_identity,'provisioningProfiles':{'app.piyopiyo.iphone':profile_info['Name']},'manageAppVersionAndBuildNumber':False,'uploadSymbols':False,'stripSwiftSymbols':True}
        export_path=private/'ExportOptions.plist';export_path.write_bytes(plistlib.dumps(export))
        logged('ios-export',['xcodebuild','-exportArchive','-archivePath',str(archive),'-exportPath',str(output/'ios'),'-exportOptionsPlist',str(export_path)])
        archived_app=next((archive/'Products/Applications').glob('*.app'))
        app_info=plistlib.loads((archived_app/'Info.plist').read_bytes())
        assert app_info['CFBundleIdentifier']=='app.piyopiyo.iphone'
        assert app_info['CFBundleShortVersionString']==version and app_info['CFBundleVersion']==build
        assert app_info['UIDeviceFamily']==[1,2] and len(app_info['UISupportedInterfaceOrientations'])==4
        logged('mac-build',['xcodebuild','-project','PiyoPiyo/PiyoPiyo.xcodeproj','-scheme','PiyoPiyo-macOS','-configuration','Release','-destination','platform=macOS','-derivedDataPath',str(root/'DerivedData/apple-mac'),*settings,f'CODE_SIGN_IDENTITY={mac_identity}','build'])
        main=output/'PiyoPiyo.app';shutil.copytree(root/'DerivedData/apple-mac/Build/Products/Release/PiyoPiyo.app',main)
        source_env={**os.environ,'PIYOPIYO_RELEASE_DIR':str(output),'PIYOPIYO_SOURCES_VERSION':version,'PIYOPIYO_BUILD_NUMBER':build,'PIYOPIYO_SIGNING_IDENTITY':mac_identity}
        logged('sources-package',['python3','scripts/package-sources.py'],env=source_env)
        for app in [main,output/'PiyoPiyo Sources.app']:
            quiet(['codesign','--verify','--deep','--strict',str(app)])
            name=app.stem.replace(' ','-')+'-'+version+'.zip';zip_path=output/name
            quiet(['ditto','-c','-k','--keepParent',str(app),str(zip_path)])
            result=json.loads(quiet(['xcrun','notarytool','submit',str(zip_path),'--key',str(key),'--key-id',os.environ['ASC_KEY_ID'],'--issuer',os.environ['ASC_ISSUER_ID'],'--wait','--timeout','15m','--output-format','json']))
            if result.get('status')!='Accepted':raise RuntimeError('Notarization failed: '+str(result.get('id')))
            proof['notarization'][app.stem]={'id':result['id'],'status':result['status']}
            quiet(['xcrun','stapler','staple',str(app)])
            quiet(['spctl','--assess','--type','execute',str(app)])
            quiet(['ditto','-c','-k','--keepParent',str(app),str(zip_path)])
        ipa=next((output/'ios').glob('*.ipa'));proof['ipaPath']=str(ipa.relative_to(root))
        for path in [ipa,*output.glob('*.zip')]:
            proof['artifacts'].append({'path':str(path.relative_to(root)),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'bytes':path.stat().st_size})
        proof['status']='SIGNED_AND_NOTARIZED';proof['completedAt']=datetime.datetime.now(datetime.timezone.utc).isoformat()
        (output/'manifest.json').write_text(json.dumps(proof,indent=2)+'\n')
        print('Signed iPhone/iPad IPA and both notarized Mac packages are ready.',flush=True)
    finally:
        quiet(['security','list-keychains','-d','user','-s',*previous])
        if created:quiet(['security','delete-keychain',str(keychain)])
        for path in profile_paths:path.unlink(missing_ok=True)
