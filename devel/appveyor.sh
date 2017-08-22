#!/bin/bash
set -xeuo pipefail
shopt -s lastpipe

# Test script for the AppVeyor CI service.
# Ran from ../appveyor.yml.
# Runs under CygWin bash.

# Reset PATH variable inherited from Windows environment
export PATH=/usr/local/bin:/usr/bin:/bin

# Set correct working directory
cd "$(dirname "$0")"/..

# Download talloc
test -f talloc-2.1.10.tar.gz || wget https://www.samba.org/ftp/talloc/talloc-2.1.10.tar.gz
rm -rf talloc-2.1.10
tar zxvf talloc-2.1.10.tar.gz

# Build/install talloc
(
	cd talloc-2.1.10
	./configure --prefix=/usr --disable-python
	make || true # fails at linking - fix problem and resume build
	ln -s cygtalloc-2.dll bin/default/talloc.dll
	ln -s cygtalloc-2.dll bin/default/cygtalloc.dll
	make
	make install
)

./configure

# Windows PE loader doesn't understand Cygwin symlinks
cp -L /usr/lib/cygtalloc.dll cygtalloc-2.dll

make
make test

"$@"
