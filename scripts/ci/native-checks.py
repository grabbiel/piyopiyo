"""Portable functional tests and unsigned builds on GitHub's Xcode 27 runner.
Rendering snapshots remain on their documented macOS/iOS 27 reference runtimes.
"""
import json, pathlib, subprocess, sys
from apple_toolchain import verify_toolchain
from native_simulators import select_ios_targets
verify_toolchain()
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
runtimes = json.loads(subprocess.check_output(['xcrun', 'simctl', 'list', 'runtimes', '--json']))['runtimes']
runtime, targets = select_ios_targets(devices, runtimes)
print(f'Testing iPhone and iPad on {runtime}', flush=True)
for family, scheme in [('iPhone', 'PiyoPiyo-iPhoneTests'), ('iPad', 'PiyoPiyo-iPadTests')]:
    target = targets[family]
    run(f'{family}-tests', ['xcodebuild', '-project', 'PiyoPiyo/PiyoPiyo.xcodeproj', '-scheme', scheme, '-destination', f'platform=iOS Simulator,id={target}', '-derivedDataPath', 'DerivedData/ci-tests', '-resultBundlePath', f'artifacts/ci/{family}.xcresult', f'-skip-testing:{scheme}/SnapshotTests', 'CODE_SIGNING_ALLOWED=NO', 'test'])
    subprocess.run(['xcrun', 'simctl', 'shutdown', target], check=False, capture_output=True)
