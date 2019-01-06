
# make-alarmpi-image

Documentation coming.


You will need:

https://github.com/cromarty/rpi-image-tool.git

## Note about aarch64

It is important to note that the `userland` code is absent from the
aarch64 images.

This is because the `userland` code is not currently available for the
64-bit kernel.

Therefore any aarch64 images created should be regarded as *server*
images, since there will be no sound and no video rendering available
on those images.

This will be the case until somebody takes it upon themselves to write
64-bit versions of the `userland` code. And I think I am right in
saying this is not all Open Source.




