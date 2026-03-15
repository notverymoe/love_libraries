-- Copyright 2026 Natalie Baker -- MIT --

-------------------------------------------------------------------------------
--#region System
-------------------------------------------------------------------------------

---@class System
---@field name string
---@field _handle function
---@field _dependencies {[System]: true}
---@field _dependencyCount integer
local System = {}
System.__index = System

---Create a new system
---@param name string
---@param handle function The handle to execute
---@return System
function System.new(name, handle)
    return setmetatable({name = name, _handle = handle, _dependencies = {}, _dependencyCount = 0}, System)
end

---Adds a dependency that prevents this system running before the given system
---@param other System The system to run after
---@return System
function System.after(self, other)
    if not self._dependencies[other] then
        self._dependencies[other] = true
        self._dependencyCount = self._dependencyCount + 1
    end
    return self
end

-------------------------------------------------------------------------------
--#endregion System
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--#region Schedule
-------------------------------------------------------------------------------

---@class Schedule
---@field name string
---@field _systems System[]
local Schedule = {}
Schedule.__index = Schedule

---@param systems System[]
---@return Schedule
function Schedule.new(name, systems)
    return setmetatable({name = name, _systems = systems}, Schedule)
end

--- Runs every system in-order with the given arguments
---@param ... any
function Schedule.run(self, ...)
    for _,system in pairs(self._systems) do
        system._handle(...)
    end
end

-------------------------------------------------------------------------------
--#endregion Schedule
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--#region ScheduleBuilder
-------------------------------------------------------------------------------

---@class ScheduleBuilder
---@field name string
---@field _systems {[System]: number}
---@field _systemCount integer
local ScheduleBuilder = {}
ScheduleBuilder.__index = ScheduleBuilder

---Creates a new schedule builder
---@return ScheduleBuilder
function ScheduleBuilder.new(name)
    return setmetatable({name = name, _systems = {}, _systemCount = 0}, ScheduleBuilder)
end

---Adds a system to the schedule being built
---@param self ScheduleBuilder
---@param system System
---@return self
function ScheduleBuilder.add(self, system)
    if not self._systems[system] then
        self._systemCount     = self._systemCount + 1
        self._systems[system] = self._systemCount
    end
    return self
end

---Checks if a system has had all of it's "after" dependancies are resolved. 
---A system's dependancy is considered to be resolved if either the system
---it's ordered after is not being added to the schedule, or if the system
---has already been resolved previously. Obviously if a system has no dependancies
---then it's automatically resolved.
---
---@param systems {[System]: integer} All systems being added to the schedule
---@param resolved {[System]: true}[] Systems with their ordering resolved
---@param stage integer The current index being resolved, which is ignored for ordering
---@param system System The system to check if the dependancies have been resolved for
---@return boolean
local function areSystemDepsSatisfied(systems, resolved, stage, system)
    if (system._dependencyCount == 0) then
        return true
    end

    for dep,_ in pairs(system._dependencies) do
        -- If dependency is not in schedule at all, then it's satisfied
        if systems[dep] == nil then return true end

        local found = false
        for i = 1,stage-1 do
            if resolved[i][dep] ~= nil then
                found = true
                break
            end
        end
        if not found then return false end
    end
    return true
end

---Builds the schedule from the systems and their dependencies. The systems
---are first grouped into stages that ensure their dependencies were satisfied
---in a previous stage. Then within each group, they are sorted by insertion
---order to ensure deterministic system ordering.
---
---TODO CONDITION we store systems by-system. Is this going to break insertion 
---order guarntees in any way when we group systems into stages, since iteration
---order is not guarnteed? Hopefully not, but we should check...
---
---@return Schedule
function ScheduleBuilder.build(self)
    local pending = {} --[[@as {[System]: true}]]
    
    -- Initial
    for system,_ in pairs(self._systems) do
        pending[system] = true
    end

    -- Resolve remaining
    ---@type {[System]: integer}[]
    local resolved = { }
    local stage = 1
    local pendingCount = self._systemCount
    while pendingCount > 0 do
        local resolveCount = 0
        resolved[stage] = {}
        for system,_ in pairs(pending) do
            if areSystemDepsSatisfied(self._systems, resolved, stage, system) then
                resolved[stage][system] = self._systems[system]
                pending[system] = nil
                pendingCount = pendingCount - 1
                resolveCount = resolveCount + 1
            end
        end

        if resolveCount <= 0 then
            error("Could not resolve schedule with name: "..self.name)
        end

        stage = stage + 1
    end

    -- Final flattened ordering of stages
    ---@type System[]
    local orderedSystems = {}
    for _,group in pairs(resolved) do

        --@TODO OPT Certainly some faster way to append these tables in-order

        ---@type {[integer]: {system: System, ordering: integer}}
        local sorting = {}
        for system,ordering in pairs(group) do
            table.insert(sorting, {system=system, ordering=ordering})
        end
        table.sort(sorting, function(a, b) return a.ordering < b.ordering end)

        for _,sortPair in ipairs(sorting) do
            table.insert(orderedSystems, sortPair.system)
        end

    end

    return Schedule.new(self.name, orderedSystems)
end

-------------------------------------------------------------------------------
--#endregion ScheduleBuilder
-------------------------------------------------------------------------------

---@class SardineModuleSchedule
---@field System System
---@field Schedule Schedule
---@field ScheduleBuilder ScheduleBuilder

return {
    System           = System,
    Schedule         = Schedule,
    ScheduleBuilder  = ScheduleBuilder,
}