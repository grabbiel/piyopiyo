import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / 'scripts/ci'))
from native_simulators import select_ios_targets


class SimulatorTests(unittest.TestCase):
    def test_hardware_suffix_does_not_break_version_sorting_or_drop_ipad(self):
        prefix = 'com.apple.CoreSimulator.SimRuntime.iOS-'
        runtimes = [
            {'identifier': prefix + '27-0', 'version': '27.0', 'isAvailable': True},
            {'identifier': prefix + '27-2', 'version': '27.2', 'isAvailable': True},
            {'identifier': prefix + '27-2-iPhone19-1', 'version': '27.2', 'isAvailable': True},
            {'identifier': prefix + '27-3', 'version': '27.3', 'isAvailable': False},
        ]
        pair = [{'name': 'iPhone 17', 'udid': 'phone'}, {'name': 'iPad mini', 'udid': 'tablet'}]
        devices = {r['identifier']: pair for r in runtimes}
        devices[prefix + '27-2-iPhone19-1'] = [{'name': 'iPhone Duo', 'udid': 'duo'}]
        self.assertEqual(select_ios_targets(devices, runtimes), (prefix + '27-2', {'iPhone': 'phone', 'iPad': 'tablet'}))

    def test_missing_ipad_fails_instead_of_silently_omitting_coverage(self):
        runtime = {'identifier': 'com.apple.CoreSimulator.SimRuntime.iOS-27-2', 'version': '27.2', 'isAvailable': True}
        with self.assertRaisesRegex(RuntimeError, 'both an iPhone and an iPad'):
            select_ios_targets({runtime['identifier']: [{'name': 'iPhone 17', 'udid': 'phone'}]}, [runtime])
