-- Copyright 2026 Natalie Baker -- MIT --

---@class luassert
---@field message fun(string): luassert.internal

local arlu = require("arlu")

describe("EntityAllocator", function()
    it("should allocate in a sequence", function()
        local alloc = arlu.EntityAllocator.new()

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
        local alloc = arlu.EntityAllocator.new()

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

    it("should not free already freed indexes", function()
        local alloc = arlu.EntityAllocator.new()

        local gid = alloc:alloc()
        alloc:freeSlow(gid)

        assert
            .message("Simple double-free with no realloc")
            .has_error(function() alloc:freeSlow(gid) end)
    end)

end)