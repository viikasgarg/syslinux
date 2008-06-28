## -----------------------------------------------------------------------
##
##   Copyright 1998-2008 H. Peter Anvin - All Rights Reserved
##
##   This program is free software; you can redistribute it and/or modify
##   it under the terms of the GNU General Public License as published by
##   the Free Software Foundation, Inc., 53 Temple Place Ste 330,
##   Boston MA 02111-1307, USA; either version 2 of the License, or
##   (at your option) any later version; incorporated herein by reference.
##
## -----------------------------------------------------------------------

#
# Main Makefile for SYSLINUX
#
topdir = .
include $(topdir)/MCONFIG

VERSION := $(shell cat version)

#
# The BTARGET refers to objects that are derived from ldlinux.asm; we
# like to keep those uniform for debugging reasons; however, distributors
# want to recompile the installers (ITARGET).
#
# BOBJECTS and IOBJECTS are the same thing, except used for
# installation, so they include objects that may be in subdirectories
# with their own Makefiles.  Finally, there is a list of those
# directories.
#

# syslinux.exe is BTARGET so as to not require everyone to have the
# mingw suite installed
BTARGET  = version.gen version.h
BOBJECTS = $(BTARGET) \
	mbr/mbr.bin mbr/gptmbr.bin \
	core/pxelinux.0 core/isolinux.bin core/isolinux-debug.bin \
	gpxe/gpxelinux.0 dos/syslinux.com win32/syslinux.exe \
	memdisk/memdisk memdump/memdump.com
# BESUBDIRS and IESUBDIRS are "early", i.e. before the root; BSUBDIRS
# and ISUBDIRS are "late", after the root.
BESUBDIRS = 
BSUBDIRS = codepage core memdisk com32 mbr memdump gpxe sample dos win32
ITARGET  = 
IOBJECTS = $(ITARGET) dos/copybs.com utils/gethostip utils/mkdiskimage \
	mtools/syslinux linux/syslinux extlinux/extlinux
IESUBDIRS =
ISUBDIRS = mtools linux extlinux utils

# Things to install in /usr/bin
INSTALL_BIN   =	mtools/syslinux
# Things to install in /sbin
INSTALL_SBIN  = extlinux/extlinux
# Things to install in /usr/lib/syslinux
INSTALL_AUX   =	core/pxelinux.0 gpxe/gpxelinux.0 core/isolinux.bin \
		core/isolinux-debug.bin \
		dos/syslinux.com dos/copybs.com win32/syslinux.exe \
		memdisk/memdisk memdump/memdump.com \
		mbr/mbr.bin mbr/gptmbr.bin
INSTALL_AUX_OPT = win32/syslinux.exe

# These directories manage their own installables
INSTALLSUBDIRS = com32 utils

# Things to install in /boot/extlinux
EXTBOOTINSTALL = memdisk/memdisk memdump/memdump.com \
		 com32/menu/*.c32 com32/modules/*.c32

# Things to install in /tftpboot
NETINSTALLABLE = core/pxelinux.0 gpxe/gpxelinux.0 memdisk/memdisk \
		 memdump/memdump.com com32/menu/*.c32 com32/modules/*.c32

all:
	set -e ; for i in $(BESUBDIRS) $(IESUBDIRS) ; do $(MAKE) -C $$i $@ ; done
	$(MAKE) all-local
	set -e ; for i in $(BSUBDIRS) $(ISUBDIRS) ; do $(MAKE) -C $$i $@ ; done
	-ls -l $(BOBJECTS) $(IOBJECTS)

all-local: $(BTARGET) $(ITARGET)

installer:
	set -e ; for i in $(IESUBDIRS); do $(MAKE) -C $$i all ; done
	$(MAKE) installer-local
	set -e ; for i in $(ISUBDIRS); do $(MAKE) -C $$i all ; done
	-ls -l $(BOBJECTS) $(IOBJECTS)

installer-local: $(ITARGET) $(BINFILES)

version.gen: version version.pl
	$(PERL) version.pl $< $@ '%define'

version.h: version version.pl
	$(PERL) version.pl $< $@ '#define'

local-install: installer
	mkdir -m 755 -p $(INSTALLROOT)$(BINDIR)
	install -m 755 -c $(INSTALL_BIN) $(INSTALLROOT)$(BINDIR)
	mkdir -m 755 -p $(INSTALLROOT)$(SBINDIR)
	install -m 755 -c $(INSTALL_SBIN) $(INSTALLROOT)$(SBINDIR)
	mkdir -m 755 -p $(INSTALLROOT)$(AUXDIR)
	install -m 644 -c $(INSTALL_AUX) $(INSTALLROOT)$(AUXDIR)
	-install -m 644 -c $(INSTALL_AUX_OPT) $(INSTALLROOT)$(AUXDIR)
	mkdir -m 755 -p $(INSTALLROOT)$(MANDIR)/man1
	install -m 644 -c man/*.1 $(INSTALLROOT)$(MANDIR)/man1
	: mkdir -m 755 -p $(INSTALLROOT)$(MANDIR)/man8
	: install -m 644 -c man/*.8 $(INSTALLROOT)$(MANDIR)/man8

install: local-install
	set -e ; for i in $(INSTALLSUBDIRS) ; do $(MAKE) -C $$i $@ ; done

netinstall: installer
	mkdir -p $(INSTALLROOT)$(TFTPBOOT)
	install -m 644 $(NETINSTALLABLE) $(INSTALLROOT)$(TFTPBOOT)

extbootinstall: installer
	mkdir -m 755 -p $(INSTALLROOT)$(EXTLINUXDIR)
	install -m 644 $(EXTBOOTINSTALL) $(INSTALLROOT)$(EXTLINUXDIR)

install-all: install netinstall extbootinstall

local-tidy:
	rm -f *.o *.elf *_bin.c stupid.* patch.offset
	rm -f *.lsr *.lst *.map *.sec
	rm -f $(OBSOLETE)

tidy: local-tidy
	set -e ; for i in $(BESUBDIRS) $(IESUBDIRS) $(BSUBDIRS) $(ISUBDIRS) ; do $(MAKE) -C $$i $@ ; done

local-clean:
	rm -f $(ITARGET)

clean: local-tidy local-clean
	set -e ; for i in $(BESUBDIRS) $(IESUBDIRS) $(BSUBDIRS) $(ISUBDIRS) ; do $(MAKE) -C $$i $@ ; done

local-dist:
	find . \( -name '*~' -o -name '#*' -o -name core \
		-o -name '.*.d' -o -name .depend \) -type f -print0 \
	| xargs -0rt rm -f

dist: local-dist local-tidy
	set -e ; for i in $(BESUBDIRS) $(IESUBDIRS) $(BSUBDIRS) $(ISUBDIRS) ; do $(MAKE) -C $$i $@ ; done

local-spotless:
	rm -f $(BTARGET) .depend *.so.*

spotless: local-clean local-dist local-spotless
	set -e ; for i in $(BESUBDIRS) $(IESUBDIRS) $(BSUBDIRS) $(ISUBDIRS) ; do $(MAKE) -C $$i $@ ; done

local-depend:

depend: local-depend
	$(MAKE) -C memdisk depend

# Shortcut to build linux/syslinux using klibc
klibc:
	$(MAKE) clean
	$(MAKE) CC=klcc ITARGET= ISUBDIRS='linux extlinux' BSUBDIRS=

# Hook to add private Makefile targets for the maintainer.
-include Makefile.private
