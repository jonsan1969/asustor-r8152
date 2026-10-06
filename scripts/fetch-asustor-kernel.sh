#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT="$ROOT/work/downloads"
mkdir -p "$OUT"

BASE='https://sourceforge.net/projects/asgpl/files/ADM%202.3/GPL%20Source/GPL_2.5.2RCG2'
KERNEL='GPL_linux-3.12.20_20150924.tar.bz2'
CONFIG='linux-3.12.20-x86_64.config'

fetch() {
    url=$1
    dst=$2
    if command -v curl >/dev/null 2>&1; then
        curl -fL --retry 3 --retry-delay 2 "$url" -o "$dst"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$dst" "$url"
    else
        echo "Need curl or wget" >&2
        exit 1
    fi
}

[ -s "$OUT/$KERNEL" ] || fetch "$BASE/$KERNEL/download" "$OUT/$KERNEL"
[ -s "$OUT/$CONFIG" ] || fetch "$BASE/$CONFIG/download" "$OUT/$CONFIG"

echo "Downloaded:"
ls -lh "$OUT/$KERNEL" "$OUT/$CONFIG"
