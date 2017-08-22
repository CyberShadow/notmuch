#!/bin/bash
set -xeuo pipefail
shopt -s lastpipe

# Test script for the AppVeyor CI service.
# Ran from ../appveyor.yml.
# Runs under CygWin bash.

# Part 1 - setup
function setup() {
	# Install apt-cyg, a command-line Cygwin package installer
	if ! command -v foo >/dev/null 2>&1 
	then
		test -f apt-cyg || wget -O apt-cyg https://raw.githubusercontent.com/kou1okada/apt-cyg/2e97789e53af1aa0eec83d2f2be470892d60e907/apt-cyg
		install apt-cyg /usr/local/bin/
	fi
	
	# Install necessary packages
	apt-cyg --no-verify install gnupg
	apt-cyg install gcc-core gcc-g++ make python2 libxapian-devel libgmime2.6-devel libiconv-devel
}

# Part 3 - build
function build() {
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

	echo '#define asprintf(pp, ...) talloc_asprintf(NULL, __VA_ARGS__)' >> lib/notmuch-private.h

	make notmuch
}

# Reset environment
env --null | while read -r -d $'\0' v
do
	name=${v/=*}
	unset "$name" || true # Ignore variable names that are invalid bash identifiers
done

# Reset PATH variable inherited from Windows environment
export PATH=/usr/local/bin:/usr/bin:/bin

"$@"
