class PDFGroup
  constructor: (@doc, @bbox) ->
    @name = 'G' + (++@doc._groupCount)
    @closed = false
    @resources = @doc.ref
      ProcSet: ['PDF', 'Text', 'ImageB', 'ImageC', 'ImageI']
    @xobj = @doc.ref
      Type: 'XObject'
      Subtype: 'Form'
      FormType: 1
      BBox: @bbox
      Resources: @resources
      Group:
        S: 'Transparency'
        CS: 'DeviceRGB'
        I: true
        K: false

    # text.coffee mixin uses these
    @page =
      width: @bbox[2] - @bbox[0]
      height: @bbox[3] - @bbox[1]
      margins:
        left: -@bbox[0]
        top: -@bbox[1]
        right: 0
        bottom: 0

    @doc._groups[@name] = this

    @initColor()
    @initVector()
    @initFonts()
    @initText()
    @initImages()

  mixin = (methods) =>
    for name, method of methods
      this::[name] = method

  mixin require './mixins/color'
  mixin require './mixins/vector'
  mixin require './mixins/fonts'
  mixin require './mixins/text'
  mixin require './mixins/images'

  close: () ->
    @resources.end()
    @xobj.end()
    @closed = true

  ref: (data) ->
    return @doc.ref(data)

  addContent: (data) ->
    @xobj.write data
    return this
  
  addResource: (type, key, data) ->
    dictionary = @resources.data[type] ?= {}
    dictionary[key] ?= data
    return this

  getBBox: () ->
    return @bbox

module.exports = PDFGroup
