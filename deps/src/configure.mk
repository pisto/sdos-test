include ../platform.mk

ROOT= $(realpath ../$(DEPSNAME))
ifeq ($(strip $(ROOT)),)
$(error Missing directory for platform $(PREFIX))
endif

ifneq (,$(findstring Linux,$(shell uname)))
ifneq (,$(findstring apple,$(PREFIX)))
EXCLUDEX11= --disable-video-x11
endif
endif

default:
	$(error Select a library to build)

libenet:
	cd libenet; ./configure --host=$(PREFIX) --prefix="$(ROOT)" --enable-shared=no

libz:
	cd libz; CHOST="$(PREFIX)" ./configure --prefix="$(ROOT)" --static

libjpeg:
	cd libjpeg; ./configure --host=$(PREFIX) --prefix="$(ROOT)" --without-turbojpeg --without-arith-enc --enable-shared=no

libpng:
	cd libpng; ./configure --host=$(PREFIX) --prefix="$(ROOT)" --enable-shared=no

libogg:
	cd libogg; ./configure --host=$(PREFIX) --prefix="$(ROOT)" --enable-shared=no

libvorbis:
	cd libvorbis; ./configure --host=$(PREFIX) --prefix="$(ROOT)" --enable-shared=no --disable-oggtest --enable-docs=no --enable-examples=no

libSDL:
	cd libSDL; unset PKG_CONFIG_LIBDIR; ac_cv_header_iconv_h=no ac_cv_func_iconv=no ac_cv_func_iconv_open=no ./configure --host=$(PREFIX) --prefix="$(ROOT)" --enable-shared=no --enable-assertions=release --enable-render=no --enable-joystick=no --enable-haptic=no --enable-power=no --enable-ssemath --enable-sse2 --disable-alsatest --enable-diskaudio=no --enable-dummyaudio=no --enable-video-dummy=no --enable-libudev=no --enable-dbus=no --enable-input-tslib=no --enable-render-d3d=no $(EXCLUDEX11)

libSDL_image:
	cd libSDL_image; ac_cv_lib_jpeg_jpeg_CreateDecompress=yes ./configure --host=$(PREFIX) --prefix="$(ROOT)" --enable-shared=no --enable-imageio=no --enable-bmp=no --enable-gif=no --enable-jpg-shared=no --enable-png-shared=no --enable-pnm=no --enable-webp=no --enable-tif=no --enable-lbm=no --enable-pcx=no --enable-tga=no --enable-xcf=no --enable-xpm=no --enable-xv=no --disable-sdltest

libSDL_mixer:
	cd libSDL_mixer; ./configure --host=$(PREFIX) --prefix="$(ROOT)" --enable-shared=no --disable-sdltest --enable-music-cmd=no --enable-music-mod=no --enable-music-mod-modplug=no --enable-music-mod-mikmod=no --enable-music-midi=no --enable-music-midi-timidity=no --enable-music-midi-native=no --enable-music-midi-fluidsynth=no --enable-music-flac=no --enable-music-ogg-shared=no --enable-music-mp3=no --enable-music-mp3-smpeg=no --enable-music-mp3-mad-gpl=no --disable-smpegtest 

libgeoip:
	cd libgeoip; ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes ./configure --host=$(PREFIX) --prefix="$(ROOT)" --enable-shared=no

libressl:
	cd libressl; ./configure --host=$(PREFIX) --prefix="$(ROOT)" --enable-shared=no

libcurl:
	cd libcurl; ./configure --host=$(PREFIX) --prefix="$(ROOT)" --enable-shared=no --enable-threaded-resolver --disable-ldap --disable-ldaps --disable-rtsp --with-ssl --without-libssh2 --without-libidn --without-librtmp

env:
	env

.PHONY : libz libenet libjpeg libpng libvorbis libogg libSDL libSDL_image libSDL_mixer libgeoip libressl libcurl env

