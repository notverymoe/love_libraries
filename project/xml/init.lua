-- Copyright 2026 Natalie Baker -- MIT --
-- This is a stub to ease the use of the xml2library to load XML files as DOM trees
-- It also provides LuaLS typing to the output

local IMPORT_ROOT = (...):match("(.-)[^%.]+$")

local xml2lua    = require(IMPORT_ROOT.."xml.xml2lua")
local domHandler = require(IMPORT_ROOT.."xml.dom")

---@class NodeRoot
---@field _name string
---@field _type "ROOT"
---@field _attr {[string]: any}
---@field _children (NodeElement | NodeText | NodeComment | NodeOther)[]

---@class NodeElement
---@field _name string
---@field _type "ELEMENT"
---@field _attr {[string]: any}
---@field _parent NodeRoot | NodeElement
---@field _children (NodeElement | NodeText | NodeComment | NodeOther)[]

---@class NodeText
---@field _type "TEXT"
---@field _text string
---@field _parent NodeRoot | NodeElement

---@class NodeComment
---@field _type "COMMENT"
---@field _text string
---@field _parent NodeRoot | NodeElement

---@class NodeOther
---@field _type "PI" | "DECL" | "DTD"
---@field _attr {[string]: any}
---@field _parent NodeRoot | NodeElement

---Parses the given string as an XML file into a DOM node structure
---@param str string The string to parse
---@return NodeRoot | nil
local function parse(str)
    local handler = domHandler:new()
    local parser = xml2lua.parser(handler)
    parser:parse(str)
    if handler.root then
        return handler.root
    else
        return nil
    end
end

return {
    parse = parse
}