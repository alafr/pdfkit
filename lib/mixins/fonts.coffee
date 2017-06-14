PDFFont = require '../font'

module.exports =
  initFonts: ->
    # Lookup table for embedded fonts
    @globals.fontFamilies = {}
    @globals.fontCount ?= 0

    # Font state
    @_fontSize = 12
    @_font = null

    @globals.registeredFonts ?= {}

    # Set the default font
    @font 'Helvetica'

  font: (src, family, size) ->
    if typeof family is 'number'
      size = family
      family = null

    # check registered fonts if src is a string
    if typeof src is 'string' and @globals.registeredFonts[src]
      cacheKey = src
      {src, family} = @globals.registeredFonts[src]
    else
      cacheKey = family or src
      cacheKey = null unless typeof cacheKey is 'string'

    @fontSize size if size?

    # fast path: check if the font is already in the PDF
    if font = @globals.fontFamilies[cacheKey]
      @_font = font
      return this

    # load the font
    id = 'F' + (++@globals.fontCount)
    @_font = PDFFont.open(this, src, family, id)

    # check for existing font familes with the same name already in the PDF
    # useful if the font was passed as a buffer
    if font = @globals.fontFamilies[@_font.name]
      @_font = font
      return this

    # save the font for reuse later
    if cacheKey
      @globals.fontFamilies[cacheKey] = @_font

    if @_font.name
      @globals.fontFamilies[@_font.name] = @_font

    return this

  fontSize: (@_fontSize) ->
    return this

  currentLineHeight: (includeGap = false) ->
    @_font.lineHeight @_fontSize, includeGap

  registerFont: (name, src, family) ->
    @globals.registeredFonts[name] =
      src: src
      family: family

    return this
