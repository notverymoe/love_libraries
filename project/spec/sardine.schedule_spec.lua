-- Copyright 2026 Natalie Baker -- MIT --

local sardine = require("sardine")

---@class luassert
---@field message fun(string): luassert.internal

describe("Schedule", function()

    local function createOrderSystem(name, index, updateCount)
        return sardine.System.new(name, function()
            local count = updateCount()
            assert.message("System expects be run "..name).equal(index, count)
        end)
    end

    it("NoDeps", function()
        local counter = 1
        local function updateCounter()
            counter = counter + 1
            return counter - 1
        end

        local sysA = createOrderSystem("first",  1, updateCounter)
        local sysB = createOrderSystem("second", 2, updateCounter)
        local sysC = createOrderSystem("third",  3, updateCounter)

        local builder = sardine.ScheduleBuilder.new("Test Schedule")
            :add(sysA) -- Must be in-order because we have no dep working
            :add(sysB)
            :add(sysC)
        assert.message("Expect schedule builder to have 3 systems").equal(3, builder._systemCount)

        local schedule = builder:build()
        assert.message("Expect schedule to have 3 systems").equal(3, #schedule._systems)

        schedule:run()
        assert.message("Expect systems to have counted to 4").equal(4, counter)
    end)

    it("SingleLinearDeps", function()
        local counter = 1
        local function updateCounter()
            counter = counter + 1
            return counter - 1
        end

        local sysA   = createOrderSystem("first",  1, updateCounter)
        local sysAA  = createOrderSystem("second", 2, updateCounter):after(sysA )
        local sysAAA = createOrderSystem("third",  3, updateCounter):after(sysAA)

        local builder = sardine.ScheduleBuilder.new("Test Schedule")
            :add(sysAAA) -- Out of order to ensure dep ordering being tested
            :add(sysA  )
            :add(sysAA )
        assert.message("Expect schedule builder to have 3 systems").equal(3, builder._systemCount)

        local schedule = builder:build()
        assert.message("Expect schedule to have 3 systems").equal(3, #schedule._systems)

        schedule:run()
        assert.message("Expect systems to have counted to 4").equal(4, counter)
    end)

    it("MultiLinearDeps", function()

        local counter = 1
        local function updateCounter()
            counter = counter + 1
            return counter - 1
        end

        local sysA = createOrderSystem("first", 1, updateCounter)
            local sysAA = createOrderSystem("third", 3, updateCounter):after(sysA)
                local sysAAA = createOrderSystem("seventh", 7, updateCounter):after(sysAA)
            local sysAB = createOrderSystem("fourth", 4, updateCounter):after(sysA)
                local sysABA = createOrderSystem("eigth", 8, updateCounter):after(sysAB)
                local sysABB = createOrderSystem("ninth", 9, updateCounter):after(sysAB)
        local sysB = createOrderSystem("second", 2, updateCounter)
            local sysBA = createOrderSystem("fifth", 5, updateCounter):after(sysB)
            local sysBB = createOrderSystem("sixth", 6, updateCounter):after(sysB)

        local builder = sardine.ScheduleBuilder.new("Test Schedule")
            :add(sysA)
                :add(sysAA)
                    :add(sysAAA)
                :add(sysAB)
                    :add(sysABA)
                    :add(sysABB)
            :add(sysB)
                :add(sysBA)
                :add(sysBB)
        assert.message("Expect schedule builder to have 9 systems").equal(9, builder._systemCount)

        local schedule = builder:build()
        assert.message("Expect schedule to have 9 systems").equal(9, #schedule._systems)

        schedule:run()
        assert.message("Expect systems to have counted to 10").equal(10, counter)
    end)
end)

--TODO test setup init funcs
--TODO test run params
--TODO test init params

