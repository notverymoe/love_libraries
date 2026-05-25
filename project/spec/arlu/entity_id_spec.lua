-- Copyright 2026 Natalie Baker -- MIT --

---@class luassert
---@field message fun(string): luassert.internal

local arlu = require("arlu")

describe("EntityIds", function()

    it("Default init is (1, 1)", function()
        local defId = arlu.EId.new()
        assert.are_equal(defId.index,      1)
        assert.are_equal(defId.generation, 1)
    end)

    it("Init with id but no generation is (id, 1)", function()
        local defId = arlu.EId.new(10)
        assert.are_equal(defId.index,      10)
        assert.are_equal(defId.generation, 1)
    end)

    it("Init with generation but no id is (1, gen)", function()
        local defId = arlu.EId.new(nil, 10)
        assert.are_equal(defId.index,      1)
        assert.are_equal(defId.generation, 10)
    end)

    it("Equality checked id and generation", function()
        local a11 = arlu.EId.new(1, 1)
        local a12 = arlu.EId.new(1, 2)
        local a21 = arlu.EId.new(2, 1)
        local a22 = arlu.EId.new(2, 2)

        -- Test all combos
        assert.are_equal(a11, a11)
        assert.are_not_equal(a11, a12)
        assert.are_not_equal(a11, a21)
        assert.are_not_equal(a11, a22)

        assert.are_equal(a12, a12)
        assert.are_not_equal(a12, a11)
        assert.are_not_equal(a12, a21)
        assert.are_not_equal(a12, a22)

        assert.are_equal(a21, a21)
        assert.are_not_equal(a21, a11)
        assert.are_not_equal(a21, a12)
        assert.are_not_equal(a21, a22)

        assert.are_equal(a22, a22)
        assert.are_not_equal(a22, a11)
        assert.are_not_equal(a22, a12)
        assert.are_not_equal(a22, a21)

        -- Ensure that we're creating seperate instances, instead of reusing
        local t11 = arlu.EId.new(1, 1)
        assert.are_equal(a11, t11)
        assert.is_false(rawequal(a11, t11))
    end)

    it("Next returns a copy with an incremented genration", function()
        local a11 = arlu.EId.new(1, 1)
        local a12 = a11:next()

        assert.are_not_equal(a11, a12)
        assert.are_equal(a11.index, a12.index)
        assert.are_not_equal(a11.generation, a12.generation)
        assert.are_equal(a11.generation+1, a12.generation)
    end)

end)