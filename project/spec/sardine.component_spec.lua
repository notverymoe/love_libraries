-- Copyright 2026 Natalie Baker -- MIT --

---@class luassert
---@field message fun(string): luassert.internal

---@param name string
---@param block fun()
local function insulateIt(name, block)
    insulate("", function ()
        it(name, block)
    end)
end

describe("ComponentStorage", function()

    insulateIt("Allocate components UIDs", function()
        local sardine = require("sardine")

        local compA = sardine.IdComponent.register("compA")
        local compB = sardine.IdComponent.register("compB")
        local compC = sardine.IdComponent.register("compC")
        
        assert.are_not_equal(compA, compB, compC)
        assert.are_equal(compA, 1)
        assert.are_equal(compB, 2)
        assert.are_equal(compC, 3)
    end)

    insulateIt("Allocate components UIDs, ensure insulation", function()
        local sardine = require("sardine")

        local compA = sardine.IdComponent.register("compAA")
        local compB = sardine.IdComponent.register("compBB")
        local compC = sardine.IdComponent.register("compCC")
        
        assert.are_not_equal(compA, compB, compC)
        assert.are_equal(compA, 1)
        assert.are_equal(compB, 2)
        assert.are_equal(compC, 3)
    end)
end)