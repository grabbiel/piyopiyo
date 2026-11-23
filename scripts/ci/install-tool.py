"""Install checksum-pinned official CI tool releases, without changing system tools."""
import hashlib, os, pathlib, shutil, sys, tempfile, urllib.request
TOOLS = {
    'xcodegen': ('https://github.com/yonaskolb/XcodeGen/releases/download/2.48.0/xcodegen.zip', '620c9f0dc10849f94728ab5df52d225ebab8187439dd6fee1925e59e80dff892', 'zip'),
    'gitleaks': ('https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_x64.tar.gz', '551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb', 'gztar'),
    'actionlint': ('https://github.com/rhysd/actionlint/releases/download/v1.7.12/actionlint_1.7.12_linux_amd64.tar.gz', '8aca8db96f1b94770f1b0d72b6dddcb1ebb8123cb3712530b08cc387b349a3d8', 'gztar'),
}
for name in sys.argv[1:]:
    url, expected, archive_format = TOOLS[name]
    with tempfile.TemporaryDirectory() as tmp:
        archive = pathlib.Path(tmp) / 'download'
        with urllib.request.urlopen(url, timeout=60) as source:
            archive.write_bytes(source.read())
        if hashlib.sha256(archive.read_bytes()).hexdigest() != expected:
            raise SystemExit(f'{name} checksum mismatch')
        unpacked = pathlib.Path(tmp) / 'unpacked'
        shutil.unpack_archive(archive, unpacked, archive_format)
        candidates = [p for p in unpacked.rglob(name) if p.is_file()]
        if len(candidates) != 1:
            raise SystemExit(f'Expected one {name} executable')
        destination = pathlib.Path('.agent/tools') / name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(candidates[0], destination)
        destination.chmod(0o755)
        print(f'Installed verified {name}')
