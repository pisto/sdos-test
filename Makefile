include deps/platform.mk

override CFLAGS+= -Ideps/$(DEPSNAME)/include/SDL2 -Ishared -Iengine -Ifpsgame -Imod -Wall -fsigned-char
override CXXFLAGS+= -Ideps/$(DEPSNAME)/include/SDL2 -Ishared -Iengine -Ifpsgame -Imod -std=gnu++14 -Wall -fsigned-char -fno-exceptions -fno-rtti
ifneq (,$(findstring -ggdb,$(CXXFLAGS)))
  STRIP=true
  UPX=true
else
  UPX=upx
endif

CLIENT_OBJS:= \
	shared/crypto.o \
	shared/geom.o \
	shared/glemu.o \
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
	mod/ipbuf.o mod/proxy-detection.o mod/version.o \
	datazip.o

mod/version.o:
	{ echo "int SAUERSVNREV = 5296; const char* WCREVISION = "\"`git rev-parse --short HEAD` `git show -s --format=%ci`\"\;; } | $(CC) $(CFLAGS) -x c -c -o mod/version.o -

ifdef WINDOWS
override LDFLAGS+= -mwindows
override LIBS+= -lenet -lSDL2 -lSDL2_image -ljpeg -lpng -lz -lSDL2_mixer -logg -lvorbis -lvorbisfile -lws2_32 -lwinmm -lopengl32 -ldxguid -lgdi32 -lole32 -limm32 -lversion -loleaut32 -lcurl -lssl -lcrypto -lGeoIP -static-libgcc -static-libstdc++
endif

ifdef LINUX
override LIBS+= -lGL -lenet -lSDL2 -lSDL2_image -ljpeg -lpng -lz -lSDL2_mixer -logg -lvorbis -lvorbisfile -lcurl -lssl -lcrypto -lGeoIP -lm -ldl
endif

ifdef MAC
override LIBS+= -lenet -lSDL2 -lSDL2_image -ljpeg -lpng -lz -lSDL2_mixer -logg -lvorbis -lvorbisfile -lcurl -lssl -lcrypto -lGeoIP -framework IOKit -framework Cocoa -framework CoreVideo -framework Carbon -framework CoreAudio -framework OpenGL -framework AudioUnit -lm -ldl
endif

data.zip:
	cd data-svn && zip -qr9 ../data.zip *

datazip.o: data.zip
	xxd -i data.zip - | $(CC) $(CFLAGS) -x c -c -o datazip.o -

ifdef WINDOWS
client: $(CLIENT_OBJS)
	$(WINDRES) -I vcpp -i vcpp/mingw.rc -J rc -o vcpp/mingw.res -O coff 
	$(CXX) -static $(CXXFLAGS) $(LDFLAGS) -o sauerbraten.exe vcpp/mingw.res $(CLIENT_OBJS) -Wl,--as-needed -Wl,--start-group $(LIBS) -Wl,--end-group
	$(STRIP) sauerbraten.exe
	-$(UPX) sauerbraten.exe
endif

ifdef MAC

client:	$(CLIENT_OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o sauerbraten $(CLIENT_OBJS) $(LIBS)
	$(STRIP) sauerbraten
	-$(UPX) sauerbraten
endif

ifdef LINUX
client:	$(CLIENT_OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o sauer_client $(CLIENT_OBJS) -Wl,--as-needed -Wl,--start-group $(LIBS) -lrt -Wl,--end-group
	$(STRIP) sauer_client
ifneq ($(STRIP),true)
	-$(UPX) sauer_client
endif
endif

clean:
	-$(RM) -r $(CLIENT_OBJS) data.zip sauer_client sauerbraten sauerbraten.exe vcpp/mingw.res

makedepend:
	makedepend -a -Y -Ishared -Iengine -Ifpsgame -Imod $(CLIENT_OBJS:.o=.cpp)

.DEFAULT_GOAL := client
.PHONY := makedepend clean mod/version.o

# DO NOT DELETE

shared/crypto.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/crypto.o: shared/command.h shared/glexts.h shared/glemu.h
shared/crypto.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
shared/crypto.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
shared/crypto.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
shared/crypto.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
shared/crypto.o: mod/plugin.h shared/igame.h
shared/geom.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/geom.o: shared/command.h shared/glexts.h shared/glemu.h
shared/geom.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
shared/geom.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
shared/geom.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
shared/geom.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
shared/geom.o: mod/plugin.h shared/igame.h
shared/glemu.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/glemu.o: shared/command.h shared/glexts.h shared/glemu.h
shared/glemu.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
shared/glemu.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
shared/glemu.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
shared/glemu.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
shared/glemu.o: mod/plugin.h shared/igame.h
shared/stream.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/stream.o: shared/command.h shared/glexts.h shared/glemu.h
shared/stream.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
shared/stream.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
shared/stream.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
shared/stream.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
shared/stream.o: mod/plugin.h shared/igame.h
shared/tools.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/tools.o: shared/command.h shared/glexts.h shared/glemu.h
shared/tools.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
shared/tools.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
shared/tools.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
shared/tools.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
shared/tools.o: mod/plugin.h shared/igame.h
shared/zip.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
shared/zip.o: shared/command.h shared/glexts.h shared/glemu.h
shared/zip.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
shared/zip.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
shared/zip.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
shared/zip.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
shared/zip.o: shared/igame.h
engine/3dgui.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/3dgui.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/3dgui.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/3dgui.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/3dgui.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/3dgui.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/3dgui.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/3dgui.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/3dgui.o: engine/model.h engine/textedit.h
engine/bih.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/bih.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/bih.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/bih.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
engine/bih.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
engine/bih.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
engine/bih.o: shared/igame.h engine/world.h engine/octa.h engine/lightmap.h
engine/bih.o: engine/bih.h engine/texture.h engine/model.h
engine/blend.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/blend.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/blend.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/blend.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/blend.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/blend.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/blend.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/blend.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/blend.o: engine/model.h
engine/blob.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/blob.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/blob.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/blob.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/blob.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/blob.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/blob.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/blob.o: engine/lightmap.h engine/bih.h engine/texture.h engine/model.h
engine/client.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/client.o: shared/ents.h shared/command.h shared/glexts.h
engine/client.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/client.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/client.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/client.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/client.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/client.o: engine/world.h engine/octa.h engine/lightmap.h engine/bih.h
engine/client.o: engine/texture.h engine/model.h
engine/command.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/command.o: shared/ents.h shared/command.h shared/glexts.h
engine/command.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/command.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/command.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/command.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/command.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/command.o: engine/world.h engine/octa.h engine/lightmap.h engine/bih.h
engine/command.o: engine/texture.h engine/model.h
engine/console.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/console.o: shared/ents.h shared/command.h shared/glexts.h
engine/console.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/console.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/console.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/console.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/console.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/console.o: engine/world.h engine/octa.h engine/lightmap.h engine/bih.h
engine/console.o: engine/texture.h engine/model.h
engine/cubeloader.o: engine/engine.h shared/cube.h shared/tools.h
engine/cubeloader.o: shared/geom.h shared/ents.h shared/command.h
engine/cubeloader.o: shared/glexts.h shared/glemu.h shared/iengine.h
engine/cubeloader.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/cubeloader.o: mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
engine/cubeloader.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/cubeloader.o: mod/chat.h mod/events.h mod/thread.h
engine/cubeloader.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/cubeloader.o: engine/world.h engine/octa.h engine/lightmap.h
engine/cubeloader.o: engine/bih.h engine/texture.h engine/model.h
engine/decal.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/decal.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/decal.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/decal.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/decal.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/decal.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/decal.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/decal.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/decal.o: engine/model.h
engine/dynlight.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/dynlight.o: shared/ents.h shared/command.h shared/glexts.h
engine/dynlight.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/dynlight.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/dynlight.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/dynlight.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/dynlight.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/dynlight.o: engine/world.h engine/octa.h engine/lightmap.h
engine/dynlight.o: engine/bih.h engine/texture.h engine/model.h
engine/glare.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/glare.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/glare.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/glare.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/glare.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/glare.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/glare.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/glare.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/glare.o: engine/model.h engine/rendertarget.h
engine/grass.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/grass.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/grass.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/grass.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/grass.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/grass.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/grass.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/grass.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/grass.o: engine/model.h
engine/lightmap.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/lightmap.o: shared/ents.h shared/command.h shared/glexts.h
engine/lightmap.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/lightmap.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/lightmap.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/lightmap.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/lightmap.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/lightmap.o: engine/world.h engine/octa.h engine/lightmap.h
engine/lightmap.o: engine/bih.h engine/texture.h engine/model.h
engine/main.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/main.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/main.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/main.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/main.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/main.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/main.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/main.o: engine/lightmap.h engine/bih.h engine/texture.h engine/model.h
engine/material.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/material.o: shared/ents.h shared/command.h shared/glexts.h
engine/material.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/material.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/material.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/material.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/material.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/material.o: engine/world.h engine/octa.h engine/lightmap.h
engine/material.o: engine/bih.h engine/texture.h engine/model.h
engine/menus.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/menus.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/menus.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/menus.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/menus.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/menus.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/menus.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/menus.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/menus.o: engine/model.h
engine/movie.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/movie.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/movie.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/movie.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/movie.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/movie.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/movie.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/movie.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/movie.o: engine/model.h
engine/normal.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/normal.o: shared/ents.h shared/command.h shared/glexts.h
engine/normal.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/normal.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/normal.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/normal.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/normal.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/normal.o: engine/world.h engine/octa.h engine/lightmap.h engine/bih.h
engine/normal.o: engine/texture.h engine/model.h
engine/octa.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/octa.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/octa.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/octa.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/octa.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/octa.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/octa.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/octa.o: engine/lightmap.h engine/bih.h engine/texture.h engine/model.h
engine/octaedit.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/octaedit.o: shared/ents.h shared/command.h shared/glexts.h
engine/octaedit.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/octaedit.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/octaedit.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/octaedit.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/octaedit.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/octaedit.o: engine/world.h engine/octa.h engine/lightmap.h
engine/octaedit.o: engine/bih.h engine/texture.h engine/model.h
engine/octarender.o: engine/engine.h shared/cube.h shared/tools.h
engine/octarender.o: shared/geom.h shared/ents.h shared/command.h
engine/octarender.o: shared/glexts.h shared/glemu.h shared/iengine.h
engine/octarender.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/octarender.o: mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
engine/octarender.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/octarender.o: mod/chat.h mod/events.h mod/thread.h
engine/octarender.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/octarender.o: engine/world.h engine/octa.h engine/lightmap.h
engine/octarender.o: engine/bih.h engine/texture.h engine/model.h
engine/physics.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/physics.o: shared/ents.h shared/command.h shared/glexts.h
engine/physics.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/physics.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/physics.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/physics.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/physics.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/physics.o: engine/world.h engine/octa.h engine/lightmap.h engine/bih.h
engine/physics.o: engine/texture.h engine/model.h engine/mpr.h
engine/pvs.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/pvs.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/pvs.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/pvs.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
engine/pvs.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
engine/pvs.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
engine/pvs.o: shared/igame.h engine/world.h engine/octa.h engine/lightmap.h
engine/pvs.o: engine/bih.h engine/texture.h engine/model.h
engine/rendergl.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/rendergl.o: shared/ents.h shared/command.h shared/glexts.h
engine/rendergl.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/rendergl.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/rendergl.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/rendergl.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/rendergl.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/rendergl.o: engine/world.h engine/octa.h engine/lightmap.h
engine/rendergl.o: engine/bih.h engine/texture.h engine/model.h
engine/rendermodel.o: engine/engine.h shared/cube.h shared/tools.h
engine/rendermodel.o: shared/geom.h shared/ents.h shared/command.h
engine/rendermodel.o: shared/glexts.h shared/glemu.h shared/iengine.h
engine/rendermodel.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/rendermodel.o: mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
engine/rendermodel.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/rendermodel.o: mod/chat.h mod/events.h mod/thread.h
engine/rendermodel.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/rendermodel.o: engine/world.h engine/octa.h engine/lightmap.h
engine/rendermodel.o: engine/bih.h engine/texture.h engine/model.h
engine/rendermodel.o: engine/ragdoll.h engine/animmodel.h engine/vertmodel.h
engine/rendermodel.o: engine/skelmodel.h engine/md2.h engine/md3.h
engine/rendermodel.o: engine/md5.h engine/obj.h engine/smd.h engine/iqm.h
engine/renderparticles.o: engine/engine.h shared/cube.h shared/tools.h
engine/renderparticles.o: shared/geom.h shared/ents.h shared/command.h
engine/renderparticles.o: shared/glexts.h shared/glemu.h shared/iengine.h
engine/renderparticles.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/renderparticles.o: mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
engine/renderparticles.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/renderparticles.o: mod/chat.h mod/events.h mod/thread.h
engine/renderparticles.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/renderparticles.o: engine/world.h engine/octa.h engine/lightmap.h
engine/renderparticles.o: engine/bih.h engine/texture.h engine/model.h
engine/renderparticles.o: engine/rendertarget.h engine/depthfx.h
engine/renderparticles.o: engine/explosion.h engine/lensflare.h
engine/renderparticles.o: engine/lightning.h
engine/rendersky.o: engine/engine.h shared/cube.h shared/tools.h
engine/rendersky.o: shared/geom.h shared/ents.h shared/command.h
engine/rendersky.o: shared/glexts.h shared/glemu.h shared/iengine.h
engine/rendersky.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/rendersky.o: mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
engine/rendersky.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/rendersky.o: mod/chat.h mod/events.h mod/thread.h
engine/rendersky.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/rendersky.o: engine/world.h engine/octa.h engine/lightmap.h
engine/rendersky.o: engine/bih.h engine/texture.h engine/model.h
engine/rendertext.o: engine/engine.h shared/cube.h shared/tools.h
engine/rendertext.o: shared/geom.h shared/ents.h shared/command.h
engine/rendertext.o: shared/glexts.h shared/glemu.h shared/iengine.h
engine/rendertext.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/rendertext.o: mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
engine/rendertext.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/rendertext.o: mod/chat.h mod/events.h mod/thread.h
engine/rendertext.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/rendertext.o: engine/world.h engine/octa.h engine/lightmap.h
engine/rendertext.o: engine/bih.h engine/texture.h engine/model.h
engine/renderva.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/renderva.o: shared/ents.h shared/command.h shared/glexts.h
engine/renderva.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/renderva.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/renderva.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/renderva.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/renderva.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/renderva.o: engine/world.h engine/octa.h engine/lightmap.h
engine/renderva.o: engine/bih.h engine/texture.h engine/model.h
engine/server.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/server.o: shared/ents.h shared/command.h shared/glexts.h
engine/server.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/server.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/server.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/server.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/server.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/server.o: engine/world.h engine/octa.h engine/lightmap.h engine/bih.h
engine/server.o: engine/texture.h engine/model.h
engine/serverbrowser.o: engine/engine.h shared/cube.h shared/tools.h
engine/serverbrowser.o: shared/geom.h shared/ents.h shared/command.h
engine/serverbrowser.o: shared/glexts.h shared/glemu.h shared/iengine.h
engine/serverbrowser.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/serverbrowser.o: mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
engine/serverbrowser.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/serverbrowser.o: mod/chat.h mod/events.h mod/thread.h
engine/serverbrowser.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/serverbrowser.o: engine/world.h engine/octa.h engine/lightmap.h
engine/serverbrowser.o: engine/bih.h engine/texture.h engine/model.h
engine/shader.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/shader.o: shared/ents.h shared/command.h shared/glexts.h
engine/shader.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/shader.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/shader.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/shader.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/shader.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/shader.o: engine/world.h engine/octa.h engine/lightmap.h engine/bih.h
engine/shader.o: engine/texture.h engine/model.h
engine/shadowmap.o: engine/engine.h shared/cube.h shared/tools.h
engine/shadowmap.o: shared/geom.h shared/ents.h shared/command.h
engine/shadowmap.o: shared/glexts.h shared/glemu.h shared/iengine.h
engine/shadowmap.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
engine/shadowmap.o: mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
engine/shadowmap.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/shadowmap.o: mod/chat.h mod/events.h mod/thread.h
engine/shadowmap.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/shadowmap.o: engine/world.h engine/octa.h engine/lightmap.h
engine/shadowmap.o: engine/bih.h engine/texture.h engine/model.h
engine/shadowmap.o: engine/rendertarget.h
engine/sound.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/sound.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/sound.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/sound.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/sound.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/sound.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/sound.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/sound.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/sound.o: engine/model.h
engine/texture.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/texture.o: shared/ents.h shared/command.h shared/glexts.h
engine/texture.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/texture.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/texture.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/texture.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/texture.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/texture.o: engine/world.h engine/octa.h engine/lightmap.h engine/bih.h
engine/texture.o: engine/texture.h engine/model.h engine/scale.h
engine/water.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/water.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/water.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/water.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/water.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/water.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/water.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/water.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/water.o: engine/model.h
engine/world.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/world.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
engine/world.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
engine/world.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
engine/world.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
engine/world.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
engine/world.o: mod/plugin.h shared/igame.h engine/world.h engine/octa.h
engine/world.o: engine/lightmap.h engine/bih.h engine/texture.h
engine/world.o: engine/model.h
engine/worldio.o: engine/engine.h shared/cube.h shared/tools.h shared/geom.h
engine/worldio.o: shared/ents.h shared/command.h shared/glexts.h
engine/worldio.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
engine/worldio.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
engine/worldio.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
engine/worldio.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
engine/worldio.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
engine/worldio.o: engine/world.h engine/octa.h engine/lightmap.h engine/bih.h
engine/worldio.o: engine/texture.h engine/model.h
fpsgame/ai.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/ai.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
fpsgame/ai.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
fpsgame/ai.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
fpsgame/ai.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
fpsgame/ai.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
fpsgame/ai.o: shared/igame.h fpsgame/ai.h
fpsgame/client.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/client.o: shared/ents.h shared/command.h shared/glexts.h
fpsgame/client.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
fpsgame/client.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
fpsgame/client.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
fpsgame/client.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/client.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/client.o: fpsgame/ai.h fpsgame/capture.h fpsgame/ctf.h
fpsgame/client.o: fpsgame/collect.h mod/cubescript.h
fpsgame/entities.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/entities.o: shared/ents.h shared/command.h shared/glexts.h
fpsgame/entities.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
fpsgame/entities.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
fpsgame/entities.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
fpsgame/entities.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/entities.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/entities.o: fpsgame/ai.h
fpsgame/fps.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/fps.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
fpsgame/fps.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
fpsgame/fps.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
fpsgame/fps.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
fpsgame/fps.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
fpsgame/fps.o: mod/plugin.h shared/igame.h fpsgame/ai.h
fpsgame/monster.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/monster.o: shared/ents.h shared/command.h shared/glexts.h
fpsgame/monster.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
fpsgame/monster.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
fpsgame/monster.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
fpsgame/monster.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/monster.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/monster.o: fpsgame/ai.h
fpsgame/movable.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/movable.o: shared/ents.h shared/command.h shared/glexts.h
fpsgame/movable.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
fpsgame/movable.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
fpsgame/movable.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
fpsgame/movable.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/movable.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/movable.o: fpsgame/ai.h
fpsgame/render.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/render.o: shared/ents.h shared/command.h shared/glexts.h
fpsgame/render.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
fpsgame/render.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
fpsgame/render.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
fpsgame/render.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/render.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/render.o: fpsgame/ai.h
fpsgame/scoreboard.o: fpsgame/game.h shared/cube.h shared/tools.h
fpsgame/scoreboard.o: shared/geom.h shared/ents.h shared/command.h
fpsgame/scoreboard.o: shared/glexts.h shared/glemu.h shared/iengine.h
fpsgame/scoreboard.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
fpsgame/scoreboard.o: mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
fpsgame/scoreboard.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h
fpsgame/scoreboard.o: mod/chat.h mod/events.h mod/thread.h
fpsgame/scoreboard.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/scoreboard.o: fpsgame/ai.h
fpsgame/server.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/server.o: shared/ents.h shared/command.h shared/glexts.h
fpsgame/server.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
fpsgame/server.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
fpsgame/server.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
fpsgame/server.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/server.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/server.o: fpsgame/ai.h fpsgame/capture.h fpsgame/ctf.h
fpsgame/server.o: fpsgame/collect.h fpsgame/aiman.h
fpsgame/waypoint.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/waypoint.o: shared/ents.h shared/command.h shared/glexts.h
fpsgame/waypoint.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
fpsgame/waypoint.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
fpsgame/waypoint.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
fpsgame/waypoint.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/waypoint.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/waypoint.o: fpsgame/ai.h
fpsgame/weapon.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
fpsgame/weapon.o: shared/ents.h shared/command.h shared/glexts.h
fpsgame/weapon.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
fpsgame/weapon.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
fpsgame/weapon.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
fpsgame/weapon.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
fpsgame/weapon.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
fpsgame/weapon.o: fpsgame/ai.h
mod/plugin.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/plugin.o: shared/command.h shared/glexts.h shared/glemu.h
mod/plugin.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
mod/plugin.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
mod/plugin.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/plugin.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/plugin.o: shared/igame.h
mod/demorecorder.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/demorecorder.o: shared/ents.h shared/command.h shared/glexts.h
mod/demorecorder.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
mod/demorecorder.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/demorecorder.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
mod/demorecorder.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
mod/demorecorder.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
mod/demorecorder.o: fpsgame/ai.h
mod/chat.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/chat.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
mod/chat.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
mod/chat.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
mod/chat.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/chat.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/chat.o: shared/igame.h fpsgame/ai.h mod/chat-ca-certs.h
mod/events.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/events.o: shared/command.h shared/glexts.h shared/glemu.h
mod/events.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
mod/events.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
mod/events.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/events.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/events.o: shared/igame.h
mod/extinfo.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/extinfo.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
mod/extinfo.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
mod/extinfo.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
mod/extinfo.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
mod/extinfo.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
mod/extinfo.o: mod/plugin.h shared/igame.h fpsgame/ai.h
mod/gamemod.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/gamemod.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
mod/gamemod.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
mod/gamemod.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
mod/gamemod.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
mod/gamemod.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
mod/gamemod.o: mod/plugin.h shared/igame.h fpsgame/ai.h
mod/geoip.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/geoip.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
mod/geoip.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
mod/geoip.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
mod/geoip.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/geoip.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/geoip.o: shared/igame.h fpsgame/ai.h
mod/ipignore.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/ipignore.o: shared/ents.h shared/command.h shared/glexts.h shared/glemu.h
mod/ipignore.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
mod/ipignore.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
mod/ipignore.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
mod/ipignore.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
mod/ipignore.o: mod/plugin.h shared/igame.h fpsgame/ai.h
mod/mod.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/mod.o: shared/command.h shared/glexts.h shared/glemu.h shared/iengine.h
mod/mod.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
mod/mod.o: mod/ipbuf.h mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
mod/mod.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
mod/mod.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
mod/cubescript.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/cubescript.o: shared/ents.h shared/command.h shared/glexts.h
mod/cubescript.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
mod/cubescript.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/cubescript.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
mod/cubescript.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
mod/cubescript.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
mod/cubescript.o: fpsgame/ai.h
mod/hwdisplay.o: fpsgame/game.h shared/cube.h shared/tools.h shared/geom.h
mod/hwdisplay.o: shared/ents.h shared/command.h shared/glexts.h
mod/hwdisplay.o: shared/glemu.h shared/iengine.h mod/compat.h mod/mod.h
mod/hwdisplay.o: mod/compiler.h mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/hwdisplay.o: mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
mod/hwdisplay.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
mod/hwdisplay.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
mod/hwdisplay.o: fpsgame/ai.h
mod/playerdisplay.o: fpsgame/game.h shared/cube.h shared/tools.h
mod/playerdisplay.o: shared/geom.h shared/ents.h shared/command.h
mod/playerdisplay.o: shared/glexts.h shared/glemu.h shared/iengine.h
mod/playerdisplay.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
mod/playerdisplay.o: mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
mod/playerdisplay.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h
mod/playerdisplay.o: mod/chat.h mod/events.h mod/thread.h
mod/playerdisplay.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
mod/playerdisplay.o: fpsgame/ai.h
mod/http.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/http.o: shared/command.h shared/glexts.h shared/glemu.h shared/iengine.h
mod/http.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
mod/http.o: mod/ipbuf.h mod/gamemod.h mod/http.h mod/ipignore.h mod/extinfo.h
mod/http.o: mod/demorecorder.h mod/chat.h mod/events.h mod/thread.h
mod/http.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
mod/strtool.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/strtool.o: shared/command.h shared/glexts.h shared/glemu.h
mod/strtool.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
mod/strtool.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h
mod/strtool.o: mod/http.h mod/ipignore.h mod/extinfo.h mod/demorecorder.h
mod/strtool.o: mod/chat.h mod/events.h mod/thread.h mod/proxy-detection.h
mod/strtool.o: mod/plugin.h shared/igame.h
mod/crypto.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/crypto.o: shared/command.h shared/glexts.h shared/glemu.h
mod/crypto.o: shared/iengine.h mod/compat.h mod/mod.h mod/compiler.h
mod/crypto.o: mod/strtool.h mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
mod/crypto.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/crypto.o: mod/events.h mod/thread.h mod/proxy-detection.h mod/plugin.h
mod/crypto.o: shared/igame.h
mod/extinfo-playerpreview.o: fpsgame/game.h shared/cube.h shared/tools.h
mod/extinfo-playerpreview.o: shared/geom.h shared/ents.h shared/command.h
mod/extinfo-playerpreview.o: shared/glexts.h shared/glemu.h shared/iengine.h
mod/extinfo-playerpreview.o: mod/compat.h mod/mod.h mod/compiler.h
mod/extinfo-playerpreview.o: mod/strtool.h mod/crypto.h mod/ipbuf.h
mod/extinfo-playerpreview.o: mod/gamemod.h mod/http.h mod/ipignore.h
mod/extinfo-playerpreview.o: mod/extinfo.h mod/demorecorder.h mod/chat.h
mod/extinfo-playerpreview.o: mod/events.h mod/thread.h mod/proxy-detection.h
mod/extinfo-playerpreview.o: mod/plugin.h shared/igame.h fpsgame/ai.h
mod/ipbuf.o: shared/cube.h shared/tools.h shared/geom.h shared/ents.h
mod/ipbuf.o: shared/command.h shared/glexts.h shared/glemu.h shared/iengine.h
mod/ipbuf.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h mod/crypto.h
mod/ipbuf.o: mod/ipbuf.h mod/gamemod.h mod/http.h mod/ipignore.h
mod/ipbuf.o: mod/extinfo.h mod/demorecorder.h mod/chat.h mod/events.h
mod/ipbuf.o: mod/thread.h mod/proxy-detection.h mod/plugin.h shared/igame.h
mod/proxy-detection.o: fpsgame/game.h shared/cube.h shared/tools.h
mod/proxy-detection.o: shared/geom.h shared/ents.h shared/command.h
mod/proxy-detection.o: shared/glexts.h shared/glemu.h shared/iengine.h
mod/proxy-detection.o: mod/compat.h mod/mod.h mod/compiler.h mod/strtool.h
mod/proxy-detection.o: mod/crypto.h mod/ipbuf.h mod/gamemod.h mod/http.h
mod/proxy-detection.o: mod/ipignore.h mod/extinfo.h mod/demorecorder.h
mod/proxy-detection.o: mod/chat.h mod/events.h mod/thread.h
mod/proxy-detection.o: mod/proxy-detection.h mod/plugin.h shared/igame.h
mod/proxy-detection.o: fpsgame/ai.h
