class PDFGroup
  constructor: (@doc, @bbox) ->

    @bbox = @bbox
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
    
    @_ctm = [1, 0, 0, 1, 0, 0]
    @doc._groups[@name] = this

    @initColor()
    @initVector()
    @initImages()

  mixin = (methods) =>
    for name, method of methods
      this::[name] = method

  mixin require './mixins/color'
  mixin require './mixins/vector'
  mixin require './mixins/images'

  close: () ->
    @resources.end()
    @xobj.end()
    @closed = true
    
  addContent: (data) ->
    @xobj.write data
    return this
  
  addResource: (type, key, data) ->
    dictionary = @resources.data[type] ?= {}
    dictionary[key] ?= data
    return this

module.exports = PDFGroup
