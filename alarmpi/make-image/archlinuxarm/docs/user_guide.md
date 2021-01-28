
# How to Generate Arch Linux Images for the Raspberry Pi Using These Tools

## Dependencies

You will need 'kpartx' for mounting the file-systems inside files.

The package for this on Arch Linux is 'multipath-tools' from the Arch
User Repository (AUR).

On Raspbian the packages is called 'kpartx'.

Then you wil need to clone and install my 'rpi-image-tool' tool:


```
git clone https://github.com/cromarty/rpi-image-tool.git
cd rpi-image-tool
make
make install
```

For the above to work you will need to have installed either the
'base-devel' package on Arch or the 'build-essential' package on
Debian/Ubuntu/Raspbian or other Debian derivatives.

You also need gettext and intltool installed for `rpi-image-tool`.

There are three scripts which will call the main script to create
three different flavours of Arch Linux image:

* armv6.sh
* armv7.sh
* aarch64.sh

You will probably want the middle one, unless you have an older Pi.

Having run any of the above, you should have an image called:

```
ArchLinuxARM-yyyymmdd.arch.img
```

Where yyy = the year in four digits, mm = the month in two digits, dd
= the day in two digits, and 'arch' will correspond to which
architecture you picked.

You can override the name of the image, see the documentation of the
main script by running:

```
make-arch-image -h
```


		
