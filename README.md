# CSM213A Embedded Systems
UCLA Fall 2016 - Prof. Mani Srivastava

Yi-Fan Zhang

yifanz@ucla.edu

#### Table of Contents

1. [Project Proposal](#project-proposal)
  * [Objectives](#project-objectives)
2. [Background](#background)
  * [PRUSS](#Programmable-Realtime-Unit-Subsystem)
  * [Device Tree](#device-tree)
3. [Design](#design)

## Project Proposal 
### Cyclops - PL + Compiler + IDE for making PRUs easier to use

![alt text](https://github.com/yifanz/CSM213A/raw/master/images/ide_screenshot.png "ide")

The Sitara AM335x SoC on the Beaglebone Black development board features an on-chip programmable real-time unit (PRU) subsystem consisting of two 32-bit RISC cores.
Key features include a deterministic RISC instruction set with single cycle access to I/O pins, access to all resources on the SoC and an interrupt controller for capturing system-wide events.
Having a separate PRU subsystem allows for software emulation of peripheral hardware without taking time away from the main processor.
Moreover, the general purpose programmability of the PRUs affords more fexibility compared to custom ASICs without the increased board space, materials and development cost of adding an FPGA.

Despite these advantages, PRUs are often overlooked by application developers because of impediments they face during development. For instance, the PRUs are not enabled by default which requires developers to learn how to configure them through the Linux device tree subsystem before any further development can occur. Once configured, developers then need to learn the low level bits of the PRU and implement boilerplate logic for loading program binaries and communication with the PRU. Furthermore, the only languages supported by TI are C/C++ and the PRU assembly language. In either case, all user interaction is performed on the commandline.

It would be convenient to have a [mbed](https://developer.mbed.org) style development environment along with a high level language for experimenting on the PRU. The aim of this project is to make PRU programming easier by adding automated configuration for device tree setup, creating a high level programming language for the PRU and provide an IDE which hides all the boilerplate and configuration. This will be a deep dive on language and compiler implementation for the PRU hardware as well as a bit of Linux kernel module development.

#### Project Objectives

1. Automate PRU and pinmux setup that will handle the Linux device tree configuration.
2. Implement a custom kernel driver for the pinmux to get around limitations of device tree overlays.
3. Design a language aimed at making PRU programming easier and implement the corresponding compiler.
4. Create a browser based IDE (similar to mbed) for prototyping on the PRU.

## Background

This project targets the Beaglebone Black Rev C running the default Debian Linux (3.8+ kernel) image. We will be dealing primarily with the on-chip Programmable Realtime Unit Subsystem (PRUSS) and the device tree subsystem on Linux.

### Programmable Realtime Unit Subsystem

The PRUSS functions as an on-chip peripheral that is capable of general purpose computation as well as fast digital I/O. Within the PRUSS, there are two 32-bit PRU cores. Each is clocked at 200 Mhz (5 ns per instruction) and has its own dedicated instruction and data RAM (8Kb each) in addition to 12 Kb of shared RAM between each core. The PRUs also hace full access to the main memory as well as other on-chip peripherals, but accessing them from the PRU requires sending data across the higher latency L3 network-on-chip interconnect. However, certain pins classified as fast digital I/O pins with single cycle access latency can be assigned directly to the PRUs through a pinmux configuration.

<p align="center">
  <img src="https://github.com/yifanz/CSM213A/raw/master/images/pru.png" alt="PRUSS" width="500">
</p>

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

The system can roughly be divided into the following components: a kernel module for pinmux configuration, a PRU loader for handling PRU communication, a high level programming language similar to javascript, a compiler for the PL and a browser based IDE that ties everything together. As shown in the diagram below, the components form a vertical slice of the system starting from the high level user-facing application all the way down to the kernel module for interacting with the hardware.

<p align="center">
  <img src="https://github.com/yifanz/CSM213A/raw/master/images/cyclops_diag.png" alt="PRUSS" width="600">
</p>

### Kernel Modules

There are two main on-chip peripherals Cyclops needs to manipulate: the pinmux controller and the PRUSS. The pinmux controller needs to be reconfigured during runtime in order to support dynamically remapping pins to and from the PRU. The PRUSS is obviously needed to execute programs on the PRU.

#### libpruss UIO driver

Libpruss is a UIO (userspace IO) driver shipped with the Linux distribution for controlling the PRUSS. In general, UIO is a Linux kernel subsystem for mapping hardware MMIO (memory mapped IO) address ranges directly into userspace. This way, most of the driver logic an live as a userspace library and only a minimal amount of code needs to run in the kernel.

#### pin-pirate LKM

### PRU Loader

### Programming Language

### Compiler

### IDE
