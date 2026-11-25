"""Select a shared iPhone/iPad runtime using simctl's version metadata."""


def select_ios_targets(devices, runtimes):
    candidates = []
    for runtime in runtimes:
        identifier = runtime['identifier']
        if not runtime.get('isAvailable') or '.iOS-' not in identifier:
            continue
        available = devices.get(identifier, [])
        targets = {}
        for family in ['iPhone', 'iPad']:
            target = next((d for d in available if d['name'].startswith(family) and d.get('isAvailable', True)), None)
            if target:
                targets[family] = target['udid']
        # Xcode 27 also installs hardware-specific runtimes with only an iPhone.
        if len(targets) == 2:
            version = tuple(int(part) for part in runtime['version'].split('.'))
            candidates.append((version, identifier, targets))
    if not candidates:
        raise RuntimeError('No available iOS runtime contains both an iPhone and an iPad simulator')
    _, identifier, targets = max(candidates, key=lambda item: item[:2])
    return identifier, targets
