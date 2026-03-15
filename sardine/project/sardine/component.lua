-- Copyright 2026 Natalie Baker -- MIT --

local IMPORT_ROOT = (...):match("(.-)[^%.]+$")

local SARDINE_MODULE_ENTITY = require(IMPORT_ROOT.."entity") --[[@as SardineModuleEntity]]
local GenIdStorage   = SARDINE_MODULE_ENTITY.GenIdStorage
local GenIdAllocator = SARDINE_MODULE_ENTITY.GenIdAllocator

-------------------------------------------------------------------------------
--#region Types
-------------------------------------------------------------------------------

---@class Query
---@field required GenIdStorage[]
---@field excluded GenIdStorage[]
---@field optional GenIdStorage[]
local Query = {}
Query.__index = Query

---@class ComponentSet
---@field _items {[ComponentId]: true}
local ComponentSet = {}
ComponentSet.__index = ComponentSet

---@class ComponentStorage
---@field _components {[ComponentId]: GenIdStorage}
---@field _entityComponents GenIdStorage
---@field _entityIds GenIdAllocator
local ComponentStorage = {}
ComponentStorage.__index = ComponentStorage

-------------------------------------------------------------------------------
--#endregion Types
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--#region registerComponent
-------------------------------------------------------------------------------

---@class ComponentId
---@field uid integer

local COMPONENT_REGISTRY_ID = 0

---@param name string
---@return ComponentId
local function registerComponent(name)
    COMPONENT_REGISTRY_ID = COMPONENT_REGISTRY_ID + 1
    return { uid = COMPONENT_REGISTRY_ID, name = name }
end

-------------------------------------------------------------------------------
--#endregion registerComponent
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--#region ComponentSet
-------------------------------------------------------------------------------

---@return ComponentSet
function ComponentSet.new()
    return setmetatable({_items ={}}, ComponentSet)
end

---@param k ComponentId
---@param v boolean
---@return boolean
function ComponentSet.set(self, k, v)
    local prev = not not self._items[k]
    self._items[k] = v or nil
    return prev
end

---@param k ComponentId
---@return boolean
function ComponentSet.add(self, k)
    return self:set(k, true)
end

---@param k ComponentId
---@return boolean
function ComponentSet.remove(self, k)
    return self:set(k, false)
end

function ComponentSet.clear(self)
    self._items = {}
end

---@param k ComponentId
---@return boolean
function ComponentSet.has(self, k)
    return not not self._items[k]
end

-------------------------------------------------------------------------------
--#endregion ComponentSet
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--#region ComponentStorage
-------------------------------------------------------------------------------

function ComponentStorage.new()
    return setmetatable({
        _components       = {},
        _entityComponents = GenIdStorage.new(),
        _entityIds        = GenIdAllocator.new(),
    }, ComponentStorage)
end

---@param attachments { [ComponentId]: any } | nil
---@return GenId
function ComponentStorage.spawn(self, attachments)
    local eId = self._entityIds:alloc()
    if attachments then self:attachAll(eId, attachments) end
    return eId
end

---@param eId GenId
---@param attachments { [ComponentId]: any }
---@param replace boolean | nil
function ComponentStorage.attachAll(self, eId, attachments, replace)
    local components = self:getEntityComponentSet(eId)
    for k,v in pairs(attachments) do
        -- Mark the component on the entity, set component data if
        -- it did not have it before or if we are in replace mode
        if not components:add(k) or replace then
            self:getComponentType(k):addOrSet(eId, v)
        end
    end
end

---@param eId GenId
---@param cId ComponentId
---@param cVal any
function ComponentStorage.attach(self, eId, cId, cVal)
    self:getEntityComponentSet(eId):add(cId)
    self:getComponentType(cId):addOrSet(eId, cVal)
end

---@param eId GenId
---@param cId ComponentId
---@param cVal any
function ComponentStorage.detach(self, eId, cId, cVal)
    if self:getEntityComponentSet(eId):remove(cId) then
        self:getComponentType(cId):addOrSet(eId, cVal)
    end
end

---@param eId GenId
function ComponentStorage.despawn(self, eId)
    self._entityIds:freeUnchecked(eId)
    for _,cId in (self._entityComponents:remove(eId) --[[ @as ComponentSet ]]) do
        self:getComponentType(cId):remove(eId)
    end
end

---@param eId GenId
---@param cId ComponentId
---@return any
function ComponentStorage.get(self, eId, cId)
    return self:getComponentType(cId):get(eId)
end

---@param cId ComponentId
---@return (fun(table: table<GenId, any>, index?: GenId):GenId, any), table<GenId, any>
function ComponentStorage.components(self, cId)
    return pairs(self:getComponentType(cId).data)
end

---@param eId GenId
---@return ComponentSet
function ComponentStorage.getEntityComponentSet(self, eId)
    return self._entityComponents:getOrSet(eId, ComponentSet.new) --[[ @as ComponentSet ]]
end

---@param cId ComponentId
---@return GenIdStorage
function ComponentStorage.getComponentType(self, cId)
    local storage = self._components[cId] or GenIdStorage.new()
    self._components[cId] = storage
    return storage
end

---@param components GenIdStorage[]
---@param entity GenId
---@return nil | any[]
local function getComponentMapRequired(components, entity)
    local result = {}
    for i,storage in ipairs(components) do
        local component = storage:tryGet(entity)
        if component == nil then
            return nil
        end
        result[i] = component
    end
    return result
end

---@param components GenIdStorage[]
---@param entity GenId
---@return any[]
local function getComponentMapOptional(components, entity)
    local result = {}
    for i,storage in ipairs(components) do
        result[i] = storage:tryGet(entity)
    end
    return result
end

---Iterate across all entities sharing a set of components
---@param self ComponentStorage
---@param require ComponentId[]
---@param exclude ComponentId[] | nil
---@param optional ComponentId[] | nil
---@return fun(state: ComponentStorage, key: GenId): (GenId, any[], any[]), Query, any
function ComponentStorage.query(self, require, exclude, optional)
    return Query.new(self, require, exclude, optional):run()
end

-------------------------------------------------------------------------------
--#endregion ComponentStorage
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--#region Query
-------------------------------------------------------------------------------

---@param storage ComponentStorage
---@param require ComponentId[]
---@param exclude ComponentId[] | nil
---@param optional ComponentId[] | nil
---@return Query
function Query.new(storage, require, exclude, optional)

    ---@type GenIdStorage[]
    local reqComponents = {}
    for i,id in ipairs(require) do reqComponents[i] = storage:getComponentType(id) end

    ---@type GenIdStorage[]
    local optComponents = {}
    for i,id in ipairs(optional or {}) do optComponents[i] = storage:getComponentType(id) end

    ---@type GenIdStorage[]
    local exclComponents = {}
    for i,id in ipairs(exclude or {}) do exclComponents[i] = storage:getComponentType(id) end

    return setmetatable({
        required = reqComponents,
        optional = optComponents,
        excluded = exclComponents,
    }, Query)
end

---@param self Query
---@return fun(state: ComponentStorage, key: GenId): (GenId, any[], any[]), Query, any
function Query.run(self)

    ---@type GenIdStorage
    local minComponent = nil
    for _,storage in ipairs(self.required) do
        if minComponent == nil or storage.count < minComponent.count then
            minComponent = storage
        end
    end

    local next, t, _ = minComponent:iter()
    return function(_t, p)
        while(true) do
            local entity, _ = next(t, p)
            ---@diagnostic disable-next-line: return-type-mismatch
            if entity == nil then return nil, nil, nil end
            p = entity

            local componentMap = getComponentMapRequired(self.required, entity)
            if componentMap ~= nil then

                local skip = false
                for _,storage in ipairs(self.excluded) do
                    if storage:tryGet(entity) ~= nil then
                        skip = true
                        break
                    end
                end

                if not skip then
                    local optionalMap = getComponentMapOptional(self.optional, entity)
                    return entity, componentMap, optionalMap
                end
            end
        end
    end, self, nil

end

-------------------------------------------------------------------------------
--#endregion Query
-------------------------------------------------------------------------------

--@TODO ComponentStorage get component(s) on entity
--@TODO ComponentStorage get all components on entity
--@TODO Archetype storage?

---@class SardineModuleComponent
---@field Query Query
---@field ComponentStorage ComponentStorage
---@field registerComponent fun(name: string): ComponentId

return {
    ComponentStorage  = ComponentStorage,
    Query             = Query,
    registerComponent = registerComponent,
}

