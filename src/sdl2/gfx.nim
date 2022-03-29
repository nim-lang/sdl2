# SDL2_gfxPrimitives.h: graphics primitives for SDL
#
# Copyright (C) 2012  Andreas Schiffler
#
# This software is provided 'as-is', without any express or implied
# warranty. In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
# claim that you wrote the original software. If you use this software
# in a product, an acknowledgment in the product documentation would be
# appreciated but is not required.
#
# 2. Altered source versions must be plainly marked as such, and must not be
# misrepresented as being the original software.
#
# 3. This notice may not be removed or altered from any source
# distribution.
#
# Andreas Schiffler -- aschiffler at ferzkopp dot net
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
    ## Highest possible rate supported by framerate controller in Hz (1/s).
  FPS_LOWER_LIMIT* = 1
    ## Lowest possible rate supported by framerate controller in Hz (1/s).
  FPS_DEFAULT* = 30
    ## Default rate of framerate controller in Hz (1/s).


type
  FpsManager* {.pure, final.} = object
    ## Object holding the state and timing information
    ## of the framerate controller.
    framecount*: cint
    rateticks*: cfloat
    baseticks*: cint
    lastticks*: cint
    rate*: cint

{.pragma: i, importc, discardable.}

when not defined(SDL_Static):
  {.push callConv:cdecl, dynlib: LibName.}

proc pixelColor*(renderer: RendererPtr; x, y: int16;
                 color: uint32): SDL_Return {.importc, discardable.}
  ## Pixel draw with alpha blending enabled if `a` < `255`.
  ##
  ## `x`, `y`  Coordinates of the pixel.

proc pixelRGBA*(renderer: RendererPtr; x: int16; y: int16; r: uint8; g: uint8;
                b: uint8; a: uint8): SDL_Return  {.importc, discardable.}
  ## Pixel draw with alpha blending enabled if `a` < `255`.
  ##
  ## `x`, `y`  Coordinates of the pixel.

# Horizontal line
proc hlineColor*(renderer: RendererPtr; x1: int16; x2: int16; y: int16;
                 color: uint32): SDL_Return {.importc, discardable.}
  ## Draw horizontal line with alpha blending.
  ##
  ## `x1`  X coordinate of the first point (i.e. left) of the line.
  ##
  ## `x2`  X coordinate of the second point (i.e. right) of the line.
  ##
  ## `y` Y coordinate of the points of the line.

proc hlineRGBA*(renderer: RendererPtr; x1: int16; x2: int16; y: int16;
                r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw horizontal line with alpha blending.
  ##
  ## `x1`  X coordinate of the first point (i.e. left) of the line.
  ##
  ## `x2`  X coordinate of the second point (i.e. right) of the line.
  ##
  ## `y` Y coordinate of the points of the line.

# Vertical line
proc vlineColor*(renderer: RendererPtr; x, y1, y2: int16;
                 color: uint32): SDL_Return {.importc, discardable.}
  ## Draw vertical line with alpha blending.
  ##
  ## `x` X coordinate of the points of the line.
  ##
  ## `y1`  Y coordinate of the first point (i.e. top) of the line.
  ##
  ## `y2`  Y coordinate of the second point (i.e. bottom) of the line.

proc vlineRGBA*(renderer: RendererPtr; x, y1, y2: int16;
                r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw vertical line with alpha blending.
  ##
  ## `x` X coordinate of the points of the line.
  ##
  ## `y1`  Y coordinate of the first point (i.e. top) of the line.
  ##
  ## `y2`  Y coordinate of the second point (i.e. bottom) of the line.

# Rectangle
proc rectangleColor*(renderer: RendererPtr; x1, y1, x2, y2: int16;
                     color: uint32): SDL_Return {.importc, discardable.}
  ## Draw rectangle with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point (i.e. top right)
  ## of the rectangle.
  ##
  ## `x2`, `y2`  Coordinates of the second point (i.e. bottom left)
  ## of the rectangle.

proc rectangleRGBA*(renderer: RendererPtr; x1, y1, x2, y2: int16;
                    r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw rectangle with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point (i.e. top right)
  ## of the rectangle.
  ##
  ## `x2`, `y2`  Coordinates of the second point (i.e. bottom left)
  ## of the rectangle.

# Rounded-Corner Rectangle
proc roundedRectangleColor*(renderer: RendererPtr; x1, y1, x2, y2, rad: int16;
                            color: uint32): SDL_Return {.importc, discardable.}
  ## Draw rounded-corner rectangle with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point (i.e. top right)
  ## of the rectangle.
  ##
  ## `x2`, `y2`  Coordinates of the second point (i.e. bottom left)
  ## of the rectangle.
  ##
  ## `rad` The radius of the corner arc.

proc roundedRectangleRGBA*(renderer: RendererPtr; x1, y1, x2, y2, rad: int16;
              r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw rounded-corner rectangle with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point (i.e. top right)
  ## of the rectangle.
  ##
  ## `x2`, `y2`  Coordinates of the second point (i.e. bottom left)
  ## of the rectangle.
  ##
  ## `rad` The radius of the corner arc.

# Filled rectangle (Box)
proc boxColor*(renderer: RendererPtr; x1, y1, x2, y2: int16;
               color: uint32): SDL_Return {.importc, discardable.}
  ## Draw box (filled rectangle) with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point (i.e. top right)
  ## of the box.
  ##
  ## `x2`, `y2`  Coordinates of the second point (i.e. bottom left)
  ## of the box.

proc boxRGBA*(renderer: RendererPtr; x1, y1, x2, y2: int16;
              r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw box (filled rectangle) with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point (i.e. top right)
  ## of the box.
  ##
  ## `x2`, `y2`  Coordinates of the second point (i.e. bottom left)
  ## of the box.

# Rounded-Corner Filled rectangle (Box)
proc roundedBoxColor*(renderer: RendererPtr; x1, y1, x2, y2, rad: int16;
                      color: uint32): SDL_Return {.importc, discardable.}
  ## Draw rounded-corner box (filled rectangle) with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point (i.e. top right)
  ## of the box.
  ##
  ## `x2`, `y2`  Coordinates of the second point (i.e. bottom left)
  ## of the box.
  ##
  ## `rad` The radius of the cornder arcs of the box.

proc roundedBoxRGBA*(renderer: RendererPtr; x1, y1, x2, y2, rad: int16;
                     r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw rounded-corner box (filled rectangle) with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point (i.e. top right)
  ## of the box.
  ##
  ## `x2`, `y2`  Coordinates of the second point (i.e. bottom left)
  ## of the box.
  ##
  ## `rad` The radius of the cornder arcs of the box.

# Line
proc lineColor*(renderer: RendererPtr; x1, y1, x2, y2: int16;
                color: uint32): SDL_Return {.importc, discardable.}
  ## Draw line with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point of the line.
  ##
  ## `x2`, `y2`  Coordinates of the second point of the line.

proc lineRGBA*(renderer: RendererPtr; x1, y1, x2, y2: int16;
               r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw line with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point of the line.
  ##
  ## `x2`, `y2`  Coordinates of the second point of the line.

# AA Line
proc aalineColor*(renderer: RendererPtr;
                  x1: int16; y1: int16;
                  x2: int16; y2: int16;
                  color: uint32): SDL_Return {.importc, discardable.}
  ## Draw anti-aliased line with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point of the aa-line.
  ##
  ## `x2`, `y2`  Coordinates of the second point of the aa-line.

proc aalineRGBA*(renderer: RendererPtr; x1: int16; y1: int16;
                 x2: int16; y2: int16; r: uint8; g: uint8; b: uint8;
                 a: uint8): SDL_Return {.importc, discardable.}
  ## Draw anti-aliased line with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point of the aa-line.
  ##
  ## `x2`, `y2`  Coordinates of the second point of the aa-line.

# Thick Line
proc thickLineColor*(renderer: RendererPtr; x1, y1, x2, y2: int16;
  width: uint8; color: uint32): SDL_Return {.importc, discardable.}
  ## Draw thick line with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point of the line.
  ##
  ## `x2`, `y2`  Coordinates of the second point of the line.
  ##
  ## `width` Width of the line in pixels. Must be `>0`.

proc thickLineRGBA*(renderer: RendererPtr; x1, y1, x2, y2: int16;
                  width, r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw thick line with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point of the line.
  ##
  ## `x2`, `y2`  Coordinates of the second point of the line.
  ##
  ## `width` Width of the line in pixels. Must be `>0`.

# Circle
proc circleColor*(renderer: RendererPtr; x, y, rad: int16;
                  color: uint32): SDL_Return {.importc, discardable.}
  ## Draw circle with alpha blending.
  ##
  ## `x`, `y`  Coordinates of the center of the circle.
  ##
  ## `rad` Radius in pixels of the circle.

proc circleRGBA*(renderer: RendererPtr; x, y, rad: int16;
                 r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw circle with alpha blending.
  ##
  ## `x`, `y`  Coordinates of the center of the circle.
  ##
  ## `rad` Radius in pixels of the circle.

# Arc
proc arcColor*(renderer: RendererPtr; x, y, rad, start, finish: int16;
               color: uint32): SDL_Return {.importc, discardable.}
  ## Draw arc with alpha blending.
  ##
  ## `x`, `y`  Coordinates of the center of the arc.
  ##
  ## `rad` Radius in pixels of the arc.
  ##
  ## `start`, `end` Starting and ending radius in degrees of the arc.
  ## `0` degrees is down, increasing counterclockwise.

proc arcRGBA*(renderer: RendererPtr; x, y, rad, start, finish: int16;
              r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw arc with alpha blending.
  ##
  ## `x`, `y`  Coordinates of the center of the arc.
  ##
  ## `rad` Radius in pixels of the arc.
  ##
  ## `start`, `end` Starting and ending radius in degrees of the arc.
  ## `0` degrees is down, increasing counterclockwise.

# AA Circle
proc aacircleColor*(renderer: RendererPtr; x, y, rad: int16;
                    color: uint32): SDL_Return {.importc, discardable.}
  ## Draw anti-aliased circle with alpha blending.
  ##
  ## `x`, `y` Coordinates of the center of the aa-circle.
  ##
  ## `rad` Radius in pixels of the aa-circle.

proc aacircleRGBA*(renderer: RendererPtr; x, y, rad: int16;
                   r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw anti-aliased circle with alpha blending.
  ##
  ## `x`, `y` Coordinates of the center of the aa-circle.
  ##
  ## `rad` Radius in pixels of the aa-circle.

# Filled Circle
proc filledCircleColor*(renderer: RendererPtr; x, y, r: int16;
                        color: uint32): SDL_Return {.importc, discardable.}
  ## Draw filled circle with alpha blending.
  ##
  ## `x`, `y`  Coordinates of the center of the filled circle.
  ##
  ## `rad` Radius in pixels of the filled circle.

proc filledCircleRGBA*(renderer: RendererPtr; x, y, rad: int16;
                       r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw filled circle with alpha blending.
  ##
  ## `x`, `y`  Coordinates of the center of the filled circle.
  ##
  ## `rad` Radius in pixels of the filled circle.

# Ellipse
proc ellipseColor*(renderer: RendererPtr; x: int16; y: int16;
                   rx: int16; ry: int16;
                   color: uint32): SDL_Return {.importc, discardable.}
  ## Draw ellipse with alpha blending.
  ##
  ## `x`, `y`  Coordinates of the center of the ellipse.
  ##
  ## `rx`  Horizontal radius in pixels of the ellipse.
  ##
  ## `ry`  Vertical radius in pixels of the ellipse.

proc ellipseRGBA*(renderer: RendererPtr; x: int16; y: int16;
                  rx: int16; ry: int16; r: uint8; g: uint8; b: uint8;
                  a: uint8): SDL_Return {.importc, discardable.}
  ## Draw ellipse with alpha blending.
  ##
  ## `x`, `y`  Coordinates of the center of the ellipse.
  ##
  ## `rx`  Horizontal radius in pixels of the ellipse.
  ##
  ## `ry`  Vertical radius in pixels of the ellipse.

# AA Ellipse
proc aaellipseColor*(renderer: RendererPtr; x, y, rx, ry: int16;
                     color: uint32): SDL_Return {.importc, discardable.}
  ## Draw anti-aliased ellipse with alpha blending.
  ##
  ## `x`, `y`  Coordinates of the center of the aa-ellipse.
  ##
  ## `rx`  Horizontal radius in pixels of the aa-ellipse.
  ##
  ## `ry`  Vertical radius in pixels of the aa-ellipse.

proc aaellipseRGBA*(renderer: RendererPtr; x, y, rx, ry: int16;
                    r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw anti-aliased ellipse with alpha blending.
  ##
  ## `x`, `y`  Coordinates of the center of the aa-ellipse.
  ##
  ## `rx`  Horizontal radius in pixels of the aa-ellipse.
  ##
  ## `ry`  Vertical radius in pixels of the aa-ellipse.

# Filled Ellipse
proc filledEllipseColor*(renderer: RendererPtr; x, y, rx, ry: int16;
  color: uint32): SDL_Return {.importc, discardable.}
  ## Draw filled ellipse with alpha blending.
  ##
  ## `x`, `y` Coordinates of the center of the filled ellipse.
  ##
  ## `rx`  Horizontal radius in pixels of the filled ellipse.
  ##
  ## `ry`  Vertical radius in pixels of the filled ellipse.

proc filledEllipseRGBA*(renderer: RendererPtr; x, y, rx, ry: int16;
  r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw filled ellipse with alpha blending.
  ##
  ## `x`, `y` Coordinates of the center of the filled ellipse.
  ##
  ## `rx`  Horizontal radius in pixels of the filled ellipse.
  ##
  ## `ry`  Vertical radius in pixels of the filled ellipse.

# Pie
proc pieColor*(renderer: RendererPtr; x, y, rad, start, finish: int16;
               color: uint32): SDL_Return {.importc, discardable.}
  ## Draw pie (outline) with alpha blending.
  ##
  ## `x`, `y` Coordinates of the center of the pie.
  ##
  ## `rad` Radius in pixels of the pie.
  ##
  ## `start`, `end`  Starting and ending radius in degrees of the pie.

proc pieRGBA*(renderer: RendererPtr; x, y, rad, start, finish: int16;
              r, g, b, a: uint8): SDL_Return  {.importc, discardable.}
  ## Draw pie (outline) with alpha blending.
  ##
  ## `x`, `y` Coordinates of the center of the pie.
  ##
  ## `rad` Radius in pixels of the pie.
  ##
  ## `start`, `end`  Starting and ending radius in degrees of the pie.

# Filled Pie
proc filledPieColor*(renderer: RendererPtr; x, y, rad, start, finish: int16;
                     color: uint32): SDL_Return {.importc, discardable.}
  ## Draw filled pie with alpha blending.
  ##
  ## `x`, `y`  Coordinates of the center of the filled pie.
  ##
  ## `rad` Radius in pixels of the filled pie.
  ##
  ## `start`, `end` Starting and ending radius in degrees
  ## of the filled pie.

proc filledPieRGBA*(renderer: RendererPtr; x, y, rad, start, finish: int16;
                    r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw filled pie with alpha blending.
  ##
  ## `x`, `y`  Coordinates of the center of the filled pie.
  ##
  ## `rad` Radius in pixels of the filled pie.
  ##
  ## `start`, `end` Starting and ending radius in degrees
  ## of the filled pie.

# Trigon
proc trigonColor*(renderer: RendererPtr; x1,y1,x2,y2,x3,y3: int16,
                  color: uint32): SDL_Return {.importc, discardable.}
  ## Draw trigon (triangle outline) with alpha blending.
  ##
  ## `x1`, `y1` Coordinates of the first point of the trigon.
  ##
  ## `x2`, `y2` Coordinates of the second point of the trigon.
  ##
  ## `x3`, `y3` Coordinates of the third point of the trigon.

proc trigonRGBA*(renderer: RendererPtr; x1, y1, x2, y2, x3, y3: int16;
                 r,g,b,a: uint8): SDL_Return {.importc, discardable.}
  ## Draw trigon (triangle outline) with alpha blending.
  ##
  ## `x1`, `y1` Coordinates of the first point of the trigon.
  ##
  ## `x2`, `y2` Coordinates of the second point of the trigon.
  ##
  ## `x3`, `y3` Coordinates of the third point of the trigon.

# AA-Trigon
proc aaTrigonColor*(renderer: RendererPtr; x1, y1, x2, y2, x3, y3: int16;
                    color: uint32): SDL_Return {.importc: "aatrigonColor",
                    discardable.}
  ## Draw anti-aliased trigon (triangle outline) with alpha blending.
  ##
  ## `x1`, `y1` Coordinates of the first point of the aa-trigon.
  ##
  ## `x2`, `y2` Coordinates of the second point of the aa-trigon.
  ##
  ## `x3`, `y3` Coordinates of the third point of the aa-trigon.

proc aaTrigonRGBA*(renderer: RendererPtr; x1, y1, x2, y2, x3, y3: int16;
  r, g, b, a: uint8): SDL_Return {.importc: "aatrigonRGBA", discardable.}
  ## Draw anti-aliased trigon (triangle outline) with alpha blending.
  ##
  ## `x1`, `y1` Coordinates of the first point of the aa-trigon.
  ##
  ## `x2`, `y2` Coordinates of the second point of the aa-trigon.
  ##
  ## `x3`, `y3` Coordinates of the third point of the aa-trigon.

# Filled Trigon
proc filledTrigonColor*(renderer: RendererPtr; x1: int16; y1: int16;
                        x2: int16; y2: int16; x3: int16; y3: int16;
                        color: uint32): SDL_Return {.importc, discardable.}
  ## Draw filled trigon (triangle) with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point of the filled trigon.
  ##
  ## `x2`, `y2`  Coordinates of the first point of the filled trigon.
  ##
  ## `x3`, `y3`  Coordinates of the first point of the filled trigon.

proc filledTrigonRGBA*(renderer: RendererPtr; x1: int16; y1: int16;
                       x2: int16; y2: int16; x3: int16; y3: int16;
                       r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw filled trigon (triangle) with alpha blending.
  ##
  ## `x1`, `y1`  Coordinates of the first point of the filled trigon.
  ##
  ## `x2`, `y2`  Coordinates of the first point of the filled trigon.
  ##
  ## `x3`, `y3`  Coordinates of the first point of the filled trigon.

# Polygon
proc polygonColor*(renderer: RendererPtr; vx: ptr int16; vy: ptr int16;
                   n: cint; color: uint32): SDL_Return {.importc, discardable.}
  ## Draw polygon with alpha blending.
  ##
  ## `vx`, `vy` Vertex arrays containing coordinates of the points
  ## of the polygon.
  ##
  ## `n` Number of points in the vertex array. Minimum number is `3`.

proc polygonRGBA*(renderer: RendererPtr; vx: ptr int16; vy: ptr int16;
                  n: cint; r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw polygon with alpha blending.
  ##
  ## `vx`, `vy` Vertex arrays containing coordinates of the points
  ## of the polygon.
  ##
  ## `n` Number of points in the vertex array. Minimum number is `3`.

# AA-Polygon
proc aaPolygonColor*(renderer: RendererPtr; vx: ptr int16; vy: ptr int16;
                     n: cint; color: uint32): SDL_Return {.
                    importc: "aapolygonColor", discardable.}
  ## Draw anti-aliased polygon with alpha blending.
  ##
  ## `vx`, `vy` Vertex arrays containing coordinates of the points
  ## of the aa-polygon.
  ##
  ## `n` Number of points in the vertex array. Minimum number is `3`.

proc aaPolygonRGBA*(renderer: RendererPtr; vx: ptr int16; vy: ptr int16;
                    n: cint; r,g,b,a: uint8): SDL_Return {.
                    importc: "aapolygonRGBA", discardable.}
  ## Draw anti-aliased polygon with alpha blending.
  ##
  ## `vx`, `vy` Vertex arrays containing coordinates of the points
  ## of the aa-polygon.
  ##
  ## `n` Number of points in the vertex array. Minimum number is `3`.

# Filled Polygon
proc filledPolygonColor*(renderer: RendererPtr; vx: ptr int16;
                         vy: ptr int16; n: cint;
                         color: uint32): SDL_Return {.importc, discardable.}
  ## Draw filled polygon with alpha blending.
  ##
  ## `vx`, `vy`  Vertex arrays containing coordinates of the points
  ## of the filled polygon.
  ##
  ## `n` Number of points in the vertex array. Minimum number is `3`.

proc filledPolygonRGBA*(renderer: RendererPtr; vx: ptr int16;
                        vy: ptr int16; n: cint; r: uint8; g: uint8; b: uint8;
                        a: uint8): SDL_Return {.importc, discardable.}
  ## Draw filled polygon with alpha blending.
  ##
  ## `vx`, `vy`  Vertex arrays containing coordinates of the points
  ## of the filled polygon.
  ##
  ## `n` Number of points in the vertex array. Minimum number is `3`.

# Textured Polygon
proc texturedPolygon*(renderer: RendererPtr; vx: ptr int16;
                      vy: ptr int16; n: cint; texture: SurfacePtr;
                      texture_dx: cint;
                      texture_dy: cint): SDL_Return {.importc, discardable.}
  ## Draw polygon filled with the given texture.
  ##
  ## `vx`, `vy`  Vertex arrays containing coordinates of the points
  ## of the textured polygon.
  ##
  ## `n` Number of points in the vertex array. Minimum number is `3`.
  ##
  ## `texture` The `sdl.Surface` to use to fill the polygon.
  ##
  ## `texture_dx`, `texture_dy`  The offset of the texture
  ## relative to the screen. If you move the polygon `10` pixels to the left
  ## and want the texture to appear the same, you need to increase
  ## the `texture_dx` value.

# Bezier
proc bezierColor*(renderer: RendererPtr; vx,vy: ptr int16;
                  n: cint; s: cint;
                  color: uint32): SDL_Return {.importc, discardable.}
  ## Draw a bezier curve with alpha blending.
  ##
  ## `vx`, `vy`  Vertex arrays containing coordinates of the points
  ## of the bezier curve.
  ##
  ## `n` Number of points in the vertex array. Minimum number is `3`.
  ##
  ## `s` Number of steps for the interpolation. Minimum number is `2`.

proc bezierRGBA*(renderer: RendererPtr; vx, vy: ptr int16;
                 n: cint; s: cint;
                 r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw a bezier curve with alpha blending.
  ##
  ## `vx`, `vy`  Vertex arrays containing coordinates of the points
  ## of the bezier curve.
  ##
  ## `n` Number of points in the vertex array. Minimum number is `3`.
  ##
  ## `s` Number of steps for the interpolation. Minimum number is `2`.

# Characters/Strings
proc gfxPrimitivesSetFont*(fontdata: pointer; cw: uint32; ch: uint32) {.importc.}
  ## Sets or resets the current global font data.
  ##
  ## The font data array is organized in follows:
  ##
  ## `[fontdata] = [character 0][character 1]...[character 255]`
  ## where
  ## `[character n] = [byte 1 row 1][byte 2 row 1]...[byte {pitch} row 1]
  ## [byte 1 row 2] ...[byte {pitch} row height]`
  ## where
  ## `[byte n] = [bit 0]...[bit 7]`
  ## where
  ## `[bit n] = [0 for transparent pixel|1 for colored pixel]`
  ##
  ## `fontdata`  Pointer to array of font data. Set to `nil`, to reset
  ## global font to the default `8x8` font.
  ##
  ## `cw`, `ch`  Width and height of character in bytes.
  ## Ignored if `fontdata` == `nil`.

proc gfxPrimitivesSetFontRotation*(rotation: uint32) {.importc.}
  ## Sets current global font character rotation steps.
  ##
  ## Default is `0` (no rotation).
  ##
  ## `1` = 90deg clockwise.
  ##
  ## `2` = 180deg clockwise.
  ##
  ## `3` = 270deg clockwise.
  ##
  ## Changing the rotation, will reset the character cache.
  ##
  ## `rotation`  Number of 90deg clockwise steps to rotate.

proc characterColor*(renderer: RendererPtr; x: int16; y: int16;
                     c: char; color: uint32): SDL_Return {.importc.}
  ## Draw a character of the currently set font.
  ##
  ## `x`, `y`  Coordinates of the upper left corner of the character.
  ##
  ## `c` The character to draw.

proc characterRGBA*(renderer: RendererPtr; x: int16; y: int16; c: char;
                    r, g, b, a: uint8): SDL_Return {.importc.}
  ## Draw a character of the currently set font.
  ##
  ## `x`, `y`  Coordinates of the upper left corner of the character.
  ##
  ## `c` The character to draw.

proc stringColor*(renderer: RendererPtr; x: int16; y: int16;
                  s: cstring; color: uint32): SDL_Return {.importc.}
  ## Draw a string in the currently set font.
  ##
  ## `x`, `y`  Coordinates of the upper left corner of the string.
  ##
  ## `s` The string to draw.

proc stringRGBA*(renderer: RendererPtr; x: int16; y: int16; s: cstring;
                 r, g, b, a: uint8): SDL_Return {.importc, discardable.}
  ## Draw a string in the currently set font.
  ##
  ## `x`, `y`  Coordinates of the upper left corner of the string.
  ##
  ## `s` The string to draw.

# Ends C function definitions when using C++

proc rotozoomSurface*(src: SurfacePtr; angle, zoom: cdouble;
                      smooth: cint): SurfacePtr {.importc.}
  ## Rotates and zooms a surface and optional anti-aliasing.
  ##
  ## Rotates and zoomes a 32-bit or 8-bit `src` surface to newly created
  ## `dst` surface. If the surface is not 8-bit or 32-bit RGBA/ABGR,
  ## it will be converted into a 32-bit RGBA format on the fly.
  ##
  ## `angle` The angle to rotate in degrees.
  ##
  ## `zoom`  The scaling factor.
  ##
  ## `smooth`  Antialiasing flag. Set to `SMOOTHING_ON` to enable.
  ##
  ## `Return` the new rotozoomed surface.

proc rotozoomSurfaceXY*(src: SurfacePtr; angle, zoomX, zoomY: cdouble;
                        smooth: cint): SurfacePtr {.importc.}
  ## Rotates and zooms a surface with different horizontal and vertical
  ## scaling factors and optional anti-aliasing.
  ##
  ## Rotates and zooms a 32-bit or 8-bit `src` surface to newly created
  ## `dst` surface. If the surface is not 8-bit or 32-bit RGBA/ABGR,
  ## it will be converted into a 32-bit RGBA format on the fly.
  ##
  ## `angle` The angle to rotate in degrees.
  ##
  ## `zoomx` The horizontal scaling factor.
  ##
  ## `zoomy` The vertical scaling factor.
  ##
  ## `smooth`  Antialiasing flag. Set to `SMOOTHING_ON` to enable.
  ##
  ## `Return` the new rotozoomed surface.

proc rotozoomSurfaceSize*(width, height: cint; angle, zoom: cdouble;
                          dstwidth, dstheight: var cint) {.importc.}
  ## `Return` the size of the resulting target surface
  ## for a `rotozoomSurface()` call.
  ##
  ## `width` The source surface width.
  ##
  ## `height`  The source surface height.
  ##
  ## `angle` The angle to rotate in degrees.
  ##
  ## `zoom`  The scaling factor.
  ##
  ## `dstwidth`  The calculated width of the rotozoomed destination surface.
  ##
  ## `dstheight` The calculated height of the rotozoomed destination surface.

proc rotozoomSurfaceSizeXY*(width, height: cint; angle, zoomX, zoomY: cdouble;
                            dstwidth, dstheight: var cint) {.importc.}
  ## `Return` the size of the resulting target surface
  ## for a `rotozoomSurfaceXY()` call.
  ##
  ## `width` The source surface width.
  ##
  ## `height`  The source surface height.
  ##
  ## `angle` The angle to rotate in degrees.
  ##
  ## `zoomx`  The horizontal scaling factor.
  ##
  ## `zoomy` The vertical scaling factor.
  ##
  ## `dstwidth`  The calculated width of the rotozoomed destination surface.
  ##
  ## `dstheight` The calculated height of the rotozoomed destination surface.

proc zoomSurface*(src: SurfacePtr; zoomX, zoomY: cdouble;
                  smooth: cint): SurfacePtr {.importc.}
  ## Zoom a surface by independent horizontal and vertical factors
  ## with optional smoothing.
  ##
  ## `zoomx` The horizontal zoom factor.
  ##
  ## `zoomy` The vertical zoom factor.
  ##
  ## `smooth` Antialiasing flag. Set to `SMOOTHING_ON` to enable.
  ##
  ## `Return` the new, zoomed surface.

proc zoomSurfaceSize*(width, height: cint; zoomX, zoomY: cdouble;
                      dstWidth, dstHeight: var cint) {.importc.}
  ## Calculates the size of the target surface for a `zoomSurface()` call.
  ##
  ## The minimum size of the target surface is `1`.
  ## The input facors can be positive or negative.
  ##
  ## `width` The width of the soruce surface to zoom.
  ##
  ## `height` The height of the source surface to zoom.
  ##
  ## `zoomx` The horizontal zoom factor.
  ##
  ## `zoomy` The vertical zoom factor.
  ##
  ## `dstwidth`  Pointer to an integer to store the calculated width
  ## of the zoomed target surface.
  ##
  ## `dstheight` Pointer to an integer to store the calculated height
  ## of the zoomed target surface.


proc shrinkSurface*(src: SurfacePtr; factorx, factorY: cint): SurfacePtr {.importc.}
  ## Shrink a surface by an integer ratio using averaging.
  ##
  ## `factorx` The horizontal shrinking ratio.
  ##
  ## `factory` The vertical shrinking ratio.
  ##
  ## `Return` the new, shrunken surface.

proc rotateSurface90Degrees*(src: SurfacePtr;
                             numClockwiseTurns: cint): SurfacePtr {.importc.}
  ## Rotates a 32 bit surface in increments of 90 degrees.
  ##
  ## Specialized `90` degree rotator which rotates a `src` surface
  ## in `90` degree increments clockwise returning a new surface.
  ## Faster than rotozoomer since no scanning or interpolation takes place.
  ##
  ## Input surface must be 8/16/24/32-bit.
  ##
  ## (code contributed by J. Schiller, improved by C. Allport and A. Schiffler)
  ##
  ## `numClockwiseTurns` Number of clockwise `90` degree turns to apply
  ## to the source.
  ##
  ## `Return` the new, rotated surface,
  ## or `nil` for surfaces with incorrect input format.


proc init*(manager: var FpsManager) {.importc: "SDL_initFramerate".}
  ## Initialize the framerate manager, set default framerate
  ## of 30Hz and reset delay interpolation.

proc setFramerate*(manager: var FpsManager; rate: cint): SDL_Return {.
  importc: "SDL_setFramerate", discardable.}
  ## Set the framerate in Hz.
  ##
  ## Sets a new framerate for the manager and reset delay interpolation.
  ## Rate values must be between `FPS_LOWER_LIMIT` and `FPS_UPPER_LIMIT`
  ## inclusive to be accepted.
  ##
  ## `Return` `0` or value for sucess and `-1` for error.

proc getFramerate*(manager: var FpsManager): cint {.importc: "SDL_getFramerate".}
  ## `Return` the current target framerate in Hz or `-1` on error.

proc getFramecount*(manager: var FpsManager): cint {.importc: "SDL_getFramecount".}
  ## Get the current framecount from the framerate manager.
  ## A frame is counted each time `framerateDelay()` is called.
  ##
  ## `Return` current frame count or `-1` on error.

proc delay*(manager: var FpsManager): cint {.
  importc: "SDL_framerateDelay", discardable.}
  ## Generate a delay to accomodate currently set framerate.
  ## Call once in the graphics/rendering loop.
  ## If the computer cannot keep up with the rate (i.e. drawing too slow),
  ## the delay is zero and the delay interpolation is reset.
  ##
  ## `Return` time that passed since the last call to the procedure in ms.
  ## May return `0`.


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
