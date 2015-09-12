include deps/platform.mk

override CFLAGS+= -Ideps/$(DEPSNAME)/include/SDL2 -Ishared -Iengine -Ifpsgame -Imod -Wall -fsigned-char
override CXXFLAGS+= -Ideps/$(DEPSNAME)/include/SDL2 -Ishared -Iengine -Ifpsgame -Imod -std=gnu++14 -Wall -fsigned-char -fno-exceptions -fno-rtti
ifneq (,$(findstring -ggdb,$(CXXFLAGS)))
  STRIP=true
  UPX=true
else
  UPX=upx
endif

$(shell ./get_revision.sh)

CLIENT_OBJS:= \
	shared/crypto.o \
	shared/geom.o \
	shared/stream.o \
	shared/tools.o \
	shared/zip.o \
	engine/3dgui.o \
	engine/bih.o \
	engine/blend.o \
	engine/blob.o \
	engine/client.o	\
	engine/command.o \
	engine/console.o \
	engine/cubeloader.o \
	engine/decal.o \
	engine/dynlight.o \
	engine/glare.o \
	engine/grass.o \
	engine/lightmap.o \
	engine/main.o \
	engine/material.o \
	engine/menus.o \
	engine/movie.o \
	engine/normal.o	\
	engine/octa.o \
	engine/octaedit.o \
	engine/octarender.o \
	engine/physics.o \
	engine/pvs.o \
	engine/rendergl.o \
	engine/rendermodel.o \
	engine/renderparticles.o \
	engine/rendersky.o \
	engine/rendertext.o \
	engine/renderva.o \
	engine/server.o	\
	engine/serverbrowser.o \
	engine/shader.o \
	engine/shadowmap.o \
	engine/sound.o \
	engine/texture.o \
	engine/water.o \
	engine/world.o \
	engine/worldio.o \
	fpsgame/ai.o \
	fpsgame/client.o \
	fpsgame/entities.o \
	fpsgame/fps.o \
	fpsgame/monster.o \
	fpsgame/movable.o \
	fpsgame/render.o \
	fpsgame/scoreboard.o \
	fpsgame/server.o \
	fpsgame/waypoint.o \
	fpsgame/weapon.o \
	mod/plugin.o mod/demorecorder.o mod/chat.o mod/events.o \
	mod/extinfo.o mod/gamemod.o mod/geoip.o mod/ipignore.o mod/mod.o \
	mod/cubescript.o mod/hwdisplay.o mod/playerdisplay.o mod/http.o \
	mod/strtool.o mod/crypto.o mod/extinfo-playerpreview.o \
	mod/ipbuf.o mod/proxy-detection.o
MACOBJC:= \
	xcode/Launcher.o \
	xcode/main.o
MACOBJCXX:= xcode/macutils.o

ifdef WINDOWS
override LDFLAGS+= -mwindows
override LIBS+= -lenet -lSDL2 -lSDL2_image -ljpeg -lpng -lz -lSDL2_mixer -logg -lvorbis -lvorbisfile -lws2_32 -lwinmm -lopengl32 -ldxguid -lgdi32 -lole32 -limm32 -lversion -loleaut32 -lcurl -lssl -lcrypto -lGeoIP -static-libgcc -static-libstdc++
endif

ifdef LINUX
override LIBS+= -lGL -lenet -lSDL2 -lSDL2_image -ljpeg -lpng -lz -lSDL2_mixer -logg -lvorbis -lvorbisfile -lcurl -lssl -lcrypto -lGeoIP -lm -ldl
ifneq (, $(findstring x86_64,$(PREFIX)))
override LDFLAGS+= -Wl,--wrap=__pow_finite,--wrap=__acosf_finite,--wrap=__log_finite,--wrap=__exp_finite,--wrap=__logf_finite,--wrap=__expf_finite,--wrap=__asin_finite,--wrap=__atan2f_finite,--wrap=__log10f_finite,--wrap=__atan2_finite,--wrap=__acos_finite,--wrap=memcpy
CLIENT_OBJS+= quirks/oldglibc64.o
else
override LDFLAGS+= -Wl,--wrap=__pow_finite
override CLIENT_OBJS+= quirks/oldglibc32.o
endif
endif

ifdef MAC
override LIBS+= -lenet -lSDL2 -lSDL2_image -ljpeg -lpng -lz -lSDL2_mixer -logg -lvorbis -lvorbisfile -lcurl -lssl -lcrypto -lGeoIP -framework IOKit -framework Cocoa -framework CoreVideo -framework Carbon -framework CoreAudio -framework OpenGL -framework AudioUnit -lm -ldl
endif


quirks/oldglibc%: override CXXFLAGS += -fno-fast-math

default: all

all: client

clean:
	-$(RM) -r $(CLIENT_OBJS) $(MACOBJC) $(MACOBJCXX) quirks/*.o sauer_client sauerbraten.exe vcpp/mingw.res

ifdef WINDOWS
client: $(CLIENT_OBJS)
	$(WINDRES) -I vcpp -i vcpp/mingw.rc -J rc -o vcpp/mingw.res -O coff 
	$(CXX) -static $(CXXFLAGS) $(LDFLAGS) -o sauerbraten.exe vcpp/mingw.res $(CLIENT_OBJS) -Wl,--as-needed -Wl,--start-group $(LIBS) -Wl,--end-group
	$(STRIP) sauerbraten.exe
	-$(UPX) sauerbraten.exe
endif

ifdef MAC
$(MACOBJCXX):
	$(CXX) -c $(CXXFLAGS) -o $@ $(subst .o,.mm,$@)
$(MACOBJC):
	$(CC) -c $(CFLAGS) -o $@ $(subst .o,.m,$@)

client:	$(CLIENT_OBJS) $(MACOBJCXX) $(MACOBJC)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o sauerbraten $(CLIENT_OBJS) $(MACOBJCXX) $(MACOBJC) $(LIBS)
	$(STRIP) sauerbraten
	-$(UPX) sauerbraten
endif

ifdef LINUX
client:	$(CLIENT_OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o sauer_client $(CLIENT_OBJS) -Wl,--as-needed -Wl,--start-group $(LIBS) -lrt -Wl,--end-group
	$(STRIP) sauer_client
ifneq ($(STRIP),true)
ifneq (, $(findstring x86_64,$(PREFIX)))
	./quirks/remove_symbol_version memcpy@GLIBC_2.2.5
endif
endif
	-$(UPX) sauer_client
endif

# DO NOT DELETE

shared/crypto.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/crypto.o: shared/command.h shared/iengine.h mod/compat.h mod/mod.h
shared/crypto.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
shared/crypto.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
shared/crypto.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
shared/crypto.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
shared/crypto.o: shared/igame.h
shared/geom.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/geom.o: shared/command.h shared/iengine.h mod/compat.h mod/mod.h
shared/geom.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
shared/geom.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
shared/geom.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
shared/geom.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
shared/geom.o: shared/igame.h
shared/stream.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/stream.o: shared/command.h shared/iengine.h mod/compat.h mod/mod.h
shared/stream.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
shared/stream.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
shared/stream.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
shared/stream.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
shared/stream.o: shared/igame.h
shared/tools.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/tools.o: shared/command.h shared/iengine.h mod/compat.h mod/mod.h
shared/tools.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
shared/tools.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
shared/tools.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
shared/tools.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
shared/tools.o: shared/igame.h
shared/zip.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/zip.o: shared/command.h shared/iengine.h mod/compat.h mod/mod.h
shared/zip.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
shared/zip.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
shared/zip.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
shared/zip.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
shared/zip.o: shared/igame.h
engine/3dgui.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/3dgui.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/3dgui.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/3dgui.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/3dgui.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/3dgui.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/3dgui.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/3dgui.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/3dgui.o: engine/model.h engine/varray.h engine/textedit.h
engine/bih.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/bih.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/bih.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/bih.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
engine/bih.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
engine/bih.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
engine/bih.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/bih.o: engine/lightmap.h engine/bih.h engine/texture.h engine/model.h
engine/bih.o: engine/varray.h
engine/blend.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/blend.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/blend.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/blend.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/blend.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/blend.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/blend.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/blend.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/blend.o: engine/model.h engine/varray.h
engine/blob.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/blob.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/blob.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/blob.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/blob.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/blob.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/blob.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/blob.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/blob.o: engine/model.h engine/varray.h
engine/client.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/client.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/client.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/client.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/client.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/client.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/client.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/client.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/client.o: engine/texture.h engine/model.h engine/varray.h
engine/command.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/command.o: shared/ents.h shared/command.h shared/iengine.h
engine/command.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/command.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
engine/command.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
engine/command.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/command.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/command.o: engine/world.h engine/glexts.h engine/octa.h
engine/command.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/command.o: engine/model.h engine/varray.h
engine/console.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/console.o: shared/ents.h shared/command.h shared/iengine.h
engine/console.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/console.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
engine/console.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
engine/console.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/console.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/console.o: engine/world.h engine/glexts.h engine/octa.h
engine/console.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/console.o: engine/model.h engine/varray.h
engine/console.o: engine/sdl2_keymap_extrakeys.h
engine/cubeloader.o: engine/engine.h shared/cube.h shared/tools.h
engine/cubeloader.o: shared/geom.h shared/ents.h shared/command.h
engine/cubeloader.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/cubeloader.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/wcversion.h
engine/cubeloader.o: mod/gamemod.h mod/http.h mod/geoip.h mod/ipignore.h
engine/cubeloader.o: mod/extinfo.h mod/demorecorder.h mod/chat.h mod/events.h
engine/cubeloader.o: mod/thread.h mod/proxy-detection.h mod/plugin.h
engine/cubeloader.o: shared/igame.h engine/world.h engine/glexts.h
engine/cubeloader.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/cubeloader.o: engine/texture.h engine/model.h engine/varray.h
engine/decal.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/decal.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/decal.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/decal.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/decal.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/decal.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/decal.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/decal.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/decal.o: engine/model.h engine/varray.h
engine/dynlight.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/dynlight.o: shared/ents.h shared/command.h shared/iengine.h
engine/dynlight.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/dynlight.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
engine/dynlight.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
engine/dynlight.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/dynlight.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/dynlight.o: engine/world.h engine/glexts.h engine/octa.h
engine/dynlight.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/dynlight.o: engine/model.h engine/varray.h
engine/glare.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/glare.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/glare.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/glare.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/glare.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/glare.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/glare.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/glare.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/glare.o: engine/model.h engine/varray.h engine/rendertarget.h
engine/grass.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/grass.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/grass.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/grass.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/grass.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/grass.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/grass.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/grass.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/grass.o: engine/model.h engine/varray.h
engine/lightmap.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/lightmap.o: shared/ents.h shared/command.h shared/iengine.h
engine/lightmap.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/lightmap.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
engine/lightmap.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
engine/lightmap.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/lightmap.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/lightmap.o: engine/world.h engine/glexts.h engine/octa.h
engine/lightmap.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/lightmap.o: engine/model.h engine/varray.h
engine/main.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/main.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/main.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/main.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/main.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/main.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/main.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/main.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/main.o: engine/model.h engine/varray.h
engine/material.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/material.o: shared/ents.h shared/command.h shared/iengine.h
engine/material.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/material.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
engine/material.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
engine/material.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/material.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/material.o: engine/world.h engine/glexts.h engine/octa.h
engine/material.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/material.o: engine/model.h engine/varray.h
engine/menus.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/menus.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/menus.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/menus.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/menus.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/menus.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/menus.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/menus.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/menus.o: engine/model.h engine/varray.h
engine/movie.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/movie.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/movie.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/movie.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/movie.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/movie.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/movie.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/movie.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/movie.o: engine/model.h engine/varray.h
engine/normal.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/normal.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/normal.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/normal.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/normal.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/normal.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/normal.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/normal.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/normal.o: engine/texture.h engine/model.h engine/varray.h
engine/octa.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/octa.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/octa.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/octa.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/octa.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/octa.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/octa.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/octa.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/octa.o: engine/model.h engine/varray.h
engine/octaedit.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/octaedit.o: shared/ents.h shared/command.h shared/iengine.h
engine/octaedit.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/octaedit.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
engine/octaedit.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
engine/octaedit.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/octaedit.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/octaedit.o: engine/world.h engine/glexts.h engine/octa.h
engine/octaedit.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/octaedit.o: engine/model.h engine/varray.h
engine/octarender.o: engine/engine.h shared/cube.h shared/tools.h
engine/octarender.o: shared/geom.h shared/ents.h shared/command.h
engine/octarender.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/octarender.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/wcversion.h
engine/octarender.o: mod/gamemod.h mod/http.h mod/geoip.h mod/ipignore.h
engine/octarender.o: mod/extinfo.h mod/demorecorder.h mod/chat.h mod/events.h
engine/octarender.o: mod/thread.h mod/proxy-detection.h mod/plugin.h
engine/octarender.o: shared/igame.h engine/world.h engine/glexts.h
engine/octarender.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/octarender.o: engine/texture.h engine/model.h engine/varray.h
engine/physics.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/physics.o: shared/ents.h shared/command.h shared/iengine.h
engine/physics.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/physics.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
engine/physics.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
engine/physics.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/physics.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/physics.o: engine/world.h engine/glexts.h engine/octa.h
engine/physics.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/physics.o: engine/model.h engine/varray.h engine/mpr.h
engine/pvs.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/pvs.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/pvs.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/pvs.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
engine/pvs.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
engine/pvs.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
engine/pvs.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/pvs.o: engine/lightmap.h engine/bih.h engine/texture.h engine/model.h
engine/pvs.o: engine/varray.h
engine/rendergl.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/rendergl.o: shared/ents.h shared/command.h shared/iengine.h
engine/rendergl.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/rendergl.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
engine/rendergl.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
engine/rendergl.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/rendergl.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/rendergl.o: engine/world.h engine/glexts.h engine/octa.h
engine/rendergl.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/rendergl.o: engine/model.h engine/varray.h
engine/rendermodel.o: engine/engine.h shared/cube.h shared/tools.h
engine/rendermodel.o: shared/geom.h shared/ents.h shared/command.h
engine/rendermodel.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/rendermodel.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/wcversion.h
engine/rendermodel.o: mod/gamemod.h mod/http.h mod/geoip.h mod/ipignore.h
engine/rendermodel.o: mod/extinfo.h mod/demorecorder.h mod/chat.h
engine/rendermodel.o: mod/events.h mod/thread.h mod/proxy-detection.h
engine/rendermodel.o: mod/plugin.h shared/igame.h engine/world.h
engine/rendermodel.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/rendermodel.o: engine/bih.h engine/texture.h engine/model.h
engine/rendermodel.o: engine/varray.h engine/ragdoll.h engine/animmodel.h
engine/rendermodel.o: engine/vertmodel.h engine/skelmodel.h engine/md2.h
engine/rendermodel.o: engine/md3.h engine/md5.h engine/obj.h engine/smd.h
engine/rendermodel.o: engine/iqm.h
engine/renderparticles.o: engine/engine.h shared/cube.h shared/tools.h
engine/renderparticles.o: shared/geom.h shared/ents.h shared/command.h
engine/renderparticles.o: shared/iengine.h mod/compat.h mod/mod.h
engine/renderparticles.o: mod/compiler.h mod/strtool.h mod/crypto.h
engine/renderparticles.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h
engine/renderparticles.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
engine/renderparticles.o: mod/demorecorder.h mod/chat.h mod/events.h
engine/renderparticles.o: mod/thread.h mod/proxy-detection.h mod/plugin.h
engine/renderparticles.o: shared/igame.h engine/world.h engine/glexts.h
engine/renderparticles.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/renderparticles.o: engine/texture.h engine/model.h engine/varray.h
engine/renderparticles.o: engine/rendertarget.h engine/depthfx.h
engine/renderparticles.o: engine/explosion.h engine/lensflare.h
engine/renderparticles.o: engine/lightning.h
engine/rendersky.o: engine/engine.h shared/cube.h shared/tools.h
engine/rendersky.o: shared/geom.h shared/ents.h shared/command.h
engine/rendersky.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/rendersky.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/wcversion.h
engine/rendersky.o: mod/gamemod.h mod/http.h mod/geoip.h mod/ipignore.h
engine/rendersky.o: mod/extinfo.h mod/demorecorder.h mod/chat.h mod/events.h
engine/rendersky.o: mod/thread.h mod/proxy-detection.h mod/plugin.h
engine/rendersky.o: shared/igame.h engine/world.h engine/glexts.h
engine/rendersky.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/rendersky.o: engine/texture.h engine/model.h engine/varray.h
engine/rendertext.o: engine/engine.h shared/cube.h shared/tools.h
engine/rendertext.o: shared/geom.h shared/ents.h shared/command.h
engine/rendertext.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/rendertext.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/wcversion.h
engine/rendertext.o: mod/gamemod.h mod/http.h mod/geoip.h mod/ipignore.h
engine/rendertext.o: mod/extinfo.h mod/demorecorder.h mod/chat.h mod/events.h
engine/rendertext.o: mod/thread.h mod/proxy-detection.h mod/plugin.h
engine/rendertext.o: shared/igame.h engine/world.h engine/glexts.h
engine/rendertext.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/rendertext.o: engine/texture.h engine/model.h engine/varray.h
engine/renderva.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/renderva.o: shared/ents.h shared/command.h shared/iengine.h
engine/renderva.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/renderva.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
engine/renderva.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
engine/renderva.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/renderva.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/renderva.o: engine/world.h engine/glexts.h engine/octa.h
engine/renderva.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/renderva.o: engine/model.h engine/varray.h
engine/server.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/server.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/server.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/server.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/server.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/server.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/server.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/server.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/server.o: engine/texture.h engine/model.h engine/varray.h
engine/serverbrowser.o: engine/engine.h shared/cube.h shared/tools.h
engine/serverbrowser.o: shared/geom.h shared/ents.h shared/command.h
engine/serverbrowser.o: shared/iengine.h mod/compat.h mod/mod.h
engine/serverbrowser.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/serverbrowser.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
engine/serverbrowser.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/serverbrowser.o: mod/chat.h mod/events.h mod/thread.h
engine/serverbrowser.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/serverbrowser.o: engine/world.h engine/glexts.h engine/octa.h
engine/serverbrowser.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/serverbrowser.o: engine/model.h engine/varray.h
engine/shader.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/shader.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/shader.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/shader.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/shader.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/shader.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/shader.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/shader.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/shader.o: engine/texture.h engine/model.h engine/varray.h
engine/shadowmap.o: engine/engine.h shared/cube.h shared/tools.h
engine/shadowmap.o: shared/geom.h shared/ents.h shared/command.h
engine/shadowmap.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/shadowmap.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/wcversion.h
engine/shadowmap.o: mod/gamemod.h mod/http.h mod/geoip.h mod/ipignore.h
engine/shadowmap.o: mod/extinfo.h mod/demorecorder.h mod/chat.h mod/events.h
engine/shadowmap.o: mod/thread.h mod/proxy-detection.h mod/plugin.h
engine/shadowmap.o: shared/igame.h engine/world.h engine/glexts.h
engine/shadowmap.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/shadowmap.o: engine/texture.h engine/model.h engine/varray.h
engine/shadowmap.o: engine/rendertarget.h
engine/sound.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/sound.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/sound.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/sound.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/sound.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/sound.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/sound.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/sound.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/sound.o: engine/model.h engine/varray.h
engine/texture.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/texture.o: shared/ents.h shared/command.h shared/iengine.h
engine/texture.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/texture.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
engine/texture.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
engine/texture.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/texture.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/texture.o: engine/world.h engine/glexts.h engine/octa.h
engine/texture.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/texture.o: engine/model.h engine/varray.h engine/scale.h
engine/water.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/water.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/water.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/water.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/water.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/water.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/water.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/water.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/water.o: engine/model.h engine/varray.h
engine/world.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/world.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
engine/world.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
engine/world.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
engine/world.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/world.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/world.o: mod/plugin.h shared/igame.h engine/world.h engine/glexts.h
engine/world.o: engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h
engine/world.o: engine/model.h engine/varray.h
engine/worldio.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/worldio.o: shared/ents.h shared/command.h shared/iengine.h
engine/worldio.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/worldio.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
engine/worldio.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
engine/worldio.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/worldio.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/worldio.o: engine/world.h engine/glexts.h engine/octa.h
engine/worldio.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/worldio.o: engine/model.h engine/varray.h
fpsgame/ai.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/ai.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
fpsgame/ai.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
fpsgame/ai.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
fpsgame/ai.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
fpsgame/ai.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
fpsgame/ai.o: shared/igame.h fpsgame/ai.h
fpsgame/client.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/client.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/client.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
fpsgame/client.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
fpsgame/client.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
fpsgame/client.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/client.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/client.o: fpsgame/ai.h fpsgame/capture.h fpsgame/ctf.h
fpsgame/client.o: fpsgame/collect.h mod/cubescript.h
fpsgame/entities.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/entities.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/entities.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
fpsgame/entities.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
fpsgame/entities.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
fpsgame/entities.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/entities.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/entities.o: fpsgame/ai.h
fpsgame/fps.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/fps.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
fpsgame/fps.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
fpsgame/fps.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
fpsgame/fps.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
fpsgame/fps.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
fpsgame/fps.o: mod/plugin.h shared/igame.h fpsgame/ai.h
fpsgame/monster.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/monster.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/monster.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
fpsgame/monster.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
fpsgame/monster.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
fpsgame/monster.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/monster.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/monster.o: fpsgame/ai.h
fpsgame/movable.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/movable.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/movable.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
fpsgame/movable.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
fpsgame/movable.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
fpsgame/movable.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/movable.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/movable.o: fpsgame/ai.h
fpsgame/render.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/render.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/render.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
fpsgame/render.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
fpsgame/render.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
fpsgame/render.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/render.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/render.o: fpsgame/ai.h
fpsgame/scoreboard.o: fpsgame/game.h shared/cube.h shared/tools.h
fpsgame/scoreboard.o: shared/geom.h shared/ents.h shared/command.h
fpsgame/scoreboard.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
fpsgame/scoreboard.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/wcversion.h
fpsgame/scoreboard.o: mod/gamemod.h mod/http.h mod/geoip.h mod/ipignore.h
fpsgame/scoreboard.o: mod/extinfo.h mod/demorecorder.h mod/chat.h
fpsgame/scoreboard.o: mod/events.h mod/thread.h mod/proxy-detection.h
fpsgame/scoreboard.o: mod/plugin.h shared/igame.h fpsgame/ai.h
fpsgame/server.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/server.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/server.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
fpsgame/server.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
fpsgame/server.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
fpsgame/server.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/server.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/server.o: fpsgame/ai.h fpsgame/capture.h fpsgame/ctf.h
fpsgame/server.o: fpsgame/collect.h fpsgame/aiman.h
fpsgame/waypoint.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/waypoint.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/waypoint.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
fpsgame/waypoint.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
fpsgame/waypoint.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
fpsgame/waypoint.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/waypoint.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/waypoint.o: fpsgame/ai.h
fpsgame/weapon.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/weapon.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/weapon.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
fpsgame/weapon.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
fpsgame/weapon.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
fpsgame/weapon.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/weapon.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/weapon.o: fpsgame/ai.h
mod/plugin.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/plugin.o: shared/command.h shared/iengine.h mod/compat.h mod/mod.h
mod/plugin.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/plugin.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
mod/plugin.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/plugin.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/plugin.o: shared/igame.h
mod/demorecorder.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/demorecorder.o: shared/ents.h shared/command.h shared/iengine.h
mod/demorecorder.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
mod/demorecorder.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
mod/demorecorder.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
mod/demorecorder.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
mod/demorecorder.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
mod/demorecorder.o: fpsgame/ai.h
mod/chat.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/chat.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
mod/chat.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/chat.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
mod/chat.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/chat.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/chat.o: shared/igame.h fpsgame/ai.h mod/chat-ca-certs.h
mod/events.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/events.o: shared/command.h shared/iengine.h mod/compat.h mod/mod.h
mod/events.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/events.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
mod/events.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/events.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/events.o: shared/igame.h
mod/extinfo.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/extinfo.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
mod/extinfo.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
mod/extinfo.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
mod/extinfo.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
mod/extinfo.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
mod/extinfo.o: mod/plugin.h shared/igame.h fpsgame/ai.h
mod/gamemod.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/gamemod.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
mod/gamemod.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
mod/gamemod.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
mod/gamemod.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
mod/gamemod.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
mod/gamemod.o: mod/plugin.h shared/igame.h fpsgame/ai.h
mod/geoip.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/geoip.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
mod/geoip.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/geoip.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
mod/geoip.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/geoip.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/geoip.o: shared/igame.h fpsgame/ai.h
mod/ipignore.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/ipignore.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
mod/ipignore.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
mod/ipignore.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
mod/ipignore.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
mod/ipignore.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
mod/ipignore.o: mod/plugin.h shared/igame.h fpsgame/ai.h
mod/mod.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/mod.o: shared/command.h shared/iengine.h mod/compat.h mod/mod.h
mod/mod.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/mod.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
mod/mod.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/mod.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/mod.o: shared/igame.h last_sauer_svn_rev.h
mod/cubescript.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/cubescript.o: shared/ents.h shared/command.h shared/iengine.h
mod/cubescript.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
mod/cubescript.o: mod/crypto.h mod/ipbuf.h mod/wcversion.h mod/gamemod.h
mod/cubescript.o: mod/http.h mod/geoip.h mod/ipignore.h mod/extinfo.h
mod/cubescript.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
mod/cubescript.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
mod/cubescript.o: fpsgame/ai.h
mod/hwdisplay.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/hwdisplay.o: shared/ents.h shared/command.h shared/iengine.h mod/compat.h
mod/hwdisplay.o: mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
mod/hwdisplay.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h mod/http.h
mod/hwdisplay.o: mod/geoip.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
mod/hwdisplay.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
mod/hwdisplay.o: mod/plugin.h shared/igame.h fpsgame/ai.h
mod/playerdisplay.o: fpsgame/game.h shared/cube.h shared/tools.h
mod/playerdisplay.o: shared/geom.h shared/ents.h shared/command.h
mod/playerdisplay.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
mod/playerdisplay.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/wcversion.h
mod/playerdisplay.o: mod/gamemod.h mod/http.h mod/geoip.h mod/ipignore.h
mod/playerdisplay.o: mod/extinfo.h mod/demorecorder.h mod/chat.h mod/events.h
mod/playerdisplay.o: mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/playerdisplay.o: shared/igame.h fpsgame/ai.h
mod/http.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/http.o: shared/command.h shared/iengine.h mod/compat.h mod/mod.h
mod/http.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/http.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
mod/http.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/http.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/http.o: shared/igame.h
mod/strtool.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/strtool.o: shared/command.h shared/iengine.h mod/compat.h mod/mod.h
mod/strtool.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/strtool.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
mod/strtool.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/strtool.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/strtool.o: shared/igame.h
mod/crypto.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/crypto.o: shared/command.h shared/iengine.h mod/compat.h mod/mod.h
mod/crypto.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/crypto.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
mod/crypto.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/crypto.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/crypto.o: shared/igame.h
mod/extinfo-playerpreview.o: fpsgame/game.h shared/cube.h shared/tools.h
mod/extinfo-playerpreview.o: shared/geom.h shared/ents.h shared/command.h
mod/extinfo-playerpreview.o: shared/iengine.h mod/compat.h mod/mod.h
mod/extinfo-playerpreview.o: mod/compiler.h mod/strtool.h mod/crypto.h
mod/extinfo-playerpreview.o: mod/ipbuf.h mod/wcversion.h mod/gamemod.h
mod/extinfo-playerpreview.o: mod/http.h mod/geoip.h mod/ipignore.h
mod/extinfo-playerpreview.o: mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/extinfo-playerpreview.o: mod/events.h mod/thread.h mod/proxy-detection.h
mod/extinfo-playerpreview.o: mod/plugin.h shared/igame.h fpsgame/ai.h
mod/ipbuf.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/ipbuf.o: shared/command.h shared/iengine.h mod/compat.h mod/mod.h
mod/ipbuf.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/ipbuf.o: mod/wcversion.h mod/gamemod.h mod/http.h mod/geoip.h
mod/ipbuf.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/ipbuf.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/ipbuf.o: shared/igame.h
mod/proxy-detection.o: fpsgame/game.h shared/cube.h shared/tools.h
mod/proxy-detection.o: shared/geom.h shared/ents.h shared/command.h
mod/proxy-detection.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
mod/proxy-detection.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/wcversion.h
mod/proxy-detection.o: mod/gamemod.h mod/http.h mod/geoip.h mod/ipignore.h
mod/proxy-detection.o: mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/proxy-detection.o: mod/events.h mod/thread.h mod/proxy-detection.h
mod/proxy-detection.o: mod/plugin.h shared/igame.h fpsgame/ai.h
