# CSM213A Embedded Systems
UCLA Fall 2016 - Prof. Mani Srivastava

Yi-Fan Zhang

yifanz@ucla.edu

#### Table of Contents

1. [Project Proposal](#project-proposal)
  * [Objectives](#project-objectives)
2. [Background](#background)
  * [Device Tree](#device-tree)
3. [Design](#design)

## Project Proposal 
### Cyclops - PL + Compiler + IDE for making PRUs easier to use
The Sitara AM335x SoC on the Beaglebone Black development board features an on-chip programmable real-time unit (PRU) subsystem consisting of two 32-bit RISC cores.
Key features include a deterministic RISC instruction set with single cycle access to I/O pins, access to all resources on the SoC and an interrupt controller for capturing system-wide events.
Having a separate PRU subsystem allows for software emulation of peripheral hardware without taking time away from the main processor.
Moreover, the general purpose programmability of the PRUs affords more fexibility compared to custom ASICs without the increased board space, materials and development cost of adding an FPGA.

Despite these advantages, PRUs are often overlooked by application developers because of impediments they face during development. For instance, the PRUs are not enabled by default which requires developers to learn how to configure them through the Linux device tree subsystem before any further development can occur. Once configured, developers then need to learn the low level bits of the PRU and re-implement all the common functions typically provided by an RTOS. Furthermore, there isn't a unified, working and documented set of tutorial applications that utilizes all of the common features of the PRU (I/O, shared memory, interrupts).

It would be convenient to have a [mbed](https://developer.mbed.org) style development environment along with useful library functions for the PRU. The aim of this project is to make PRU programming easier by adding automated configuration for device tree setup, creating a tool and library for the PRU that mimics that of mbed and providing tutorial applications of PRU usage. This will be a deep dive into the details of how common mbed functions are implemented and translating them to work on PRU hardware.

#### Project Objectives

1. Automate PRU and pinmux setup that will handle the Linux device tree configuration.
2. Implement a custom kernel driver for the pinmux to get around limitations of device tree overlays.
3. Design a language aimed at making PRU programming easier and implement the corresponding compiler.
4. Create a browser based IDE (similar to mbed) for prototyping on the PRU.

## Background

This project targets the Beaglebone Black Rev C running the default Debian Linux (3.8+ kernel) image. We will be dealing primarily with the on-chip Programmable Realtime Unit Subsystem (PRUSS) and the device tree subsystem on Linux.

### Device Tree

When a system boots up, the kernel needs to learn what memory address ranges correspond to peripheral hardware registers.
A naive approach would be to hardcode this information into the kernel sources, but this would require a separate build of the kernel for each hardware platform with a different configuration.
PC-style systems, solve this by providing onboard firmware (e.g. BIOS or UEFI) that will fill out in-memory system descriptor tables according to an industry standard format (ACPI).
Hotplugged hardware is handled by bus protocols like PCI which support self-discovery and runtime reconfiguration.

Unlike PCs, hardware in embedded systems is typically fixed for a specific use case with tight performance requirements and are often used in proprietary settings.
Running hotplug and self-discovery firmware may interfere with performance requirements or may simply be no worth the additional complexity.

For these cases, Linux adopted a solution called device tree, sometimes referred to as Open Firmware or flattened device tree (FDT).
In short, device tree is a standard binary data structure for describing non-discoverable hardware to the kernel.
There are no strict rules for what can be described in the device tree, but they typically contain parameters for hardware register addresses, interrupts and hardware specific metadata.
Linux parses the device tree and provides a querying API to device drivers.

Initially, the device tree can be written by users in a `dts` text format which can then be serialized into a `dtb` binary using the `dtc` userspace utility. The `dtb` can be copied into the boot partition and the bootloader can be configured to pass the `dtb` to the kernel in a parameter. This way, a kernel compiled for a particular architecture can be supported on different hardware platforms of the same architecture simply by specifying a different `dtb`.

## Design
