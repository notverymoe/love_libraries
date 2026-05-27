-- Copyright 2026 Natalie Baker -- MIT --

---@class luassert
---@field message fun(string): luassert.internal

local arlu = require("arlu")

describe("World", function()
    local aId = arlu.CId.register("a")
    local bId = arlu.CId.register("b")
    local cId = arlu.CId.register("c")

    it("Should allow spawning, querying and destroying entities", function()
        local w = arlu.World.new()

        local aEnt = w:spawn({
            [aId] = 1,
            [bId] = 2,
        })

        local bEnt = w:spawn({
            [bId] = 3,
            [cId] = 4,
        })

        local cEnt = w:spawn({ -- Same archetype as bEnt
            [bId] = 5,
            [cId] = 6,
        })

        -- Confirm initial state
        assert.are_equal(2, #w:query({ [cId] = cId }):collect(w))
        assert.are_equal(3, #w:query({ [bId] = bId }):collect(w))

        assert.are_equal(1, w:getComponent(aId, aEnt))
        assert.are_equal(2, w:getComponent(bId, aEnt))
        assert.is_nil(w:getComponent(cId, aEnt))
        assert.are_same({ [aId] = 1, [bId] = 2 }, w:get(aEnt))

        assert.is_nil(w:getComponent(aId, bEnt))
        assert.are_equal(3, w:getComponent(bId, bEnt))
        assert.are_equal(4, w:getComponent(cId, bEnt))
        assert.are_same({ [bId] = 3, [cId] = 4 }, w:get(bEnt))

        assert.is_nil(w:getComponent(aId, cEnt))
        assert.are_equal(5, w:getComponent(bId, cEnt))
        assert.are_equal(6, w:getComponent(cId, cEnt))
        assert.are_same({ [bId] = 5, [cId] = 6 }, w:get(cEnt))

        -- Remove B
        w:destroy(bEnt)

        -- Check no longer exists
        assert.are_equal(1, #w:query({ [cId] = cId }):collect(w))
        assert.are_equal(2, #w:query({ [bId] = bId }):collect(w))

        assert.are_equal(1, w:getComponent(aId, aEnt))
        assert.are_equal(2, w:getComponent(bId, aEnt))
        assert.is_nil(w:getComponent(cId, aEnt))
        assert.are_same({ [aId] = 1, [bId] = 2 }, w:get(aEnt))

        assert.is_nil(w:getComponent(aId, bEnt))
        assert.is_nil(w:getComponent(bId, bEnt))
        assert.is_nil(w:getComponent(cId, bEnt))
        assert.is_nil(w:get(bEnt))

        assert.is_nil(w:getComponent(aId, cEnt))
        assert.are_equal(5, w:getComponent(bId, cEnt))
        assert.are_equal(6, w:getComponent(cId, cEnt))
        assert.are_same({ [bId] = 5, [cId] = 6 }, w:get(cEnt))

        -- Spawn new entity with same archetype as B
        local dEnt = w:spawn({
            [bId] = 5,
            [cId] = 6,
        })

        assert.are_not_equal(bEnt, dEnt)

        assert.are_equal(2, #w:query({ [cId] = cId }):collect(w))
        assert.are_equal(3, #w:query({ [bId] = bId}):collect(w))

        assert.are_equal(1, w:getComponent(aId, aEnt))
        assert.are_equal(2, w:getComponent(bId, aEnt))
        assert.is_nil(w:getComponent(cId, aEnt))
        assert.are_same({ [aId] = 1, [bId] = 2 }, w:get(aEnt))

        assert.is_nil(w:getComponent(aId, bEnt))
        assert.is_nil(w:getComponent(bId, bEnt))
        assert.is_nil(w:getComponent(cId, bEnt))
        assert.is_nil(w:get(bEnt))

        assert.is_nil(w:getComponent(aId, cEnt))
        assert.are_equal(5, w:getComponent(bId, cEnt))
        assert.are_equal(6, w:getComponent(cId, cEnt))
        assert.are_same({ [bId] = 5, [cId] = 6 }, w:get(cEnt))

        assert.is_nil(w:getComponent(aId, dEnt))
        assert.are_equal(5, w:getComponent(bId, dEnt))
        assert.are_equal(6, w:getComponent(cId, dEnt))
        assert.are_same({ [bId] = 5, [cId] = 6 }, w:get(dEnt))

        -- Attach new component, change existing and observe archetype change
        w:attach(dEnt, { [aId] = 7, [bId] = 8 })

        assert.are_equal(2, #w:query({ [cId] = cId }):collect(w))
        assert.are_equal(3, #w:query({ [bId] = bId }):collect(w))

        assert.are_equal(1, w:getComponent(aId, aEnt))
        assert.are_equal(2, w:getComponent(bId, aEnt))
        assert.is_nil(w:getComponent(cId, aEnt))
        assert.are_same({ [aId] = 1, [bId] = 2 }, w:get(aEnt))

        assert.is_nil(w:getComponent(aId, bEnt))
        assert.is_nil(w:getComponent(bId, bEnt))
        assert.is_nil(w:getComponent(cId, bEnt))
        assert.is_nil(w:get(bEnt))

        assert.is_nil(w:getComponent(aId, cEnt))
        assert.are_equal(5, w:getComponent(bId, cEnt))
        assert.are_equal(6, w:getComponent(cId, cEnt))
        assert.are_same({ [bId] = 5, [cId] = 6 }, w:get(cEnt))

        assert.are_equal(7, w:getComponent(aId, dEnt))
        assert.are_equal(8, w:getComponent(bId, dEnt))
        assert.are_equal(6, w:getComponent(cId, dEnt))
        assert.are_same({ [aId] = 7, [bId] = 8, [cId] = 6 }, w:get(dEnt))

        -- Detach component and observe archetype change
        w:detach(dEnt, arlu.ComponentSet.from(cId))

        assert.are_equal(1, #w:query({ [cId] = cId }):collect(w))
        assert.are_equal(3, #w:query({ [bId] = cId }):collect(w))

        assert.are_equal(1, w:getComponent(aId, aEnt))
        assert.are_equal(2, w:getComponent(bId, aEnt))
        assert.is_nil(w:getComponent(cId, aEnt))
        assert.are_same({ [aId] = 1, [bId] = 2 }, w:get(aEnt))

        assert.is_nil(w:getComponent(aId, bEnt))
        assert.is_nil(w:getComponent(bId, bEnt))
        assert.is_nil(w:getComponent(cId, bEnt))
        assert.is_nil(w:get(bEnt))

        assert.is_nil(w:getComponent(aId, cEnt))
        assert.are_equal(5, w:getComponent(bId, cEnt))
        assert.are_equal(6, w:getComponent(cId, cEnt))
        assert.are_same({ [bId] = 5, [cId] = 6 }, w:get(cEnt))

        assert.are_equal(7, w:getComponent(aId, dEnt))
        assert.are_equal(8, w:getComponent(bId, dEnt))
        assert.is_nil(w:getComponent(cId, dEnt))
        assert.are_same({ [aId] = 7, [bId] = 8 }, w:get(dEnt))
    end)
end)
