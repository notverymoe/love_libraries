-- Copyright 2026 Natalie Baker -- MIT --

---@class luassert
---@field message fun(string): luassert.internal

local arlu = require("arlu")

local function anyMatch(value, ...)
    for _,v in pairs({...}) do
        if v == value then return true end
    end
    return false
end

describe("ArchetypeStorage", function()

    local aId = arlu.CId.register("a")
    local bId = arlu.CId.register("b")
    local cId = arlu.CId.register("c")

    it("Should create tables", function ()
        local as = arlu.ArchetypeStorage.new()

        local tblA, idxA = as:getOrCreateTable(arlu.ComponentSet.from(aId))
        assert.are_equal(tblA, as:getTable(arlu.ComponentSet.from(aId)))
        assert.are_equal(tblA, as:getTableById(idxA))

        local tblAB, idxAB = as:getOrCreateTable(arlu.ComponentSet.from(aId, bId))
        assert.are_equal(tblAB, as:getTable(arlu.ComponentSet.from(aId, bId)))
        assert.are_equal(tblAB, as:getTableById(idxAB))

        local tblAC, idxAC = as:getOrCreateTable(arlu.ComponentSet.from(aId, cId))
        assert.are_equal(tblAC, as:getTable(arlu.ComponentSet.from(aId, cId)))
        assert.are_equal(tblAC, as:getTableById(idxAC))

        local tblABC, idxABC = as:getOrCreateTable(arlu.ComponentSet.from(aId, bId, cId))
        assert.are_equal(tblABC, as:getTable(arlu.ComponentSet.from(aId, bId, cId)))
        assert.are_equal(tblABC, as:getTableById(idxABC))

        assert.are_not_equal(idxA, idxAB, idxAC, idxABC)
        assert.are_not_equal(tblA, tblAB, tblAC, tblABC)
    end)

    it("Should handle queries", function()
        local as = arlu.ArchetypeStorage.new()
        local tblA   = as:getOrCreateTable(arlu.ComponentSet.from(aId))
        local tblAB  = as:getOrCreateTable(arlu.ComponentSet.from(aId, bId))
        local tblAC  = as:getOrCreateTable(arlu.ComponentSet.from(aId, cId))
        local tblABC = as:getOrCreateTable(arlu.ComponentSet.from(aId, bId, cId))

        local q = as:query(arlu.ComponentSetFilter.from({aId}))
        assert.equal(4, #q)
        for _,idx in pairs(q) do
            local table = as:getTableById(idx)
            assert.is_true(anyMatch(table, tblA, tblAB, tblAC, tblABC))
        end

        q = as:query(arlu.ComponentSetFilter.from({bId}))
        assert.equal(2, #q)
        for _,idx in pairs(q) do
            local table = as:getTableById(idx)
            assert.message("Got "..tostring(table).." expected "..tostring(tblAB).." or "..tostring(tblABC)).is_true(anyMatch(table, tblAB, tblABC))
        end

        q = as:query(arlu.ComponentSetFilter.from({aId}, {cId}))
        assert.equal(2, #q)
        for _,idx in pairs(q) do
            local table = as:getTableById(idx)
            assert.is_true(anyMatch(table, tblA, tblAB))
        end

    end)

end)