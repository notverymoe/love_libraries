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
