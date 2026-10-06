#!/bin/sh
set -eu

MODULE=${1:-./r8152.ko}

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root (or with sudo)." >&2
    exit 1
fi

[ -f "$MODULE" ] || {
    echo "Module not found: $MODULE" >&2
    exit 1
}

if lsmod 2>/dev/null | grep -q '^r8152 '; then
    echo "r8152 is already loaded; refusing to continue." >&2
    exit 1
fi

echo "Loading $MODULE"
if ! insmod "$MODULE"; then
    rc=$?
    echo "insmod failed (rc=$rc). Recent dmesg:" >&2
    dmesg | tail -n 80 >&2
    exit "$rc"
fi

echo
echo "Loaded:"
lsmod | grep '^r8152 ' || true

echo
echo "Recent dmesg:"
dmesg | tail -n 80

echo
echo "Unloading r8152"
rmmod r8152

echo "Module loaded and unloaded cleanly."
