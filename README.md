# CSM213A Embedded Systems
UCLA Fall 2016 - Prof. Mani Srivastava

Yi-Fan Zhang

yifanz@ucla.edu

## Project Proposal 
### mbed for the PRU
The Sitara AM335x SoC on the Beaglebone Black development board features an on-chip programmable real-time unit (PRU) subsystem consisting of two 32-bit RISC cores.
Key features include a deterministic RISC instruction set with single cycle access to I/O pins, access to all resources on the SoC and an interrupt controller for capturing system-wide events.
Having a separate PRU subsystem allows for software emulation of peripheral hardware without taking time away from the main processor.
Moreover, the general purpose programmability of the PRUs affords more fexibility compared to custom ASICs without the increased board space, materials and development cost of adding an FPGA.

Despite these advantages, PRUs are often overlooked by application developers because of impediments they face during development. For instance, the PRUs are not enabled by default which requires developers to learn how to configure them through the Linux device tree subsystem before any further development can occur. Once configured, developers then need to learn the low level bits of the PRU and re-implement all the common functions typically provided by an RTOS. Furthermore, there isn't a unified, working and documented set of tutorial applications that utilizes all of the common features of the PRU (I/O, shared memory, interrupts).

It would be convenient to have a mbed style development environment along with useful library functions for the PRU. The aim of this project is to make PRU programming easier by adding automated configuration for device tree setup, creating a tool and library for the PRU that mimics that of mbed and providing tutorial applications of PRU usage. This will be a deep dive into the details of how common mbed functions are implemented and translating them to work on PRU hardware.

#### Project Objectives

1. Automate PRU and pinmux setup through shell scripts that will handle the Linux device tree configuration.
2. Implement a library of common functions with a similar interface as mbed for the PRU.
3. Create a browser based IDE hosted from the Beaglebone Black for developing on the PRU.
