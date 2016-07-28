pairs = (o) ->
    a_ = []
    for k, v of o
        a_.push [k, v]
    return a_

toObj = (a) ->
    o_ = {}
    for [k, v] in a
        o_[k] = v
    return o_

mapObj = (o, f) ->
    o_ = {}
    for k, v of o
        o_[k] = f o[k]
    return o_

mapObjKey = (o, f) ->
    o_ = {}
    for k, v of o
        o_[k] = f k
    return o_

compactObj = (o) ->
    o_ = {}
    for k, v of o
        o_[k] = v if v?
    return o_

capitalize = (type) -> type[0].toUpperCase() + type.slice(1)
capWords = (s) -> s.replace /\b\w/g, (m) -> m.toUpperCase()
capIDs = (s) -> s.replace /\bid\b/, 'ID'

slugify = (s) -> s.toLowerCase().replace /\W+/g, '-'
deslugify = (s) -> capWords capIDs s.replace /[^a-z]+/g, ' '
humanize = (s) ->
    s = s.toLowerCase().replace /[^a-z]+/g, ' '
    s = s[0].toUpperCase() + s.substr(1)
    return s

module.exports = {
    pairs
    toObj
    mapObj
    mapObjKey
    compactObj
    capitalize
    capWords
    capIDs
    slugify
    deslugify
    humanize
}