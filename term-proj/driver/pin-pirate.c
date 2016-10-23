/**
 * @file	pin-pirate.c 
 * @author	Yi-Fan Zhang
 * @date	22 OCT 2016
 * @version 0.1
 * @brief Kernel module that allows users to force pinmux configurations from user-space.
 * @see Based on example code from Derek Molloy http://www.derekmolloy.ie/.
*/

#include <linux/init.h>             // Macros used to mark up functions e.g., __init __exit
#include <linux/module.h>           // Core header for loading LKMs into the kernel
#include <linux/kernel.h>           // Contains types, macros, functions for the kernel
#include <linux/io.h>

MODULE_LICENSE("GPL");				///< The license type -- this affects runtime behavior
MODULE_AUTHOR("Yi-Fan Zhang");		///< The author -- visible when you use modinfo
MODULE_DESCRIPTION("Hijack pins");	///< The description -- see modinfo
MODULE_VERSION("0.1");				///< The version of the module

#define PINMUX_IO_BASE 0x44e10800
#define PINMUX_IO_SIZE 0x238

static void *pinmux_io_base;

/** @brief The LKM initialization function
 *  The static keyword restricts the visibility of the function to within this C file. The __init
 *  macro means that for a built-in driver (not a LKM) the function is only used at initialization
 *  time and that it can be discarded and its memory freed up after that point.
 *  @return returns 0 if successful
 */
static int __init pinpirate_init(void){
	printk(KERN_INFO "PINPIRATE: pin-pirate module init\n");
	pinmux_io_base = ioremap(PINMUX_IO_BASE, PINMUX_IO_SIZE);
	if (pinmux_io_base == NULL) {
		return -ENODEV;
	}
	writeb(0x06, pinmux_io_base + 0x34);
	return 0;
}

/** @brief The LKM cleanup function
 *  Similar to the initialization function, it is static. The __exit macro notifies that if this
 *  code is used for a built-in driver (not a LKM) that this function is not required.
 */
static void __exit pinpirate_exit(void){
	printk(KERN_INFO "PINPIRATE: pin-pirate module exit\n");
	iounmap(pinmux_io_base);
}

/** @brief A module must use the module_init() module_exit() macros from linux/init.h, which
 *  identify the initialization function at insertion time and the cleanup function (as
 *  listed above)
 */
module_init(pinpirate_init);
module_exit(pinpirate_exit);
