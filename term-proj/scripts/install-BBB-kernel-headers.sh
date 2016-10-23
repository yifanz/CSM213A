#
# Run this on the BBB to install kernel headers for kernel module development
#

# update the package manager
sudo apt-get update

# uname -r lists the exact kernel build version
sudo apt-cache search linux-headers-$(uname -r)

# I happen to be using 3.8.13-bone79, you should replace with your version
sudo apt-get install linux-headers-3.8.13-bone79

# If successful you will find the headers in /usr/src/linux-headers-3.8.13-bone79
