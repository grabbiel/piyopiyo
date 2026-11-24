"""Verify Apple's minimum upload SDK before building or importing signing keys."""
import json
import re
import subprocess


def require_upload_sdk(value, label):
    match = re.fullmatch(r"(?:iphoneos)?(\d+)(?:\.\d+)*", value)
    if not match or int(match[1]) < 27:
        raise RuntimeError(f"{label} must be iOS 27 or later; found {value!r}")


def verify_toolchain():
    xcode = subprocess.check_output(["xcodebuild", "-version"], text=True).strip()
    match = re.match(r"Xcode (\d+)(?:\.\d+)*\n", xcode)
    if not match or int(match[1]) < 27 or "beta" in xcode.lower():
        raise RuntimeError(f"A release version of Xcode 27 or later is required; found {xcode!r}")
    sdk = subprocess.check_output(["xcrun", "--sdk", "iphoneos", "--show-sdk-version"], text=True).strip()
    require_upload_sdk(sdk, "Selected iPhone SDK")
    result = {"xcode": xcode, "iphoneosSDK": sdk}
    print(json.dumps(result), flush=True)
    return result


if __name__ == "__main__":
    verify_toolchain()
