-- Copyright 2026 Natalie Baker -- MIT --

local IMPORT_ROOT = (...):match("(.-)[^%.]+$")

local SARDINE_MODULE_ENTITY    = require(IMPORT_ROOT.."sardine.entity"   ) --[[@as SardineModuleEntity   ]]
local SARDINE_MODULE_SCHEDULED = require(IMPORT_ROOT.."sardine.schedule" ) --[[@as SardineModuleSchedule ]]
local SARDINE_MODULE_COMPONENT = require(IMPORT_ROOT.."sardine.component") --[[@as SardineModuleComponent]]

---@class SardineModule: SardineModuleEntity, SardineModuleComponent, SardineModuleSchedule
return {
    GenId          = SARDINE_MODULE_ENTITY.GenId,
    GenIdAllocator = SARDINE_MODULE_ENTITY.GenIdAllocator,
    GenIdStorage   = SARDINE_MODULE_ENTITY.GenIdStorage,

    ComponentStorage  = SARDINE_MODULE_COMPONENT.ComponentStorage,
    registerComponent = SARDINE_MODULE_COMPONENT.registerComponent,
    Query             = SARDINE_MODULE_COMPONENT.Query,

    Schedule        = SARDINE_MODULE_SCHEDULED.Schedule,
    ScheduleBuilder = SARDINE_MODULE_SCHEDULED.ScheduleBuilder,
    System          = SARDINE_MODULE_SCHEDULED.System,

    __HOMEPAGE = 'https://github.com/notverymoe/love_libraries/tree/main/sardine',
    __DESCRIPTION = 'An ECS implementation for Love2D.',
    __VERSION = '2026.03.15',
    __LICENSE = [[
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
    ]]
}