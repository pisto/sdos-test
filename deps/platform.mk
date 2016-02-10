DEPSDIR:= $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
PREFIX:= $(shell $(DEPSDIR)/config.guess)
ifeq (,$(DEPSNAME))
BITS:= $(subst x86_64,64,$(findstring x86_64,$(PREFIX)))
ifeq (,$(BITS))
BITS:=32
endif
ifneq (,$(findstring linux,$(PREFIX)))
OS:=linux
else ifneq (,$(findstring mingw,$(PREFIX)))
OS:=mingw
else ifneq (,$(findstring apple,$(PREFIX)))
OS:=apple
else
$(error Unknown architecture $(PREFIX))
endif
DEPSNAME:=$(OS)$(BITS)
endif
ARCHFLAGS:= -I$(DEPSDIR)/$(DEPSNAME)/include
OPTFLAGS:= -O3 -fomit-frame-pointer -fvisibility=hidden

ifneq (, $(findstring mingw,$(PREFIX)))
WINDOWS:= 1
CXX:= $(PREFIX)-g++
CC:= $(PREFIX)-gcc
WINDRES:= $(PREFIX)-windres
ARCHFLAGS+= -pthread -I$(DEPSDIR)/extra/xaudio2

else ifneq (, $(findstring linux,$(PREFIX)))
LINUX:= 1
ARCHFLAGS+= -pthread

else ifneq (, $(findstring darwin,$(PREFIX)))
CXX:= $(shell which $(PREFIX)-clang++ 2>/dev/null || echo clang++)
CC:= $(shell which $(PREFIX)-clang 2>/dev/null || echo clang)
ARCHFLAGS+= -mmacosx-version-min=10.6
MAC:= 1

else
$(error Unknown architecture $(PREFIX))
endif

STRIP:= $(shell which $(PREFIX)-strip 2>/dev/null || echo strip)

ifneq (, $(findstring x86_64,$(PREFIX)))
ARCHFLAGS+= -m64 
else
ARCHFLAGS+= -m32 
endif


export CC
export CXX
override CPPFLAGS+= $(ARCHFLAGS) $(OPTFLAGS)
export CPPFLAGS
override CFLAGS+= $(ARCHFLAGS) $(OPTFLAGS)
export CFLAGS
override LDFLAGS+= $(ARCHFLAGS) $(OPTFLAGS) -L$(DEPSDIR)/$(DEPSNAME)/lib
export LDFLAGS
override CXXFLAGS+= $(ARCHFLAGS) $(OPTFLAGS) -fvisibility-inlines-hidden
export CXXFLAGS
export PKG_CONFIG_LIBDIR:= $(DEPSDIR)/$(DEPSNAME)/lib/pkgconfig
export PKG_CONFIG_PATH:= $(PKG_CONFIG_LIBDIR)
override PATH:= $(DEPSDIR)/$(DEPSNAME)/bin:$(PATH)
export PATH

