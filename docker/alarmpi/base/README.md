
# Raspberry Pi Arch Docker Container

This needs to be run on a Raspberry Pi 
running Arch Linux.

It will auto-detect the architecture of 
the OS which is running:

1. armv* = 32-bit
2. aarch64 = 64-bit


Note that MongoDB does not support 
32-bit after a certain version, and the 
`wired tiger` DB format is not supported 
on 32-bit.

Note also that currently there is no 
sound on 64-bit Raspberry Pi OSes. This 
is because there is no 64-bit `userland` 
code.



