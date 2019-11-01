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

# Docs: http://www.ferzkopp.net/Software/SDL_gfx-2.0/Docs/html/_s_d_l__gfx_primitives_8c.html

import sdl2

when not defined(SDL_Static):
  when defined(windows):
    const LibName = "SDL2_gfx.dll"
  elif defined(macosx):
    const LibName = "libSDL2_gfx.dylib"
  else:
    const LibName = "libSDL2_gfx(|-2.0).so(|.0)"
else:
  static: echo "SDL_Static option is deprecated and will soon be removed. Instead please use --dynlibOverride:SDL2_gfx."

const
  FPS_UPPER_LIMIT* = 200
  FPS_LOWER_LIMIT* = 1
  FPS_DEFAULT* = 30

type
  FpsManager* {.pure, final.} = object
    framecount*: cint
    rateticks*: cfloat
    baseticks*: cint
    lastticks*: cint
    rate*: cint

{.pragma: i, importc, discardable.}

when not defined(SDL_Static):
  {.push callConv:cdecl, dynlib: LibName.}

# ---- Function Prototypes
# Note: all ___Color routines expect the color to be in format 0xAABBGGRR
# Pixel
proc pixelColor*(renderer: RendererPtr; x, y: int16; color: uint32): SDL_Return {.importc, discardable.}
proc pixelRGBA*(renderer: RendererPtr; x: int16; y: int16; r: uint8;
                g: uint8; b: uint8; a: uint8): SDL_Return  {.importc, discardable.}
# Horizontal line
proc hlineColor*(renderer: RendererPtr; x1: int16; x2: int16;
                 y: int16; color: uint32): SDL_Return {.importc, discardable.}
proc hlineRGBA*(renderer: RendererPtr; x1: int16; x2: int16; y: int16;
                r,g,b,a: uint8): SDL_Return {.importc, discardable.}
# Vertical line
proc vlineColor*(renderer: RendererPtr; x,y1,y2: int16;
                  color: uint32): SDL_Return {.importc, discardable.}
proc vlineRGBA*(renderer: RendererPtr; x,y1,y2: int16;
                r,g,b,a: uint8): SDL_Return {.importc, discardable.}
# Rectangle
proc rectangleColor*(renderer: RendererPtr; x1,y1,x2,y2: int16;
      color: uint32): SDL_Return {.importc, discardable.}
proc rectangleRGBA*(renderer: RendererPtr; x1,y1,x2,y2: int16; r,g,b,a: uint8): SDL_Return {.
      importc, discardable.}
# Rounded-Corner Rectangle
proc roundedRectangleColor*(renderer: RendererPtr; x1,y1,x2,y2,rad: int16;
                            color: uint32): SDL_Return {.importc, discardable.}
proc roundedRectangleRGBA*(renderer: RendererPtr; x1,y1,x2,y2,rad: int16;
              r,g,b,a: uint8): SDL_Return {.importc, discardable.}
# Filled rectangle (Box)
proc boxColor*(renderer: RendererPtr; x1, y1, x2, y2: int16;
  color: uint32): SDL_Return {.importc, discardable.}
proc boxRGBA*(renderer: RendererPtr; x1, y1, x2, y2: int16;
  r, g, b, a: uint8): SDL_Return {.importc, discardable.}
# Rounded-Corner Filled rectangle (Box)
proc roundedBoxColor*(renderer: RendererPtr; x1,y1,x2,y2,rad: int16;
                       color: uint32): SDL_Return {.importc, discardable.}
proc roundedBoxRGBA*(renderer: RendererPtr; x1,y1,x2,y2,rad: int16;
                  r,g,b,a: uint8): SDL_Return {.importc, discardable.}
# Line
proc lineColor*(renderer: RendererPtr; x1,y1,x2,y2: int16;
    color: uint32): SDL_Return {.importc, discardable.}
proc lineRGBA*(renderer: RendererPtr; x1,y1,x2,y2: int16; r,g,b,a: uint8): SDL_Return {.
  importc, discardable.}
# AA Line
proc aalineColor*(renderer: RendererPtr; x1: int16; y1: int16;
                  x2: int16; y2: int16; color: uint32): SDL_Return {.importc, discardable.}
proc aalineRGBA*(renderer: RendererPtr; x1: int16; y1: int16;
                 x2: int16; y2: int16; r: uint8; g: uint8; b: uint8;
                 a: uint8): SDL_Return {.importc, discardable.}
# Thick Line
proc thickLineColor*(renderer: RendererPtr; x1, y1, x2, y2: int16;
  width: uint8; color: uint32): SDL_Return {.importc, discardable.}
proc thickLineRGBA*(renderer: RendererPtr; x1, y1, x2, y2: int16;
  width, r, g, b, a: uint8): SDL_Return {.importc, discardable.}
# Circle
proc circleColor*(renderer: RendererPtr; x, y, rad: int16;
  color: uint32): SDL_Return {.importc, discardable.}
proc circleRGBA*(renderer: RendererPtr; x, y, rad: int16;
  r, g, b, a: uint8): SDL_Return {.importc, discardable.}
# Arc
proc arcColor*(renderer: RendererPtr; x, y, rad, start, finish: int16;
  color: uint32): SDL_Return {.importc, discardable.}
proc arcRGBA*(renderer: RendererPtr; x, y, rad, start, finish: int16;
  r, g, b, a: uint8): SDL_Return {.importc, discardable.}
# AA Circle
proc aacircleColor*(renderer: RendererPtr; x, y, rad: int16;
  color: uint32): SDL_Return {.importc, discardable.}
proc aacircleRGBA*(renderer: RendererPtr; x, y, rad: int16;
  r, g, b, a: uint8): SDL_Return {.importc, discardable.}
# Filled Circle
proc filledCircleColor*(renderer: RendererPtr; x, y, r: int16;
  color: uint32): SDL_Return {.importc, discardable.}
proc filledCircleRGBA*(renderer: RendererPtr; x, y, rad: int16;
  r, g, b, a: uint8): SDL_Return {.importc, discardable.}
# Ellipse
proc ellipseColor*(renderer: RendererPtr; x: int16; y: int16;
                   rx: int16; ry: int16; color: uint32): SDL_Return {.importc, discardable.}
proc ellipseRGBA*(renderer: RendererPtr; x: int16; y: int16;
                  rx: int16; ry: int16; r: uint8; g: uint8; b: uint8;
                  a: uint8): SDL_Return {.importc, discardable.}
# AA Ellipse
proc aaellipseColor*(renderer: RendererPtr; x, y, rx, ry: int16;
  color: uint32): SDL_Return {.importc, discardable.}
proc aaellipseRGBA*(renderer: RendererPtr; x, y, rx, ry: int16;
  r, g, b, a: uint8): SDL_Return {.importc, discardable.}
# Filled Ellipse
proc filledEllipseColor*(renderer: RendererPtr; x, y, rx, ry: int16;
  color: uint32): SDL_Return {.importc, discardable.}
proc filledEllipseRGBA*(renderer: RendererPtr; x, y, rx, ry: int16;
  r, g, b, a: uint8): SDL_Return {.importc, discardable.}
# Pie
proc pieColor*(renderer: RendererPtr; x, y, rad, start, finish: int16;
  color: uint32): SDL_Return {.importc, discardable.}
proc pieRGBA*(renderer: RendererPtr; x, y, rad, start, finish: int16;
  r, g, b, a: uint8): SDL_Return  {.importc, discardable.}
# Filled Pie
proc filledPieColor*(renderer: RendererPtr; x, y, rad, start, finish: int16;
  color: uint32): SDL_Return {.importc, discardable.}
proc filledPieRGBA*(renderer: RendererPtr; x, y, rad, start, finish: int16;
  r, g, b, a: uint8): SDL_Return {.importc, discardable.}
# Trigon
proc trigonColor*(renderer: RendererPtr; x1,y1,x2,y2,x3,y3: int16,
                   color: uint32): SDL_Return {.importc, discardable.}
proc trigonRGBA*(renderer: RendererPtr; x1, y1, x2, y2, x3, y3: int16;
                  r,g,b,a: uint8): SDL_Return {.importc, discardable.}
# AA-Trigon
proc aaTrigonColor*(renderer: RendererPtr; x1, y1, x2, y2, x3, y3: int16;
                    color: uint32): SDL_Return {.importc: "aatrigonColor",
                    discardable.}
proc aaTrigonRGBA*(renderer: RendererPtr; x1, y1, x2, y2, x3, y3: int16;
                    r,g,b,a: uint8): SDL_Return {.importc: "aatrigonRGBA",
                    discardable.}
# Filled Trigon
proc filledTrigonColor*(renderer: RendererPtr; x1: int16; y1: int16;
                        x2: int16; y2: int16; x3: int16; y3: int16;
                        color: uint32): SDL_Return {.importc, discardable.}
proc filledTrigonRGBA*(renderer: RendererPtr; x1: int16; y1: int16;
                       x2: int16; y2: int16; x3: int16; y3: int16;
                       r,g,b,a: uint8): SDL_Return {.importc, discardable.}
# Polygon
proc polygonColor*(renderer: RendererPtr; vx: ptr int16; vy: ptr int16;
                   n: cint; color: uint32): SDL_Return {.importc, discardable.}
proc polygonRGBA*(renderer: RendererPtr; vx: ptr int16; vy: ptr int16;
                  n: cint; r,g,b,a: uint8): SDL_Return {.importc, discardable.}
# AA-Polygon
proc aaPolygonColor*(renderer: RendererPtr; vx: ptr int16; vy: ptr int16;
                     n: cint; color: uint32): SDL_Return {.importc: "aapolygonColor",
                     discardable.}
proc aaPolygonRGBA*(renderer: RendererPtr; vx: ptr int16; vy: ptr int16;
                    n: cint; r,g,b,a: uint8): SDL_Return {.importc: "aapolygonRGBA",
                    discardable.}
# Filled Polygon
proc filledPolygonColor*(renderer: RendererPtr; vx: ptr int16;
                         vy: ptr int16; n: cint; color: uint32): SDL_Return {.importc, discardable.}
proc filledPolygonRGBA*(renderer: RendererPtr; vx: ptr int16;
                        vy: ptr int16; n: cint; r: uint8; g: uint8; b: uint8;
                        a: uint8): SDL_Return {.importc, discardable.}
# Textured Polygon
proc texturedPolygon*(renderer: RendererPtr; vx: ptr int16;
                      vy: ptr int16; n: cint; texture: SurfacePtr;
                      texture_dx: cint; texture_dy: cint): SDL_Return {.importc, discardable.}
# Bezier
proc bezierColor*(renderer: RendererPtr; vx,vy: ptr int16;
                  n: cint; s: cint; color: uint32): SDL_Return {.importc, discardable.}
proc bezierRGBA*(renderer: RendererPtr; vx, vy: ptr int16;
                 n: cint; s: cint; r, g, b, a: uint8): SDL_Return {.importc, discardable.}
# Characters/Strings
proc gfxPrimitivesSetFont*(fontdata: pointer; cw: uint32; ch: uint32) {.importc.}
proc gfxPrimitivesSetFontRotation*(rotation: uint32) {.importc.}
proc characterColor*(renderer: RendererPtr; x: int16; y: int16;
                     c: char; color: uint32): SDL_Return {.importc.}
proc characterRGBA*(renderer: RendererPtr; x: int16; y: int16; c: char;
                    r,g,b,a: uint8): SDL_Return {.importc.}
proc stringColor*(renderer: RendererPtr; x: int16; y: int16;
                  s: cstring; color: uint32): SDL_Return {.importc.}
proc stringRGBA*(renderer: RendererPtr; x: int16; y: int16; s: cstring;
                 r,g,b,a: uint8): SDL_Return {.importc, discardable.}
# Ends C function definitions when using C++

proc rotozoomSurface*(src: SurfacePtr; angle, zoom: cdouble;
  smooth: cint): SurfacePtr {.importc.}
proc rotozoomSurfaceXY*(src: SurfacePtr; angle, zoomX, zoomY: cdouble;
  smooth: cint): SurfacePtr {.importc.}
proc rotozoomSurfaceSize*(width, height: cint; angle, zoom: cdouble;
  dstwidth, dstheight: var cint) {.importc.}
proc rotozoomSurfaceSizeXY*(width, height: cint; angle, zoomX, zoomY: cdouble;
                            dstwidth, dstheight: var cint) {.importc.}
proc zoomSurface*(src: SurfacePtr; zoomX, zoomY: cdouble;
  smooth: cint): SurfacePtr {.importc.}
proc zoomSurfaceSize*(width, height: cint; zoomX, zoomY: cdouble;
  dstWidth, dstHeight: var cint) {.importc.}

proc shrinkSurface*(src: SurfacePtr; factorx, factorY: cint): SurfacePtr {.importc.}
proc rotateSurface90Degrees*(src: SurfacePtr;
  numClockwiseTurns: cint): SurfacePtr {.importc.}

proc init*(manager: var FpsManager) {.importc: "SDL_initFramerate".}
proc setFramerate*(manager: var FpsManager; rate: cint): SDL_Return {.
  importc: "SDL_setFramerate", discardable.}
proc getFramerate*(manager: var FpsManager): cint {.importc: "SDL_getFramerate".}
proc getFramecount*(manager: var FpsManager): cint {.importc: "SDL_getFramecount".}
proc delay*(manager: var FpsManager): cint {.importc: "SDL_framerateDelay", discardable.}

when not defined(SDL_Static):
  {.pop.}

from strutils import splitLines
proc mlStringRGBA*(renderer: RendererPtr; x,y: int16, S: string, R,G,B,A: uint8, lineSpacing = 2'i16) =
  ## Draw a multi-line string
  var ln = 0
  for L in splitLines(S):
    renderer.stringRGBA(x,(y + int16(ln * 8) + int16(ln * lineSpacing)),L, R,G,B,A)
    inc ln
proc mlStringRGBA*(renderer: RendererPtr; x,y: int16; S: seq[string]; R,G,B,A: uint8; lineSpacing = 2'i16) =
  var ln = 0
  while ln < S.len:
    renderer.stringRGBA(x, y + int16(ln * 8 + ln * lineSpacing), S[ln], R,G,B,A)
    inc ln

{.deprecated: [TFPSmanager: FpsManager].}
