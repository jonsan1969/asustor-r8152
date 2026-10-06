# Build notes

## 1. Fetch ASUSTOR kernel source

Run:

```sh
./scripts/fetch-asustor-kernel.sh
```

The script downloads the public ASUSTOR Linux 3.12.20 source archive and the x86_64 config into `work/downloads/`.

## 2. Extract and prepare the kernel tree

```sh
./scripts/prepare-kernel.sh
```

This creates `work/kernel-3.12.20/`, installs the ASUSTOR config as `.config`, and runs the kernel preparation targets needed for an external module.

## 3. Compiler

The target kernel reports:

```text
gcc 4.6.4
crosstool-NG 1.22.0
x86_64 64-bit toolchain - ASUSTOR Inc.
```

The build scripts accept either a native `CC=...` compiler or a cross prefix through `CROSS_COMPILE=...`.

Example:

```sh
CROSS_COMPILE=/path/to/bin/x86_64-asustor-linux-gnu- ./scripts/build-module.sh
```

Do not assume that ASUSTOR's oldest published toolchain is byte-for-byte identical to the 2022 compiler. Record the exact compiler used for every successful module build.

## 4. Build

```sh
./scripts/build-module.sh
```

Expected output:

```text
dist/r8152.ko
```

The script also prints the ELF identity and any visible vermagic string.

## 5. First NAS test

Copy only the module and test script to a temporary directory on the NAS. Do not install it into `/usr/builtin`.

```sh
sudo ./test-module-on-nas.sh ./r8152.ko
```

Success criteria:

- `insmod` returns 0
- `lsmod` shows `r8152`
- `dmesg` has no `invalid module format`
- `dmesg` has no `Unknown symbol`
- module can be removed cleanly with `rmmod r8152`

Only after that test passes should hardware be purchased/attached.
