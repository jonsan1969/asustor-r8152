# Project state

Updated: 2026-10-06

## Target

ASUSTOR AS-608T running the final ADM 3.5.x generation.

```text
Linux AS-608T-534E 3.12.20 #1 SMP Mon Aug 22 00:26:25 CST 2022 x86_64 GNU/Linux

Linux version 3.12.20
(root@asustor-sw1-daily-build-35)
(gcc version 4.6.4
 (crosstool-NG crosstool-ng-1.22.0 - x86_64 64-bit toolchain - ASUSTOR Inc.))
```

## What was probed on the NAS

The stock system currently has no usable Realtek USB Ethernet driver:

- no `r8152.ko` found under `/lib/modules`
- no matching driver found under `/lib`, `/usr/lib`, or `/usr/builtin`
- no `r8152`, `rtl8152`, `rtl8153`, or `rtl8156` symbols in `/proc/kallsyms`
- no r8152 driver registered in `/sys/bus/usb/drivers`
- no r8152-related aliases found in the module alias data

ASUSTOR's `modinfo` is minimal and the shipped modules are heavily stripped. `igb.ko` and `ixgbe.ko` expose no useful modinfo/vermagic strings through the tools present on the NAS.

No `__crc_*` or `__crc_module_layout` entries were visible in `/proc/kallsyms`, and no `__versions` section was found in the sampled vendor modules. The working assumption is therefore `CONFIG_MODVERSIONS=n`, but the real proof will be a successful external-module load.

## Chosen driver baseline

Start with Realtek r8152 v2.13.0 from bb-qq/r8152 tag `2.13.0-1`.

Why this version:

1. It already contains 2.5GbE support.
2. It matches `0bda:8156`.
3. Its compatibility layer explicitly supports old kernels, including the 3.12 era.
4. ASUSTOR shipped r8152 v2.13.0 on newer ADM 3.x systems, so it is a historically plausible baseline rather than a modern-driver backport.

## Current status

- [x] Confirm target kernel and compiler identity
- [x] Confirm stock AS-608T has no usable r8152 support
- [x] Select a conservative driver baseline
- [x] Vendor and lock the selected GPL driver source
- [ ] Prepare the ASUSTOR 3.12.20 kernel tree
- [ ] Build `r8152.ko`
- [ ] Check module vermagic/ELF architecture
- [ ] Test `insmod` with no USB NIC attached
- [ ] Buy/attach RTL8156BG adapter
- [ ] Verify USB ID and driver binding
- [ ] Verify 2500 Mb/s link
- [ ] iperf3 test
- [ ] SMB throughput test
- [ ] Persistent load/APKG packaging
