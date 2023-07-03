#================================================================
# ELSES version 0.04
# Copyright (C) ELSES. 2007-2014 all rights reserved
#================================================================

TOPDIR ?= .

# Common settings
MOD_OPT=-I
#XML_SELFTEST = './elses-xml-selftest'
# For cross compiler systems,
XML_SELFTEST = echo './elses-xml-selftest'
%.o:%.mod

XML-DIR = xmlf90-1.2g-elses

BINDIR=$(TOPDIR)/bin
SRCDIR=$(TOPDIR)/src

FFLAGS-NRL =$(MOD_OPT)$(TOPDIR)/src/Nrl
FFLAGS-XML =\
 $(MOD_OPT)$(TOPDIR)/$(XML-DIR)/strings\
 $(MOD_OPT)$(TOPDIR)/$(XML-DIR)/sax\
 $(MOD_OPT)$(TOPDIR)/$(XML-DIR)/dom\
 $(MOD_OPT)$(SRCDIR)
LIBS-XML = -L$(TOPDIR)/$(XML-DIR)/macros/lib -lflib
OBJS-XML = $(SRCDIR)/elses-xml-config.o $(SRCDIR)/elses-config.o\
 $(SRCDIR)/elses-xml-misc.o $(SRCDIR)/elses-xml-sax-counter.o\
 $(SRCDIR)/elses-xml-sax-handler.o $(SRCDIR)/elses-xml-sax-parser.o

# For gfortran
FC = gfortran
FFLAGS = -O3 -fopenmp -I${MKLROOT}/include/intel64/ilp64 -fdefault-integer-8  -m64  -I"${MKLROOT}/include"
LDFLAGS = $(FFLAGS)  ${MKLROOT}/lib/intel64/libmkl_blas95_ilp64.a ${MKLROOT}/lib/intel64/libmkl_lapack95_ilp64.a -L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_gf_ilp64 -lmkl_gnu_thread -lmkl_core -lgomp -lpthread -lm -ldl
LIBS = -llapack -lblas -lgomp
