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
        local sardine = require("sardine.component")

        local compA = sardine.registerComponent("compA")
        local compB = sardine.registerComponent("compB")
        local compC = sardine.registerComponent("compC")
        
        assert.are_not_equal(compA.uid, compB.uid, compC.uid)
        assert.are_equal(compA.uid, 1)
        assert.are_equal(compB.uid, 2)
        assert.are_equal(compC.uid, 3)
    end)

    insulateIt("Allocate components UIDs, ensure insulation", function()
        local sardine = require("sardine.component")

        local compA = sardine.registerComponent("compAA")
        local compB = sardine.registerComponent("compBB")
        local compC = sardine.registerComponent("compCC")
        
        assert.are_not_equal(compA.uid, compB.uid, compC.uid)
        assert.are_equal(compA.uid, 1)
        assert.are_equal(compB.uid, 2)
        assert.are_equal(compC.uid, 3)
    end)

    insulateIt("Iterate entities with common components", function()
        local sardine = require("sardine.component")

        local compA = sardine.registerComponent("compA")
        local compB = sardine.registerComponent("compB")
        local compC = sardine.registerComponent("compC")

        local components = sardine.ComponentStorage.new()
        for i=1,2 do components:spawn({ [compA] = {compA, i}, [compB] = {compB, i} }) end
        for i=1,4 do components:spawn({ [compA] = {compA, i}, [compC] = {compC, i} }) end
        for i=1,8 do components:spawn({ [compB] = {compB, i}, [compC] = {compC, i} }) end

        --

        local count = 0
        for _,v in components:query({compA, compB}) do
            local a, b = unpack(v)
            assert.are_equal(compA.uid, a[1].uid)
            assert.are_equal(compB.uid, b[1].uid)
            count = count + 1
        end
        assert.are_equal(count, 2)

        count = 0
        for _,v in components:query({compA, compC}) do 
            local a, c = unpack(v)
            assert.are_equal(compA.uid, a[1].uid)
            assert.are_equal(compC.uid, c[1].uid)
            count = count + 1
        end
        assert.are_equal(count, 4)

        count = 0
        for _,v in components:query({compB, compC}) do 
            local b, c = unpack(v)
            assert.are_equal(compB.uid, b[1].uid)
            assert.are_equal(compC.uid, c[1].uid)
            count = count + 1
        end
        assert.are_equal(count, 8)

        --

        count = 0
        for _,v in components:query({compA}) do 
            local a = unpack(v)
            assert.are_equal(compA.uid, a[1].uid)
            count = count + 1
        end
        assert.are_equal(count, 6)

        count = 0
        for _,v in components:query({compB}) do
            local b = unpack(v)
            assert.are_equal(compB.uid, b[1].uid)
            count = count + 1
        end
        assert.are_equal(count, 10)

        count = 0
        for _,v in components:query({compC}) do
            local c = unpack(v)
            assert.are_equal(compC.uid, c[1].uid)
            count = count + 1
        end
        assert.are_equal(count, 12)

        --

        count = 0
        for _,_ in components:query({compA, compB, compC}) do count = count + 1 end
        assert.are_equal(count, 0)

        --
    end)


end)