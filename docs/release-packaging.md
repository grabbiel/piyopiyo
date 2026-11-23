# Reproducing the signed release

Version 1.0.0 (3) was packaged with Xcode 27. The project has three targets, but the iOS and iPadOS application targets both support device families 1 and 2 under `app.piyopiyo.iphone`; distribute one universal IPA. Separate simulator test schemes retain their intended form factors.

## Generate and build

```sh
swift scripts/make-icons.swift
xcodegen generate --spec PiyoPiyo/project.yml
xcodebuild -project PiyoPiyo/PiyoPiyo.xcodeproj \
  -scheme PiyoPiyo-macOS -configuration Release \
  -derivedDataPath DerivedData/release-mac build
xcodebuild -project PiyoPiyo/PiyoPiyo.xcodeproj \
  -scheme PiyoPiyo-iOS -configuration Release \
  -destination generic/platform=iOS \
  -archivePath artifacts/release/PiyoPiyo-iOS.xcarchive archive
xcodebuild -exportArchive \
  -archivePath artifacts/release/PiyoPiyo-iOS.xcarchive \
  -exportPath artifacts/release/iOS \
  -exportOptionsPlist PiyoPiyo/ExportOptions.plist
```

Use the installed Apple Distribution identity and `PiyoPiyo iPhone App Store` profile. Release signing is configured on the application targets so the profile does not propagate to Swift package resource bundles. The profile is installed in Xcode's user provisioning-profile directory. Mac uses Developer ID, hardened runtime, secure timestamps, sandbox/network/file-selection entitlements, and no debug task entitlement.

The app-specific signing keychain and its unlock material are under ignored `.macos/release-signing/`. The previous keychain search list was restored and the app keychain locked after this release. Future builds must unlock/add it for signing, then restore/lock it afterward. Do not print passwords or copy keys into project resources. Existing private Apple API-key metadata is in ignored `.agent/apple-credentials.json`.

## Notarize the Mac app

Quit the running release app before replacing its bundle. Copy the built app to `artifacts/release/PiyoPiyo.app`, verify its signature, and ZIP with `ditto -c -k --keepParent`. Submit that ZIP with `xcrun notarytool submit --wait` using the owner's local API-key file or an existing Keychain profile. Do not log secret key contents.

After Apple returns Accepted:

```sh
xcrun stapler staple artifacts/release/PiyoPiyo.app
xcrun stapler validate artifacts/release/PiyoPiyo.app
codesign --verify --deep --strict artifacts/release/PiyoPiyo.app
spctl --assess --type execute --verbose artifacts/release/PiyoPiyo.app
ditto -c -k --keepParent artifacts/release/PiyoPiyo.app \
  artifacts/release/PiyoPiyo-1.0.0-rc.2.zip
```

Regenerate the final ZIP after stapling. Build 3 notarization ID: `df1313fe-a356-45ef-8712-e3ac7d6463aa`. SHA-256 checksums and icon verification are in `tests/release-artifacts.json`.

Before distribution, verify build/version and universal device families, both privacy manifests, Mac `.icns`/iOS icon entries, compiled assets, original audio/provenance, and absence of signing keys or external reference media. Run the release checks in the root README and record final device acceptance. Do not confuse an exported App Store IPA with a directly installable development build.
