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

    it("Should be able to store and retrieve data", function ()
        local g = arlu.ComponentSetStorage.new()

        local idx = g:insert(arlu.ComponentSet.from(aId, bId), 1)
        assert.equal(g:getByIdx(idx), 1)
        assert.equal(g:getByKey(arlu.ComponentSet.from(aId, bId)), 1)
        assert.equal(g:getByKey(arlu.ComponentSet.from(bId, aId)), 1) -- Reordered

        -- Reuse idx, change value
        g:insert(arlu.ComponentSet.from(aId, bId), 2)
        assert.equal(g:getByIdx(idx), 2)
        assert.equal(g:getByKey(arlu.ComponentSet.from(aId, bId)), 2)
        assert.equal(g:getByKey(arlu.ComponentSet.from(bId, aId)), 2) -- Reordered

        -- Add second value
        local idx2 = g:insert(arlu.ComponentSet.from(aId, bId, cId), 3)
        assert.equal(g:getByIdx(idx2), 3)
        assert.equal(g:getByKey(arlu.ComponentSet.from(aId, bId, cId)), 3)
        assert.equal(g:getByKey(arlu.ComponentSet.from(aId, cId, bId)), 3) -- Reordered

        -- Ensure still holds first value
        assert.equal(g:getByIdx(idx), 2)
        assert.equal(g:getByKey(arlu.ComponentSet.from(aId, bId)), 2)
        assert.equal(g:getByKey(arlu.ComponentSet.from(bId, aId)), 2) -- Reordered
    end)

    it("Should be able to iterate filter matches", function ()
        local g = arlu.ComponentSetStorage.new()

        local sets = {
            arlu.ComponentSet.from(aId, bId),
            arlu.ComponentSet.from(aId, bId, cId),
            arlu.ComponentSet.from(aId, cId),
            arlu.ComponentSet.from(cId),
            arlu.ComponentSet.from(bId, cId)
        }

        for i,set in ipairs(sets) do
            g:insert(set, i)
        end

        local expected = {1, 2, 3}
        for _,item in pairs(g:filter(arlu.ComponentSet.from(aId))) do
            local found = false
            for _,value in ipairs(expected) do
                if item == value then
                    found = true
                    break
                end
            end
            assert.message("Recieved unexpected data: "..item).is_true(found)
        end

        expected = {3}
        for _,item in pairs(g:filter(arlu.ComponentSet.from(aId), arlu.ComponentSet.from(bId))) do
            local found = false
            for _,value in ipairs(expected) do
                if item == value then
                    found = true
                    break
                end
            end
            assert.message("Recieved unexpected data: "..item).is_true(found)
        end

        expected = {3, 4}
        for _,item in pairs(g:filter(arlu.ComponentSet.from(cId), arlu.ComponentSet.from(bId))) do
            local found = false
            for _,value in ipairs(expected) do
                if item == value then
                    found = true
                    break
                end
            end
            assert.message("Recieved unexpected data: "..item).is_true(found)
        end

        expected = {4}
        for _,item in pairs(g:filter(arlu.ComponentSet.from(cId), arlu.ComponentSet.from(bId, aId))) do
            local found = false
            for _,value in ipairs(expected) do
                if item == value then
                    found = true
                    break
                end
            end
            assert.message("Recieved unexpected data: "..item).is_true(found)
        end

    end)


    it("Should be able to iterate query matches", function ()
        local g = arlu.ComponentSetStorage.new()

        local sets = {
            {requires=arlu.ComponentSet.from(aId, bId),      excludes=arlu.ComponentSet.from(dId)},
            {requires=arlu.ComponentSet.from(aId, bId, cId), excludes=arlu.ComponentSet.from(dId)},
            {requires=arlu.ComponentSet.from(aId, cId),      excludes=arlu.ComponentSet.from(dId)},
            {requires=arlu.ComponentSet.from(cId),           excludes=arlu.ComponentSet.from(eId)},
            {requires=arlu.ComponentSet.from(aId, bId),      excludes=arlu.ComponentSet.from(eId)}
        }

        for i,set in ipairs(sets) do
            g:insert(set, i)
        end

        local expected = {1, 5}
        for _,item in pairs(g:query(arlu.ComponentSet.from(aId, bId))) do
            local found = false
            for _,value in ipairs(expected) do
                if item == value then
                    found = true
                    break
                end
            end
            assert.message("Recieved unexpected data: "..item).is_true(found)
        end

        expected = {5}
        for _,item in pairs(g:query(arlu.ComponentSet.from(aId, bId, dId))) do
            local found = false
            for _,value in ipairs(expected) do
                if item == value then
                    found = true
                    break
                end
            end
            assert.message("Recieved unexpected data: "..item).is_true(found)
        end

        expected = {1}
        for _,item in pairs(g:query(arlu.ComponentSet.from(aId, bId, eId))) do
            local found = false
            for _,value in ipairs(expected) do
                if item == value then
                    found = true
                    break
                end
            end
            assert.message("Recieved unexpected data: "..item).is_true(found)
        end

        expected = {1,2,3}
        for _,item in pairs(g:query(arlu.ComponentSet.from(aId, bId, cId, eId))) do
            local found = false
            for _,value in ipairs(expected) do
                if item == value then
                    found = true
                    break
                end
            end
            assert.message("Recieved unexpected data: "..item).is_true(found)
        end

    end)



end)