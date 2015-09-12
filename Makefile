include deps/platform.mk

override CFLAGS+= -Ideps/$(DEPSNAME)/include/SDL2 -Ishared -Iengine -Ifpsgame -Wall -fsigned-char
override CXXFLAGS+= -Ideps/$(DEPSNAME)/include/SDL2 -Ishared -Iengine -Ifpsgame -std=gnu++0x -Wall -fsigned-char -fno-exceptions -fno-rtti
ifneq (,$(findstring -ggdb,$(CXXFLAGS)))
  STRIP=true
  UPX=true
else
  UPX=upx
endif

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
	fpsgame/weapon.o
MACOBJC:= \
	xcode/Launcher.o \
	xcode/main.o
MACOBJCXX:= xcode/macutils.o

ifdef WINDOWS
override LDFLAGS+= -mwindows
override LIBS+= -lenet -lSDL2 -lSDL2_image -ljpeg -lpng -lz -lSDL2_mixer -logg -lvorbis -lvorbisfile -lws2_32 -lwinmm -lopengl32 -ldxguid -lgdi32 -lole32 -limm32 -lversion -loleaut32 -static-libgcc -static-libstdc++
endif

ifdef LINUX
override LIBS+= -lGL -lenet -lSDL2 -lSDL2_image -ljpeg -lpng -lz -lSDL2_mixer -logg -lvorbis -lvorbisfile -lm -ldl
ifneq (, $(findstring x86_64,$(PREFIX)))
override LDFLAGS+= -Wl,--wrap=__pow_finite,--wrap=__acosf_finite,--wrap=__log_finite,--wrap=__exp_finite,--wrap=__logf_finite,--wrap=__expf_finite,--wrap=__asin_finite,--wrap=__atan2f_finite,--wrap=__log10f_finite,--wrap=__atan2_finite,--wrap=__acos_finite,--wrap=memcpy
CLIENT_OBJS+= quirks/oldglibc64.o
else
override LDFLAGS+= -Wl,--wrap=__pow_finite
override CLIENT_OBJS+= quirks/oldglibc32.o
endif
endif

ifdef MAC
override LIBS+= -lenet -lSDL2 -lSDL2_image -ljpeg -lpng -lz -lSDL2_mixer -logg -lvorbis -lvorbisfile -framework IOKit -framework Cocoa -framework CoreVideo -framework Carbon -framework CoreAudio -framework OpenGL -framework AudioUnit -lm -ldl
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

engine/3dgui.o:		engine/engine.h engine/textedit.h
engine/bih.o:		engine/engine.h
engine/blend.o:		engine/engine.h
engine/blob.o:		engine/engine.h
engine/client.o:	engine/engine.h
engine/command.o:	engine/engine.h
engine/console.o:	engine/engine.h engine/sdl2_keymap_extrakeys.h
engine/cubeloader.o:	engine/engine.h
engine/decal.o:		engine/engine.h
engine/dynlight.o:	engine/engine.h
engine/engine.h:	shared/cube.h engine/world.h engine/octa.h engine/lightmap.h engine/bih.h engine/texture.h engine/model.h engine/varray.h
engine/glare.o:		engine/engine.h engine/rendertarget.h
engine/grass.o:		engine/engine.h
engine/lightmap.o:	engine/engine.h
engine/main.o:		engine/engine.h engine/sdosscripts.h
engine/master.o:	shared/cube.h
engine/material.o:	engine/engine.h
engine/menus.o:		engine/engine.h
engine/movie.o:		engine/engine.h
engine/normal.o:	engine/engine.h
engine/octa.o:		engine/engine.h
engine/octaedit.o:	engine/engine.h
engine/octarender.o:	engine/engine.h
engine/physics.o:	engine/engine.h engine/mpr.h
engine/pvs.o:		engine/engine.h
engine/rendergl.o:	engine/engine.h engine/varray.h
engine/rendermodel.o:	engine/engine.h engine/ragdoll.h engine/animmodel.h engine/vertmodel.h engine/skelmodel.h engine/md2.h engine/md3.h engine/md5.h engine/obj.h engine/smd.h engine/iqm.h
engine/renderparticles.o: engine/engine.h engine/rendertarget.h engine/depthfx.h engine/explosion.h engine/lensflare.h engine/lightning.h
engine/rendersky.o:	engine/engine.h
engine/rendertext.o:	engine/engine.h
engine/renderva.o:	engine/engine.h
engine/serverbrowser.o:	engine/engine.h
engine/server.o:	engine/engine.h
engine/shader.o:	engine/engine.h
engine/shadowmap.o:	engine/engine.h engine/rendertarget.h
engine/sound.o:		engine/engine.h
engine/texture.o:	engine/engine.h engine/scale.h
engine/water.o:		engine/engine.h
engine/world.o:		engine/engine.h
engine/worldio.o:	engine/engine.h
fpsgame/ai.o:		fpsgame/game.h
fpsgame/client.o:	fpsgame/game.h fpsgame/capture.h fpsgame/ctf.h fpsgame/collect.h
fpsgame/entities.o:	fpsgame/game.h
fpsgame/fps.o:		fpsgame/game.h
fpsgame/game.h:		shared/cube.h fpsgame/ai.h
fpsgame/monster.o:	fpsgame/game.h
fpsgame/movable.o:	fpsgame/game.h
fpsgame/render.o:	fpsgame/game.h
fpsgame/scoreboard.o:	fpsgame/game.h
fpsgame/server.o:	fpsgame/game.h fpsgame/capture.h fpsgame/ctf.h fpsgame/collect.h fpsgame/extinfo.h fpsgame/aiman.h
fpsgame/waypoint.o:	fpsgame/game.h
fpsgame/weapon.o:	fpsgame/game.h
shared/crypto.o:	shared/cube.h
shared/cube.h:		shared/tools.h shared/geom.h shared/ents.h shared/command.h shared/iengine.h shared/igame.h
shared/geom.o:		shared/cube.h
shared/stream.o:	shared/cube.h
shared/tools.o:		shared/cube.h
shared/zip.o:		shared/cube.h

xcode/Launcher.o:	xcode/Launcher.h
xcode/main.o:		xcode/Launcher.h

quirks/oldglibc32.o:	quirks/wrapper.hpp
quirks/oldglibc64.o:	quirks/wrapper.hpp


shared/tools.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/tools.o: shared/command.h shared/iengine.h shared/igame.h
shared/zip.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/zip.o: shared/command.h shared/iengine.h shared/igame.h
shared/geom.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/geom.o: shared/command.h shared/iengine.h shared/igame.h
shared/crypto.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/crypto.o: shared/command.h shared/iengine.h shared/igame.h
shared/stream.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/stream.o: shared/command.h shared/iengine.h shared/igame.h
engine/cubeloader.o: engine/engine.h shared/cube.h shared/tools.h
engine/cubeloader.o: shared/geom.h shared/ents.h shared/command.h
engine/cubeloader.o: shared/iengine.h shared/igame.h engine/world.h
engine/cubeloader.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/cubeloader.o: engine/bih.h engine/texture.h engine/model.h
engine/cubeloader.o: engine/varray.h
engine/renderparticles.o: engine/engine.h shared/cube.h shared/tools.h
engine/renderparticles.o: shared/geom.h shared/ents.h shared/command.h
engine/renderparticles.o: shared/iengine.h shared/igame.h engine/world.h
engine/renderparticles.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/renderparticles.o: engine/bih.h engine/texture.h engine/model.h
engine/renderparticles.o: engine/varray.h engine/rendertarget.h
engine/renderparticles.o: engine/depthfx.h engine/explosion.h
engine/renderparticles.o: engine/lensflare.h engine/lightning.h
engine/dynlight.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/dynlight.o: shared/ents.h shared/command.h shared/iengine.h
engine/dynlight.o: shared/igame.h engine/world.h engine/glexts.h
engine/dynlight.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/dynlight.o: engine/texture.h engine/model.h engine/varray.h
engine/command.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/command.o: shared/ents.h shared/command.h shared/iengine.h
engine/command.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/command.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/command.o: engine/model.h engine/varray.h
engine/console.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/console.o: shared/ents.h shared/command.h shared/iengine.h
engine/console.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/console.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/console.o: engine/model.h engine/varray.h
engine/console.o: engine/sdl2_keymap_extrakeys.h
engine/blob.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/blob.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
engine/blob.o: engine/world.h engine/glexts.h engine/octa.h engine/lightmap.h
engine/blob.o: engine/bih.h engine/texture.h engine/model.h engine/varray.h
engine/menus.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/menus.o: shared/ents.h shared/command.h shared/iengine.h
engine/menus.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/menus.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/menus.o: engine/model.h engine/varray.h
engine/rendersky.o: engine/engine.h shared/cube.h shared/tools.h
engine/rendersky.o: shared/geom.h shared/ents.h shared/command.h
engine/rendersky.o: shared/iengine.h shared/igame.h engine/world.h
engine/rendersky.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/rendersky.o: engine/bih.h engine/texture.h engine/model.h
engine/rendersky.o: engine/varray.h
engine/server.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/server.o: shared/ents.h shared/command.h shared/iengine.h
engine/server.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/server.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/server.o: engine/model.h engine/varray.h
engine/rendermodel.o: engine/engine.h shared/cube.h shared/tools.h
engine/rendermodel.o: shared/geom.h shared/ents.h shared/command.h
engine/rendermodel.o: shared/iengine.h shared/igame.h engine/world.h
engine/rendermodel.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/rendermodel.o: engine/bih.h engine/texture.h engine/model.h
engine/rendermodel.o: engine/varray.h engine/ragdoll.h engine/animmodel.h
engine/rendermodel.o: engine/vertmodel.h engine/skelmodel.h engine/md2.h
engine/rendermodel.o: engine/md3.h engine/md5.h engine/obj.h engine/smd.h
engine/rendermodel.o: engine/iqm.h
engine/rendertext.o: engine/engine.h shared/cube.h shared/tools.h
engine/rendertext.o: shared/geom.h shared/ents.h shared/command.h
engine/rendertext.o: shared/iengine.h shared/igame.h engine/world.h
engine/rendertext.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/rendertext.o: engine/bih.h engine/texture.h engine/model.h
engine/rendertext.o: engine/varray.h
engine/worldio.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/worldio.o: shared/ents.h shared/command.h shared/iengine.h
engine/worldio.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/worldio.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/worldio.o: engine/model.h engine/varray.h
engine/sound.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/sound.o: shared/ents.h shared/command.h shared/iengine.h
engine/sound.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/sound.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/sound.o: engine/model.h engine/varray.h
engine/master.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
engine/master.o: shared/command.h shared/iengine.h shared/igame.h
engine/serverbrowser.o: engine/engine.h shared/cube.h shared/tools.h
engine/serverbrowser.o: shared/geom.h shared/ents.h shared/command.h
engine/serverbrowser.o: shared/iengine.h shared/igame.h engine/world.h
engine/serverbrowser.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/serverbrowser.o: engine/bih.h engine/texture.h engine/model.h
engine/serverbrowser.o: engine/varray.h
engine/world.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/world.o: shared/ents.h shared/command.h shared/iengine.h
engine/world.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/world.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/world.o: engine/model.h engine/varray.h
engine/pvs.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/pvs.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
engine/pvs.o: engine/world.h engine/glexts.h engine/octa.h engine/lightmap.h
engine/pvs.o: engine/bih.h engine/texture.h engine/model.h engine/varray.h
engine/renderva.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/renderva.o: shared/ents.h shared/command.h shared/iengine.h
engine/renderva.o: shared/igame.h engine/world.h engine/glexts.h
engine/renderva.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/renderva.o: engine/texture.h engine/model.h engine/varray.h
engine/client.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/client.o: shared/ents.h shared/command.h shared/iengine.h
engine/client.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/client.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/client.o: engine/model.h engine/varray.h
engine/water.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/water.o: shared/ents.h shared/command.h shared/iengine.h
engine/water.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/water.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/water.o: engine/model.h engine/varray.h
engine/material.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/material.o: shared/ents.h shared/command.h shared/iengine.h
engine/material.o: shared/igame.h engine/world.h engine/glexts.h
engine/material.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/material.o: engine/texture.h engine/model.h engine/varray.h
engine/lightmap.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/lightmap.o: shared/ents.h shared/command.h shared/iengine.h
engine/lightmap.o: shared/igame.h engine/world.h engine/glexts.h
engine/lightmap.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/lightmap.o: engine/texture.h engine/model.h engine/varray.h
engine/octa.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/octa.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
engine/octa.o: engine/world.h engine/glexts.h engine/octa.h engine/lightmap.h
engine/octa.o: engine/bih.h engine/texture.h engine/model.h engine/varray.h
engine/grass.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/grass.o: shared/ents.h shared/command.h shared/iengine.h
engine/grass.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/grass.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/grass.o: engine/model.h engine/varray.h
engine/bih.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/bih.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
engine/bih.o: engine/world.h engine/glexts.h engine/octa.h engine/lightmap.h
engine/bih.o: engine/bih.h engine/texture.h engine/model.h engine/varray.h
engine/3dgui.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/3dgui.o: shared/ents.h shared/command.h shared/iengine.h
engine/3dgui.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/3dgui.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/3dgui.o: engine/model.h engine/varray.h engine/textedit.h
engine/glare.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/glare.o: shared/ents.h shared/command.h shared/iengine.h
engine/glare.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/glare.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/glare.o: engine/model.h engine/varray.h engine/rendertarget.h
engine/movie.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/movie.o: shared/ents.h shared/command.h shared/iengine.h
engine/movie.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/movie.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/movie.o: engine/model.h engine/varray.h
engine/normal.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/normal.o: shared/ents.h shared/command.h shared/iengine.h
engine/normal.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/normal.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/normal.o: engine/model.h engine/varray.h
engine/main.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/main.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
engine/main.o: engine/world.h engine/glexts.h engine/octa.h engine/lightmap.h
engine/main.o: engine/bih.h engine/texture.h engine/model.h engine/varray.h
engine/main.o: engine/sdosscripts.h
engine/octarender.o: engine/engine.h shared/cube.h shared/tools.h
engine/octarender.o: shared/geom.h shared/ents.h shared/command.h
engine/octarender.o: shared/iengine.h shared/igame.h engine/world.h
engine/octarender.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/octarender.o: engine/bih.h engine/texture.h engine/model.h
engine/octarender.o: engine/varray.h
engine/shader.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/shader.o: shared/ents.h shared/command.h shared/iengine.h
engine/shader.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/shader.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/shader.o: engine/model.h engine/varray.h
engine/texture.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/texture.o: shared/ents.h shared/command.h shared/iengine.h
engine/texture.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/texture.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/texture.o: engine/model.h engine/varray.h engine/scale.h
engine/blend.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/blend.o: shared/ents.h shared/command.h shared/iengine.h
engine/blend.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/blend.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/blend.o: engine/model.h engine/varray.h
engine/decal.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/decal.o: shared/ents.h shared/command.h shared/iengine.h
engine/decal.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/decal.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/decal.o: engine/model.h engine/varray.h
engine/rendergl.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/rendergl.o: shared/ents.h shared/command.h shared/iengine.h
engine/rendergl.o: shared/igame.h engine/world.h engine/glexts.h
engine/rendergl.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/rendergl.o: engine/texture.h engine/model.h engine/varray.h
engine/shadowmap.o: engine/engine.h shared/cube.h shared/tools.h
engine/shadowmap.o: shared/geom.h shared/ents.h shared/command.h
engine/shadowmap.o: shared/iengine.h shared/igame.h engine/world.h
engine/shadowmap.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/shadowmap.o: engine/bih.h engine/texture.h engine/model.h
engine/shadowmap.o: engine/varray.h engine/rendertarget.h
engine/physics.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/physics.o: shared/ents.h shared/command.h shared/iengine.h
engine/physics.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/physics.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/physics.o: engine/model.h engine/varray.h engine/mpr.h
engine/octaedit.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/octaedit.o: shared/ents.h shared/command.h shared/iengine.h
engine/octaedit.o: shared/igame.h engine/world.h engine/glexts.h
engine/octaedit.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/octaedit.o: engine/texture.h engine/model.h engine/varray.h
fpsgame/waypoint.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/waypoint.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/waypoint.o: shared/igame.h fpsgame/ai.h
fpsgame/monster.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/monster.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/monster.o: shared/igame.h fpsgame/ai.h
fpsgame/server.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/server.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/server.o: shared/igame.h fpsgame/ai.h fpsgame/capture.h fpsgame/ctf.h
fpsgame/server.o: fpsgame/collect.h fpsgame/extinfo.h fpsgame/aiman.h
fpsgame/fps.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/fps.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
fpsgame/fps.o: fpsgame/ai.h
fpsgame/ai.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/ai.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
fpsgame/ai.o: fpsgame/ai.h
fpsgame/movable.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/movable.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/movable.o: shared/igame.h fpsgame/ai.h
fpsgame/client.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/client.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/client.o: shared/igame.h fpsgame/ai.h fpsgame/capture.h fpsgame/ctf.h
fpsgame/client.o: fpsgame/collect.h
fpsgame/render.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/render.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/render.o: shared/igame.h fpsgame/ai.h
fpsgame/weapon.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/weapon.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/weapon.o: shared/igame.h fpsgame/ai.h
fpsgame/entities.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/entities.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/entities.o: shared/igame.h fpsgame/ai.h
fpsgame/scoreboard.o: fpsgame/game.h shared/cube.h shared/tools.h
fpsgame/scoreboard.o: shared/geom.h shared/ents.h shared/command.h
fpsgame/scoreboard.o: shared/iengine.h shared/igame.h fpsgame/ai.h
quirks/oldglibc32.o: quirks/wrapper.hpp
quirks/oldglibc64.o: quirks/wrapper.hpp

shared/tools.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/tools.o: shared/command.h shared/iengine.h shared/igame.h
shared/zip.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/zip.o: shared/command.h shared/iengine.h shared/igame.h
shared/geom.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/geom.o: shared/command.h shared/iengine.h shared/igame.h
shared/crypto.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/crypto.o: shared/command.h shared/iengine.h shared/igame.h
shared/stream.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/stream.o: shared/command.h shared/iengine.h shared/igame.h
engine/cubeloader.o: engine/engine.h shared/cube.h shared/tools.h
engine/cubeloader.o: shared/geom.h shared/ents.h shared/command.h
engine/cubeloader.o: shared/iengine.h shared/igame.h engine/world.h
engine/cubeloader.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/cubeloader.o: engine/bih.h engine/texture.h engine/model.h
engine/cubeloader.o: engine/varray.h
engine/renderparticles.o: engine/engine.h shared/cube.h shared/tools.h
engine/renderparticles.o: shared/geom.h shared/ents.h shared/command.h
engine/renderparticles.o: shared/iengine.h shared/igame.h engine/world.h
engine/renderparticles.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/renderparticles.o: engine/bih.h engine/texture.h engine/model.h
engine/renderparticles.o: engine/varray.h engine/rendertarget.h
engine/renderparticles.o: engine/depthfx.h engine/explosion.h
engine/renderparticles.o: engine/lensflare.h engine/lightning.h
engine/dynlight.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/dynlight.o: shared/ents.h shared/command.h shared/iengine.h
engine/dynlight.o: shared/igame.h engine/world.h engine/glexts.h
engine/dynlight.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/dynlight.o: engine/texture.h engine/model.h engine/varray.h
engine/command.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/command.o: shared/ents.h shared/command.h shared/iengine.h
engine/command.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/command.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/command.o: engine/model.h engine/varray.h
engine/console.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/console.o: shared/ents.h shared/command.h shared/iengine.h
engine/console.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/console.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/console.o: engine/model.h engine/varray.h
engine/console.o: engine/sdl2_keymap_extrakeys.h
engine/blob.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/blob.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
engine/blob.o: engine/world.h engine/glexts.h engine/octa.h engine/lightmap.h
engine/blob.o: engine/bih.h engine/texture.h engine/model.h engine/varray.h
engine/menus.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/menus.o: shared/ents.h shared/command.h shared/iengine.h
engine/menus.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/menus.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/menus.o: engine/model.h engine/varray.h
engine/rendersky.o: engine/engine.h shared/cube.h shared/tools.h
engine/rendersky.o: shared/geom.h shared/ents.h shared/command.h
engine/rendersky.o: shared/iengine.h shared/igame.h engine/world.h
engine/rendersky.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/rendersky.o: engine/bih.h engine/texture.h engine/model.h
engine/rendersky.o: engine/varray.h
engine/server.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/server.o: shared/ents.h shared/command.h shared/iengine.h
engine/server.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/server.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/server.o: engine/model.h engine/varray.h
engine/rendermodel.o: engine/engine.h shared/cube.h shared/tools.h
engine/rendermodel.o: shared/geom.h shared/ents.h shared/command.h
engine/rendermodel.o: shared/iengine.h shared/igame.h engine/world.h
engine/rendermodel.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/rendermodel.o: engine/bih.h engine/texture.h engine/model.h
engine/rendermodel.o: engine/varray.h engine/ragdoll.h engine/animmodel.h
engine/rendermodel.o: engine/vertmodel.h engine/skelmodel.h engine/md2.h
engine/rendermodel.o: engine/md3.h engine/md5.h engine/obj.h engine/smd.h
engine/rendermodel.o: engine/iqm.h
engine/rendertext.o: engine/engine.h shared/cube.h shared/tools.h
engine/rendertext.o: shared/geom.h shared/ents.h shared/command.h
engine/rendertext.o: shared/iengine.h shared/igame.h engine/world.h
engine/rendertext.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/rendertext.o: engine/bih.h engine/texture.h engine/model.h
engine/rendertext.o: engine/varray.h
engine/worldio.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/worldio.o: shared/ents.h shared/command.h shared/iengine.h
engine/worldio.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/worldio.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/worldio.o: engine/model.h engine/varray.h
engine/sound.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/sound.o: shared/ents.h shared/command.h shared/iengine.h
engine/sound.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/sound.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/sound.o: engine/model.h engine/varray.h
engine/master.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
engine/master.o: shared/command.h shared/iengine.h shared/igame.h
engine/serverbrowser.o: engine/engine.h shared/cube.h shared/tools.h
engine/serverbrowser.o: shared/geom.h shared/ents.h shared/command.h
engine/serverbrowser.o: shared/iengine.h shared/igame.h engine/world.h
engine/serverbrowser.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/serverbrowser.o: engine/bih.h engine/texture.h engine/model.h
engine/serverbrowser.o: engine/varray.h
engine/world.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/world.o: shared/ents.h shared/command.h shared/iengine.h
engine/world.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/world.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/world.o: engine/model.h engine/varray.h
engine/pvs.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/pvs.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
engine/pvs.o: engine/world.h engine/glexts.h engine/octa.h engine/lightmap.h
engine/pvs.o: engine/bih.h engine/texture.h engine/model.h engine/varray.h
engine/renderva.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/renderva.o: shared/ents.h shared/command.h shared/iengine.h
engine/renderva.o: shared/igame.h engine/world.h engine/glexts.h
engine/renderva.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/renderva.o: engine/texture.h engine/model.h engine/varray.h
engine/client.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/client.o: shared/ents.h shared/command.h shared/iengine.h
engine/client.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/client.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/client.o: engine/model.h engine/varray.h
engine/water.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/water.o: shared/ents.h shared/command.h shared/iengine.h
engine/water.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/water.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/water.o: engine/model.h engine/varray.h
engine/material.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/material.o: shared/ents.h shared/command.h shared/iengine.h
engine/material.o: shared/igame.h engine/world.h engine/glexts.h
engine/material.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/material.o: engine/texture.h engine/model.h engine/varray.h
engine/lightmap.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/lightmap.o: shared/ents.h shared/command.h shared/iengine.h
engine/lightmap.o: shared/igame.h engine/world.h engine/glexts.h
engine/lightmap.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/lightmap.o: engine/texture.h engine/model.h engine/varray.h
engine/octa.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/octa.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
engine/octa.o: engine/world.h engine/glexts.h engine/octa.h engine/lightmap.h
engine/octa.o: engine/bih.h engine/texture.h engine/model.h engine/varray.h
engine/grass.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/grass.o: shared/ents.h shared/command.h shared/iengine.h
engine/grass.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/grass.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/grass.o: engine/model.h engine/varray.h
engine/bih.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/bih.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
engine/bih.o: engine/world.h engine/glexts.h engine/octa.h engine/lightmap.h
engine/bih.o: engine/bih.h engine/texture.h engine/model.h engine/varray.h
engine/3dgui.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/3dgui.o: shared/ents.h shared/command.h shared/iengine.h
engine/3dgui.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/3dgui.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/3dgui.o: engine/model.h engine/varray.h engine/textedit.h
engine/glare.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/glare.o: shared/ents.h shared/command.h shared/iengine.h
engine/glare.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/glare.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/glare.o: engine/model.h engine/varray.h engine/rendertarget.h
engine/movie.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/movie.o: shared/ents.h shared/command.h shared/iengine.h
engine/movie.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/movie.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/movie.o: engine/model.h engine/varray.h
engine/normal.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/normal.o: shared/ents.h shared/command.h shared/iengine.h
engine/normal.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/normal.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/normal.o: engine/model.h engine/varray.h
engine/main.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/main.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
engine/main.o: engine/world.h engine/glexts.h engine/octa.h engine/lightmap.h
engine/main.o: engine/bih.h engine/texture.h engine/model.h engine/varray.h
engine/main.o: engine/sdosscripts.h
engine/octarender.o: engine/engine.h shared/cube.h shared/tools.h
engine/octarender.o: shared/geom.h shared/ents.h shared/command.h
engine/octarender.o: shared/iengine.h shared/igame.h engine/world.h
engine/octarender.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/octarender.o: engine/bih.h engine/texture.h engine/model.h
engine/octarender.o: engine/varray.h
engine/shader.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/shader.o: shared/ents.h shared/command.h shared/iengine.h
engine/shader.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/shader.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/shader.o: engine/model.h engine/varray.h
engine/texture.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/texture.o: shared/ents.h shared/command.h shared/iengine.h
engine/texture.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/texture.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/texture.o: engine/model.h engine/varray.h engine/scale.h
engine/blend.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/blend.o: shared/ents.h shared/command.h shared/iengine.h
engine/blend.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/blend.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/blend.o: engine/model.h engine/varray.h
engine/decal.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/decal.o: shared/ents.h shared/command.h shared/iengine.h
engine/decal.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/decal.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/decal.o: engine/model.h engine/varray.h
engine/rendergl.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/rendergl.o: shared/ents.h shared/command.h shared/iengine.h
engine/rendergl.o: shared/igame.h engine/world.h engine/glexts.h
engine/rendergl.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/rendergl.o: engine/texture.h engine/model.h engine/varray.h
engine/shadowmap.o: engine/engine.h shared/cube.h shared/tools.h
engine/shadowmap.o: shared/geom.h shared/ents.h shared/command.h
engine/shadowmap.o: shared/iengine.h shared/igame.h engine/world.h
engine/shadowmap.o: engine/glexts.h engine/octa.h engine/lightmap.h
engine/shadowmap.o: engine/bih.h engine/texture.h engine/model.h
engine/shadowmap.o: engine/varray.h engine/rendertarget.h
engine/physics.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/physics.o: shared/ents.h shared/command.h shared/iengine.h
engine/physics.o: shared/igame.h engine/world.h engine/glexts.h engine/octa.h
engine/physics.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/physics.o: engine/model.h engine/varray.h engine/mpr.h
engine/octaedit.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/octaedit.o: shared/ents.h shared/command.h shared/iengine.h
engine/octaedit.o: shared/igame.h engine/world.h engine/glexts.h
engine/octaedit.o: engine/octa.h engine/lightmap.h engine/bih.h
engine/octaedit.o: engine/texture.h engine/model.h engine/varray.h
fpsgame/waypoint.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/waypoint.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/waypoint.o: shared/igame.h fpsgame/ai.h
fpsgame/monster.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/monster.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/monster.o: shared/igame.h fpsgame/ai.h
fpsgame/server.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/server.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/server.o: shared/igame.h fpsgame/ai.h fpsgame/capture.h fpsgame/ctf.h
fpsgame/server.o: fpsgame/collect.h fpsgame/extinfo.h fpsgame/aiman.h
fpsgame/fps.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/fps.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
fpsgame/fps.o: fpsgame/ai.h
fpsgame/ai.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/ai.o: shared/ents.h shared/command.h shared/iengine.h shared/igame.h
fpsgame/ai.o: fpsgame/ai.h
fpsgame/movable.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/movable.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/movable.o: shared/igame.h fpsgame/ai.h
fpsgame/client.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/client.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/client.o: shared/igame.h fpsgame/ai.h fpsgame/capture.h fpsgame/ctf.h
fpsgame/client.o: fpsgame/collect.h
fpsgame/render.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/render.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/render.o: shared/igame.h fpsgame/ai.h
fpsgame/weapon.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/weapon.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/weapon.o: shared/igame.h fpsgame/ai.h
fpsgame/entities.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/entities.o: shared/ents.h shared/command.h shared/iengine.h
fpsgame/entities.o: shared/igame.h fpsgame/ai.h
fpsgame/scoreboard.o: fpsgame/game.h shared/cube.h shared/tools.h
fpsgame/scoreboard.o: shared/geom.h shared/ents.h shared/command.h
fpsgame/scoreboard.o: shared/iengine.h shared/igame.h fpsgame/ai.h
quirks/oldglibc32.o: quirks/wrapper.hpp
quirks/oldglibc64.o: quirks/wrapper.hpp
