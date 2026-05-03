-- Copyright 2026 Natalie Baker -- MIT --

local sardine = require("sardine")

---@class luassert
---@field message fun(string): luassert.internal

describe("EntityAllocator", function()
    it("should allocate in a sequence", function()
        local alloc = sardine.EntityAllocator.new()

        local gid = alloc:alloc()
        assert.message("Allocator should start with index 1").equal(1, gid.index)
        assert.message("Allocator should start with generation 1").equal(1, gid.generation)
        
        local gid = alloc:alloc()
        assert.message("Allocation #2 should have an index of 2").equal(2, gid.index)
        assert.message("Allocation #2 should have a generation of 1").equal(1, gid.generation)
        
        local gid = alloc:alloc()
        assert.message("Allocation #3 should have an index of 3").equal(3, gid.index)
        assert.message("Allocation #3 should have a generation of 1").equal(1, gid.generation)
        
        local gid = alloc:alloc()
        assert.message("Allocation #3 should have an index of 3").equal(4, gid.index)
        assert.message("Allocation #3 should have a generation of 1").equal(1, gid.generation)

    end)

    it("should reuse freed indexes", function()
        local alloc = sardine.EntityAllocator.new()

        local gid1 = alloc:alloc()
        local gid2 = alloc:alloc()
        alloc:freeUnchecked(gid1)
        local gid3 = alloc:alloc()

        assert.message("Allocator should reuse the first index").equal(1, gid3.index)
        assert.message("Allocator should increment the generation on reuse").equal(2, gid3.generation)

        alloc:freeUnchecked(gid2)
        local gid4 = alloc:alloc()

        assert.message("Allocator should reuse the second index").equal(2, gid4.index)
        assert.message("Allocator should increment the generation on reuse").equal(2, gid4.generation)

        alloc:freeUnchecked(gid4)
        local gid5 = alloc:alloc()

        assert.message("Allocator should reuse the second index again").equal(2, gid5.index)
        assert.message("Allocator should increment the generation again on reuse").equal(3, gid5.generation)
    end)

    --TODO need a checked free
-- it("should not free already freed indexes", function()
--     local alloc = sardine.EntityAllocator.new()

--     local gid = alloc:alloc()
--     alloc:freeUnchecked(gid)
--     assert.message("Simple double-free with no realloc").has_error(function()
--         alloc:freeUnchecked(gid)
--     end)

-- end)

end)

describe("ComponentColumn", function()

    it("can store and retrieve entity data", function()
        local alloc = sardine.EntityAllocator.new()
        local entityA = alloc:alloc()
        local storage = sardine.ComponentColumn.new()
        storage:add(entityA, 126)
        assert.are.equal(126, storage:get(entityA))
    end)

    it("should have a predictable order", function()
        local alloc = sardine.EntityAllocator.new()

        local entityA = alloc:alloc()
        local entityB = alloc:alloc()
        local entityC = alloc:alloc()

        local storage = sardine.ComponentColumn.new()
        storage:add(entityC, 1) -- Non-consecutive entity indicies
        storage:add(entityA, 2)
        storage:add(entityB, 3)

        local iters = {}
        for entity, component in storage:iter() do
            table.insert(iters, {entity = entity.index, value = component})
        end

        assert.are.same(
            {
                {entity = entityC.index, value = 1},
                {entity = entityA.index, value = 2},
                {entity = entityB.index, value = 3},
            },
            iters,
            {
                {entity = entityC.index, value = storage:get(entityC)},
                {entity = entityA.index, value = storage:get(entityA)},
                {entity = entityB.index, value = storage:get(entityB)},
            }
        )
    end)

    it("should have a predictable order, after delete", function()
        local alloc = sardine.EntityAllocator.new()

        local entityA = alloc:alloc()
        local entityB = alloc:alloc()
        local entityC = alloc:alloc()

        local storage = sardine.ComponentColumn.new()
        storage:add(entityC, 1) -- Non-consecutive entity indicies
        storage:add(entityA, 2)
        storage:add(entityB, 3)
        storage:remove(entityA)

        local iters = {}
        for entity, component in storage:iter() do
            table.insert(iters, {entity = entity.index, value = component})
        end

        assert.are.same(
            {
                {entity = entityC.index, value = 1},
                {entity = entityB.index, value = 3},
            },
            iters,
            {
                {entity = entityC.index, value = storage:get(entityC)},
                {entity = entityB.index, value = storage:get(entityB)},
            }
        )
    end)

    it("should have a predictable order, after delete, and re-insert", function()
        local alloc = sardine.EntityAllocator.new()

        local entityA = alloc:alloc()
        local entityB = alloc:alloc()
        local entityC = alloc:alloc()
        local entityD = alloc:alloc()

        local storage = sardine.ComponentColumn.new()
        storage:add(entityC, 1) -- Non-consecutive entity indicies
        storage:add(entityA, 2)
        storage:add(entityB, 3)
        storage:add(entityD, 4)

        -- Remove & Add
        storage:remove(entityA)
        storage:add(entityA, 5)

        local iters = {}
        for entity, component in storage:iter() do
            table.insert(iters, {entity = entity.index, value = component})
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
                {entity = entityC.index, value = storage:get(entityC)},
                {entity = entityD.index, value = storage:get(entityD)},
                {entity = entityB.index, value = storage:get(entityB)},
                {entity = entityA.index, value = storage:get(entityA)},
            }
        )
    end)

    it("should have a predictable order, after delete, and new insert", function()
        local alloc = sardine.EntityAllocator.new()

        local entityA = alloc:alloc()
        local entityB = alloc:alloc()
        local entityC = alloc:alloc()
        local entityD = alloc:alloc()

        local storage = sardine.ComponentColumn.new()
        storage:add(entityC, 1) -- Non-consecutive entity indicies
        storage:add(entityA, 2)
        storage:add(entityB, 3)

        -- Remove & Add
        storage:remove(entityA)
        storage:add(entityD, 4)

        local iters = {}
        for entity, component in storage:iter() do
            table.insert(iters, {entity = entity.index, value = component})
        end

        assert.are.same(
            {
                {entity = entityC.index, value = 1},
                {entity = entityB.index, value = 3},
                {entity = entityD.index, value = 4},
            },
            iters,
            {
                {entity = entityC.index, value = storage:get(entityC)},
                {entity = entityB.index, value = storage:get(entityB)},
                {entity = entityD.index, value = storage:get(entityD)},
            }
        )
    end)

end)
