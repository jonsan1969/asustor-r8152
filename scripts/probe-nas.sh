#!/bin/sh
set -u

echo "=== SYSTEM ==="
uname -a
cat /proc/version 2>/dev/null || true

echo
echo "=== R8152 FILES ==="
find /lib /usr/lib /usr/builtin -type f 2>/dev/null | grep -Ei 'r8152|rtl8152|8156|usbnet' || true

echo
echo "=== USB DRIVERS ==="
ls -1 /sys/bus/usb/drivers 2>/dev/null | grep -Ei 'r8152|rtl|asix|cdc|usbnet' || true

echo
echo "=== KERNEL SYMBOLS ==="
grep -iE 'r8152|rtl8152|rtl8153|rtl8156' /proc/kallsyms 2>/dev/null | head -n 100 || true

echo
echo "=== MODVERSION SIGNALS ==="
grep '__crc_' /proc/kallsyms 2>/dev/null | head -n 20 || true
grep '__crc_module_layout' /proc/kallsyms 2>/dev/null || true

echo
echo "=== LOADED MODULES ==="
lsmod 2>/dev/null | grep -Ei 'r8152|usbnet|cdc_ether|asix|ax88179' || true
