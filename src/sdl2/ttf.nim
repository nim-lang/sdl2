{.deadCodeElim: on.}

when not defined(SDL_Static):
  when defined(Linux):
    const LibName = "libSDL2_ttf(|-2.0).so(|.0)"
  elif defined(macosx):
    const LibName = "libSDL2_ttf.dylib"
  elif defined(Windows):
    const LibName* = "SDL2_ttf.dll"

import sdl2

type
  FontPtr* = ptr object{.pure.}

# Set up for C function definitions, even when using C++
# Printable format: "%d.%d.%d", MAJOR, MINOR, PATCHLEVEL
#/*
##define SDL_TTF_MAJOR_VERSION	2
##define SDL_TTF_MINOR_VERSION	0
##define SDL_TTF_PATCHLEVEL	12
#
# This macro can be used to fill a version structure with the compile-time
#  version of the SDL_ttf library.
#
##define SDL_TTF_VERSION(X)						\
#{									\
# (X)->major = SDL_TTF_MAJOR_VERSION;				\
# (X)->minor = SDL_TTF_MINOR_VERSION;				\
# (X)->patch = SDL_TTF_PATCHLEVEL;				\
#}
# Backwards compatibility
##define TTF_MAJOR_VERSION	SDL_TTF_MAJOR_VERSION
##define TTF_MINOR_VERSION	SDL_TTF_MINOR_VERSION
#//#define TTF_PATCHLEVEL		SDL_TTF_PATCHLEVEL
##define TTF_VERSION(X)		SDL_TTF_VERSION(X)

when defined(SDL_Static):
  {.push header: "<SDL2/SDL_ttf.h>".}
else:
  {.push callConv:cdecl, dynlib:LibName.}

proc ttfLinkedVersion*(): ptr SDL_version {.importc: "TTF_Linked_Version".}
# ZERO WIDTH NO-BREAKSPACE (Unicode byte order mark)
const
  UNICODE_BOM_NATIVE* = 0x0000FEFF
  UNICODE_BOM_SWAPPED* = 0x0000FFFE
# This function tells the library whether UNICODE text is generally
#   byteswapped.  A UNICODE BOM character in a string will override
#   this setting for the remainder of that string.
#
proc ttfByteSwappedUnicode*(swapped: cint) {.importc: "TTF_ByteSwappedUNICODE".}

# Initialize the TTF engine - returns 0 if successful, -1 on error
proc ttfInit*(): SDL_Return  {.importc: "TTF_Init", discardable.}
# Open a font file and create a font of the specified point size.
#  Some .fon fonts will have several sizes embedded in the file, so the
#  point size becomes the index of choosing which size.  If the value
#  is too high, the last indexed size will be the default.
proc openFont*(file: cstring; ptsize: cint): FontPtr {.importc: "TTF_OpenFont".}
proc openFontIndex*(file: cstring; ptsize: cint; index: clong): FontPtr {.importc: "TTF_OpenFontIndex".}
proc openFontRW*(src: ptr RWops; freesrc: cint; ptsize: cint): FontPtr {.importc: "TTF_OpenFontRW".}
proc openFontIndexRW*(src: ptr RWops; freesrc: cint; ptsize: cint;
                          index: clong): FontPtr {.importc: "TTF_OpenFontIndexRW".}
# Set and retrieve the font style
const
  TTF_STYLE_NORMAL* = 0x00000000
  TTF_STYLE_BOLD* = 0x00000001
  TTF_STYLE_ITALIC* = 0x00000002
  TTF_STYLE_UNDERLINE* = 0x00000004
  TTF_STYLE_STRIKETHROUGH* = 0x00000008
proc getFontStyle*(font: FontPtr): cint  {.importc: "TTF_GetFontStyle".}
proc setFontStyle*(font: FontPtr; style: cint) {.importc: "TTF_SetFontStyle".}
proc getFontOutline*(font: FontPtr): cint {.importc: "TTF_GetFontOutline".}
proc setFontOutline*(font: FontPtr; outline: cint) {.importc: "TTF_SetFontOutline".}

# Set and retrieve FreeType hinter settings
const
  TTF_HINTING_NORMAL* = 0
  TTF_HINTING_LIGHT* = 1
  TTF_HINTING_MONO* = 2
  TTF_HINTING_NONE* = 3
proc getFontHinting*(font: FontPtr): cint {.importc: "TTF_GetFontHinting".}
proc setFontHinting*(font: FontPtr; hinting: cint) {.importc: "TTF_SetFontHinting".}
# Get the total height of the font - usually equal to point size
proc fontHeight*(font: FontPtr): cint {.importc: "TTF_FontHeight".}
# Get the offset from the baseline to the top of the font
#   This is a positive value, relative to the baseline.
#
proc fontAscent*(font: FontPtr): cint {.importc: "TTF_FontAscent".}
# Get the offset from the baseline to the bottom of the font
#   This is a negative value, relative to the baseline.
#
proc fontDescent*(font: FontPtr): cint {.importc: "TTF_FontDescent".}
# Get the recommended spacing between lines of text for this font
proc fontLineSkip*(font: FontPtr): cint {.importc: "TTF_FontLineSkip".}
# Get/Set whether or not kerning is allowed for this font
proc getFontKerning*(font: FontPtr): cint {.importc: "TTF_GetFontKerning".}
proc setFontKerning*(font: FontPtr; allowed: cint) {.importc: "TTF_SetFontKerning".}
# Get the number of faces of the font
proc fontFaces*(font: FontPtr): clong {.importc: "TTF_FontFaces".}
# Get the font face attributes, if any
proc fontFaceIsFixedWidth*(font: FontPtr): cint {.importc: "TTF_FontFaceIsFixedWidth".}
proc fontFaceFamilyName*(font: FontPtr): cstring {.importc: "TTF_FontFaceFamilyName".}
proc fontFaceStyleName*(font: FontPtr): cstring {.importc: "TTF_FontFaceStyleName".}
# Check wether a glyph is provided by the font or not
proc glyphIsProvided*(font: FontPtr; ch: uint16): cint {.importc: "TTF_GlyphIsProvided".}
# Get the metrics (dimensions) of a glyph
#   To understand what these metrics mean, here is a useful link:
#    http://freetype.sourceforge.net/freetype2/docs/tutorial/step2.html
#
proc glyphMetrics*(font: FontPtr; ch: uint16; minx: ptr cint;
                       maxx: ptr cint; miny: ptr cint; maxy: ptr cint;
                       advance: ptr cint): cint {.importc: "TTF_GlyphMetrics".}
# Get the dimensions of a rendered string of text
proc sizeText*(font: FontPtr; text: cstring; w: ptr cint; h: ptr cint): cint{.
  importc: "TTF_SizeText".}
proc sizeUtf8*(font: FontPtr; text: cstring; w: ptr cint; h: ptr cint): cint{.
  importc: "TTF_SizeUTF8".}
proc sizeUnicode*(font: FontPtr; text: ptr uint16; w, h: ptr cint): cint{.
  importc: "TTF_SizeUNICODE".}
# Create an 8-bit palettized surface and render the given text at
#   fast quality with the given font and color.  The 0 pixel is the
#   colorkey, giving a transparent background, and the 1 pixel is set
#   to the text color.
#   This function returns the new surface, or NULL if there was an error.
#
proc renderTextSolid*(font: FontPtr; text: cstring; fg: Color): SurfacePtr{.
  importc: "TTF_RenderText_Solid".}
proc renderUtf8Solid*(font: FontPtr; text: cstring; fg: Color): SurfacePtr{.
  importc: "TTF_RenderUTF8_Solid".}
proc renderUnicodeSolid*(font: FontPtr; text: ptr uint16;
  fg: Color): SurfacePtr {.importc: "TTF_RenderUNICODE_Solid".}
# Create an 8-bit palettized surface and render the given glyph at
#   fast quality with the given font and color.  The 0 pixel is the
#   colorkey, giving a transparent background, and the 1 pixel is set
#   to the text color.  The glyph is rendered without any padding or
#   centering in the X direction, and aligned normally in the Y direction.
#   This function returns the new surface, or NULL if there was an error.
#
proc renderGlyphSolid*(font: FontPtr; ch: uint16; fg: Color): SurfacePtr {.
  importc: "TTF_RenderGlyph_Solid".}

proc renderTextShaded*(font: FontPtr; text: cstring; fg, bg: Color): SurfacePtr {.
  importc: "TTF_RenderText_Shaded".}
proc renderUtf8Shaded*(font: FontPtr; text: cstring; fg, bg: Color): SurfacePtr {.
  importc: "TTF_RenderUTF8_Shaded".}
proc renderUnicodeShaded*(font: FontPtr; text: ptr uint16;
  fg, bg: Color): SurfacePtr {.importc: "TTF_RenderUNICODE_Shaded".}
# Create an 8-bit palettized surface and render the given glyph at
#   high quality with the given font and colors.  The 0 pixel is background,
#   while other pixels have varying degrees of the foreground color.
#   The glyph is rendered without any padding or centering in the X
#   direction, and aligned normally in the Y direction.
#   This function returns the new surface, or NULL if there was an error.
#
proc renderGlyphShaded*(font: FontPtr; ch: uint16; fg, bg: Color): SurfacePtr {.
  importc: "TTF_RenderGlyph_Shaded".}
# Create a 32-bit ARGB surface and render the given text at high quality,
#   using alpha blending to dither the font with the given color.
#   This function returns the new surface, or NULL if there was an error.
#
proc renderTextBlended*(font: FontPtr; text: cstring; fg: Color): SurfacePtr {.
  importc: "TTF_RenderText_Blended".}
proc renderUtf8Blended*(font: FontPtr; text: cstring; fg: Color): SurfacePtr {.
  importc: "TTF_RenderUTF8_Blended".}
proc renderUnicodeBlended*(font: FontPtr; text: ptr uint16;
  fg: Color): SurfacePtr {.importc: "TTF_RenderUNICODE_Blended".}
# Create a 32-bit ARGB surface and render the given text at high quality,
#   using alpha blending to dither the font with the given color.
#   Text is wrapped to multiple lines on line endings and on word boundaries
#   if it extends beyond wrapLength in pixels.
#   This function returns the new surface, or NULL if there was an error.
#
proc renderTextBlendedWrapped*(font: FontPtr; text: cstring; fg: Color; wrapLength: uint32):
  SurfacePtr {.importc: "TTF_RenderText_Blended_Wrapped".}
proc renderUtf8BlendedWrapped*(font: FontPtr; text: cstring; fg: Color;
  wrapLength: uint32): SurfacePtr {.importc: "TTF_RenderUTF8_Blended_Wrapped".}
proc renderUnicodeBlendedWrapped*(font: FontPtr; text: ptr uint16; fg: Color;
  wrapLength: uint32): SurfacePtr  {.importc: "TTF_RenderUNICODE_Blended_Wrapped".}
# Create a 32-bit ARGB surface and render the given glyph at high quality,
#   using alpha blending to dither the font with the given color.
#   The glyph is rendered without any padding or centering in the X
#   direction, and aligned normally in the Y direction.
#   This function returns the new surface, or NULL if there was an error.
#
proc renderGlyphBlended*(font: FontPtr; ch: uint16; fg: Color): SurfacePtr {.
  importc: "TTF_RenderGlyph_Blended".}


#
#/* Close an opened font file
proc close*(font: FontPtr) {.importc: "TTF_CloseFont".}
# De-initialize the TTF engine
proc ttfQuit*() {.importc: "TTF_Quit".}
# Check if the TTF engine is initialized
proc ttfWasInit*(): bool {.importc: "TTF_WasInit".}
# Get the kerning size of two glyphs
proc getFontKerningSize*(font: FontPtr; prev_index, indx: cint): cint {.
  importc: "TTF_GetFontKerningSize".}

proc ttfGetError*(): cstring {.importc: "TTF_GetError".}

{.pop.}


# For compatibility with previous versions, here are the old functions
##define TTF_RenderText(font, text, fg, bg)	\
# TTF_RenderText_Shaded(font, text, fg, bg)
##define TTF_RenderUTF8(font, text, fg, bg)	\
# TTF_RenderUTF8_Shaded(font, text, fg, bg)
##define TTF_RenderUNICODE(font, text, fg, bg)	\
# TTF_RenderUNICODE_Shaded(font, text, fg, bg)

proc renderText*(font: FontPtr; text: cstring;
  fg, bg: Color): SurfacePtr = renderTextShaded(font, text, fg, bg)

{.deprecated: [PFont: FontPtr].}

{.deprecated: [Close: close].}
{.deprecated: [FontAscent: fontAscent].}
{.deprecated: [FontDescent: fontDescent].}
{.deprecated: [FontFaceFamilyName: fontFaceFamilyName].}
{.deprecated: [FontFaceIsFixedWidth: fontFaceIsFixedWidth].}
{.deprecated: [FontFaceStyleName: fontFaceStyleName].}
{.deprecated: [FontFaces: fontFaces].}
{.deprecated: [FontHeight: fontHeight].}
{.deprecated: [FontLineSkip: fontLineSkip].}
{.deprecated: [GetFontHinting: getFontHinting].}
{.deprecated: [GetFontKerning: getFontKerning].}
{.deprecated: [GetFontKerningSize: getFontKerningSize].}
{.deprecated: [GetFontOutline: getFontOutline].}
{.deprecated: [GetFontStyle: getFontStyle].}
{.deprecated: [GlyphIsProvided: glyphIsProvided].}
{.deprecated: [GlyphMetrics: glyphMetrics].}
{.deprecated: [OpenFont: openFont].}
{.deprecated: [OpenFontIndex: openFontIndex].}
{.deprecated: [OpenFontIndexRW: openFontIndexRW].}
{.deprecated: [OpenFontRW: openFontRW].}
{.deprecated: [RenderGlyph_Blended: renderGlyphBlended].}
{.deprecated: [RenderGlyph_Shaded: renderGlyphShaded].}
{.deprecated: [RenderGlyph_Solid: renderGlyphSolid].}
{.deprecated: [RenderText: renderText].}
{.deprecated: [RenderText_Blended: renderTextBlended].}
{.deprecated: [RenderText_Blended_Wrapped: renderTextBlendedWrapped].}
{.deprecated: [RenderText_Shaded: renderTextShaded].}
{.deprecated: [RenderText_Solid: renderTextSolid].}
{.deprecated: [RenderUNICODE_Blended: renderUnicodeBlended].}
{.deprecated: [RenderUNICODE_Blended_Wrapped: renderUnicodeBlendedWrapped].}
{.deprecated: [RenderUNICODE_Shaded: renderUnicodeShaded].}
{.deprecated: [RenderUNICODE_Solid: renderUnicodeSolid].}
{.deprecated: [RenderUTF8_Blended: renderUtf8Blended].}
{.deprecated: [RenderUTF8_Blended_Wrapped: renderUtf8BlendedWrapped].}
{.deprecated: [RenderUTF8_Shaded: renderUtf8Shaded].}
{.deprecated: [RenderUTF8_Solid: renderUtf8Solid].}
{.deprecated: [SetFontHinting: setFontHinting].}
{.deprecated: [SetFontKerning: setFontKerning].}
{.deprecated: [SetFontOutline: setFontOutline].}
{.deprecated: [SetFontStyle: setFontStyle].}
{.deprecated: [SizeText: sizeText].}
{.deprecated: [SizeUNICODE: sizeUnicode].}
{.deprecated: [SizeUTF8: sizeUtf8].}
{.deprecated: [TTF_ByteSwappedUNICODE: ttfByteSwappedUnicode].}
{.deprecated: [TTF_Init: ttfInit].}
{.deprecated: [TTF_Linked_Version: ttfLinkedVersion].}
{.deprecated: [TTF_Quit: ttfQuit].}
{.deprecated: [TTF_WasInit: ttfWasInit].}
