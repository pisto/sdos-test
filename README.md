# SDoS Test Client #

-------

Thank you a lot for using the Sauerbraten Day of Sobriety Test Client!

Please help with testing by sending your feedback.

# What is this? #

This is test client is the foundation of what the anti-cheat client is
built on. It doesn't include any of the anti-cheat functions. The
reason it needs testing is that it uses SDL version 2 rather than
version 1, which the regular Sauerbraten client is built on. This
newer version of SDL brings many improvements that help with both the
normal game and the anti-cheat protections, but it is a major
change. Things could break. We need some help with testing.

You can play with this client on any normal server. It's meant to work
just like the normal sauer client, with some improvements.

# Installation #

The installation is the same as the acc client or the swlacc
builds. If you can't remember the procedure, you can refresh your
memory with the appropriate README in the archive.

# Testing #

The following is some sparse info of what you should consider while
testing. Reports of oddities or bad functioning are important, but
"everything works fine" is helpful too.

- SDL2 should provider saner behavior with minimization and general
  windowed or fullscreen gaming, input handling, and sounds playback.
  - variable `vsync` now is only 0 or 1 (-1 does not exist anymore)
  - <kbd>Ctrl+v</kbd> should finally work on most linux setups
  - Mouse input uses now the raw API (also known as "hardware mouse").
    This has the side effect that [Windows 8.1 mouse input should be fine](http://www.reddit.com/r/windows/comments/1oor43/windows_81_warning_for_gamers_issues_with/ "some reddit rant"). If
    for any reason you notice a difference, please report.
- The engine can be run in an almost [fps-independent mode](https://github.com/pisto/sdos-test#bonus-pro-setting-multipoll--101-low-latency-input "just a few lines down in this README")
- All dependent libraries are updated (and libjpeg is replace by
  libjpeg-turbo), recompiled and linked statically for better performance.
- New configuration variables should go to `sdos.cfg`, to avoid
    interfering with `config.cfg`
- `showfps 1` now uses a different internal logic: fps counting should
  be more precise and responsive, but the downside is that the refresh
  rate is now fixed to one second. Also, `showfpsrange 1` has no effect.
- The original client draws one smoke "flake" for each drawn frame in the
  trail of grenades and rockets. This means that a higher fps degrades
  visibility. There is now a variable `smokefps [0-200]` (default 80) which
  controls how many flakes can be drawn, for each trail, per second.
- Use `reducesparks 1` to eliminate the drawing of bullet collision sparks
  (ETERNALSOLSTICE wanted this so badly)
- `explosions 0` disables the explosion ball for grenades and rockets, for
  extra visibility
- Map load times should be greatly improved with `vsync 1`, to match load
  times without vsync.
- The original client had an synthetic extra lag of 15ms (in average)
  between the time you type text/hit/do any game action and when the
  packet itself is sent to the server. This has been fixed.

## Bonus pro setting : low latency, just-in-time VSYNC. ##

  Usually top players set `/vsync 0` and a suitable value of `/maxfps`
  to minimize input lag. This is because the standard Sauerbraten engine
  draws one frame for each engine update. This means that with `/vsync 1`,
  or a low framerate, the input lag gets to be substantial.

  I try to fix this problem by decoupling the engine refresh cycles from
  drawing, and running the two things in different threads: this means that
  while a frame is being drawn, the engine can keep running and poll input,
  work on network packets, etc. It is then possible to use `/vsync 1` to
  remove tearing, and still have acceptable input lag.

  This can be further improved by moving the start of the frame drawing, and
  so the game state read, as close as possible to the vsync, that is the start
  of the screen refresh. For a more in-depth discussion, please read
  [this nice explanation](http://www.quakeworld.nu/forum/topic/2444/vsync-lag-solution).
  The implementation I have now is referred in the topic as *just-in-time VSYNC ON*.
  Simply put, the drawer thread wakes up just in time to draw a frame (plus
  a safety margin to allow jitter in the frame draw time), and finish
  very close to vsync. The time lag between the start of the frame draw
  and the vsync should equal the real input lag, and this process should
  minimize it.

  To enable this experimental very-low-latency code, just use `/vsync 2`.
  There is just another parameter: `/jitvanticipate <value>`: it controls
  the safety marging of early wakeup of the drawer thread. A lower value
  minimizes input lag, but can cause a higher vsync miss.

  `/showfps 1` helps you in evaluating and tuning the just-in-time
  performance:

- fps: number of frames drawn (should equal the monitor refresh rate)
- lag x(y): x is the total input lag, y is the time wasted in waiting
  for vsync
- miss x(y): x is the number of vsync misses per second, y is the number
  of the resets of the timing engine (happens with a way too low value
  of `/jitvanticipate`, and cause microstutters)

  On my crappy hardware, I can get a stable input lag down to 3-4 ms
  with a 60 Hz LCD, which is much better than the frame display time (~16 ms).

# Giving Feedback #

Send feedback

- via email to pisto, blaffablaffa at gmail
- via irc in #sdos on Gamesurge

When giving a feedback, please include:

- some way to contact you back
- version of the test client you use
- build type (OS and 32/64 bit if applicable)
- graphic card model and driver, if related to the issue
- mouse model, if related to the issue
