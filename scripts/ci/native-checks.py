"""Portable functional tests and unsigned builds on GitHub's macOS 26 runner.
Rendering snapshots remain on their documented macOS/iOS 27 reference runtimes.
"""
import json, pathlib, subprocess, sys
logs = pathlib.Path('.agent/ci-logs'); logs.mkdir(parents=True, exist_ok=True)
def run(name, args):
    print(f'Running {name}', flush=True)
    with (logs / (name + '.log')).open('w') as log:
        result = subprocess.run(args, stdout=log, stderr=subprocess.STDOUT)
    if result.returncode:
        print('\n'.join((logs / (name + '.log')).read_text().splitlines()[-100:]))
        raise SystemExit(result.returncode)
    print(f'Passed {name}', flush=True)
run('generate', ['xcodegen', 'generate', '--spec', 'PiyoPiyo/project.yml'])
run('core-tests', ['swift', 'test', '--package-path', 'PiyoPiyo/PiyoPiyoCore', '--skip', 'SnapshotTests'])
run('sources-build', ['swift', 'build', '--package-path', 'SourcesDesk', '-c', 'release'])
run('mac-build', ['xcodebuild', '-project', 'PiyoPiyo/PiyoPiyo.xcodeproj', '-scheme', 'PiyoPiyo-macOS', '-configuration', 'Debug', '-destination', 'platform=macOS', '-derivedDataPath', 'DerivedData/ci-mac', 'CODE_SIGNING_ALLOWED=NO', 'build'])
run('ios-build', ['xcodebuild', '-project', 'PiyoPiyo/PiyoPiyo.xcodeproj', '-scheme', 'PiyoPiyo-iOS', '-configuration', 'Debug', '-sdk', 'iphonesimulator', '-destination', 'generic/platform=iOS Simulator', '-derivedDataPath', 'DerivedData/ci-ios', 'CODE_SIGNING_ALLOWED=NO', 'build'])
devices = json.loads(subprocess.check_output(['xcrun', 'simctl', 'list', 'devices', 'available', '--json']))['devices']
ios = [(runtime, values) for runtime, values in devices.items() if '.iOS-' in runtime and values]
if not ios:
    raise SystemExit('No iOS simulator runtime is installed')
runtime, available = sorted(ios, key=lambda row: tuple(int(x) for x in row[0].split('.iOS-')[1].split('-')), reverse=True)[0]
for family, scheme in [('iPhone', 'PiyoPiyo-iPhoneTests'), ('iPad', 'PiyoPiyo-iPadTests')]:
    candidates = [d for d in available if d['name'].startswith(family)]
    if not candidates: raise SystemExit(f'No {family} simulator in {runtime}')
    target = candidates[0]['udid']
    run(f'{family}-tests', ['xcodebuild', '-project', 'PiyoPiyo/PiyoPiyo.xcodeproj', '-scheme', scheme, '-destination', f'platform=iOS Simulator,id={target}', '-derivedDataPath', 'DerivedData/ci-tests', '-resultBundlePath', f'artifacts/ci/{family}.xcresult', f'-skip-testing:{scheme}/SnapshotTests', 'CODE_SIGNING_ALLOWED=NO', 'test'])
    subprocess.run(['xcrun', 'simctl', 'shutdown', target], check=False, capture_output=True)
