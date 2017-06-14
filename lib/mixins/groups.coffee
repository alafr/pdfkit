PDFGroup = require '../group'

module.exports =
  initGroups: ->
    @globals.groupCount ?= 0
    @globals.maskCount ?= 0
    @globals.groups ?= {}

  createGroup: (bbox) ->
    return new PDFGroup(this, bbox)

  insertGroup: (group) ->
    group.close() unless group.closed
    @addResource 'XObject', group.name, group.xobj
    @addContent("/#{group.name} Do")
    return this

  applyMask: (group, clip) ->
    group.close() unless group.closed
    name = 'M' + (++@globals.maskCount)
    gstate = @ref
      Type: 'ExtGState'
      CA: 1
      ca: 1
      BM: 'Normal'
      SMask:
        S: 'Luminosity'
        G: group.xobj
        BC: if clip then [0,0,0] else [1,1,1]
    gstate.end()
    @addResource 'ExtGState', name, gstate
    @addContent("/#{name} gs")
    return this
