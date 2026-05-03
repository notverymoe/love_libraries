
--#region Parse Helpers

---@param node NodeRoot | NodeElement
---@param attr string
---@return number
local function reqNumber(node, attr)
    local value = node._attr[attr]
    if (value == nil) then error("Field "..attr.." is required but does not exist")  end
    local converted = tonumber(value)
    if (converted == nil) then error("Field "..attr.." has value "..value.." that converted to number") end
    return converted
end

---@generic T
---@param node NodeRoot | NodeElement
---@param attr string
---@param defVal T
---@return T | number
local function optNumber(node, attr, defVal)
    local value = node._attr[attr]
    if (value == nil) then return defVal end
    local converted = tonumber(value)
    if (converted == nil) then error("Field "..attr.." has value "..value.." that converted to number") end
    return converted
end

---@param node NodeRoot | NodeElement
---@param attr string
---@return boolean
local function reqBoolean(node, attr)
    local value = node._attr[attr]
    if (value == nil) then error("Field "..attr.." is required but does not exist")  end
    if (value == "0") then return false end
    if (value == "1") then return true end
    error("Field "..attr.." has value "..value.." that converted to number")
end

---@generic T
---@param node NodeRoot | NodeElement
---@param attr string
---@param defVal T
---@return T | boolean
local function optBoolean(node, attr, defVal)
    local value = node._attr[attr]
    if (value == nil) then return defVal end
    if (value == "0") then return false end
    if (value == "1") then return true end
    return defVal
end

---@param node NodeRoot | NodeElement
---@param attr string
---@return string
local function reqString(node, attr)
    local value = node._attr[attr]
    if (value == nil) then error("Field "..attr.." is required but does not exist") end
    return value
end

---@generic T
---@param node NodeRoot | NodeElement
---@param attr string
---@param defVal T
---@return T | string
local function optString(node, attr, defVal)
    local value = node._attr[attr]
    if (value == nil) then return defVal end
    return value
end

--#endregion Parse Helpers

local parseNode

---@generic T
---@param children NodeElement[]
---@return T[]
local function parseNodes(children)
    local result = {}
    for _,child in ipairs(children or {}) do
        table.insert(result, parseNode(child))
    end
    return result
end

---@param node NodeRoot | NodeElement
---@return TMXMap
local function parseMap(node)
    local parsed = {
        _kind     = "map",
        _children = parseNodes(node._children),

        version          = reqString(node,  "version"     ),
        tiledversion     = reqString(node,  "tiledversion"),
        class            = optString(node,  "class",    ""),
        orientation      = reqString(node,  "orientation" ),
        renderorder      = optString(node,  "renderorder", "right-down"),
        compressionlevel = optNumber(node,  "compressionlevel",  -1),
        width            = reqNumber(node,  "width"     ),
        height           = reqNumber(node,  "height"    ),
        tilewidth        = reqNumber(node,  "tilewidth" ),
        tileheight       = reqNumber(node,  "tileheight"),
        parallaxoriginx  = optNumber(node,  "parallaxoriginx", 0),
        parallaxoriginy  = optNumber(node,  "parallaxoriginy", 0),
        backgroundcolor  = optString(node,  "backgroundcolor", "00000000"), ---@TODO parse colour
        infinite         = optBoolean(node, "infinite",        false),
    } --[[@as TMXMap]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXEditorSettings
local function parseEditorSettings(node)
    local parsed = {
        _kind = "editorsettings",

        _children = parseNodes(node._children),
        _attr     = node._attr,
    } --[[@as TMXEditorSettings]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXMap
local function parseChunkSize(node)
    local parsed = {
        _kind  = "chunksize",

        width  = reqNumber(node, "width" ),
        height = reqNumber(node, "height"),
    } --[[@as TMXChunkSize]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXExport
local function parseExport(node)
    local parsed = {
        _kind  = "export",

        target = reqString(node, "target"),
        format = reqString(node, "format"),
    } --[[@as TMXExport]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXTileset
local function parseTileset(node)
    local parsed = {
        _kind  = "tileset",
        _children = parseNodes(node._children),

        firstgid   = optNumber(node, "firstgid", nil),
        source     = optString(node, "source", nil),
        name      = optString(node,  "name",     ""),
        class      = optString(node, "class", ""),
        tilewidth  = reqNumber(node, "tilewidth"),
        tileheight = reqNumber(node, "tileheight"),
        spacing    = optNumber(node, "spacing", 0),
        margin     = optNumber(node, "margin", 0),
        tilecount  = reqNumber(node, "tilecount"),
        columns    = reqNumber(node, "columns"),
        objectalignment = optString(node, "objectalignment", "bottomleft"), -- TODO map context
        tilerendersize  = optString(node, "objectalignment", "tile"),
        fillmode        = optString(node, "fillmode", "stretch"),
    } --[[@as TMXTileset]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXTileOffset
local function parseTileOffset(node)
    local parsed = {
        _kind  = "tileoffset",

        x = reqNumber(node, "x"),
        y = reqNumber(node, "y"),
    } --[[@as TMXTileOffset]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXGrid
local function parseGrid(node)
    local parsed = {
        _kind  = "grid",

        orientation = optString(node, "orientation", "orthogonal"),
        width       = reqNumber(node, "width" ),
        height      = reqNumber(node, "height"),
    } --[[@as TMXGrid]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXImage
local function parseImage(node)
    local parsed = {
        _kind  = "image",
        _children = parseNodes(node._children),

        format = reqString(node, "format"),
        source = optString(node, "source", nil),
        trans  = optString(node, "trans",  nil),
        width  = reqNumber(node, "width" ),
        height = reqNumber(node, "height"),
    } --[[@as TMXImage]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXTransformations
local function parseTransformations(node)
    local parsed = {
        _kind  = "transformations",
        _children = parseNodes(node._children),

        hflip  = optBoolean(node, "hflip", false),
        vflip  = optBoolean(node, "vflip", false),
        rotate =  optNumber(node, "rotate", 0),
        preferuntransformed = optBoolean(node, "preferuntransformed", false),
    } --[[@as TMXTransformations]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXTile
local function parseTile(node)
    local parsed = {
        _kind  = "tile",
        _children = parseNodes(node._children),

        id   = reqNumber(node, "id"),
        type = optString(node, "type", ""),
        probability = optNumber(node, "probability", 1),
        x      = optNumber(node, "x", 0),
        y      = optNumber(node, "y", 0),
        width  = optNumber(node, "width",  0),
        height = optNumber(node, "height", 0),
    } --[[@as TMXTile]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXAnimation
local function parseAnimation(node)
    local parsed = {
        _kind  = "animation",
        _children = parseNodes(node._children),
    } --[[@as TMXAnimation]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXFrame
local function parseFrame(node)
    local parsed = {
        _kind  = "frame",

        tileid   = reqNumber(node, "tileid"),
        duration = reqNumber(node, "duration")
    } --[[@as TMXFrame]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXWangSets
local function parseWangSets(node)
    local parsed = {
        _kind  = "wangsets",
        _children = parseNodes(node._children),
    } --[[@as TMXWangSets]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXWangSet
local function parseWangSet(node)
    local parsed = {
        _kind  = "wangset",
        _children = parseNodes(node._children),

        name  = optString(node,  "name", ""),
        class = optString(node, "class", ""),
        tile  = reqNumber(node, "tile")
    } --[[@as TMXWangSet]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXWangColor
local function parseWangColor(node)
    local parsed = {
        _kind  = "wangcolor",
        _children = parseNodes(node._children),

        name  = optString(node, "name",  ""),
        class = optString(node, "class", ""),
        tile  = reqNumber(node, "tile"),
        probability = optNumber(node, "probability", 1),
    } --[[@as TMXWangColor]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXWangTile
local function parseWangTile(node)
    local parsed = {
        _kind  = "wangtile",
        _children = parseNodes(node._children),
        tileid  = reqNumber(node, "tileid"),
        wangid  = reqString(node, "wangid"),
    } --[[@as TMXWangTile]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXLayer
local function parseLayer(node)
    local parsed = {
        _kind  = "layer",
        _children = parseNodes(node._children),

        id        = reqNumber(node, "id"),
        name      = optString(node, "name", ""),
        class     = optString(node, "class", ""),
        width     = optNumber(node, "width",  0),
        height    = optNumber(node, "height", 0),
        opacity   = optNumber(node, "opacity", 1),
        visible   = optBoolean(node, "visible", true),
        tintcolor = optString(node, "tintcolor", nil), ---@TODO parse colour
        offsetx   = optNumber(node, "offsetx", 0),
        offsety   = optNumber(node, "offsety", 0),
        parallaxx = optNumber(node, "parallaxx", 0),
        parallaxy = optNumber(node, "parallaxy", 0),
        mode      = optString(node, "parallaxy", "normal"),
    } --[[@as TMXLayer]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXData
local function parseData(node)
    local parsed = {  ---@TODO decompress/dencode data or provide method to?
        _kind     = "data",
        _children = parseNodes(node._children),

        encoding    = optString(node, "encoding",    nil),
        compression = optString(node, "compression", nil),
    } --[[@as TMXData]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXChunk
local function parseChunk(node)
    local parsed = {
        _kind     = "chunk",
        _children = parseNodes(node._children),

        x      = reqNumber(node, "x"),
        y      = reqNumber(node, "y"),
        width  = reqNumber(node, "width"),
        height = reqNumber(node, "height"),
    } --[[@as TMXChunk]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXObjectGroup
local function parseObjectGroup(node)
    local parsed = {
        _kind     = "objectgroup",
        _children = parseNodes(node._children),

        id        = reqNumber(node, "id"),
        name      = optString(node,  "name",     ""),
        class     = optString(node, "class", ""),
        color     = optString(node, "color", nil), ---@TODO parse colour
        opacity   = optNumber(node, "opacity", 1),
        visible   = optBoolean(node, "visible", true),
        tintcolor = optString(node, "tintcolor", nil), ---@TODO parse colour
        offsetx   = optNumber(node, "offsetx", 0),
        offsety   = optNumber(node, "offsety", 0),
        parallaxx = optNumber(node, "parallaxx", 0),
        parallaxy = optNumber(node, "parallaxy", 0),
        draworder = optString(node, "draworder", "topdown"),
    } --[[@as TMXObjectGroup]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXObject
local function parseObject(node)
    local parsed = {
        _kind     = "object",
        _children = parseNodes(node._children),

        id       = reqNumber(node, "id"),
        name      = optString(node,  "name",     ""),
        type     = optString(node, "type", ""),
        x        = optNumber(node, "x", 0),
        y        = optNumber(node, "y", 0),
        width    = optNumber(node, "width", 0),
        height   = optNumber(node, "height", 0),
        rotation = optNumber(node, "rotation", 0),
        opacity  = optNumber(node, "opacity", 1),
        gid      = optNumber(node, "gid", nil),
        visible  = optBoolean(node, "visible", true),
        template = optString(node, "template", nil),
    } --[[@as TMXObject]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXEllipse
local function parseEllipse(node)
    local parsed = {
        _kind = "ellipse",
    } --[[@as TMXEllipse]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXCapsule
local function parseCapsule(node)
    local parsed = {
        _kind = "capsule",
    } --[[@as TMXCapsule]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXPoint
local function parsePoint(node)
    local parsed = {
        _kind = "point",
    } --[[@as TMXPoint]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXPolygon
local function parsePolygon(node)
    local parsed = {
        _kind = "polygon",
        points = reqString(node, "points"), ---@TODO parse points
    } --[[@as TMXPolygon]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXPolyline
local function parsePolyline(node)
    local parsed = {
        _kind = "polyline",
        points = reqString(node, "points"), ---@TODO parse points
    } --[[@as TMXPolyline]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXText
local function parseText(node)
    local parsed = {
        _kind = "text",

        fontfamily =  optString(node, "fontfamily", "sans-serif"),
        pixelsize  =  optNumber(node, "pixelsize",  16    ),
        wrap       = optBoolean(node, "wrap",       false ),
        color      =  optString(node, "color",      "000000"), ---@TODO parse colour
        bold       = optBoolean(node, "bold",       false ),
        italic     = optBoolean(node, "italic",     false ),
        underline  = optBoolean(node, "underline",  false ),
        strikeout  = optBoolean(node, "strikeout",  false ),
        kerning    = optBoolean(node, "kerning",    true  ),
        halign     =  optString(node, "halign",     "left"),
        valign     =  optString(node, "valign",     "top" ),
    } --[[@as TMXText]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXImageLayer
local function parseImageLayer(node)
    local parsed = {
        _kind = "imagelayer",
        _children = parseNodes(node._children),
        
        id        = reqNumber(node, "id"),
        name      = optString(node,  "name",     ""),
        class     = optString(node, "class", ""),
        offsetx   = optNumber(node, "offsetx", 0),
        offsety   = optNumber(node, "offsety", 0),
        parallaxx = optNumber(node, "parallaxx", 0),
        parallaxy = optNumber(node, "parallaxy", 0),
        opacity   = optNumber(node, "opacity", 1),
        visible   = optBoolean(node, "visible", true),
        tintcolor = optString(node, "tintcolor", nil), ---@TODO parse colour
        repeatx   = reqBoolean(node, "repeatx"),
        repeaty   = reqBoolean(node, "repeaty"),
    } --[[@as TMXImageLayer]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXGroup
local function parseGroup(node)
    local parsed = {
        _kind = "group",
        _children = parseNodes(node._children),
        
        id        = optNumber(node,  "id",        0),
        name      = optString(node,  "name",     ""),
        class     = optString(node,  "class",    ""),
        offsetx   = optNumber(node,  "offsetx",   0),
        offsety   = optNumber(node,  "offsety",   0),
        parallaxx = optNumber(node,  "parallaxx", 1),
        parallaxy = optNumber(node,  "parallaxy", 1),
        opacity   = optNumber(node,  "opacity",   1),
        visible   = optBoolean(node, "visible",   true),
        tintcolor = optString(node,  "tintcolor", nil), ---@TODO parse colour
    } --[[@as TMXGroup]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXProperties
local function parseProperties(node)
    local parsed = {
        _kind = "properties",
        _children = parseNodes(node._children),
    } --[[@as TMXProperties]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXProperty
local function parseProperty(node)
    local parsed = {
        _kind = "property",
        _children = parseNodes(node._children),

        name = optString(node, "name", ""),
        type = optString(node, "type", "string"),
        propertytype = optString(node, "propertytype", nil),
        value = node._attr.value ---@TODO parse value
    } --[[@as TMXProperty]]
    return parsed
end

---@param node NodeRoot | NodeElement
---@return TMXMap | TMXEditorSettings | TMXChunkSize | TMXExport | TMXTileset | TMXTileOffset | TMXGrid | TMXImage | TMXTransformations | TMXTile | TMXAnimation | TMXFrame | TMXWangSets | TMXWangSet | TMXWangColor | TMXWangTile | TMXLayer | TMXData | TMXChunk | TMXObjectGroup | TMXObject | TMXEllipse | TMXCapsule | TMXPoint | TMXPolygon | TMXPolyline | TMXText | TMXImageLayer | TMXGroup | TMXProperties | TMXProperty | TMXUnhandled
parseNode = function(node)
    if node._name == "map" then
        return parseMap(node)
    elseif node._name == "editorsettings" then
        return parseEditorSettings(node)
    elseif node._name == "chunksize" then
        return parseChunkSize(node)
    elseif node._name == "export" then
        return parseExport(node)
    elseif node._name == "tileset" then
        return parseTileset(node)
    elseif node._name == "tileoffset" then
        return parseTileOffset(node)
    elseif node._name == "grid" then
        return parseGrid(node)
    elseif node._name == "image" then
        return parseImage(node)
    elseif node._name == "transformations" then
        return parseTransformations(node)
    elseif node._name == "tile" then
        return parseTile(node)
    elseif node._name == "animation" then
        return parseAnimation(node)
    elseif node._name == "frame" then
        return parseFrame(node)
    elseif node._name == "wangsets" then
        return parseWangSets(node)
    elseif node._name == "wangset" then
        return parseWangSet(node)
    elseif node._name == "wangcolor" then
        return parseWangColor(node)
    elseif node._name == "wangtile" then
        return parseWangTile(node)
    elseif node._name == "layer" then
        return parseLayer(node)
    elseif node._name == "data" then
        return parseData(node)
    elseif node._name == "chunk" then
        return parseChunk(node)
    elseif node._name == "objectgroup" then
        return parseObjectGroup(node)
    elseif node._name == "object" then
        return parseObject(node)
    elseif node._name == "ellipse" then
        return parseEllipse(node)
    elseif node._name == "capsule" then
        return parseCapsule(node)
    elseif node._name == "point" then
        return parsePoint(node)
    elseif node._name == "polygon" then
        return parsePolygon(node)
    elseif node._name == "polyline" then
        return parsePolyline(node)
    elseif node._name == "text" then
        return parseText(node)
    elseif node._name == "imagelayer" then
        return parseImageLayer(node)
    elseif node._name == "group" then
        return parseGroup(node)
    elseif node._name == "properties" then
        return parseProperties(node)
    elseif node._name == "property" then
        return parseProperty(node)
    else
        ---@TODO warn when emiting
        return {
            _kind     = "unhandled",
            _name     = node._name,
            _attr     = node._attr,
            _children = parseNodes(node._children),
        } --[[@as TMXUnhandled]]
    end
end

return {
    parse = parseNode
}