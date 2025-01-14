#
# x86_win32_vc16.mk - make variables and rules specific to
#                     Visual Studio 16 / 2019
#

WindowsNT = 1
x86Processor = 1

compiler_version_suffix=_vc16

WINVER = 0x0501

BINDIR = bin/x86_win32
LIBDIR = lib/x86_win32

ABSTOP = $(shell cd $(TOP); pwd)

#
# Python set-up
#
# You must set a path to a Python interpreter, ideally version 3.5 or
# later, but obsolete version 2.7 is still supported.

#PYTHON = /cygdrive/c/Python310/python
#PYTHON = /cygdrive/c/Python27/python


# Use the following set of flags to build and use multithreaded DLLs
#
MSVC_DLL_CXXNODEBUGFLAGS       = -FS -MD -EHs -GS -GR -Zi -nologo
MSVC_DLL_CXXLINKNODEBUGOPTIONS = -nologo -manifest -DEBUG
MSVC_DLL_CNODEBUGFLAGS         = -FS -MD -GS -GR -Zi -nologo
MSVC_DLL_CLINKNODEBUGOPTIONS   = -nologo -manifest -DEBUG
#
MSVC_DLL_CXXDEBUGFLAGS         = -FS -MDd -EHs -RTC1 -GS -GR -Zi -nologo
MSVC_DLL_CXXLINKDEBUGOPTIONS   = -nologo -manifest -DEBUG
MSVC_DLL_CDEBUGFLAGS           = -FS -MDd -RTC1 -GS -GR -Zd -Zi -nologo
MSVC_DLL_CLINKDEBUGOPTIONS     = -nologo -manifest -DEBUG
#
# Or
#
# Use the following set of flags to build and use multithread static libraries
#
MSVC_STATICLIB_CXXNODEBUGFLAGS       = -FS -MT -EHs -GS -GR -Zi -nologo
MSVC_STATICLIB_CXXLINKNODEBUGOPTIONS = -nologo -manifest -DEBUG
MSVC_STATICLIB_CNODEBUGFLAGS         = -FS -MT -GS -GR -Zi -nologo
MSVC_STATICLIB_CLINKNODEBUGOPTIONS   = -nologo -manifest -DEBUG

MSVC_STATICLIB_CXXDEBUGFLAGS         = -FS -MTd -EHs -RTC1 -GS -GR -Zi -nologo
MSVC_STATICLIB_CXXLINKDEBUGOPTIONS   = -nologo -manifest -DEBUG
MSVC_STATICLIB_CDEBUGFLAGS           = -FS -MTd -RTC1 -GS -GR -Zi -nologo
MSVC_STATICLIB_CLINKDEBUGOPTIONS     = -nologo -manifest -DEBUG


#
# Include general win32 things
#

include $(THIS_IMPORT_TREE)/mk/win32.mk

MANIFESTTOOL = mt.exe

IMPORT_CPPFLAGS += -D__x86__ -D__NT__ -D__OSVERSION__=4 \
                   -D_CRT_SECURE_NO_DEPRECATE=1


# Default directory for the omniNames log files.
OMNINAMES_LOG_DEFAULT_LOCATION = C:\\temp


# Add the location of the Open SSL library

# To build the SSL transport, OPEN_SSL_ROOT must be defined and point to
# the top level directory of the openssl library. The default is to disable
# the build.
#
#OPEN_SSL_ROOT = /cygdrive/c/openssl
#

OPEN_SSL_CPPFLAGS = -I$(OPEN_SSL_ROOT)/include

OPEN_SSL_LIB = $(patsubst %,$(LibPathPattern),$(OPEN_SSL_ROOT)/lib) \
               libssl.lib libcrypto.lib

# Previous OpenSSL versions used these library names:

#OPEN_SSL_LIB = $(patsubst %,$(LibPathPattern),$(OPEN_SSL_ROOT)/lib) \
#               ssleay32.lib libeay32.lib

OMNIORB_SSL_LIB += $(OPEN_SSL_LIB)
OMNIORB_SSL_CPPFLAGS += $(OPEN_SSL_CPPFLAGS)


# To build ZIOP support, EnableZIOP must be defined and one or both of
# the zlib and zstd sections must be defined.

#EnableZIOP = 1

#EnableZIOPZLib = 1
#ZLIB_ROOT = /cygdrive/c/zlib-1.2.11
#ZLIB_CPPFLAGS = -DOMNI_ENABLE_ZIOP_ZLIB -I$(ZLIB_ROOT)
#ZLIB_LIB = $(patsubst %,$(LibPathPattern),$(ZLIB_ROOT)) zdll.lib

#EnableZIOPZStd = 1
#ZSTD_ROOT = /cygdrive/c/zstd
#ZSTD_CPPFLAGS = -DOMNI_ENABLE_ZIOP_ZSTD -I$(ZSTD_ROOT)/include
#ZSTD_LIB = $(patsubst %,$(LibPathPattern),$(ZSTD_ROOT)/lib) zstd.lib
