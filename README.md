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

Despite these advantages, PRUs are often overlooked by application developers because of impediments they face during development. First, the PRUs are not enabled by default which requires developers to learn how to configure them through the Linux device tree subsystem before any further development can occur. Second, the PRU driver on Linux does not provide the breakpoint and step-through debugging environment application developers are accustomed to. Lastly, there isn't a unified, working and documented example application that utilizes all of the common features of the PRU (I/O, shared memory, interrupts). The aim of this project is to remove these impediments by adding automated configuration, enhanced debugging and example code documentation.

#### Project Objectives

1. Automate PRU and pinmux setup through a shell script that will handle the Linux device tree configuration.
2. Enhance the prussdrv UIO driver to support single step and breakpoint debugging.
3. Write an example application to demonstrate how to access gpio, shared memory and the interrupt controller from the PRU.
