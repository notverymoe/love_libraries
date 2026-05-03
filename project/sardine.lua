-- Copyright 2026 Natalie Baker -- MIT --

local ffi = require("ffi")

--===========================================================================--
--#region Entities
--===========================================================================--

-------------------------------------------------------------------------------
--#region IdEntity
-------------------------------------------------------------------------------

local IdEntity_t = ffi.typeof[[struct { 
    uint32_t index; 
    uint32_t generation;
}]]

---@class IdEntity
---@field index integer
---@field generation integer
local IdEntity = {}
IdEntity.__index = IdEntity
ffi.metatype(IdEntity_t, IdEntity)

--- Create a new EntityId. 
--- An index or generation of 0 is an "invalid" identifier.
---@param index      integer | nil Index of the identifier, defaults to 1
---@param generation integer | nil Generation of the identifier, defaults to 1
---@return IdEntity
function IdEntity.new(index, generation)
    if index      == nil then index      = 1 end
    if generation == nil then generation = 1 end
    return IdEntity_t(index, generation) --[[@as IdEntity]]
end

--- Gets the EntityId with the next generation
---@param id integer
---@return IdEntity
function IdEntity.withId(self, id)
    return IdEntity.new(id, self.generation)
end

--- Gets the EntityId with the next generation
---@return IdEntity
function IdEntity.next(self)
    return IdEntity.new(self.index, self.generation+1)
end

--- An index or generation of 0 is an "invalid" identifier.
---@return boolean
function IdEntity.isValid(self)
    return self.index > 0 and self.generation > 0
end

-------------------------------------------------------------------------------
--#endregion IdEntity
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--#region EntityAllocator
-------------------------------------------------------------------------------

---@class EntityAllocator
---@field _freelist IdEntity[]
---@field _freecount integer
---@field _next integer
local EntityAllocator = {}
EntityAllocator.__index = EntityAllocator

---Creates a new EntityId allocator
---@return EntityAllocator
function EntityAllocator.new()
    return setmetatable(
        {_next = 0, _freelist = {}, _freecount = 0},
        EntityAllocator
    )
end

---Allocates a single new EntityId
---@return IdEntity
function EntityAllocator.alloc(self)
    if self._freecount > 0 then
        self._freecount = self._freecount-1
        return table.remove(self._freelist, self._freecount+1)
    else
        self._next = self._next + 1
        return IdEntity.new(self._next)
    end
end

---Frees a single EntityId for reuse with a newer generation
---@param id IdEntity The identifier to free for reuse
---@warning This method cannot verify if an id has been freed previously or is still valid
function EntityAllocator.freeUnchecked(self, id)
    self._freecount = self._freecount + 1
    table.insert(self._freelist, self._freecount, id:next())
end


-------------------------------------------------------------------------------
--#endregion EntityIdAllocator
-------------------------------------------------------------------------------

--===========================================================================--
--#endregion Entities
--===========================================================================--

--===========================================================================--
--#region Components
--===========================================================================--

------------------------------------------------------------------------------
--#region IdComponent
------------------------------------------------------------------------------

---@class IdComponent

---@class ModuleIdComponent
---@field _next integer
---@field _data {name: string, uid: string}[]
---@field _lookup table<string, integer>
local IdComponent = {
    _next   = 1,
    _data   = {},
    _lookup = {}
}

---Register a component
---@param name string Name of the component, should be unique or provide uid in options
---@param options { uid: string? }? Options to configure the registered component with
---@return IdComponent
---@nodiscard
function IdComponent.register(name, options)
    options = options or {}
    local uid = options.uid or name

    if IdComponent._lookup[uid] ~= nil then
        error("Component with given UID already exists: " + uid)
    end

    local id = IdComponent._next
    IdComponent._next = IdComponent._next + 1

    IdComponent._lookup[uid] = id
    IdComponent._data[id] = {name = name, uid = uid}

    return id --[[@as IdComponent]]
end

---Gets the name of the given component ID
---@param id any
---@return string
---@nodiscard
function IdComponent.nameOfId(id)
    return IdComponent._data[id].name
end

---Gets the name of the given component UID
---@return string
---@nodiscard
function IdComponent.nameOfUID(uid)
    local id = IdComponent.fromUID(uid)
    return id and IdComponent._data[id].name
end

---Gets the component ID of the given component UID
---@return string
---@nodiscard
function IdComponent.toUID(id)
    local entry = IdComponent._data[id]
    return entry and entry.uid
end

---Gets the component ID of the given component UID
---@return IdComponent
---@nodiscard
function IdComponent.fromUID(uid)
    return IdComponent._lookup[uid] --[[@as IdComponent]]
end

------------------------------------------------------------------------------
--#endregion IdComponent
------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--#region ComponentColumn
-------------------------------------------------------------------------------

---@class ComponentColumn
---@field count integer
---@field _slots IdEntity[]
---@field data any[]
---@field _back integer[]
local ComponentColumn = {}
ComponentColumn.__index = ComponentColumn

---Creates a new storage for EntityId-associated data
---@return ComponentColumn
function ComponentColumn.new()
    return setmetatable(
        {count = 0, data = {}, _slots = {}, _back = {}},
        ComponentColumn
    ) --[[@as ComponentColumn]]
end

---@param self ComponentColumn
---@return fun(state: ComponentColumn, key: integer): (integer, any), ComponentColumn, any
function ComponentColumn.iterFast(self)
    return pairs(self.data)
end

---@param self ComponentColumn
---@return fun(state: ComponentColumn, key: IdEntity): (IdEntity, any), ComponentColumn, any
function ComponentColumn.iter(self)
    local next, t, _ = pairs(self.data)
    return function(self, p)
        local k, v = next(t, p and self._slots[p.index].index)
        return k and self._slots[self._back[k]]:withId(self._back[k]), k and v
    end, self, nil
end

local ZERO_SLOT = IdEntity.new(0,0)

function ComponentColumn._getSlot(self, entityId)
    return self._slots[entityId.index] or ZERO_SLOT
end

---Adds a new value associated with the given EntityId
---@param entityId IdEntity
---@param value any
function ComponentColumn.add(self, entityId, value)
    if(self:_getSlot(entityId).generation > entityId.generation) then
        error("Slot already used with newer generation, cannot reuse older generation")
    end
    self.count = self.count + 1
    self._slots[entityId.index] = IdEntity.new(self.count, entityId.generation)
    self._back[self.count] = entityId.index
    self.data[self.count] = value
end

---Sets data currently associated with the given EntityId to a new value
---@param entityId IdEntity The identifier to update the value of
---@param value any The new value to associate
function ComponentColumn.set(self, entityId, value)
    self.count = self.count + 1
    local slot = self:_getSlot(entityId)
    if (slot.index      <= 0              ) then error("EntityId is not allocated") end
    if (slot.generation ~= entityId.generation) then error("EntityId generation does not match slot generation") end
    self.data[slot.index] = value
end

---Adds or sets data currently associated with the given EntityId to a new value
---@param entityId IdEntity The identifier to update the value of
---@param value any The new value to associate
function ComponentColumn.addOrSet(self, entityId, value)
    self.count = self.count + 1
    local slot = self:_getSlot(entityId)
    if (slot.index <= 0) or (slot.generation ~= entityId.generation) then
        self:add(entityId, value)
    else
        self.data[slot.index] = value
    end
end

---Gets the data in the given slot index
---@param slotIdx integer
---@return IdEntity
function ComponentColumn.getEntityIdFromRaw(self, slotIdx)
    --TODO SAFETY
    local back = self._back[slotIdx]
    return self._slots[back]:withId(back)
end

---Gets the data in the given slot index
---@param slotIdx integer
---@return any
function ComponentColumn.getRaw(self, slotIdx)
    --TODO SAFETY
    return self.data[slotIdx]
end

---Gets the data currently associated with the given EntityId
---@param entityId IdEntity
---@return any
function ComponentColumn.get(self, entityId)
    self.count = self.count + 1
    local slot = self:_getSlot(entityId)
    if (slot.index      <=               0) then error("EntityId is not allocated") end
    if (slot.generation ~= entityId.generation) then error("EntityId generation does not match slot generation") end
    return self.data[slot.index]
end

---Tries to get the data currently associated with the given EntityId, or nil if not assigned
---@param entityId IdEntity
---@return any
function ComponentColumn.tryGet(self, entityId)
    self.count = self.count + 1
    local slot = self:_getSlot(entityId)
    if (slot.index      <=               0) then return nil end
    if (slot.generation ~= entityId.generation) then return nil end
    return self.data[slot.index]
end

---Gets the data currently associated with the given EntityId
---@param entityId IdEntity
---@return any
function ComponentColumn.getOrSet(self, entityId, defVal)
    self.count = self.count + 1
    local slot = self:_getSlot(entityId)
    if (slot.index <= 0) or (slot.generation ~= entityId.generation) then
        local val = defVal()
        self:add(entityId, val)
        return val
    else
        return self.data[slot.index]
    end
end

--- Removes the data associated with the current EntityId and prevents
--- reusing the EntityId in future new associations.
---@param entityId IdEntity
---@return any _ The last value associated with the given id
function ComponentColumn.remove(self, entityId)
    local slot = self:_getSlot(entityId)
    if slot.index <= 0 then error("EntityId is not allocated") end

    -- Move slot to end of data
    local slotValue = self.data[slot.index]
    if slot.index ~= self.count then
        local endIndex = self._back[self.count]
        self._slots[endIndex].index = slot.index      -- point end slot to vacated data index
        self._back[slot.index]      = endIndex        -- point back ref to vacated slot index
        self.data[slot.index] = self.data[self.count] -- move data into slot
        -- The original back ref can dangle, it's fine
    end

    -- Dealloc last slot
    slot.index = 0
    self.data[self.count] = nil
    self.count = self.count - 1

    return slotValue
end

-------------------------------------------------------------------------------
--#endregion ComponentColumn
-------------------------------------------------------------------------------

--===========================================================================--
--#endregion Components
--===========================================================================--

--===========================================================================--
--#region ComponentSets
--===========================================================================--

------------------------------------------------------------------------------
--#region ComponentSet
------------------------------------------------------------------------------

---@alias ComponentSet table<IdComponent, any>

---@class ModuleComponentSet
local ComponentSet = {}

--- Checks if all components listed in `a` exist in `b`
---@param a ComponentSet
---@param b ComponentSet
---@return boolean
---@nodiscard
function ComponentSet.all(a, b)
    for k,_ in pairs(a) do
        if b[k] == nil then
            return false
        end
    end
    return true
end

--- Checks if any component listed in `a` exists in `b`
---@param a ComponentSet
---@param b ComponentSet
---@return boolean
---@nodiscard
function ComponentSet.any(a, b)
    for k,_ in pairs(a) do
        if b[k] ~= nil then
            return true
        end
    end
    return false
end

--- Checks that `a`and `b` list exactly the same components
---@param a ComponentSet
---@param b ComponentSet
---@return boolean
---@nodiscard
function ComponentSet.exact(a, b)
    local count = 0

    --- Check keys in self exist in other table,
    --- and count number of keys in this container
    for k,_ in pairs(a) do
        if b[k] == nil then
            return false
        end
        count = count + 1
    end

    --- Ensure other table has same number of keys,
    --- if all of our keys existed in the other and
    --- we have the same number of keys, then we both
    --- have the same keys.
    for _ in pairs(b) do
        count = count - 1
    end

    return count == 0
end

------------------------------------------------------------------------------
--#endregion ComponentSet
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--#region ComponentSetFilter
------------------------------------------------------------------------------

---@alias ComponentSetFilter {includes: ComponentSet, excludes: ComponentSet} | ComponentSet

---@class ModuleComponentSetFilter
local ComponentSetFilter = {}

---Returns the ComponentSet representing the included (required) components
---@param a ComponentSetFilter
---@return ComponentSet
---@nodiscard
function ComponentSetFilter.includes(a)
    return a.includes or a
end

---Returns the ComponentSet representing the excluded components
---@param a ComponentSetFilter
---@return ComponentSet
---@nodiscard
function ComponentSetFilter.excludes(a)
    return a.excludes or {}
end

---Checks if `a` will accept `b`
---@param a ComponentSetFilter filter
---@param b ComponentSet item
---@return boolean
---@nodiscard
function ComponentSetFilter.accepts(a, b)
    return ComponentSet.all(ComponentSetFilter.includes(a), b) and
       not ComponentSet.any(ComponentSetFilter.excludes(a), b)
end

---Checks if `a` is eaxctly the same as `b`
---@param a ComponentSetFilter filter
---@param b ComponentSetFilter filter
---@return boolean
---@nodiscard
function ComponentSetFilter.exact(a, b)
    return ComponentSet.exact(
        ComponentSetFilter.includes(a),
        ComponentSetFilter.includes(b)
    ) and ComponentSet.exact(
        ComponentSetFilter.excludes(a),
        ComponentSetFilter.excludes(b)
    )
end

------------------------------------------------------------------------------
--#endregion ComponentSetFilter
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--#region ComponentSetStorage
------------------------------------------------------------------------------

---@class ComponentSetStorage
---@field _next integer
---@field _groups table<IdComponent, {key: ComponentSetFilter, idx: integer}[]>
---@field _data any[]
local ComponentSetStorage = {}
ComponentSetStorage.__index = ComponentSetStorage

function ComponentSetStorage.new()
    return setmetatable({_next = 1, _groups = {}, _data = {}}, ComponentSetStorage)
end

---Insert a new entry or replace an existing entry
---@param self ComponentSetStorage
---@param k ComponentSetFilter The composite key to associate with
---@param v any The value to associate with the composite key
---@return integer idx The data index inserted at
function ComponentSetStorage.insert(self, k, v)
    local idx = self:indexOf(k)
    if idx == nil then
        idx = self._next
        self._next = self._next + 1

        -- Add to lookup
        for part,_ in pairs(ComponentSetFilter.includes(k)) do
            local group = self._groups[part] or {}
            table.insert(group, {key=k, idx=idx})
            self._groups[part] = group
        end
    end

    self._data[idx] = v
    return idx
end

function ComponentSetStorage.remove(self, k)

end

---Finds all composite keys that accept the given components
---@param self ComponentSetStorage
---@param components ComponentSet The list of components search with
---@return table<integer, any> results Pairs of data index and data that accepted the given component set
---@nodiscard
function ComponentSetStorage.query(self, components)
    local found = {}
    for part,_ in pairs(ComponentSetFilter.includes(components)) do
        local group = self._groups[part]
        if group ~= nil then
            for _,entry in ipairs(group) do
                if found[entry.idx] == nil and ComponentSetFilter.accepts(entry.key, components) then
                    found[entry.idx] = self._data[entry.idx]
                end
            end
        end
    end
    return found
end

---Gets the data associated with the given key
---@param self ComponentSetStorage
---@param k ComponentSetFilter The composite key to lookup
---@return any data The data associated with the given composite key, or nil if it doesn't exist
---@nodiscard
function ComponentSetStorage.getByKey(self, k)
    local idx = self:indexOf(k)
    return idx and self:getByIdx(idx)
end

---Gets data by the raw index
---@param self ComponentSetStorage
---@param idx integer The index of the data to get
---@return any data The data stored at the given index, or nil if it doesn't exist
---@nodiscard
function ComponentSetStorage.getByIdx(self, idx)
    return self._data[idx]
end

---Finds the data index of the given key, or nil if it doesn't exist
---@param self ComponentSetStorage
---@param k ComponentSetFilter
---@return integer? index The data index of the key
---@nodiscard
function ComponentSetStorage.indexOf(self, k)
    --TODO OPT we could find the smallest group?
    for part,_ in pairs(ComponentSetFilter.includes(k)) do
        local group = self._groups[part]
        if group == nil then
            return nil -- If the group doesn't exist we don't store the key
        end
        for _,entry in ipairs(group) do
            if ComponentSetFilter.exact(k, entry.key) then
                return entry.idx
            end
        end
    end
    return nil
end

------------------------------------------------------------------------------
--#endregion ComponentSetStorage
------------------------------------------------------------------------------

--===========================================================================--
--#endregion ComponentSets
--===========================================================================--

--===========================================================================--
--#region Archetypes
--===========================================================================--

---@class IdArchetype

---@class IdQuery

------------------------------------------------------------------------------
--#region ArchetypeTable
------------------------------------------------------------------------------

---@class ArchetypeTable
---@field components ComponentSet
---@field columns table<IdComponent, ComponentColumn>
local ArchetypeTable = {}
ArchetypeTable.__index = ArchetypeTable

--TODO flatten ComponentColumn into ArchetypeTable to remove redundant lookups and back tables

---@param components ComponentSet
---@return ArchetypeTable
function ArchetypeTable.new(components)
    local columns = {}
    for id,_ in pairs(components) do
        columns[id] = ComponentColumn.new()
    end
    return setmetatable(
        { components=components, columns=columns, },
        ArchetypeTable
    )
end

---@param self ArchetypeTable
---@param entity IdEntity
---@param components ComponentSet
function ArchetypeTable.insert(self, entity, components)
    if not ComponentSet.exact(self.components, components) then
        error("Inserted components do not match archetype columns")
    end
    for id,component in pairs(components) do
        self.columns[id]:add(entity, component)
    end
end

---@param self ArchetypeTable
---@param entity IdEntity
---@param component IdComponent
---@return any
function ArchetypeTable.get(self, entity, component)
    return self.columns[component]:get(entity)
end

---@param self ArchetypeTable
---@param entitySlot integer
---@param component IdComponent
---@return any
function ArchetypeTable.getRaw(self, entitySlot, component)
    return self.columns[component]:getRaw(entitySlot)
end

---@param self ArchetypeTable
---@param entitySlot integer
---@return any
function ArchetypeTable.getEntityIdFromRaw(self, entitySlot)
    return self:_firstColumn():getEntityIdFromRaw(entitySlot)
end

---@param self ArchetypeTable
---@return ComponentColumn
function ArchetypeTable._firstColumn(self)
    return select(2, next(self.columns))
end

---@param self ArchetypeTable
---@return integer
function ArchetypeTable.count(self)
    return self:_firstColumn().count
end

---@param self ArchetypeTable
---@param entity IdEntity
---@return ComponentSet
function ArchetypeTable.remove(self, entity)
    local components = {}
    for id,_ in pairs(self.components) do
        components[id] = self.columns[id]:remove(entity)
    end
    return components
end

------------------------------------------------------------------------------
--#endregion ArchetypeTable
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--#region ArchetypeStorage
------------------------------------------------------------------------------

---@class ArchetypeStorage
---@field _archetypes ComponentSetStorage
---@field _queries    ComponentSetStorage
local ArchetypeStorage = {}
ArchetypeStorage.__index = ArchetypeStorage

---@return ArchetypeStorage
function ArchetypeStorage.new()
    return setmetatable({
        _archetypes=ComponentSetStorage.new(),
        _queries=ComponentSetStorage.new()
    }, ArchetypeStorage)
end

---@param self ArchetypeStorage
---@param id IdArchetype
---@return ArchetypeTable
function ArchetypeStorage.getTableById(self, id)
    return self._archetypes:getByIdx(id --[[@as integer]]) --[[@as ArchetypeTable]]
end

---@param self ArchetypeStorage
---@param components ComponentSet
---@return ArchetypeTable
---@return IdArchetype
function ArchetypeStorage.getTable(self, components)
    local idx = self._archetypes:indexOf(components)
    return idx and self._archetypes:getByIdx(idx) --[[@as ArchetypeTable]], idx --[[@as IdArchetype]]
end

---@param self ArchetypeStorage
---@param components ComponentSet
---@return ArchetypeTable
---@return IdArchetype
function ArchetypeStorage.getOrCreateTable(self, components)
    local existing, idx = self:getTable(components)
    if existing == nil then
        existing = ArchetypeTable.new(components)
        idx = self._archetypes:insert(components, existing) --[[@as IdArchetype]]
        for _,data in pairs(self._queries:query(components)) do
            table.insert(data, idx)
        end
    end
    return existing, idx
end

---Run a query (cached) over all archetype component sets
---@param self ArchetypeStorage
---@param filter any The filter to run over the archetype component sets
---@param idCache IdQuery? The cache index for the filter, faster if provided
---@return IdArchetype[] archetypes List of archetype ids that match the filter
---@return IdQuery idCache The cache index associated with the given filter
function ArchetypeStorage.query(self, filter, idCache)
    if idCache == nil then
        idCache = self._queries:indexOf(filter) --[[@as IdQuery?]]
    end
    if idCache == nil then
        idCache = self._queries:insert(filter, self:queryRaw(filter)) --[[@as IdQuery]]
    end
    return self._queries:getByIdx(idCache --[[@as integer]]), idCache
end

---Run a query (uncached) over all archetype component sets
---@param self ArchetypeStorage
---@param filter ComponentSetFilter
---@return IdArchetype[]
function ArchetypeStorage.queryRaw(self, filter)
    local results = {}
    for idx,data in pairs(self._archetypes:query(ComponentSetFilter.includes(filter))) do
        local archetypeTable = data --[[@as ArchetypeTable]]
        if not ComponentSet.any(ComponentSetFilter.excludes(filter), archetypeTable.components) then
            table.insert(results, idx)
        end
    end
    return results
end

------------------------------------------------------------------------------
--#endregion ArchetypeStorage
------------------------------------------------------------------------------

--===========================================================================--
--#endregion Archetypes
--===========================================================================--

--===========================================================================--
--#region World
--===========================================================================--

------------------------------------------------------------------------------
--#region QueryEntity
------------------------------------------------------------------------------

---@class QueryEntity
---@field _archetype ArchetypeTable
---@field _entityRaw integer
local QueryEntity = {}
QueryEntity.__index = QueryEntity

function QueryEntity._new(archetype, entity)
    return setmetatable({_archetype=archetype, _entityRaw=entity}, QueryEntity)
end

---@param self QueryEntity
---@param archetype ArchetypeTable
---@param entitySlot integer
---@return QueryEntity
function QueryEntity._reset(self, archetype, entitySlot)
    self._archetype = archetype
    self._entityRaw = entitySlot
    return self
end

function QueryEntity.id(self)
    return self._archetype:getEntityIdFromRaw(self._entityRaw)
end

function QueryEntity.component(self, id)
    return self._archetype:getRaw(self._entityRaw, id)
end

------------------------------------------------------------------------------
--#endregion QueryEntity
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--#region Query
------------------------------------------------------------------------------

---@class Query
---@field _id IdQuery
local Query = {}
Query.__index = Query

function Query.new(id)
    return setmetatable({_id=id}, Query)
end

---@param self Query
---@param world World
---@return IdEntity[]
function Query.collect(self, world)
    local archetypes,_ = world._storage:query(nil, self._id)
    local entities = {}
    for _,idArchetype in ipairs(archetypes) do
        local archetype = world._storage:getTableById(idArchetype)
        for i=1,archetype:count() do
            table.insert(entities[idArchetype], QueryEntity._new(archetype, i))
        end
    end
    return entities
end

---@class QueryIterState
---@field archetypes IdArchetype[]
---@field storage ArchetypeStorage

---@class QueryIterKey
---@field aCur ArchetypeTable
---@field aIdx integer
---@field eIdx integer
---@field eQur QueryEntity

---@param s QueryIterState
---@param k QueryIterKey
function Query._iterNext(s, k)
    k.eIdx = k.eIdx + 1
    while k.eIdx > k.aCur:count() do
        k.aIdx = k.aIdx + 1
        if k.aIdx > #s.archetypes then
            return nil, nil
        end
        k.aCur = s.storage:getTableById(s.archetypes[k.aIdx])
        k.eIdx = 1
    end
    return k, k.eQur:_reset(k.aCur, k.eIdx)
end

---@param self Query
---@param world World
function Query.iter(self, world)
    local archetypes,_ = world._storage:query(nil, self._id)

    ---@type QueryIterState
    local state = {
        archetypes=archetypes,
        storage=world._storage
    }

    ---@type QueryIterKey
    local key = {
        aCur=world._storage:getTableById(archetypes[1]),
        aIdx=1,
        eIdx=0,
        eQur=QueryEntity._new()
    }

    return Query._iterNext, state, key
end

------------------------------------------------------------------------------
--#endregion Query
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--#region Query
------------------------------------------------------------------------------

---Creates a system setup function that initializes
---a query from the world and passes it as userdata
---@param name string
---@param includes IdComponent[]
---@param excludes IdComponent[]
---@return fun(userdata: table, args: table)
function SystemQuery(name, includes, excludes)
    local filter = {includes=includes or {}, excludes=excludes or {}}
    return function(userdata, args)
        local world = args.world --[[@as World]]
        local query = world:query(filter)
        userdata[name] = query
    end
end

------------------------------------------------------------------------------
--#endregion Query
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--#region EntityBuilder
------------------------------------------------------------------------------

---@class EntityBuilder
---@field _world World
---@field _entity IdEntity
---@field _components ComponentSet
local EntityBuilder = {}
EntityBuilder.__index = {}

---@param world World
---@param entity IdEntity
---@param components ComponentSet?
---@return EntityBuilder
function EntityBuilder.new(world, entity, components)
    return setmetatable(
        {_world=world, _entity=entity, _components=(components or {})},
        EntityBuilder
    )
end

---@param self EntityBuilder
---@param id IdComponent
---@param component any
---@return EntityBuilder
function EntityBuilder.attach(self, id, component)
    self._components[id] = component
    return self
end

---@param self EntityBuilder
---@param id IdComponent
---@param op fun(any)
---@return EntityBuilder
function EntityBuilder.modify(self, id, op)
    op(self._components[id])
    return self
end

---@param self EntityBuilder
---@param id IdComponent
---@return EntityBuilder
function EntityBuilder.detach(self, id)
    self._components[id] = nil
    return self
end

---@param self EntityBuilder
---@return IdEntity
function EntityBuilder.ud(self, id)
    return self._entity
end

---@param self EntityBuilder
function EntityBuilder.spawn(self)
    self._world:_initEntity(self._entity, self._components)
    return self._entity
end

------------------------------------------------------------------------------
--#endregion EntityBuilder
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--#region World
------------------------------------------------------------------------------

---@class World
---@field _allocator EntityAllocator
---@field _storage ArchetypeStorage
---@field _archetypeLookup ComponentColumn
local World = {}
World.__index = {}

function World.new()
    return setmetatable(
        {_allocator=EntityAllocator.new(), _storage=ArchetypeStorage.new(), _archetypeLookup=ComponentColumn.new()},
        World
    )
end

---@param self World
---@param components ComponentSet?
---@return EntityBuilder
function World.entityBuild(self, components)
    local id = self._allocator:alloc()
    return EntityBuilder.new(self, id, components)
end

---@param self World
---@param components ComponentSet
---@return IdEntity
function World.entitySpawn(self, components)
    local id = self._allocator:alloc()
    self:_initEntity(id, components)
    return id
end

---@param self World
---@param entity IdEntity
---@param components ComponentSet
function World._initEntity(self, entity, components)
    --TODO how do we want to handle empty entities
    -- if components ~= nil and next(components) ~= nil then
    local archetype, id = self._storage:getOrCreateTable(components)
    archetype:insert(entity, components)
    self._archetypeLookup:set(entity, id)
end

function World.getComponent(self, entity, component)
    --TODO do we want to fail on bad entity and/or bad component lookup?
    local archetype = self._archetypeLookup:get(entity) --[[@as IdArchetype?]]
    if archetype == nil then
        error("Entity does not exist")
    end
    return self._storage:getTableById(archetype):get(entity, component)
end

---@param self World
---@param filter ComponentSetFilter
---@return Query
function World.query(self, filter)
    local _,id = self._storage:query(filter, nil)
    return Query.new(id)
end

------------------------------------------------------------------------------
--#endregion World
------------------------------------------------------------------------------

--===========================================================================--
--#endregion World
--===========================================================================--

--===========================================================================--
--#region Scheduling
--===========================================================================--

-------------------------------------------------------------------------------
--#region System
-------------------------------------------------------------------------------

---@class System
---@field name string
---@field userdata table
---@field _handle function
---@field _setupOps (fun(userdata: table, args: table))[]
---@field _dependencies {[System]: true}
---@field _dependencyCount integer
local System = {}
System.__index = System

---Create a new system
---@param name string
---@param handle function The handle to execute
---@param userdata table?
---@return System
function System.new(name, handle, userdata)
    return setmetatable({
        name = name,
        userdata = userdata or {},
        _handle = handle,
        _setupOps = {},
        _dependencies = {},
        _dependencyCount = 0
    }, System)
end

---Registers a function that recives arguments on setup and can update userdata
---@param self System
---@param ... fun(userdata: table, args: table)
function System.addSetupOps(self, ...)
    for _,op in ipairs{...} do
        table.insert(self._setupOps, op)
    end
end

---Adds the given key-value pair to the userdata of the function
---@param self System
---@param k any
---@param v any
function System.addUserdata(self, k, v)
    self.userdata[k] = v
end

---Internal use, called to proccess setup ops on build
---@param self System
---@param args any
function System._setup(self, args)
    for _,op in ipairs(self._setupOps) do
        op(self.userdata, args)
    end
    self._setupOps = {}
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
        system._handle(system.userdata, ...)
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
---@param args table?
---@return Schedule
function ScheduleBuilder.build(self, args)
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
        --TODO OPT Certainly some faster way to append these tables in-order

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

    for _,system in ipairs(orderedSystems) do
        system:_setup(args or {})
    end

    return Schedule.new(self.name, orderedSystems)
end

-------------------------------------------------------------------------------
--#endregion ScheduleBuilder
-------------------------------------------------------------------------------

--===========================================================================--
--#endregion Scheduling
--===========================================================================--

return {
    IdEntity           = IdEntity,        -- Tests: Initial
    EntityAllocator    = EntityAllocator, -- Tests: Initial

    IdComponent         = IdComponent,         -- Tests: Initial
    ComponentColumn     = ComponentColumn,     -- Tests: Initial

    ComponentSet        = ComponentSet,        -- Tests: TODO
    ComponentSetFilter  = ComponentSetFilter,  -- Tests: TODO
    ComponentSetStorage = ComponentSetStorage, -- Tests: TODO

    ArchetypeTable     = ArchetypeTable,    -- Tests: TODO
    ArchetypeStorage   = ArchetypeStorage,  -- Tests: TODO

    QueryEntity   = QueryEntity,   -- Tests: TODO
    Query         = Query,         -- Tests: TODO
    EntityBuilder = EntityBuilder, -- Tests: TODO
    World         = World,         -- Tests: TODO

    System          = System,          -- Tests: Initial
    Schedule        = Schedule,        -- Tests: Initial
    ScheduleBuilder = ScheduleBuilder, -- Tests: Initial
}