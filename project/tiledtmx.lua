-- Copyright 2026 Natalie Baker -- MIT --

--#region Map Node

---@class TMXMap
---@field _kind "map"
---@field _children (TMXProperties | TMXTileset | TMXLayer | TMXObjectGroup | TMXImageLayer | TMXGroup)[]
---@field version string
---@field tiledversion string
---@field class string
---@field orientation "orthogonal" | "isometrtic" | "oblique" | "staggered" | "hexagonal"
---@field renderorder "right-down" | "right-up" | "left-down" | "left-up"
---@field compressionlevel integer
---@field width integer
---@field height integer
---@field tilewidth integer
---@field tileheight integer
---@field parallaxoriginx integer
---@field parallaxoriginy integer
---@field backgroundcolor string
---@field infinite boolean

--#endregion Map Node

--#region ChunkSize Node

---@class TMXEditorSettings
---@field _kind "editorsettings"
---@field _attr {[string]: any}
---@field _children (TMXChunkSize | TMXExport)[]

--#endregion ChunkSize Node


--#region ChunkSize Node

---@class TMXChunkSize
---@field _kind "chunksize"
---@field width integer
---@field height integer

--#endregion ChunkSize Node

--#region Export Node

---@class TMXExport
---@field _kind "export"
---@field target string
---@field format string

--#endregion Export Node

--#region Tileset Node

---@class TMXTileset
---@field _kind "tileset"
---@field _children (TMXImage | TMXTileOffset | TMXGrid | TMXProperties | TMXWangSets | TMXTransformations)
---@field firstgid integer | nil
---@field source string | nil
---@field name string
---@field class string
---@field tilewidth integer
---@field tileheight integer
---@field spacing integer
---@field margin integer
---@field tilecount integer
---@field columns integer
---@field objectalignment "unspecified" | "topleft" | "top" | "topright" | "left" | "center" | "right" | "bottomleft" | "bottom" | "bottomright"
---@field tilerendersize "tile" | "grid"
---@field fillmode "stretch" | "preserve-aspect-fit"

--#endregion Tileset Node

--#region TileOffset Node

---@class TMXTileOffset
---@field _kind "tileoffset"
---@field x number
---@field y number

--#endregion TileOffset Node

--#region Grid Node

---@class TMXGrid
---@field _kind "grid"
---@field orientation "orthogonal" | "isometric"
---@field width number
---@field height number

--#endregion Grid Node

--#region Image Node

---@class TMXImage
---@field _kind "image"
---@field _children [TMXData] | {}
---@field format string | nil
---@field source string | nil
---@field trans  string | nil
---@field width integer
---@field height integer

--#endregion Image Node

--#region Transformations Node

---@class TMXTransformations
---@field _kind "transformations"
---@field hflip boolean
---@field vflip boolean
---@field rotate integer
---@field preferuntransformed boolean

--#endregion Transformations Node

--#region Tile Node

---@class TMXTile
---@field _kind "tile"
---@field _children (TMXProperties | TMXImage | TMXObjectGroup | TMXAnimation)[]
---@field id integer
---@field type string
---@field probability number
---@field x number
---@field y number
---@field width number
---@field height number

--#endregion Tile Node

--#region Animation Node

---@class TMXAnimation
---@field _kind "animation"
---@field _children TMXFrame

--#endregion Animation Node

--#region Frame Node

---@class TMXFrame
---@field _kind "frame"
---@field tileid integer
---@field duration number

--#endregion Frame Node

--#region WangSets Node

---@class TMXWangSets
---@field _kind "wangsets"
---@field _children TMXWangSet[]

--#endregion WangSets Node

--#region WangSet Node

---@class TMXWangSet
---@field _kind "wangset"
---@field _children (TMXProperties | TMXWangColor | TMXWangTile)[]
---@field name string
---@field class string
---@field tile integer

--#endregion WangSet Node

--#region WangColor Node

---@class TMXWangColor
---@field _kind "wangcolor"
---@field _children [TMXProperties] | {}
---@field name string
---@field class string
---@field tile integer
---@field probability number

--#endregion WangColor Node

--#region WangTile Node

---@class TMXWangTile
---@field _kind "wangtile"
---@field tileid integer
---@field wangid string

--#endregion WangTile Node

--#region Layer Node

---@class TMXLayer
---@field _kind "layer"
---@field _children (TMXProperties | TMXData)[]
---@field id integer
---@field name string
---@field class string
---@field width integer
---@field height integer
---@field opacity number
---@field visible boolean
---@field tintcolor string | nil
---@field offsetx integer
---@field offsety integer
---@field parallaxx number
---@field parallaxy number
---@field mode "normal" | "add" | "multiply" | "screen" | "overlay" | "darken" | "lighten" | "color-dodge" | "color-burn" | "hard-light" | "soft-light" | "difference" | "exclusion"

--#endregion Layer Node

--#region Data Node

---@class TMXData
---@field _kind "data"
---@field _children (TMXTile | TMXChunk)[]
---@field encoding "base64" | "csv" | nil
---@field compression "gzip" | "zlib" | "zstd" | nil

--#endregion Data Node

--#region Chunk Node

---@class TMXChunk
---@field _kind "chunk"
---@field _children TMXTile[]
---@field x integer
---@field y integer
---@field width integer
---@field height integer

--#endregion Chunk Node

--#region ObjectGroup Node

---@class TMXObjectGroup
---@field _kind "objectgroup"
---@field _children (TMXProperties | TMXObject)[]
---@field id integer
---@field name string
---@field class string
---@field color string | nil
---@field opacity number
---@field visible boolean
---@field tintcolor string | nil
---@field offsetx integer
---@field offsety integer
---@field parallaxx number
---@field parallaxy number
---@field draworder "index" | "topdown"

--#endregion ObjectGroup Node

--#region Object Node

---@class TMXObject
---@field _kind "object"
---@field _children (TMXProperties | TMXEllipse | TMXCapsule | TMXPoint | TMXPolygon | TMXPolyline | TMXText)[]
---@field id integer
---@field name string
---@field type string
---@field x integer
---@field y integer
---@field width integer
---@field height integer
---@field rotation number
---@field opacity number
---@field gid integer | nil
---@field visible boolean
---@field template string | nil

--#endregion Object Node

--#region Ellipse Node

---@class TMXEllipse
---@field _kind "ellipse"

--#endregion Ellipse Node

--#region Capsule Node

---@class TMXCapsule
---@field _kind "capsule"

--#endregion Capsule Node

--#region Point Node

---@class TMXPoint
---@field _kind "point"

--#endregion Point Node

--#region Polygon Node

---@class TMXPolygon
---@field _kind "polygon"
---@field points string

--#endregion Polygon Node

--#region Polyline Node

---@class TMXPolyline
---@field _kind "polyline"
---@field points string

--#endregion Polyline Node

--#region Text Node

---@class TMXText
---@field _kind "text"
---@field fontfamily string
---@field pixelsize number
---@field wrap boolean
---@field color string
---@field bold boolean
---@field italic boolean
---@field underline boolean
---@field strikeout boolean
---@field kerning boolean
---@field halign "left" | "center" | "right" | "justify"
---@field valign "top" | "center" | "bottom" | "top"

--#endregion Text Node

--#region ImageLayer Node

---@class TMXImageLayer
---@field _kind "imagelayer"
---@field _children (TMXProperties | TMXImage)[]
---@field id integer
---@field name string
---@field class string
---@field offsetx integer
---@field offsety integer
---@field parallaxx number
---@field parallaxy number
---@field opacity number
---@field visible boolean
---@field tintcolor string | nil
---@field repeatx boolean
---@field repeaty boolean

--#endregion ImageLayer Node

--#region Group Node

---@class TMXGroup
---@field _kind "group"
---@field _children (TMXProperties | TMXLayer | TMXObjectGroup | TMXImageLayer | TMXGroup)[]
---@field id integer
---@field name string
---@field class string
---@field offsetx integer
---@field offsety integer
---@field parallaxx number
---@field parallaxy number
---@field opacity number
---@field visible boolean
---@field tintcolor string | nil

--#endregion Group Node

--#region Properties Node

---@class TMXProperties
---@field _kind "properties"
---@field _children TMXProperty[]

--#endregion Properties Node

--#region Property Node

---@class TMXProperty
---@field _kind "property"
---@field _children [TMXProperties] | {}
---@field name string
---@field type "string" | "int" | "float" | "bool" | "color" | "file" | "object" | "class"
---@field propertytype string | nil
---@field value any

--#endregion Property Node

--#region Property Node

---@class TMXUnhandled
---@field _kind "unhandled"
---@field _children (TMXMap | TMXEditorSettings | TMXChunkSize | TMXExport | TMXTileset | TMXTileOffset | TMXGrid | TMXImage | TMXTransformations | TMXTile | TMXAnimation | TMXFrame | TMXWangSets | TMXWangSet | TMXWangColor | TMXWangTile | TMXLayer | TMXData | TMXChunk | TMXObjectGroup | TMXObject | TMXEllipse | TMXCapsule | TMXPoint | TMXPolygon | TMXPolyline | TMXText | TMXImageLayer | TMXGroup | TMXProperties | TMXProperty | TMXUnhandled)[]
---@field _name string
---@field _attr {[string]: any}

--#endregion Property Node


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
    __HOMEPAGE    = 'https://github.com/notverymoe/love_libraries/',
    __DESCRIPTION = 'WIP Simple Tiled Parser',
    __VERSION     = '2026.05.03',
    __LICENSE     = [[
        MIT License

        Copyright 2026 Natalie Baker

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
    ]],

    parse = parseNode
}