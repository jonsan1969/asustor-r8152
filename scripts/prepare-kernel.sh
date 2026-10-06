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

# Linux 3.12 predates GCC 10's switch to -fno-common.  Modern GitHub
# runners build the host-side x86 relocs helper with a current GCC, where
# the old source otherwise fails with duplicate per_cpu_load_addr symbols.
# Keep the target compiler untouched; this flag is only for host utilities.
HOSTCFLAGS_COMPAT='-O2 -Wall -Wmissing-prototypes -Wstrict-prototypes -fomit-frame-pointer -fcommon'

run_make() {
    if [ -n "${CC:-}" ]; then
        make -C "$KDIR" ARCH=x86 \
            CROSS_COMPILE="${CROSS_COMPILE:-}" \
            CC="$CC" \
            HOSTCFLAGS="$HOSTCFLAGS_COMPAT" \
            "$@"
    else
        make -C "$KDIR" ARCH=x86 \
            CROSS_COMPILE="${CROSS_COMPILE:-}" \
            HOSTCFLAGS="$HOSTCFLAGS_COMPAT" \
            "$@"
    fi
}

echo "Preparing kernel tree: $KDIR"
yes "" | run_make oldconfig
run_make prepare
run_make modules_prepare

echo "Kernel tree prepared."
