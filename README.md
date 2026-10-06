# asustor-r8152

Out-of-tree Realtek `r8152` USB Ethernet driver work for legacy ASUSTOR NAS models.

Initial target:

- ASUSTOR AS-608T / AS-6 series
- ADM 3.5.9
- Linux 3.12.20 x86_64
- RTL8156 / RTL8156B / RTL8156BG USB 2.5GbE adapters

## Why

The AS-608T has USB 3.0 but its final ADM build does not ship an `r8152.ko` module and does not expose an in-kernel r8152 driver. The goal is to add a loadable `r8152.ko` without replacing the kernel.

The first hardware target is a USB-A RTL8156BG adapter. The expected native Realtek USB ID is `0bda:8156`; this must still be verified on the purchased adapter.

## Confirmed target system

```text
Linux AS-608T-534E 3.12.20 #1 SMP Mon Aug 22 00:26:25 CST 2022 x86_64 GNU/Linux

Linux version 3.12.20
(root@asustor-sw1-daily-build-35)
(gcc version 4.6.4
 (crosstool-NG crosstool-ng-1.22.0 - x86_64 64-bit toolchain - ASUSTOR Inc.))
```

Observed on the target NAS:

- no `r8152.ko` under `/lib/modules`, `/usr/lib`, or `/usr/builtin`
- no r8152/rtl815x symbols in `/proc/kallsyms`
- no r8152 driver registered under `/sys/bus/usb/drivers`
- no `__crc_*` symbols observed in `/proc/kallsyms`
- vendor modules appear heavily stripped; `modinfo` exposes only the filename

The published ASUSTOR x86_64 kernel config confirms `CONFIG_MODVERSIONS=y`. The absence of visible `__crc_*` symbols on the running NAS was therefore not sufficient to infer otherwise. A full build of the ASUSTOR 3.12.20 tree is required to generate `Module.symvers` before building the external module; the final proof remains a successful `insmod` on the target NAS.

## Driver baseline

The initial baseline is Realtek `r8152` **v2.13.0 (2020/04/20)**, taken from the GPL-2.0 source used by the bb-qq/r8152 project at tag `2.13.0-1`.

That source:

- contains explicit support for 2.5GbE
- contains the Realtek `0bda:8156` USB ID
- contains compatibility code for kernels older than 3.12
- matches the driver version reported by ASUSTOR on newer ADM 3.x systems

Upstream reference:
https://github.com/bb-qq/r8152/tree/2.13.0-1

## ASUSTOR kernel source

ASUSTOR publishes Linux 3.12.20 GPL source and the matching x86_64 config here:

https://sourceforge.net/projects/asgpl/files/ADM%202.3/GPL%20Source/GPL_2.5.2RCG2/

Files of interest:

- `GPL_linux-3.12.20_20150924.tar.bz2`
- `linux-3.12.20-x86_64.config`

ASUSTOR also publishes legacy x86_64 toolchains under:

https://sourceforge.net/projects/asgpl/files/ADM%202.0/Toolchain/

The exact compiler identity of the running kernel is recorded above. Reproducing it as closely as practical is preferred.

## Milestones

1. Reproduce the ASUSTOR 3.12.20 kernel build environment.
2. Build the full kernel tree to generate versioned symbol CRCs (`Module.symvers`).
3. Build patched `r8152.ko` from the v2.13.0 source.
4. Load the module on AS-608T with no USB NIC attached.
5. Confirm no `invalid module format` / `Unknown symbol` errors.
6. Attach RTL8156BG hardware and confirm `0bda:8156` binding.
7. Confirm a 2500 Mb/s link.
8. Test with `iperf3`.
9. Test SMB throughput against the 8-disk RAID6 array.
10. Make loading persistent and, if worthwhile, wrap it as an ASUSTOR APKG.

## Safety

Do not copy a test module into ADM's builtin module directory and do not make boot-time changes until manual `insmod` / `rmmod` testing succeeds.

This repository is experimental and currently targets one known AS-608T kernel build.

## License

The driver source is GPL-2.0. Project code and patches are distributed under GPL-2.0 as well.
