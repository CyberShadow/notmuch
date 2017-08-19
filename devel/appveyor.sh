#!/bin/bash
set -euo pipefail

# Test script for the AppVeyor CI service.
# Ran from ../appveyor.yml.
# Runs under CygWin bash.

curl https://raw.githubusercontent.com/kou1okada/apt-cyg/2e97789e53af1aa0eec83d2f2be470892d60e907/apt-cyg > apt-cyg
./apt-cyg install libxapian-devel libgmime2.6-devel

curl -O https://www.samba.org/ftp/talloc/talloc-2.1.10.tar.gz
rm -rf talloc-2.1.10
tar zxvf talloc-2.1.10.tar.gz

(
	cd talloc-2.1.10
	./configure --prefix=/usr
	make || true # fails at linking
	ln -s cygtalloc-2.dll bin/default/talloc.dll
	ln -s cygtalloc-2.dll bin/default/cygtalloc.dll
	make
	make install
)

./configure
make notmuch
