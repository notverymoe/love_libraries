-- Copyright 2026 Natalie Baker -- MIT --

---@class luassert
---@field message fun(string): luassert.internal

local arlu = require("arlu")

describe("ComponentSet", function()
    local aId = arlu.CId.register("a")
    local bId = arlu.CId.register("b")
    local cId = arlu.CId.register("c")

    it("Should allow building a set in multiple ways", function()
        local list = arlu.ComponentSet.from(cId, bId, cId)
        local arr  = arlu.ComponentSet.fromArray({cId, bId, bId})
        local map  = {[cId] = 50, [bId] = 22}
        assert.is_nil(list[aId])
        assert.is_nil( arr[aId])
        assert.is_nil( map[aId])

        assert.is_not_nil(list[cId])
        assert.is_not_nil( arr[cId])
        assert.is_not_nil( map[cId])

        assert.is_not_nil(list[bId])
        assert.is_not_nil( arr[bId])
        assert.is_not_nil( map[bId])
    end)

    it("Should allow checking if any component is present in another", function()
        local a = arlu.ComponentSet.from(aId, bId)
        local b = arlu.ComponentSet.from(bId)
        local c = arlu.ComponentSet.from(cId, bId)

        -- All
        assert.is_false(arlu.ComponentSet.all(a, c))
        assert.is_false(arlu.ComponentSet.all(c, a))

        assert.is_true(arlu.ComponentSet.all(b, a))
        assert.is_false(arlu.ComponentSet.all(a, b))

        assert.is_true(arlu.ComponentSet.all(b, c))
        assert.is_false(arlu.ComponentSet.all(c, b))
    end)

    it("Should allow checking if all components are in present in another", function()
        local a = arlu.ComponentSet.from(aId, bId)
        local b = arlu.ComponentSet.from(bId)
        local c = arlu.ComponentSet.from(cId, bId)

        -- Any
        assert.is_true(arlu.ComponentSet.any(a, c))
        assert.is_true(arlu.ComponentSet.any(c, a))

        assert.is_true(arlu.ComponentSet.any(a, b))
        assert.is_true(arlu.ComponentSet.any(b, a))

        assert.is_true(arlu.ComponentSet.any(c, b))
        assert.is_true(arlu.ComponentSet.any(b, c))
    end)

    it("Should allow checking if all components are in common", function()
        local a = arlu.ComponentSet.from(aId, bId)
        local b = arlu.ComponentSet.from(bId)
        local c = arlu.ComponentSet.from(cId, bId)

        -- Exact
        assert.is_false(arlu.ComponentSet.exact(a, c))
        assert.is_false(arlu.ComponentSet.exact(c, a))

        assert.is_false(arlu.ComponentSet.exact(b, a))
        assert.is_false(arlu.ComponentSet.exact(a, b))

        assert.is_false(arlu.ComponentSet.exact(b, c))
        assert.is_false(arlu.ComponentSet.exact(c, b))

        assert.is_true(arlu.ComponentSet.exact(a, {[aId]=true, [bId]=true}))
        assert.is_true(arlu.ComponentSet.exact(c, {[cId]=true, [bId]=true}))
        assert.is_true(arlu.ComponentSet.exact(b, {[bId]=true}))
    end)

end)
