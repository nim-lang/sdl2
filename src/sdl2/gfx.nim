# 
#
#SDL2_gfxPrimitives.h: graphics primitives for SDL
#
#Copyright (C) 2012  Andreas Schiffler
#
#This software is provided 'as-is', without any express or implied
#warranty. In no event will the authors be held liable for any damages
#arising from the use of this software.
#
#Permission is granted to anyone to use this software for any purpose,
#including commercial applications, and to alter it and redistribute it
#freely, subject to the following restrictions:
#
#1. The origin of this software must not be misrepresented; you must not
#claim that you wrote the original software. If you use this software
#in a product, an acknowledgment in the product documentation would be
#appreciated but is not required.
#
#2. Altered source versions must be plainly marked as such, and must not be
#misrepresented as being the original software.
#
#3. This notice may not be removed or altered from any source
#distribution.
#
#Andreas Schiffler -- aschiffler at ferzkopp dot net
#
#

import sdl2

when defined(Linux):
  const LibName = "libSDL2_gfx.so"
elif defined(macosx):
  const LibName = "libSDL2_gfx.dylib"
elif defined(Windows):
  const LibName = "SDL2_gfx.dll"
else: {.error.}


const 
  FPS_UPPER_LIMIT* = 200
  FPS_LOWER_LIMIT* = 1
  FPS_DEFAULT* = 30

type 
  TFPSmanager* {.pure, final.} = object 
    framecount*: cint
    rateticks*: cfloat
    baseticks*: cint
    lastticks*: cint
    rate*: cint

{.pragma: i, importc, discardable.}
{.push callConv:cdecl, dynlib: LibName.}

# ---- Function Prototypes 
# Note: all ___Color routines expect the color to be in format 0xRRGGBBAA 
# Pixel 
proc pixelColor*(renderer: PRenderer; x, y: int16; color: Uint32): SDL_Return {.importc, discardable.}
proc pixelRGBA*(renderer: PRenderer; x: int16; y: int16; r: Uint8; 
                g: Uint8; b: Uint8; a: Uint8): SDL_Return  {.importc, discardable.}
# Horizontal line 
proc hlineColor*(renderer: PRenderer; x1: int16; x2: int16; 
                 y: int16; color: Uint32): SDL_Return {.importc, discardable.}
proc hlineRGBA*(renderer: PRenderer; x1: int16; x2: int16; y: int16; 
                r,g,b,a: Uint8): SDL_Return {.importc, discardable.}
# Vertical line 
proc vlineColor*(renderer: PRenderer; x,y1,y2: int16; 
                  color: Uint32): SDL_Return {.importc, discardable.}
proc vlineRGBA*(renderer: PRenderer; x,y1,y2: int16; 
                r,g,b,a: Uint8): SDL_Return {.importc, discardable.}
# Rectangle 
proc rectangleColor*(renderer: PRenderer; x1,y1,x2,y2: int16; 
      color: Uint32): SDL_Return {.importc, discardable.}
proc rectangleRGBA*(renderer: PRenderer; x1,y1,x2,y2: int16; r,g,b,a: Uint8): SDL_Return {.
      importc, discardable.}
# Rounded-Corner Rectangle 
proc roundedRectangleColor*(renderer: PRenderer; x1,y1,x2,y2,rad: int16; 
                            color: Uint32): SDL_Return {.importc, discardable.}
proc roundedRectangleRGBA*(renderer: PRenderer; x1,y1,x2,y2,rad: int16; 
              r,g,b,a: Uint8): SDL_Return {.importc, discardable.}
# Filled rectangle (Box) 
proc boxColor*(renderer: PRenderer; x1, y1, x2, y2: int16; 
  color: Uint32): SDL_Return {.importc, discardable.}
proc boxRGBA*(renderer: PRenderer; x1, y1, x2, y2: int16; 
  r, g, b, a: Uint8): SDL_Return {.importc, discardable.}
# Rounded-Corner Filled rectangle (Box) 
proc roundedBoxColor*(renderer: PRenderer; x1,y1,x2,y2,rad: int16; 
                       color: Uint32): SDL_Return {.importc, discardable.}
proc roundedBoxRGBA*(renderer: PRenderer; x1,y1,x2,y2,rad: int16; 
                  r,g,b,a: Uint8): SDL_Return {.importc, discardable.}
# Line 
proc lineColor*(renderer: PRenderer; x1,y1,x2,y2: int16; 
    color: Uint32): SDL_Return {.importc, discardable.}
proc lineRGBA*(renderer: PRenderer; x1,y1,x2,y2: int16; r,g,b,a: Uint8): SDL_Return {.
  importc, discardable.}
# AA Line 
proc aalineColor*(renderer: PRenderer; x1: int16; y1: int16; 
                  x2: int16; y2: int16; color: Uint32): SDL_Return {.importc, discardable.}
proc aalineRGBA*(renderer: PRenderer; x1: int16; y1: int16; 
                 x2: int16; y2: int16; r: Uint8; g: Uint8; b: Uint8; 
                 a: Uint8): SDL_Return {.importc, discardable.}
# Thick Line 
proc thickLineColor*(renderer: PRenderer; x1, y1, x2, y2: int16; 
  width: Uint8; color: Uint32): SDL_Return {.importc, discardable.}
proc thickLineRGBA*(renderer: PRenderer; x1, y1, x2, y2: int16; 
  width, r, g, b, a: Uint8): SDL_Return {.importc, discardable.}
# Circle 
proc circleColor*(renderer: PRenderer; x, y, rad: int16; 
  color: Uint32): SDL_Return {.importc, discardable.}
proc circleRGBA*(renderer: PRenderer; x, y, rad: int16; 
  r, g, b, a: Uint8): SDL_Return {.importc, discardable.}
# Arc 
proc arcColor*(renderer: PRenderer; x, y, rad, start, finish: int16; 
  color: Uint32): SDL_Return {.importc, discardable.}
proc arcRGBA*(renderer: PRenderer; x, y, rad, start, finish: int16;
  r, g, b, a: Uint8): SDL_Return {.importc, discardable.}
# AA Circle 
proc aacircleColor*(renderer: PRenderer; x, y, rad: int16; 
  color: Uint32): SDL_Return {.importc, discardable.}
proc aacircleRGBA*(renderer: PRenderer; x, y, rad: int16; 
  r, g, b, a: Uint8): SDL_Return {.importc, discardable.}
# Filled Circle 
proc filledCircleColor*(renderer: PRenderer; x, y, r: int16;
  color: Uint32): SDL_Return {.importc, discardable.}
proc filledCircleRGBA*(renderer: PRenderer; x, y, rad: int16; 
  r, g, b, a: Uint8): SDL_Return {.importc, discardable.}
# Ellipse 
proc ellipseColor*(renderer: PRenderer; x: int16; y: int16; 
                   rx: int16; ry: int16; color: Uint32): SDL_Return {.importc, discardable.}
proc ellipseRGBA*(renderer: PRenderer; x: int16; y: int16; 
                  rx: int16; ry: int16; r: Uint8; g: Uint8; b: Uint8; 
                  a: Uint8): SDL_Return {.importc, discardable.}
# AA Ellipse 
proc aaellipseColor*(renderer: PRenderer; x, y, rx, ry: int16; 
  color: Uint32): SDL_Return {.importc, discardable.}
proc aaellipseRGBA*(renderer: PRenderer; x, y, rx, ry: int16; 
  r, g, b, a: Uint8): SDL_Return {.importc, discardable.}
# Filled Ellipse 
proc filledEllipseColor*(renderer: PRenderer; x, y, rx, ry: int16; 
  color: Uint32): SDL_Return {.importc, discardable.}
proc filledEllipseRGBA*(renderer: PRenderer; x, y, rx, ry: int16; 
  r, g, b, a: Uint8): SDL_Return {.importc, discardable.}
# Pie 
proc pieColor*(renderer: PRenderer; x, y, rad, start, finish: int16; 
  color: Uint32): SDL_Return {.importc, discardable.}
proc pieRGBA*(renderer: PRenderer; x, y, rad, start, finish: int16; 
  r, g, b, a: uint8): SDL_Return  {.importc, discardable.}
# Filled Pie 
proc filledPieColor*(renderer: PRenderer; x, y, rad, start, finish: int16;
  color: Uint32): SDL_Return {.importc, discardable.}
proc filledPieRGBA*(renderer: PRenderer; x, y, rad, start, finish: int16;
  r, g, b, a: uint8): SDL_Return {.importc, discardable.}
# Trigon 
proc trigonColor*(renderer: PRenderer; x1,y1,x2,y2,x3,y3: int16,
                   color: Uint32): SDL_Return {.importc, discardable.}
proc trigonRGBA*(renderer: PRenderer; x1, y1, x2, y2, x3, y3: int16; 
                  r,g,b,a: Uint8): SDL_Return {.importc, discardable.}
# AA-Trigon 
proc aatrigonColor*(renderer: PRenderer; x1, y1, x2, y2, x3, y3: int16; 
                    color: Uint32): SDL_Return {.importc, discardable.}
proc aatrigonRGBA*(renderer: PRenderer; x1, y1, x2, y2, x3, y3: int16;
                    r,g,b,a: Uint8): SDL_Return {.importc, discardable.}
# Filled Trigon 
proc filledTrigonColor*(renderer: PRenderer; x1: int16; y1: int16; 
                        x2: int16; y2: int16; x3: int16; y3: int16; 
                        color: Uint32): SDL_Return {.importc, discardable.}
proc filledTrigonRGBA*(renderer: PRenderer; x1: int16; y1: int16; 
                       x2: int16; y2: int16; x3: int16; y3: int16; 
                       r,g,b,a: Uint8): SDL_Return {.importc, discardable.}
# Polygon 
proc polygonColor*(renderer: PRenderer; vx: ptr int16; vy: ptr int16; 
                   n: cint; color: Uint32): SDL_Return {.importc, discardable.}
proc polygonRGBA*(renderer: PRenderer; vx: ptr int16; vy: ptr int16; 
                  n: cint; r,g,b,a: Uint8): SDL_Return {.importc, discardable.}
# AA-Polygon 
proc aapolygonColor*(renderer: PRenderer; vx: ptr int16; 
                     vy: ptr int16; n: cint; color: Uint32): SDL_Return {.importc, discardable.}
proc aapolygonRGBA*(renderer: PRenderer; vx: ptr int16; 
                    vy: ptr int16; n: cint; r,g,b,a: Uint8): SDL_Return {.importc, discardable.}
# Filled Polygon 
proc filledPolygonColor*(renderer: PRenderer; vx: ptr int16; 
                         vy: ptr int16; n: cint; color: Uint32): SDL_Return {.importc, discardable.}
proc filledPolygonRGBA*(renderer: PRenderer; vx: ptr int16; 
                        vy: ptr int16; n: cint; r: Uint8; g: Uint8; b: Uint8; 
                        a: Uint8): SDL_Return {.importc, discardable.}
# Textured Polygon 
proc texturedPolygon*(renderer: PRenderer; vx: ptr int16; 
                      vy: ptr int16; n: cint; texture: PSurface; 
                      texture_dx: cint; texture_dy: cint): SDL_Return {.importc, discardable.}
# Bezier 
proc bezierColor*(renderer: PRenderer; vx,vy: ptr int16; 
                  n: cint; s: cint; color: Uint32): SDL_Return {.importc, discardable.}
proc bezierRGBA*(renderer: PRenderer; vx, vy: ptr int16; 
                 n: cint; s: cint; r, g, b, a: Uint8): SDL_Return {.importc, discardable.}
# Characters/Strings 
proc gfxPrimitivesSetFont*(fontdata: pointer; cw: Uint32; ch: Uint32) {.importc.}
proc gfxPrimitivesSetFontRotation*(rotation: Uint32) {.importc.}
proc characterColor*(renderer: PRenderer; x: int16; y: int16; 
                     c: char; color: Uint32): SDL_Return {.importc.}
proc characterRGBA*(renderer: PRenderer; x: int16; y: int16; c: char; 
                    r,g,b,a: Uint8): SDL_Return {.importc.}
proc stringColor*(renderer: PRenderer; x: int16; y: int16; 
                  s: cstring; color: Uint32): SDL_Return {.importc.}
proc stringRGBA*(renderer: PRenderer; x: int16; y: int16; s: cstring; 
                 r,g,b,a: Uint8): SDL_Return {.importc, discardable.}
# Ends C function definitions when using C++ 


proc rotozoomSurface*(src: PSurface; angle, zoom: cdouble; 
  smooth: cint): PSurface {.importc.}
proc rotozoomSurfaceXY*(src: PSurface; angle, zoomX, zoomY: cdouble; 
  smooth: cint): PSurface {.importc.}
proc rotozoomSurfaceSize*(width, height: cint; angle, zoom: cdouble; 
  dstwidth, dstheight: var cint) {.importc.}
proc rotozoomSurfaceSizeXY*(width, height: cint; angle, zoomX, zoomY: cdouble; 
                            dstwidth, dstheight: var cint) {.importc.}
proc zoomSurface*(src: PSurface; zoomX, zoomY: cdouble; 
  smooth: cint): PSurface {.importc.}
proc zoomSurfaceSize*(width, height: cint; zoomX, zoomY: cdouble; 
  dstWidth, dstHeight: var cint) {.importc.}

proc shrinkSurface*(src: PSurface; factorx, factorY: cint): PSurface {.importc.}
proc rotateSurface90Degrees*(src: PSurface; 
  numClockwiseTurns: cint): PSurface {.importc.}


proc init*(manager: var TFPSmanager) {.importc: "SDL_initFramerate".}
proc setFramerate*(manager: var TFPSmanager; rate: cint): SDL_Return {.
  importc: "SDL_setFramerate", discardable.}
proc getFramerate*(manager: var TFPSmanager): cint {.importc: "SDL_getFramerate".}
proc getFramecount*(manager: var TFPSmanager): cint {.importc: "SDL_getFramecount".}
proc delay*(manager: var TFPSmanager): cint {.importc: "SDL_framerateDelay", discardable.}

{.pop.}

from strutils import splitLines
proc mlStringRGBA*(renderer: PRenderer; x,y: int16, S: string, R,G,B,A: uint8, lineSpacing = 2'i16) =
  ## Draw a multi-line string
  var ln = 0
  for L in splitLines(S): 
    renderer.StringRGBA(x,(y + int16(ln * 8) + int16(ln * lineSpacing)),L, R,G,B,A)
    inc ln
proc mlStringRGBA*(renderer: PRenderer; x,y: int16; S: seq[string]; R,G,B,A: uint8; lineSpacing = 2'i16) =
  var ln = 0
  while ln < S.len:
    renderer.StringRGBA(x, y + int16(ln * 8 + ln * lineSpacing), S[ln], R,G,B,A) 
    inc ln

