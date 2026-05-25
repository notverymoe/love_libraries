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

describe("ComponentIds", function()

    insulateIt("Component IDs are secretly numbers", function()
        local arlu = require("arlu")
        assert.is_number(arlu.CId.register("compAA"))
    end)

    insulateIt("Allocate components UIDs", function()
        local arlu = require("arlu")

        local compA = arlu.CId.register("compA")
        local compB = arlu.CId.register("compB")
        local compC = arlu.CId.register("compC")
        
        assert.are_not_equal(compA, compB, compC)
        assert.are_equal(compA, 1)
        assert.are_equal(compB, 2)
        assert.are_equal(compC, 3)
    end)

    insulateIt("Allocate components UIDs, ensure insulation", function()
        local arlu = require("arlu")

        local compA = arlu.CId.register("compAA")
        local compB = arlu.CId.register("compBB")
        local compC = arlu.CId.register("compCC")
        
        assert.are_not_equal(compA, compB, compC)
        assert.are_equal(compA, 1)
        assert.are_equal(compB, 2)
        assert.are_equal(compC, 3)
    end)

end)