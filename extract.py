@'
import plistlib
with open("Manifest.plist", "rb") as f:
    plist = plistlib.load(f)
if "BackupKeyBag" in plist:
    import base64
    kb = plist["BackupKeyBag"]
    iter = int.from_bytes(kb[:4], "big") if type(kb) == bytes else 10000
    salt = kb[4:24].hex() if type(kb) == bytes else ""
    key = kb[24:56].hex() if type(kb) == bytes else ""
    print(f"$itunes_backup$*10*{iter}*{salt}*{key}")
else:
    print("BackupKeyBag not found. Are you sure this backup is encrypted?")
'@ | Out-File -FilePath "extract.py" -Encoding utf8; python extract.py > hash.txt