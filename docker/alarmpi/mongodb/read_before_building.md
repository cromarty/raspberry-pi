
# Before Building the Docker Image

Remember this must be built on an 
`aarch64` Pi or by cross-compiling for 
such.

There are a couple of tools which are not available in the ArchARM
repo which we need for use in the MongoDB image:

* `gosu`
* `numactl`

## `gosu`

`gosu` is not available in the ARM repo.  So use su-exec instead:

https://github.com/ncopa/su-exec

Clone it to another directory, build the 
executable and put it in this directory.

Note if you clone it to a directory 
below here, unless you give it a 
different name you will not be able to 
copy the `su-exec` binary into this 
directory.

So I suggest `su_exec` instead of 
`su-exec`:

	git clone https://github.com/ncopa/su-exec su_exec
	cd su_exec
	make
	cp su-exec ..



It will get copied in to the root 
directory by the Dockerfile build.


## `numactl`

https://github.com/numactl/numactl

Just as with su-exec, if you are cloning 
into a directory below this one, you 
need to name it differently to the 
binary which will be built:

	
	git clone https://github.com/numactl/numactl numactl_
	cd numactl_
	./autogen.sh
	./configure
	./make
	cp numactl ..



