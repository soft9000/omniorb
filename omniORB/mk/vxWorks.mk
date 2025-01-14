#
# Standard make variables and rules for all VxWorks platforms.
# You must specify the host you are building from
#
#HOST_PLATFORM_WIN32 = 1
#HOST_PLATFORM_SUN   = 1
#HOST_PLATFORM_LINUX = 1
#HOST_PLATFORM_HPUX  = 1

vxWorksPlatform = 1

# Set vxNames = 1 to use Michael Sturm's cut down vxNames (see
# /etc/vxworks.zip), otherwise use standard omniNames.
# vxNamesRequired = 1

# Define OrbCoreOnly if only want to build the runtime with no support 
# for dynamic interfaces, e.g. DII, DSI, Any, Typecode etc.
OrbCoreOnly = 1

# Defining EmbeddedSystem and CrossCompiling causes the build process
# to only build src/lib.
#
EmbeddedSystem = 1
CrossCompiling = 1

# No gatekeeper
NoGateKeeper = 1

ifeq ($(HOST_PLATFORM_WIN32),1)
HOSTBINDIR = bin/x86_win32
WTXTCL = wtxtcl
WRS_INCLUDE = $(WIND_BASE)/target/h
MUNCH_TCL_SCRIPT = $(subst \,\/, $(WIND_BASE)/host/src/hutils/munch.tcl)
else
ifeq ($(HOST_PLATFORM_LINUX),1)
HOSTBINDIR = bin/i586_linux_2.0_glibc
WTXTCL = tcl
WRS_INCLUDE = /eng/gnu/i386-wrs-vxworks/include
MUNCH_TCL_SCRIPT = /eng/gnu/i386-wrs-vxworks/tcl/munch.tcl
else
ifeq ($(HOST_PLATFORM_SUN),1)
HOSTBINDIR = bin/sun4_sosV_5.6
WTXTCL = wtxtcl
WRS_INCLUDE = $(WIND_BASE)/target/h
MUNCH_TCL_SCRIPT = $(subst \,\/, $(WIND_BASE)/host/src/hutils/munch.tcl)
else
ifeq ($(HOST_PLATFORM_HPUX),1)
SYSTEM_OBJECTS=$(WIND_BASE)/target/config/pcPentium
HOSTBINDIR = $(WIND_HOST_TYPE)/bin
WTXTCL = wtxtcl
WRS_INCLUDE = $(WIND_BASE)/target/h
MUNCH_TCL_SCRIPT = $(subst \,\/, $(WIND_BASE)/host/src/hutils/munch.tcl)
IMPORT_LIBRARY_DIRS=$(WIND_BASE)/target/lib
endif
endif
endif
endif

BINDIR = $(HOSTBINDIR)

#
# Any recursively-expanded variable set here can be overridden _afterwards_ by
# a platform-specific mk file which includes this one.
#

#
# Standard unix programs - note that GNU make already defines some of
# these such as AR, RM, etc (see section 10.3 of the GNU make manual).
#

CP		= cp
MV		= move
CPP		= cpp
MKDIRHIER	= mkdir -p
INSTALL		= /usr/sbin/install -f
OMKDEPEND	= $(BASE_OMNI_TREE)/$(BINDIR)/omkdepend
RMDIRHIER	= rm -rf

CXXMAKEDEPEND   = $(OMKDEPEND)
CMAKEDEPEND     = $(OMKDEPEND)

#
# General rules for cleaning.
#

define CleanRule
$(RM) *.o *.a *.class
endef

# XXX VeryCleanRule should delete Java stubs too.

define VeryCleanRule
$(RM) *.d
$(RM) *.pyc
$(RM) $(CORBA_STUB_FILES)
endef


#
# Patterns for various file types
#
LibPathPattern    = -L%
LibNoDebugPattern = lib%.a
LibDebugPattern = lib%.a
LibPattern = lib%.a
LibSuffixPattern = %.a
LibSearchPattern = -l%
BinPattern = %.out
TclScriptPattern = %


#
# Stuff to generate statically-linked libraries.
#

define StaticLinkLibrary
(set -x; \
 $(RM) $@; \
 $(AR) $@ $^; \
 $(RANLIB) $@; \
)
endef

ifdef EXPORT_TREE
define ExportLibrary
(dir="$(EXPORT_TREE)/$(LIBDIR)"; \
 files="$^"; \
 for file in $$files; do \
   $(ExportFileToDir); \
 done; \
)
endef
endif

#
# "Export" $$file to $$dir, creating $$dir if necessary.  Searches for
# $$file in $(VPATH) if not found in current directory.
#

define ExportFileToDir
$(CreateDir); \
$(FindFileInVpath); \
base=`basename $$file`; \
if [ -f $$dir/$$base ] && cmp $$fullfile $$dir/$$base >/dev/null; then \
  echo "File $$base hasn't changed."; \
else \
  (set -x; \
   $(INSTALL) $$dir $(INSTLIBFLAGS) $$fullfile ); \
fi
endef

#
# "Export" an executable file.  Same as previous one but adds execute
# permission.
#

define ExportExecutableFileToDir
$(CreateDir); \
$(FindFileInVpath); \
base=`basename $$file`; \
if [ -f $$dir/$$base ] && cmp $$fullfile $$dir/$$base >/dev/null; then \
  echo "File $$base hasn't changed."; \
else \
  (set -x; \
   $(INSTALL) $$dir $(INSTEXEFLAGS) $$fullfile ); \
fi
endef


#
# Stuff to generate executable binaries.
#
# These rules are used like this
#
# target: objs lib_depends
#         @(libs="libs"; $(...Executable))
#
# The command we want to generate is like this
#
# linker -o target ... objs libs
# i.e. we need to filter out the lib_depends from the command
#

IMPORT_LIBRARY_FLAGS = $(patsubst %,$(LibPathPattern),$(IMPORT_LIBRARY_DIRS))


define CExecutable
(set -x; \
 echo Building CExe; \
 $(RM) $@; \
 $(CLINK) -o $@ $(CLINKOPTIONS) $(IMPORT_LIBRARY_FLAGS) \
    $(filter-out $(LibSuffixPattern),$^) $$libs; \
)
endef

ifdef EXPORT_TREE
define ExportExecutable
(dir="$(EXPORT_TREE)/$(BINDIR)"; \
 files="$^"; \
 for file in $$files; do \
   $(ExportExecutableFileToDir); \
 done; \
)
endef
endif

# omnithread - platform libraries required by omnithread.
# Use when building omnithread.
OMNITHREAD_PLATFORM_LIB = $(filter-out $(patsubst %,$(LibSearchPattern),omnithread), $(OMNITHREAD_LIB))

#
# CORBA stuff
#

include $(BASE_OMNI_TREE)/mk/version.mk

lib_depend := $(patsubst %,$(LibPattern),omniORB$(OMNIORB_MAJOR_VERSION))
omniORB_lib_depend := $(GENERATE_LIB_DEPEND)
lib_depend := $(patsubst %,$(LibPattern),omniDynamic$(OMNIORB_MAJOR_VERSION))
omniDynamic_lib_depend := $(GENERATE_LIB_DEPEND)

OMNIORB_DLL_NAME = $(patsubst %,$(LibSearchPattern),omniORB$(OMNIORB_MAJOR_VERSION))
OMNIORB_DYNAMIC_DLL_NAME = $(patsubst %,$(LibSearchPattern),omniDynamic$(OMNIORB_MAJOR_VERSION))


OMNIORB_IDL_ONLY = $(BASE_OMNI_TREE)/$(BINDIR)/omniidl -bcxx -Wbh=.hh -Wbs=SK.cc # -h .hh -s SK.cc
ifndef OrbCoreOnly
OMNIORB_IDL_ANY_FLAGS = -Wba
endif
OMNIORB_IDL = $(OMNIORB_IDL_ONLY) $(OMNIORB_IDL_ANY_FLAGS)
OMNIORB_CPPFLAGS = -D__OMNIORB$(OMNIORB_MAJOR_VERSION)__ -I$(CORBA_STUB_DIR) $(OMNITHREAD_CPPFLAGS)
OMNIORB_IDL_OUTPUTDIR_PATTERN = -C%

ifdef OrbCoreOnly
OMNIORB_LIB = $(OMNIORB_DLL_NAME)
else
OMNIORB_LIB = $(OMNIORB_DLL_NAME) $(OMNIORB_DYNAMIC_DLL_NAME)
endif
OMNIORB_LIB_NODYN = $(OMNIORB_DLL_NAME)

OMNIORB_LIB_NODYN_DEPEND = $(omniORB_lib_depend)
ifdef OrbCoreOnly
OMNIORB_LIB_DEPEND = $(omniORB_lib_depend)
else
OMNIORB_LIB_DEPEND = $(omniORB_lib_depend) $(omniDynamic_lib_depend)
endif

OMNIORB_STATIC_STUB_OBJS = \
	$(CORBA_INTERFACES:%=$(CORBA_STUB_DIR)/%SK.o)
OMNIORB_STATIC_STUB_SRCS = \
	$(CORBA_INTERFACES:%=$(CORBA_STUB_DIR)/%SK.cc)
OMNIORB_DYN_STUB_OBJS = \
	$(CORBA_INTERFACES:%=$(CORBA_STUB_DIR)/%DynSK.o)
OMNIORB_DYN_STUB_SRCS = \
	$(CORBA_INTERFACES:%=$(CORBA_STUB_DIR)/%DynSK.cc)

OMNIORB_STUB_SRCS = $(OMNIORB_STATIC_STUB_SRCS) $(OMNIORB_DYN_STUB_SRCS)
OMNIORB_STUB_OBJS = $(OMNIORB_STATIC_STUB_OBJS) $(OMNIORB_DYN_STUB_OBJS)

OMNIORB_STUB_SRC_PATTERN = $(CORBA_STUB_DIR)/%SK.cc
OMNIORB_STUB_OBJ_PATTERN = $(CORBA_STUB_DIR)/%SK.o
OMNIORB_DYN_STUB_SRC_PATTERN = $(CORBA_STUB_DIR)/%DynSK.cc
OMNIORB_DYN_STUB_OBJ_PATTERN = $(CORBA_STUB_DIR)/%DynSK.o
OMNIORB_STUB_HDR_PATTERN = $(CORBA_STUB_DIR)/%.hh


# thread libraries required by omniORB. Make sure this is the last in
# the list of omniORB related libraries

OMNIORB_LIB += $(OMNITHREAD_LIB)
OMNIORB_LIB_NODYN += $(OMNITHREAD_LIB)
OMNIORB_LIB_DEPEND += $(OMNITHREAD_LIB_DEPEND)
OMNIORB_LIB_NODYN_DEPEND += $(OMNITHREAD_LIB_DEPEND)


# omniORB SSL transport
OMNIORB_SSL_VERSION = $(OMNIORB_VERSION)
OMNIORB_SSL_MAJOR_VERSION = $(word 1,$(subst ., ,$(OMNIORB_SSL_VERSION)))
OMNIORB_SSL_MINOR_VERSION = $(word 2,$(subst ., ,$(OMNIORB_SSL_VERSION)))
OMNIORB_SSL_LIB = $(patsubst %,$(LibSearchPattern),\
                    omnisslTP$(OMNIORB_SSL_MAJOR_VERSION))

lib_depend := $(patsubst %,$(LibPattern),omnisslTP$(OMNIORB_SSL_MAJOR_VERSION))
OMNIORB_SSL_LIB_DEPEND := $(GENERATE_LIB_DEPEND)

#
# Tcl stuff
#

define TclScriptExecutable
((set -x; $(RM) $@); \
 if [ "$$wish" = "" ]; then \
   wish="$(WISH4)"; \
 fi; \
 case "$$wish" in \
 /*) ;; \
 *) \
   if [ "$(EXPORT_TREE)" != "" ]; then \
     wish="$(EXPORT_TREE)/$(BINDIR)/$$wish"; \
   else \
     wish="./$$wish"; \
   fi ;; \
 esac; \
 echo echo "#!$$wish >$@"; \
 echo "#!$$wish" >$@; \
 echo echo "set auto_path [concat {$$tcllibpath} \$$auto_path] >>$@"; \
 echo "set auto_path [concat {$$tcllibpath} \$$auto_path]" >>$@; \
 echo "cat $< >>$@"; \
 cat $< >>$@; \
 set -x; \
 chmod a+x $@; \
)
endef


##########################################################################
#
# Shared library support stuff
#
# Default setup. Work for most platforms. For those exceptions, override
# the rules in their platform files.
#
SHAREDLIB_SUFFIX = so

SharedLibraryFullNameTemplate = lib$$1$$2.$(SHAREDLIB_SUFFIX).$$3.$$4
SharedLibrarySoNameTemplate = lib$$1$$2.$(SHAREDLIB_SUFFIX).$$3
SharedLibraryLibNameTemplate = lib$$1$$2.$(SHAREDLIB_SUFFIX)

SharedLibraryPlatformLinkFlagsTemplate = -shared -Wl,-soname,$$soname

define SharedLibraryFullName
fn() { \
if [ $$2 = "_" ] ; then set $$1 "" $$3 $$4 ; fi ; \
echo $(SharedLibraryFullNameTemplate); \
}; fn
endef

define ParseNameSpec
set $$namespec ; \
if [ $$2 = "_" ] ; then set $$1 "" $$3 $$4 ; fi
endef

# MakeCXXSharedLibrary- Build shared library
#  Expect shell variable:
#  namespec = <library name> <major ver. no.> <minor ver. no.> <micro ver. no>
#  extralibs = <libraries to add to the link line>
#
#  e.g. namespec="COS 3 0 0" --> shared library libCOS3.so.0.0
#       extralibs="$(OMNIORB_LIB)"
#
define MakeCXXSharedLibrary
 $(ParseNameSpec); \
 soname=$(SharedLibrarySoNameTemplate); \
 set -x; \
 $(RM) $@; \
 $(CXX) $(SharedLibraryPlatformLinkFlagsTemplate) -o $@ \
 $(IMPORT_LIBRARY_FLAGS) $(filter-out $(LibSuffixPattern),$^) $$extralibs;
endef

# ExportSharedLibrary- export sharedlibrary
#  Expect shell variable:
#  namespec = <library name> <major ver. no.> <minor ver. no.> <micro ver. no>
#  e.g. namespec = "COS 3 0 0" --> shared library libCOS3.so.0.0
#
define ExportSharedLibrary
 $(ExportLibrary); \
 $(ParseNameSpec); \
 soname=$(SharedLibrarySoNameTemplate); \
 libname=$(SharedLibraryLibNameTemplate); \
 set -x; \
 cd $(EXPORT_TREE)/$(LIBDIR); \
 $(RM) $$soname; \
 ln -s $(<F) $$soname; \
 $(RM) $$libname; \
 ln -s $$soname $$libname;
endef

define CleanSharedLibrary
( set -x; \
$(RM) $${dir:-.}/*.$(SHAREDLIB_SUFFIX).* )
endef


# Pattern rules to build  objects files for static and shared library.
# The convention is to build the static library in the subdirectoy "static" and
# the shared library in the subdirectory "shared".
# The pattern rules below ensured that the right compiler flags are used
# to compile the source for the library.

static/%.o: %.cc
	$(CXX) -c $(subst \,/,-I$(WRS_INCLUDE)) $(CXXFLAGS) -o $@ $<

shared/%.o: %.cc
	$(CXX) -c $(subst \,/,-I$(WRS_INCLUDE)) $(SHAREDLIB_CPPFLAGS) $(CXXFLAGS)  -o $@ $<

static/%.o: %.c
	$(CC) -c $(subst \,/,-I$(WRS_INCLUDE)) $(CFLAGS) -o $@ $<

SHAREDLIB_CFLAGS = $(SHAREDLIB_CPPFLAGS)

shared/%.o: %.c
	$(CC) -c $(subst \,/,-I$(WRS_INCLUDE)) $(SHAREDLIB_CFLAGS) $(CFLAGS)  -o $@ $<

#
# Replacements for implicit rules
#

%.o: %.c
	$(CC) -c $(subst \,/,-I$(WRS_INCLUDE)) $(CFLAGS) -o $@ $<

%.o: %.cc
	$(CXX) -c $(subst \,/,-I$(WRS_INCLUDE)) $(CXXFLAGS) -o $@ $<

#
# OMNI thread stuff
#

OMNITHREAD_POSIX_CPPFLAGS = -DNoNanoSleep
OMNITHREAD_LIB = $(patsubst %,$(LibSearchPattern),omnithread)
OMNITHREAD_CPPFLAGS = -D_REENTRANT

ThreadSystem = vxWorks

lib_depend := $(patsubst %,$(LibPattern),omnithread)
OMNITHREAD_LIB_DEPEND := $(GENERATE_LIB_DEPEND)


# Default location of the omniORB configuration file [falls back to this if
# the environment variable OMNIORB_CONFIG is not set] :

OMNIORB_CONFIG_DEFAULT_LOCATION = /a2/tmp/omniORB.cfg

