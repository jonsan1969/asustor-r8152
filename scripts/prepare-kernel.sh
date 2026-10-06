#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DL="$ROOT/work/downloads"
WORK="$ROOT/work"
KERNEL_ARCHIVE="$DL/GPL_linux-3.12.20_20150924.tar.bz2"
CONFIG="$DL/linux-3.12.20-x86_64.config"
KDIR="$WORK/kernel-3.12.20"

[ -f "$KERNEL_ARCHIVE" ] || {
    echo "Missing $KERNEL_ARCHIVE; run scripts/fetch-asustor-kernel.sh first" >&2
    exit 1
}
[ -f "$CONFIG" ] || {
    echo "Missing $CONFIG; run scripts/fetch-asustor-kernel.sh first" >&2
    exit 1
}

if [ ! -d "$KDIR" ]; then
    mkdir -p "$KDIR"
    tar -xjf "$KERNEL_ARCHIVE" -C "$KDIR" --strip-components=1
fi

cp "$CONFIG" "$KDIR/.config"

# Linux uses ARCH=x86 for both i386 and x86_64 builds.
MAKE_ARGS="ARCH=x86"
if [ -n "${CROSS_COMPILE:-}" ]; then
    MAKE_ARGS="$MAKE_ARGS CROSS_COMPILE=$CROSS_COMPILE"
fi
if [ -n "${CC:-}" ]; then
    MAKE_ARGS="$MAKE_ARGS CC=$CC"
fi

echo "Preparing kernel tree: $KDIR"
yes "" | make -C "$KDIR" $MAKE_ARGS oldconfig
make -C "$KDIR" $MAKE_ARGS prepare
make -C "$KDIR" $MAKE_ARGS modules_prepare

echo "Kernel tree prepared."
