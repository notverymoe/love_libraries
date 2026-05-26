-- Copyright 2026 Natalie Baker -- MIT --

---@class luassert
---@field message fun(string): luassert.internal

local arlu = require("arlu")

describe("ComponentSetFilter", function()
    local aId = arlu.CId.register("a")
    local bId = arlu.CId.register("b")
    local cId = arlu.CId.register("c")
    local dId = arlu.CId.register("d")
    local eId = arlu.CId.register("e")

    it("Should return an empty list if exclude not provided, or self include not provided", function()
        local aFilter = arlu.ComponentSet.from(aId, bId) --[[@as arlu.ComponentSetFilter]]
        local bFilter = {requires = arlu.ComponentSet.from(aId, bId)} --[[@as arlu.ComponentSetFilter]]

        assert.is_true(rawequal(arlu.ComponentSetFilter.requires(aFilter), aFilter))
        assert.is_true(rawequal(arlu.ComponentSetFilter.requires(bFilter), bFilter.requires))

        assert.are_same(arlu.ComponentSetFilter.excludes(aFilter), {})
        assert.are_same(arlu.ComponentSetFilter.excludes(bFilter), {})
    end)

    it("Filter should only match exactly with requires and reject on any exclude being present", function()
        local aFilter = {
            requires = arlu.ComponentSet.from(aId, bId),
            excludes = arlu.ComponentSet.from(cId)
        } --[[@as arlu.ComponentSetFilter]]

        local bSet = arlu.ComponentSet.from(aId, bId          )
        local cSet = arlu.ComponentSet.from(aId, bId, cId, dId)
        local dSet = arlu.ComponentSet.from(aId,           dId)

        assert.is_true( arlu.ComponentSetFilter.matches(aFilter, bSet))
        assert.is_false(arlu.ComponentSetFilter.matches(aFilter, cSet))
        assert.is_false(arlu.ComponentSetFilter.matches(aFilter, dSet))
    end)

    it("Filter should be able to check filter equality", function()
        local aFilter = {
            requires = arlu.ComponentSet.from(aId, bId),
            excludes = arlu.ComponentSet.from(cId)
        } --[[@as arlu.ComponentSetFilter]]

        local bFilter = {
            requires = arlu.ComponentSet.from(aId, bId),
            excludes = arlu.ComponentSet.from(dId)
        } --[[@as arlu.ComponentSetFilter]]

        local cFilter = {
            requires = arlu.ComponentSet.from(eId, bId),
            excludes = arlu.ComponentSet.from(cId)
        } --[[@as arlu.ComponentSetFilter]]

        local dFilter = {
            requires = arlu.ComponentSet.from(aId, bId),
            excludes = arlu.ComponentSet.from(cId)
        } --[[@as arlu.ComponentSetFilter]]

        assert.is_false(rawequal(aFilter, dFilter))
        assert.is_true(arlu.ComponentSetFilter.exact(aFilter, dFilter))

        assert.is_false(arlu.ComponentSetFilter.exact(aFilter, bFilter))
        assert.is_false(arlu.ComponentSetFilter.exact(aFilter, cFilter))
    end)


end)