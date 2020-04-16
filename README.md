# SDL2 for Nim
This package contains the bindings for SDL2 to Nim.

# Pre-requisites
You must install the SDL2 C libraries before these Nim bindings can be used.

## macOS with Homebrew
If you don't already have Homebrew installed, install it from [the Homebrew site](https://brew.sh/).

Install the SDL2 C libraries:

```bash
brew install sdl2{,_gfx,_image,_mixer,_net,_ttf}
```

## Linux
Install SDL2 development libraries using your distribution's packaging tool of choice.

## Windows
Using SDL2 with [mingw-w64](https://mingw-w64.org) environment
 * Install [mingw-w64-builds](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/installer/mingw-w64-install.exe). Check that `x86_64-w64-mingw32\bin\` from the installed mingw toolchain is in your `PATH` variable.
 * Download [SDL2 Development Libraries](https://www.libsdl.org/download-2.0.php) for MinGW
 * Extract contents of the downoaded archive to your mingw-w64 folder (for example, `SDL2-2.0.12\x86_64-w64-mingw32\` to `mingw-w64\x86_64-8.1.0-posix-seh-rt_v6-rev0\mingw64\x86_64-w64-mingw32\`)
 ### Static linking SDL2
 Pass the following options to nim on compilation:
 `--dynlibOverride:libSDL2 --passL:"-static -lmingw32 -lSDL2main -lSDL2 -mwindows  -Wl,--no-undefined -Wl,--dynamicbase -Wl,--nxcompat -Wl,--high-entropy-va -lm -ldinput8 -ldxguid -ldxerr8 -luser32 -lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lshell32 -lsetupapi -lversion -luuid"`
 Options for the linker (`--passL:`) except `-static` are taken from `sdl2-config.cmake` which is included in SDL2 Development Libraries.

# Installation
Add `requires "sdl2"` to your `.nimble` file.

You can also install manually with `nimble install sdl2` if your project does not yet have a nimble package file.

For more information on using nimble, consult [the nim documentation](https://nim-lang.org/docs/lib.html#nimble).

# Documentation
For documentation about SDL2 see [wiki.libsdl.org](https://wiki.libsdl.org/).
