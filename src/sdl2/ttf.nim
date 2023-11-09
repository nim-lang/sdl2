## TrueType font rendering library.
##
## **Note:**
## In many places, ttf will say "glyph" when it means "code point."
## Unicode is hard, we learn as we go, and we apologize for adding to the
## confusion.

{.deadCodeElim: on.}

when not defined(SDL_Static):
  when defined(windows):
    const LibName* = "SDL2_ttf.dll"
  elif defined(macosx):
    const LibName = "libSDL2_ttf.dylib"
  else:
    const LibName = "libSDL2_ttf(|-2.0).so(|.0)"
else:
  static: echo "SDL_Static option is deprecated and will soon be removed. Instead please use --dynlibOverride:SDL2."

import sdl2

type
  FontPtr* {.pure.} = ptr object
    ## The internal structure containing font information

when not defined(SDL_Static):
  {.push callConv:cdecl, dynlib:LibName.}

proc ttfLinkedVersion*(): ptr SDL_version {.importc: "TTF_Linked_Version".}
  ## This procedure gets the version of the dynamically linked ttf library.
  # TODO Add an equivalent of the `TTF_VERSION` macro (version template ?)
  # and this comment:
  # It should NOT be used to fill a version structure, instead you should
  # use the `version()` template.

# ZERO WIDTH NO-BREAKSPACE (Unicode byte order mark)
const
  UNICODE_BOM_NATIVE* = 0x0000FEFF
  UNICODE_BOM_SWAPPED* = 0x0000FFFE

proc ttfByteSwappedUnicode*(swapped: cint) {.importc: "TTF_ByteSwappedUNICODE".}
  ## This procedure tells the library whether UNICODE text is generally
  ## byteswapped.  A UNICODE BOM character in a string will override
  ## this setting for the remainder of that string.

proc ttfInit*(): SDL_Return  {.importc: "TTF_Init", discardable.}
  ## Initialize the TTF engine.
  ##
  ## `Return` `0` if successful, `-1` on error.

proc openFont*(file: cstring; ptsize: cint): FontPtr {.importc: "TTF_OpenFont".}
  ## Open a font file and create a font of the specified point size.
  ## Some .fon fonts will have several sizes embedded in the file, so the
  ## point size becomes the index of choosing which size.  If the value
  ## is too high, the last indexed size will be the default.
  ##
  ## **See also:**
  ## * `openFontIndex proc<#openFontIndex,cstring,cint,clong>`_
  ## * `openFontRW proc<#openFontRW,ptr.RWops,cint,cint>`_
  ## * `openFontIndexRW proc<#openFontIndexRW,ptr.RWops,cint,cint,clong>`_

proc openFontIndex*(file: cstring; ptsize: cint; index: clong): FontPtr {.
  importc: "TTF_OpenFontIndex".}
proc openFontRW*(src: ptr RWops; freesrc: cint; ptsize: cint): FontPtr {.
  importc: "TTF_OpenFontRW".}
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
proc getStyle*(font: FontPtr): cint  {.importc: "TTF_GetFontStyle".}
proc setFontStyle*(font: FontPtr; style: cint) {.importc: "TTF_SetFontStyle".}
proc setStyle*(font: FontPtr; style: cint) {.importc: "TTF_SetFontStyle".}
proc getFontOutline*(font: FontPtr): cint {.importc: "TTF_GetFontOutline".}
proc getOutline*(font: FontPtr): cint {.importc: "TTF_GetFontOutline".}
proc setFontOutline*(font: FontPtr; outline: cint) {.importc: "TTF_SetFontOutline".}
proc setOutline*(font: FontPtr; outline: cint) {.importc: "TTF_SetFontOutline".}

# Set and retrieve FreeType hinter settings
const
  TTF_HINTING_NORMAL* = 0
  TTF_HINTING_LIGHT* = 1
  TTF_HINTING_MONO* = 2
  TTF_HINTING_NONE* = 3
  TTF_HINTING_LIGHT_SUBPIXEL* = 4
proc getFontHinting*(font: FontPtr): cint {.importc: "TTF_GetFontHinting".}
proc getHinting*(font: FontPtr): cint {.importc: "TTF_GetFontHinting".}

proc setFontHinting*(font: FontPtr; hinting: cint) {.importc: "TTF_SetFontHinting".}
proc setHinting*(font: FontPtr; hinting: cint) {.importc: "TTF_SetFontHinting".}

proc fontHeight*(font: FontPtr): cint {.importc: "TTF_FontHeight".}
proc height*(font: FontPtr): cint {.importc: "TTF_FontHeight".}
  ## Get the total height of the font - usually equal to point size.

proc fontAscent*(font: FontPtr): cint {.importc: "TTF_FontAscent".}
proc ascent*(font: FontPtr): cint {.importc: "TTF_FontAscent".}
  ## Get the offset from the baseline to the top of the font.
  ##
  ## This is a positive value, relative to the baseline.

proc fontDescent*(font: FontPtr): cint {.importc: "TTF_FontDescent".}
proc descent*(font: FontPtr): cint {.importc: "TTF_FontDescent".}
  ## Get the offset from the baseline to the bottom of the font.
  ##
  ## This is a negative value, relative to the baseline.

proc fontLineSkip*(font: FontPtr): cint {.importc: "TTF_FontLineSkip".}
proc lineSkip*(font: FontPtr): cint {.importc: "TTF_FontLineSkip".}
  ## Get the recommended spacing between lines of text for this font.

proc getFontKerning*(font: FontPtr): cint {.importc: "TTF_GetFontKerning".}
proc getKerning*(font: FontPtr): cint {.importc: "TTF_GetFontKerning".}
  ## Get whether or not kerning is allowed for this font.

proc setFontKerning*(font: FontPtr; allowed: cint) {.importc: "TTF_SetFontKerning".}
proc setKerning*(font: FontPtr; allowed: cint) {.importc: "TTF_SetFontKerning".}
  ## Set whether or not kerning is allowed for this font.

proc fontFaces*(font: FontPtr): clong {.importc: "TTF_FontFaces".}
  ## Get the number of faces of the font.

proc fontFaceIsFixedWidth*(font: FontPtr): cint {.importc: "TTF_FontFaceIsFixedWidth".}
  ## Get the font face attributes, if any.

proc fontFaceFamilyName*(font: FontPtr): cstring {.importc: "TTF_FontFaceFamilyName".}
proc fontFaceStyleName*(font: FontPtr): cstring {.importc: "TTF_FontFaceStyleName".}

proc glyphIsProvided*(font: FontPtr; ch: uint16): cint {.
  importc: "TTF_GlyphIsProvided".}
  ## Check wether a glyph is provided by the font or not.

proc glyphMetrics*(font: FontPtr; ch: uint16; minx: ptr cint;
                       maxx: ptr cint; miny: ptr cint; maxy: ptr cint;
                       advance: ptr cint): cint {.importc: "TTF_GlyphMetrics".}
  ## Get the metrics (dimensions) of a glyph.
  ##
  ## To understand what these metrics mean, here is a useful link:
  ##
  ## http://freetype.sourceforge.net/freetype2/docs/tutorial/step2.html

proc sizeText*(font: FontPtr; text: cstring; w: ptr cint; h: ptr cint): cint{.
  importc: "TTF_SizeText".}
  ## Get the dimensions of a rendered string of text.
  ##
  ## **See also:**
  ## * `sizeUtf8 proc<#sizeUtf8,FontPtr,cstring,ptr.cint,ptr.cint>`_
  ## * `sizeUnicode proc<#sizeUnicode,FontPtr,ptr.uint16,ptr.cint,ptr.cint>`_

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
  ## Create an 8-bit palettized surface and render the given text at
  ## fast quality with the given font and color.  The 0 pixel is the
  ## colorkey, giving a transparent background, and the 1 pixel is set
  ## to the text color.
  ##
  ## `Return` the new surface, or `nil` if there was an error.
  ##
  ## **See also:**
  ## * `renderUtf8Solid proc<#renderUtf8Solid,FontPtr,cstring,Color>`_
  ## * `renderUnicodeSolid proc<#renderUnicodeSolid,FontPtr,ptr.uint16,Color>`_

proc renderUtf8Solid*(font: FontPtr; text: cstring; fg: Color): SurfacePtr{.
  importc: "TTF_RenderUTF8_Solid".}
proc renderUnicodeSolid*(font: FontPtr; text: ptr uint16;
  fg: Color): SurfacePtr {.importc: "TTF_RenderUNICODE_Solid".}

proc renderGlyphSolid*(font: FontPtr; ch: uint16; fg: Color): SurfacePtr {.
  importc: "TTF_RenderGlyph_Solid".}
  ## Create an 8-bit palettized surface and render the given glyph at
  ## fast quality with the given font and color.  The 0 pixel is the
  ## colorkey, giving a transparent background, and the 1 pixel is set
  ## to the text color.
  ##
  ## The glyph is rendered without any padding or centering in the X
  ## direction, and aligned normally in the Y direction.
  ##
  ## `Return` the new surface, or `nil` if there was an error.

proc renderTextShaded*(font: FontPtr; text: cstring;
  fg, bg: Color): SurfacePtr {.importc: "TTF_RenderText_Shaded".}
  ## Create an 8-bit palettized surface and render the given text at
  ## high quality with the given font and colors. The 0 pixel is background,
  ## while other pixels have varying degrees of the foreground color.
  ##
  ## `Return` the new surface, or `nil` if there was an error.
  ##
  ## **See also:**
  ## * `renderUtf8Shaded proc<#renderUtf8Shaded,FontPtr,cstring,Color,Color>`_
  ## * `renderUnicodeShaded proc<#renderUnicodeShaded,FontPtr,ptr.uint16,Color,Color>`_

proc renderUtf8Shaded*(font: FontPtr; text: cstring; fg, bg: Color): SurfacePtr {.
  importc: "TTF_RenderUTF8_Shaded".}
proc renderUnicodeShaded*(font: FontPtr; text: ptr uint16;
  fg, bg: Color): SurfacePtr {.importc: "TTF_RenderUNICODE_Shaded".}

proc renderGlyphShaded*(font: FontPtr; ch: uint16; fg, bg: Color): SurfacePtr {.
  importc: "TTF_RenderGlyph_Shaded".}
  ## Create an 8-bit palettized surface and render the given glyph at
  ## high quality with the given font and colors.  The 0 pixel is background,
  ## while other pixels have varying degrees of the foreground color.
  ##
  ## The glyph is rendered without any padding or centering in the X
  ## direction, and aligned normally in the Y direction.
  ##
  ## `Return` the new surface, or `nil` if there was an error.

proc renderTextBlended*(font: FontPtr; text: cstring; fg: Color): SurfacePtr {.
  importc: "TTF_RenderText_Blended".}
  ## Create a 32-bit ARGB surface and render the given text at high quality,
  ## using alpha blending to dither the font with the given color.
  ##
  ## `Return` the new surface, or `nil` if there was an error.
  ##
  ## **See also:**
  ## * `renderUtf8Blended proc<#renderUtf8Blended,FontPtr,cstring,Color>`_
  ## * `renderUnicodeBlended proc<#renderUnicodeBlended,FontPtr,ptr.uint16,Color>`_

proc renderUtf8Blended*(font: FontPtr; text: cstring; fg: Color): SurfacePtr {.
  importc: "TTF_RenderUTF8_Blended".}
proc renderUnicodeBlended*(font: FontPtr; text: ptr uint16;
  fg: Color): SurfacePtr {.importc: "TTF_RenderUNICODE_Blended".}

proc renderTextBlendedWrapped*(font: FontPtr; text: cstring; fg: Color;
  wrapLength: uint32): SurfacePtr {.importc: "TTF_RenderText_Blended_Wrapped".}
  ## Create a 32-bit ARGB surface and render the given text at high quality,
  ## using alpha blending to dither the font with the given color.
  ## Text is wrapped to multiple lines on line endings and on word boundaries
  ## if it extends beyond wrapLength in pixels.
  ##
  ## `Return` the new surface, or `nil` if there was an error.
  ##
  ## **See also:**
  ## * `renderUtf8BlendedWrapped proc<#renderUtf8BlendedWrapped,FontPtr,cstring,Color,uint32>`_
  ## * `renderUnicodeBlendedWrapped proc<#renderUnicodeBlendedWrapped,FontPtr,ptr.uint16,Color,uint32>`_

proc renderUtf8BlendedWrapped*(font: FontPtr; text: cstring; fg: Color;
  wrapLength: uint32): SurfacePtr {.importc: "TTF_RenderUTF8_Blended_Wrapped".}
proc renderUnicodeBlendedWrapped*(font: FontPtr; text: ptr uint16; fg: Color;
  wrapLength: uint32): SurfacePtr  {.importc: "TTF_RenderUNICODE_Blended_Wrapped".}

proc renderGlyphBlended*(font: FontPtr; ch: uint16; fg: Color): SurfacePtr {.
  importc: "TTF_RenderGlyph_Blended".}
  ## Create a 32-bit ARGB surface and render the given glyph at high quality,
  ## using alpha blending to dither the font with the given color.
  ## The glyph is rendered without any padding or centering in the X
  ## direction, and aligned normally in the Y direction.
  ##
  ## `Return` the new surface, or `nil` if there was an error.


proc close*(font: FontPtr) {.importc: "TTF_CloseFont".}
  ## Close an opened font file.

proc ttfQuit*() {.importc: "TTF_Quit".}
  ## De-initialize the TTF engine.

proc ttfWasInit*(): bool {.importc: "TTF_WasInit".}
  ## Check if the TTF engine is initialized.

proc getFontKerningSize*(font: FontPtr; prev_index, indx: cint): cint {.
  importc: "TTF_GetFontKerningSize".}
  ## Get the kerning size of two glyphs indices.

when not defined(SDL_Static):
  {.pop.}


proc renderText*(font: FontPtr; text: cstring; fg, bg: Color): SurfacePtr =
  renderTextShaded(font, text, fg, bg)
