#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT="$ROOT/work/downloads"
DEST="$ROOT/work/toolchain"
ARCHIVE="$OUT/x86_64-asustor-linux-gnu-64bit.tar.gz"
URL='https://downloads.sourceforge.net/project/asgpl/ADM%202.0/Toolchain/x86_64-asustor-linux-gnu-64bit.tar.gz'
SHA256='5f4f1e6baeda7ca07b7b14acc52e4db8e3a15086e11a0797f84910e8bedaa3d4'

mkdir -p "$OUT" "$DEST"

if [ ! -s "$ARCHIVE" ]; then
    if command -v curl >/dev/null 2>&1; then
        curl -fL --retry 3 --retry-delay 2 "$URL" -o "$ARCHIVE"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$ARCHIVE" "$URL"
    else
        echo "Need curl or wget" >&2
        exit 1
    fi
fi

if command -v sha256sum >/dev/null 2>&1; then
    echo "$SHA256  $ARCHIVE" | sha256sum -c -
fi

if [ ! -f "$DEST/.extracted" ]; then
    rm -rf "$DEST"
    mkdir -p "$DEST"
    tar -xzf "$ARCHIVE" -C "$DEST"
    : > "$DEST/.extracted"
fi

GCC=$(find "$DEST" -type f -name 'x86_64-asustor-linux-gnu-gcc' -perm -111 | head -n 1 || true)
if [ -z "$GCC" ]; then
    GCC=$(find "$DEST" -type f -name '*-gcc' -perm -111 | head -n 1 || true)
fi

if [ -z "$GCC" ]; then
    echo "No cross compiler found under $DEST" >&2
    find "$DEST" -maxdepth 4 -type f | head -n 100 >&2
    exit 1
fi

PREFIX=${GCC%gcc}

echo "Compiler: $GCC"
"$GCC" --version | head -n 1
echo "CROSS_COMPILE=$PREFIX"
