when defined(Linux):
  const LibName = "libSDL2_ttf.so"
elif defined(macosx):
  const LibName = "libSDL2_ttf.dylib"

import sdl2

type
  PFont* = ptr object{.pure.}
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
#
{.push callConv:cdecl, dynlib:LibName.}

proc TTF_Linked_Version*(): ptr SDL_version {.importc: "TTF_Linked_Version".}
# ZERO WIDTH NO-BREAKSPACE (Unicode byte order mark) 
const 
  UNICODE_BOM_NATIVE* = 0x0000FEFF
  UNICODE_BOM_SWAPPED* = 0x0000FFFE
# This function tells the library whether UNICODE text is generally
#   byteswapped.  A UNICODE BOM character in a string will override
#   this setting for the remainder of that string.
#
proc TTF_ByteSwappedUNICODE*(swapped: cint) {.importc: "TTF_ByteSwappedUNICODE".}

# Initialize the TTF engine - returns 0 if successful, -1 on error 
proc TTF_Init*(): SDL_Return  {.importc: "TTF_Init".}
# Open a font file and create a font of the specified point size.
#  Some .fon fonts will have several sizes embedded in the file, so the
#  point size becomes the index of choosing which size.  If the value
#  is too high, the last indexed size will be the default. 
proc OpenFont*(file: cstring; ptsize: cint): PFont {.importc: "TTF_OpenFont".}
proc OpenFontIndex*(file: cstring; ptsize: cint; index: clong): PFont {.importc: "TTF_OpenFontIndex".}
proc OpenFontRW*(src: ptr TRWops; freesrc: cint; ptsize: cint): PFont {.importc: "TTF_OpenFontRW".}
proc OpenFontIndexRW*(src: ptr TRWops; freesrc: cint; ptsize: cint; 
                          index: clong): PFont {.importc: "TTF_OpenFontIndexRW".}
# Set and retrieve the font style 
const 
  TTF_STYLE_NORMAL* = 0x00000000
  TTF_STYLE_BOLD* = 0x00000001
  TTF_STYLE_ITALIC* = 0x00000002
  TTF_STYLE_UNDERLINE* = 0x00000004
  TTF_STYLE_STRIKETHROUGH* = 0x00000008
proc GetFontStyle*(font: PFont): cint  {.importc: "TTF_GetFontStyle".}
proc SetFontStyle*(font: PFont; style: cint) {.importc: "TTF_SetFontStyle".}
proc GetFontOutline*(font: PFont): cint {.importc: "TTF_GetFontOutline".}
proc SetFontOutline*(font: PFont; outline: cint) {.importc: "TTF_SetFontOutline".}

# Set and retrieve FreeType hinter settings 
const 
  TTF_HINTING_NORMAL* = 0
  TTF_HINTING_LIGHT* = 1
  TTF_HINTING_MONO* = 2
  TTF_HINTING_NONE* = 3
proc GetFontHinting*(font: PFont): cint {.importc: "TTF_GetFontHinting".}
proc SetFontHinting*(font: PFont; hinting: cint) {.importc: "TTF_SetFontHinting".}
# Get the total height of the font - usually equal to point size 
proc FontHeight*(font: PFont): cint {.importc: "TTF_FontHeight".}
# Get the offset from the baseline to the top of the font
#   This is a positive value, relative to the baseline.
# 
proc FontAscent*(font: PFont): cint {.importc: "TTF_FontAscent".}
# Get the offset from the baseline to the bottom of the font
#   This is a negative value, relative to the baseline.
# 
proc FontDescent*(font: PFont): cint {.importc: "TTF_FontDescent".}
# Get the recommended spacing between lines of text for this font 
proc FontLineSkip*(font: PFont): cint {.importc: "TTF_FontLineSkip".}
# Get/Set whether or not kerning is allowed for this font 
proc GetFontKerning*(font: PFont): cint {.importc: "TTF_GetFontKerning".}
proc SetFontKerning*(font: PFont; allowed: cint) {.importc: "TTF_SetFontKerning".}
# Get the number of faces of the font 
proc FontFaces*(font: PFont): clong {.importc: "TTF_FontFaces".}
# Get the font face attributes, if any 
proc FontFaceIsFixedWidth*(font: PFont): cint {.importc: "TTF_FontFaceIsFixedWidth".}
proc FontFaceFamilyName*(font: PFont): cstring {.importc: "TTF_FontFaceFamilyName".}
proc FontFaceStyleName*(font: PFont): cstring {.importc: "TTF_FontFaceStyleName".}
# Check wether a glyph is provided by the font or not 
proc GlyphIsProvided*(font: PFont; ch: uint16): cint {.importc: "TTF_GlyphIsProvided".}
# Get the metrics (dimensions) of a glyph
#   To understand what these metrics mean, here is a useful link:
#    http://freetype.sourceforge.net/freetype2/docs/tutorial/step2.html
# 
proc GlyphMetrics*(font: PFont; ch: uint16; minx: ptr cint; 
                       maxx: ptr cint; miny: ptr cint; maxy: ptr cint; 
                       advance: ptr cint): cint {.importc: "TTF_GlyphMetrics".}
# Get the dimensions of a rendered string of text 
proc SizeText*(font: PFont; text: cstring; w: ptr cint; h: ptr cint): cint{.
  importc: "TTF_SizeText".}
proc SizeUTF8*(font: PFont; text: cstring; w: ptr cint; h: ptr cint): cint{.
  importc: "TTF_SizeUTF8".}
proc SizeUNICODE*(font: PFont; text: ptr uint16; w, h: ptr cint): cint{.
  importc: "TTF_SizeUNICODE".}
# Create an 8-bit palettized surface and render the given text at
#   fast quality with the given font and color.  The 0 pixel is the
#   colorkey, giving a transparent background, and the 1 pixel is set
#   to the text color.
#   This function returns the new surface, or NULL if there was an error.
#
proc RenderText_Solid*(font: PFont; text: cstring; fg: TColor): PSurface{.
  importc: "TTF_RenderText_Solid".}
proc RenderUTF8_Solid*(font: PFont; text: cstring; fg: TColor): PSurface{.
  importc: "TTF_RenderUTF8_Solid".}
proc RenderUNICODE_Solid*(font: PFont; text: ptr uint16; 
  fg: TColor): PSurface {.importc: "TTF_RenderUNICODE_Solid".}
# Create an 8-bit palettized surface and render the given glyph at
#   fast quality with the given font and color.  The 0 pixel is the
#   colorkey, giving a transparent background, and the 1 pixel is set
#   to the text color.  The glyph is rendered without any padding or
#   centering in the X direction, and aligned normally in the Y direction.
#   This function returns the new surface, or NULL if there was an error.
#
proc RenderGlyph_Solid*(font: PFont; ch: uint16; fg: TColor): PSurface {.
  importc: "TTF_RenderGlyph_Solid".}

proc RenderText_Shaded*(font: PFont; text: cstring; fg, bg: TColor): PSurface {.
  importc: "TTF_RenderText_Shaded".}
proc RenderUTF8_Shaded*(font: PFont; text: cstring; fg, bg: TColor): PSurface {.
  importc: "TTF_RenderUTF8_Shaded".}
proc RenderUNICODE_Shaded*(font: PFont; text: ptr uint16; 
  fg, bg: TColor): PSurface {.importc: "TTF_RenderUNICODE_Shaded".}
# Create an 8-bit palettized surface and render the given glyph at
#   high quality with the given font and colors.  The 0 pixel is background,
#   while other pixels have varying degrees of the foreground color.
#   The glyph is rendered without any padding or centering in the X
#   direction, and aligned normally in the Y direction.
#   This function returns the new surface, or NULL if there was an error.
#
proc RenderGlyph_Shaded*(font: PFont; ch: uint16; fg, bg: TColor): PSurface {.
  importc: "TTF_RenderGlyph_Shaded".}
# Create a 32-bit ARGB surface and render the given text at high quality,
#   using alpha blending to dither the font with the given color.
#   This function returns the new surface, or NULL if there was an error.
#
proc RenderText_Blended*(font: PFont; text: cstring; fg: TColor): PSurface {.
  importc: "TTF_RenderText_Blended".}
proc RenderUTF8_Blended*(font: PFont; text: cstring; fg: TColor): PSurface {.
  importc: "TTF_RenderUTF8_Blended".}
proc RenderUNICODE_Blended*(font: PFont; text: ptr uint16; 
  fg: TColor): PSurface {.importc: "TTF_RenderUNICODE_Blended".}
# Create a 32-bit ARGB surface and render the given text at high quality,
#   using alpha blending to dither the font with the given color.
#   Text is wrapped to multiple lines on line endings and on word boundaries
#   if it extends beyond wrapLength in pixels.
#   This function returns the new surface, or NULL if there was an error.
#
proc RenderText_Blended_Wrapped*(font: PFont; text: cstring; fg: TColor; 
  wrapLength: uint32): PSurface {.importc: "TTF_RenderText_Blended_Wrapped".}
proc RenderUTF8_Blended_Wrapped*(font: PFont; text: cstring; fg: TColor; 
  wrapLength: uint32): PSurface {.importc: "TTF_RenderUTF8_Blended_Wrapped".}
proc RenderUNICODE_Blended_Wrapped*(font: PFont; text: ptr uint16; fg: TColor;
  wrapLength: uint32): PSurface  {.importc: "TTF_RenderUNICODE_Blended_Wrapped".}
# Create a 32-bit ARGB surface and render the given glyph at high quality,
#   using alpha blending to dither the font with the given color.
#   The glyph is rendered without any padding or centering in the X
#   direction, and aligned normally in the Y direction.
#   This function returns the new surface, or NULL if there was an error.
#
proc RenderGlyph_Blended*(font: PFont; ch: uint16; fg: TColor): PSurface {.
  importc: "TTF_RenderGlyph_Blended".}


#
#/* Close an opened font file 
proc Close*(font: PFont) {.importc: "TTF_CloseFont".}
# De-initialize the TTF engine 
proc TTF_Quit*() {.importc: "TTF_Quit".}
# Check if the TTF engine is initialized 
proc TTF_WasInit*(): bool {.importc: "TTF_WasInit".}
# Get the kerning size of two glyphs 
proc GetFontKerningSize*(font: PFont; prev_index, indx: cint): cint {.
  importc: "TTF_GetFontKerningSize".}

{.pop.}


# For compatibility with previous versions, here are the old functions 
##define TTF_RenderText(font, text, fg, bg)	\
# TTF_RenderText_Shaded(font, text, fg, bg)
##define TTF_RenderUTF8(font, text, fg, bg)	\
# TTF_RenderUTF8_Shaded(font, text, fg, bg)
##define TTF_RenderUNICODE(font, text, fg, bg)	\
# TTF_RenderUNICODE_Shaded(font, text, fg, bg)

proc RenderText*(font: PFont; text: cstring; 
  fg, bg: TColor): PSurface = RenderText_Shaded(font, text, fg, bg) 

