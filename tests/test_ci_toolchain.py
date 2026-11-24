"""Reject the delivery configuration that caused ITMS-90725."""
import pathlib
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / 'scripts/ci'))
from apple_toolchain import require_upload_sdk, verify_toolchain


class ToolchainTests(unittest.TestCase):
    def test_minimum_sdk_and_actual_archive(self):
        for value in ['27.0', 'iphoneos27.2', '28.0']:
            require_upload_sdk(value, 'Test SDK')
        for value in ['26.5', 'iphoneos26.5', '', 'iphonesimulator27.2', '27beta']:
            with self.subTest(value=value), self.assertRaises(RuntimeError):
                require_upload_sdk(value, 'Test SDK')

    def test_new_xcode_with_old_selected_sdk_is_rejected(self):
        with patch('apple_toolchain.subprocess.check_output', side_effect=['Xcode 27.2\nBuild version 27B52\n', '26.5\n']):
            with self.assertRaises(RuntimeError):
                verify_toolchain()

    def test_old_or_beta_xcode_is_rejected(self):
        for value in ['Xcode 26.6\nBuild version 17F113', 'Xcode 27.3 beta\nBuild version 27C1']:
            with self.subTest(value=value), patch('apple_toolchain.subprocess.check_output', return_value=value):
                with self.assertRaises(RuntimeError):
                    verify_toolchain()


if __name__ == '__main__':
    unittest.main()
