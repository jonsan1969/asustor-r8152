#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
KDIR=${KERNEL_DIR:-"$ROOT/work/kernel-3.12.20"}
JOBS=${JOBS:-}

[ -d "$KDIR" ] || {
    echo "Kernel tree not found: $KDIR" >&2
    echo "Run scripts/fetch-asustor-kernel.sh and scripts/prepare-kernel.sh first." >&2
    exit 1
}

if [ -z "$JOBS" ]; then
    if command -v nproc >/dev/null 2>&1; then
        JOBS=$(nproc)
    else
        JOBS=2
    fi
fi

HOSTCFLAGS_COMPAT='-O2 -Wall -Wmissing-prototypes -Wstrict-prototypes -fomit-frame-pointer -fcommon'

echo "Building full ASUSTOR kernel tree to generate Module.symvers"
echo "Kernel tree: $KDIR"
echo "Jobs: $JOBS"

if [ -n "${CC:-}" ]; then
    make -C "$KDIR" -j"$JOBS" ARCH=x86 \
        CROSS_COMPILE="${CROSS_COMPILE:-}" \
        CC="$CC" \
        HOSTCFLAGS="$HOSTCFLAGS_COMPAT"
else
    make -C "$KDIR" -j"$JOBS" ARCH=x86 \
        CROSS_COMPILE="${CROSS_COMPILE:-}" \
        HOSTCFLAGS="$HOSTCFLAGS_COMPAT"
fi

[ -s "$KDIR/Module.symvers" ] || {
    echo "Full build completed but Module.symvers is still missing/empty." >&2
    exit 1
}

echo
echo "Module.symvers generated:"
wc -l "$KDIR/Module.symvers"
echo "Sample exported symbols:"
head -n 10 "$KDIR/Module.symvers"
