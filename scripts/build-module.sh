#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
KDIR=${KERNEL_DIR:-"$ROOT/work/kernel-3.12.20"}
DRIVER="$ROOT/src/r8152-2.13.0"
DIST="$ROOT/dist"

[ -d "$KDIR" ] || {
    echo "Kernel tree not found: $KDIR" >&2
    echo "Run scripts/fetch-asustor-kernel.sh and scripts/prepare-kernel.sh first." >&2
    exit 1
}

mkdir -p "$DIST"

# Linux uses ARCH=x86 for both i386 and x86_64 builds.
MAKE_ARGS="ARCH=x86"
if [ -n "${CROSS_COMPILE:-}" ]; then
    MAKE_ARGS="$MAKE_ARGS CROSS_COMPILE=$CROSS_COMPILE"
    COMPILER="${CROSS_COMPILE}gcc"
elif [ -n "${CC:-}" ]; then
    MAKE_ARGS="$MAKE_ARGS CC=$CC"
    COMPILER="$CC"
else
    COMPILER=gcc
fi

echo "Compiler:"
"$COMPILER" --version | head -n 1 || true
echo
echo "Kernel tree: $KDIR"
echo "Driver tree: $DRIVER"

make -C "$DRIVER" clean >/dev/null 2>&1 || true
make -C "$DRIVER" KSRC="$KDIR" PWD="$DRIVER" $MAKE_ARGS

cp "$DRIVER/r8152.ko" "$DIST/r8152.ko"

echo
echo "Built: $DIST/r8152.ko"
if command -v file >/dev/null 2>&1; then
    file "$DIST/r8152.ko"
fi
if command -v readelf >/dev/null 2>&1; then
    readelf -h "$DIST/r8152.ko" | grep -E 'Class:|Machine:' || true
fi
if command -v strings >/dev/null 2>&1; then
    strings "$DIST/r8152.ko" | grep -E 'vermagic=|v2\.13\.0' || true
fi
