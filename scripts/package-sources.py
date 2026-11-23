"""Build and sign the local administrator app using the existing Developer ID."""
import pathlib
import plistlib
import shutil
import subprocess
import os

ROOT = pathlib.Path(__file__).resolve().parent.parent
def main():
    subprocess.run(["swift", "build", "-c", "release"], cwd=ROOT / "SourcesDesk", check=True)
    products = ROOT / "SourcesDesk/.build/release"
    output = pathlib.Path(os.environ.get("PIYOPIYO_RELEASE_DIR", str(ROOT / "artifacts/release")))
    version = os.environ.get("PIYOPIYO_SOURCES_VERSION", "1.0.1")
    build = os.environ.get("PIYOPIYO_BUILD_NUMBER", "2")
    identity = os.environ.get("PIYOPIYO_SIGNING_IDENTITY", "A884C146755B287E874F80402695F64BFB233159")
    app = output / "PiyoPiyo Sources.app"
    contents = app / "Contents"
    for directory in [contents / "MacOS", contents / "Resources"]:
        directory.mkdir(parents=True, exist_ok=True)
    shutil.copy2(products / "SourcesDesk", contents / "MacOS/SourcesDesk")
    shutil.copytree(products / "SourcesDesk_SourcesDesk.bundle", contents / "Resources/SourcesDesk_SourcesDesk.bundle", dirs_exist_ok=True)
    subprocess.run(["swift", "scripts/make-sources-icons.swift"], cwd=ROOT, check=True)
    subprocess.run(["iconutil", "-c", "icns", str(ROOT / "SourcesDesk/Branding/SourcesIcon.iconset"), "-o", str(contents / "Resources/SourcesIcon.icns")], check=True)
    (contents / "Resources/AppIcon.icns").unlink(missing_ok=True)
    info = {"CFBundleExecutable": "SourcesDesk", "CFBundleIdentifier": "app.piyopiyo.sources", "CFBundleName": "PiyoPiyo Sources", "CFBundleDisplayName": "PiyoPiyo Sources", "CFBundlePackageType": "APPL", "CFBundleShortVersionString": version, "CFBundleVersion": build, "CFBundleIconFile": "SourcesIcon", "LSMinimumSystemVersion": "14.0", "LSApplicationCategoryType": "public.app-category.education", "NSHighResolutionCapable": True, "CFBundleURLTypes": [{"CFBundleURLName": "app.piyopiyo.sources.auth", "CFBundleURLSchemes": ["piyopiyo-sources"]}], "CFBundleDocumentTypes": [{"CFBundleTypeName": "Learning source", "CFBundleTypeRole": "Viewer", "LSHandlerRank": "Alternate", "LSItemContentTypes": ["com.adobe.pdf", "public.plain-text", "net.daringfireball.markdown"]}]}
    (contents / "Info.plist").write_bytes(plistlib.dumps(info))
    subprocess.run(["codesign", "--force", "--options", "runtime", "--timestamp", "--sign", identity, str(app)], check=True)
    subprocess.run(["codesign", "--verify", "--deep", "--strict", str(app)], check=True)
    subprocess.run(["ditto", "-c", "-k", "--keepParent", str(app), str(output / f"PiyoPiyo-Sources-{version}.zip")], check=True)
    print("Signed PiyoPiyo Sources app and ZIP are ready.")
if __name__ == "__main__":
    main()
