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

module.exports = {
    pairs
    toObj
    mapObj
    mapObjKey
    compactObj
}
