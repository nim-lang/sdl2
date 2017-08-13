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
TODO

# Installation
Add the `sdl2` nim package to your nimble package configuration, or install it by hand using `nimble install`. For more information on using nimble, consult [the nim documentation](https://nim-lang.org/docs/lib.html#nimble).
