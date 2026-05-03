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
    __HOMEPAGE = 'https://github.com/notverymoe/love_libraries/',
    __DESCRIPTION = 'A version of xml2lua packaged for easy use in Love2D',
    __VERSION = '2026.05.03',
    __LICENSE = [[
        The MIT License (MIT)

        Copyright (c) 2026 Natalie Baker (Modified Version)
        Copyright (c) 2016 Manoel Campos da Silva Filho

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
    parse = parse
}