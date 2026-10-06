#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
KDIR=${KERNEL_DIR:-"$ROOT/work/kernel-3.12.20"}
VENDOR="$ROOT/src/r8152-2.13.0"
BUILD="$ROOT/work/r8152-build"
PATCHDIR="$ROOT/patches"
DIST="$ROOT/dist"

[ -d "$KDIR" ] || {
    echo "Kernel tree not found: $KDIR" >&2
    echo "Run scripts/fetch-asustor-kernel.sh and scripts/prepare-kernel.sh first." >&2
    exit 1
}

[ -s "$KDIR/Module.symvers" ] || {
    echo "Kernel Module.symvers is missing." >&2
    echo "CONFIG_MODVERSIONS=y on the ASUSTOR config, so a full kernel build is required." >&2
    echo "Run scripts/build-kernel-symvers.sh first." >&2
    exit 1
}

rm -rf "$BUILD"
mkdir -p "$BUILD" "$DIST"
cp -a "$VENDOR"/. "$BUILD"/

for p in "$PATCHDIR"/*.patch; do
    [ -f "$p" ] || continue
    echo "Applying $(basename "$p")"
    patch -d "$BUILD" -p1 < "$p"
done

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
echo "Vendor driver: $VENDOR"
echo "Patched build tree: $BUILD"

make -C "$BUILD" clean >/dev/null 2>&1 || true
make -C "$BUILD" KSRC="$KDIR" PWD="$BUILD" $MAKE_ARGS

cp "$BUILD/r8152.ko" "$DIST/r8152.ko"

echo
echo "Built: $DIST/r8152.ko"
if command -v file >/dev/null 2>&1; then
    file "$DIST/r8152.ko"
fi
if command -v readelf >/dev/null 2>&1; then
    readelf -h "$DIST/r8152.ko" | grep -E 'Class:|Machine:' || true
    readelf -S "$DIST/r8152.ko" | grep -E '__versions|modinfo|symtab|strtab' || true
fi
if command -v strings >/dev/null 2>&1; then
    strings "$DIST/r8152.ko" | grep -E 'vermagic=|v2\.13\.0' || true
fi
