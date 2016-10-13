# CSM213A Embedded Systems
UCLA Fall 2016 - Prof. Mani Srivastava

Yi-Fan Zhang

yifanz@ucla.edu

## Project Proposal 
### Enhance debugging support for PRU programming on the Beaglebone Black
The Sitara AM335x SoC on the Beaglebone Black development board features an on-chip programmable real-time unit (PRU) subsystem consisting of two 32-bit RISC cores.
Key features include a deterministic RISC instruction set with single cycle access to I/O pins, access to all resources on the SoC and an interrupt controller for capturing system-wide events.
Having a separate PRU subsystem allows for software emulation of peripheral hardware without taking time away from the main processor.
Moreover, the general purpose programmability of the PRUs affords more fexibility compared to custom ASICs without the increased board space, materials and development cost of adding an FPGA.

Despite these advantages, PRUs are often overlooked by application developers because of impediments they face during development. The PRUs are not enabled by default which requires developers to learn how to configure them through the Linux device tree subsystem before any further development can occur. There isn't a unified, working and documented example application that utilizes all of the common features of the PRU (I/O, shared memory, interrupts). The aim of this project is to make PRU programming easier by adding automated configuration for setup and providing a working example of PRU usage.

#### Project Objectives

1. Automate PRU and pinmux setup through a shell script that will handle the Linux device tree configuration.
3. Write an example application to demonstrate how to access gpio, shared memory and the interrupt controller from the PRU. I plan to soft emulate the SWD serial protocol using the PRU.
