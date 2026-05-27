-- Copyright 2026 Natalie Baker -- MIT --

---@class luassert
---@field message fun(string): luassert.internal

local arlu = require("arlu")

describe("ComponentTable", function()

    it("can store and retrieve entity data", function()
        local alloc = arlu.EntityAllocator.new()
        local entityA = alloc:alloc()
        local storage = arlu.ComponentTable.new({1})
        storage:set(entityA, {126})
        assert.are.equal(126, storage:get(entityA)[1])
    end)

    it("should have a predictable order", function()
        local alloc = arlu.EntityAllocator.new()

        local entityA = alloc:alloc()
        local entityB = alloc:alloc()
        local entityC = alloc:alloc()

        local storage = arlu.ComponentTable.new({1})
        storage:set(entityC, {1}) -- Non-consecutive entity indicies
        storage:set(entityA, {2})
        storage:set(entityB, {3})

        local iters = {}
        for entity, components in storage:iter() do
            table.insert(iters, {entity = entity.index, value = components[1]})
        end

        assert.are.same(
            {
                {entity = entityC.index, value = 1},
                {entity = entityA.index, value = 2},
                {entity = entityB.index, value = 3},
            },
            iters,
            {
                {entity = entityC.index, value = storage:get(entityC)[1]},
                {entity = entityA.index, value = storage:get(entityA)[1]},
                {entity = entityB.index, value = storage:get(entityB)[1]},
            }
        )
    end)

    it("should have a predictable order, after delete", function()
        local alloc = arlu.EntityAllocator.new()

        local entityA = alloc:alloc()
        local entityB = alloc:alloc()
        local entityC = alloc:alloc()

        local storage = arlu.ComponentTable.new({1})
        storage:set(entityC, {1}) -- Non-consecutive entity indicies
        storage:set(entityA, {2})
        storage:set(entityB, {3})
        storage:set(entityA, nil)

        local iters = {}
        for entity, components in storage:iter() do
            table.insert(iters, {entity = entity.index, value = components[1]})
        end

        assert.are.same(
            {
                {entity = entityC.index, value = 1},
                {entity = entityB.index, value = 3},
            },
            iters,
            {
                {entity = entityC.index, value = storage:get(entityC)[1]},
                {entity = entityB.index, value = storage:get(entityB)[1]},
            }
        )
    end)

    it("should have a predictable order, after delete, and re-insert", function()
        local alloc = arlu.EntityAllocator.new()

        local entityA = alloc:alloc()
        local entityB = alloc:alloc()
        local entityC = alloc:alloc()
        local entityD = alloc:alloc()

        local storage = arlu.ComponentTable.new({1})
        storage:set(entityC, {1}) -- Non-consecutive entity indicies
        storage:set(entityA, {2})
        storage:set(entityB, {3})
        storage:set(entityD, {4})

        -- Remove & Add
        storage:set(entityA, nil)
        storage:set(entityA, {5})

        local iters = {}
        for entity, components in storage:iter() do
            table.insert(iters, {entity = entity.index, value = components[1]})
        end

        assert.are.same(
            {
                {entity = entityC.index, value = 1},
                {entity = entityD.index, value = 4},
                {entity = entityB.index, value = 3},
                {entity = entityA.index, value = 5},
            },
            iters,
            {
                {entity = entityC.index, value = storage:get(entityC)[1]},
                {entity = entityD.index, value = storage:get(entityD)[1]},
                {entity = entityB.index, value = storage:get(entityB)[1]},
                {entity = entityA.index, value = storage:get(entityA)[1]},
            }
        )
    end)

    it("should have a predictable order, after delete, and new insert", function()
        local alloc = arlu.EntityAllocator.new()

        local entityA = alloc:alloc()
        local entityB = alloc:alloc()
        local entityC = alloc:alloc()
        local entityD = alloc:alloc()

        local storage = arlu.ComponentTable.new({1})
        storage:set(entityC, {1}) -- Non-consecutive entity indicies
        storage:set(entityA, {2})
        storage:set(entityB, {3})

        -- Remove & Add
        storage:set(entityA, nil)
        storage:set(entityD, {4})

        local iters = {}
        for entity, components in storage:iter() do
            table.insert(iters, {entity = entity.index, value = components[1]})
        end

        assert.are.same(
            {
                {entity = entityC.index, value = 1},
                {entity = entityB.index, value = 3},
                {entity = entityD.index, value = 4},
            },
            iters,
            {
                {entity = entityC.index, value = storage:get(entityC)[1]},
                {entity = entityB.index, value = storage:get(entityB)[1]},
                {entity = entityD.index, value = storage:get(entityD)[1]},
            }
        )
    end)

    it("[REG] Fetch non-existent component should return nil", function()
        local storage = arlu.ComponentTable.new({1})
        storage:set(arlu.EId.new(1,1), {100})
        assert.are_equal(100, storage:getComponent(1, arlu.EId.new(1,1))) -- Stored component id, Stored Entity
        assert.is_nil(storage:getComponent(2, arlu.EId.new(1,1))) -- Unstored id, Stored Entity

        assert.is_nil(storage:getComponent(1, arlu.EId.new(1,2))) -- Stored component id, Unstored Entity (Bad gen)
        assert.is_nil(storage:getComponent(2, arlu.EId.new(1,2))) -- Unstored id, Unstored Entity (Bad gen)

        assert.is_nil(storage:getComponent(1, arlu.EId.new(2))) -- Stored component id, Unstored Entity (Bad index)
        assert.is_nil(storage:getComponent(2, arlu.EId.new(2))) -- Unstored id, Unstored Entity (Bad index)
    end)

    it("[REG] Component access should not increment count", function()
        local storage = arlu.ComponentTable.new({1,2})
        storage:set(arlu.EId.new(1,1), {100,200})
        assert.are_equal(1, storage._count)
        ---@diagnostic disable-next-line: param-type-mismatch
        storage:getComponent(1, arlu.EId.new(1,1))
        assert.are_equal(1, storage._count)
        storage:get(arlu.EId.new(1,1))
        assert.are_equal(1, storage._count)
    end)

    it("[REG] Attempt to remove non-existent entity should be no-op", function()
        local storage = arlu.ComponentTable.new({1,2})
        storage:set(arlu.EId.new(1,1), {100,200})
        storage:set(arlu.EId.new(2,1), nil)
    end)

end)
