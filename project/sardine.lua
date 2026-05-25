-- Copyright 2026 Natalie Baker -- MIT --

--===========================================================================--
--#region Entities
--===========================================================================--

-------------------------------------------------------------------------------
--#region IdEntity
-------------------------------------------------------------------------------

---@class Sardine.IdEntity
---@field index integer
---@field generation integer
local IdEntity = {}
IdEntity.__index = IdEntity

if jit and jit.status() then
    local ffi = require("ffi")

    local IdEntity_t = ffi.typeof[[struct { 
        uint32_t index; 
        uint32_t generation;
    }]]

    ffi.metatype(IdEntity_t, IdEntity)

    --- Create a new EntityId. 
    --- An index or generation of 0 is an "invalid" identifier.
    ---@param index      integer | nil Index of the identifier, defaults to 1
    ---@param generation integer | nil Generation of the identifier, defaults to 1
    ---@return Sardine.IdEntity
    function IdEntity.new(index, generation)
        if index      == nil then index      = 1 end
        if generation == nil then generation = 1 end
        return IdEntity_t(index, generation) --[[@as Sardine.IdEntity]]
    end
else
    -- NoFFI fallback, this won't be comfortable

    function IdEntity.new(index, generation)
        if index      == nil then index      = 1 end
        if generation == nil then generation = 1 end
        return setmetatable({index = index, generation = generation} --[[@as Sardine.IdEntity]], IdEntity)
    end
end

--- Gets the EntityId with the next generation
---@param id integer
---@return Sardine.IdEntity
function IdEntity.withId(self, id)
    return IdEntity.new(id, self.generation)
end

--- Gets the EntityId with the next generation
---@return Sardine.IdEntity
function IdEntity.next(self)
    return IdEntity.new(self.index, self.generation+1)
end

--- An index or generation of 0 is an "invalid" identifier.
---@return boolean
function IdEntity.isValid(self)
    return self.index > 0 and self.generation > 0
end

---@param a Sardine.IdEntity
---@param b Sardine.IdEntity
---@return boolean
function IdEntity.__eq(a, b)
    return a.index == b.index and a.generation == b.generation
end

-------------------------------------------------------------------------------
--#endregion IdEntity
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--#region EntityAllocator
-------------------------------------------------------------------------------

---@class EntityAllocator
---@field _freelist Sardine.IdEntity[]
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
---@return Sardine.IdEntity
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
---@param id Sardine.IdEntity The identifier to free for reuse
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

---@class Sardine.IdComponent

---@class Sardine.ModuleIdComponent
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
---@return Sardine.IdComponent
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

    return id --[[@as Sardine.IdComponent]]
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
---@return Sardine.IdComponent
---@nodiscard
function IdComponent.fromUID(uid)
    return IdComponent._lookup[uid] --[[@as Sardine.IdComponent]]
end

------------------------------------------------------------------------------
--#endregion IdComponent
------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--#region ComponentColumn
-------------------------------------------------------------------------------

---@class Sardine.ComponentColumn
---@field count integer
---@field _slots Sardine.IdEntity[]
---@field data any[]
---@field _back integer[]
local ComponentColumn = {}
ComponentColumn.__index = ComponentColumn

---Creates a new storage for EntityId-associated data
---@return Sardine.ComponentColumn
function ComponentColumn.new()
    return setmetatable(
        {count = 0, data = {}, _slots = {}, _back = {}},
        ComponentColumn
    ) --[[@as Sardine.ComponentColumn]]
end

---@param self Sardine.ComponentColumn
---@param entityId Sardine.IdEntity
---@param value any
---@param force boolean?
---@return any
function ComponentColumn.set(self, entityId, value, force)
    local existing = self:_getSlot(entityId)
    if value == nil then
        if (not force) and (existing.generation ~= entityId.generation) then
            error("Entity ID generation mismatch.")
        end
        return self:_remove(existing)
    elseif (existing.index > 0) then
        if (not force) and (existing.generation ~= entityId.generation) then
            error("Slot already contains a different generation, cannot reuse unless forced or removed first.")
        end
        return self:_set(entityId, value, existing)
    else
        if (not force) and (existing.generation > entityId.generation) then
            error("Slot previously used for a newer generation, cannot add older generation unless forced.")
        end
        return self:_add(entityId, value)
    end
end

---@param entityId Sardine.IdEntity
---@return any
function ComponentColumn.get(self, entityId)
    self.count = self.count + 1
    local slot = self:_getSlot(entityId)
    if (slot.index      <=                   0) then return nil end
    if (slot.generation ~= entityId.generation) then return nil end
    return self.data[slot.index]
end

---@param entityId Sardine.IdEntity
---@param init fun(): any
---@param force boolean?
---@return any
function ComponentColumn.getOrSet(self, entityId, init, force)
    return self:get(entityId) or self:set(entityId, init(), force)
end

---Gets the data in the given slot index
---@param slotIdx integer
---@return Sardine.IdEntity
function ComponentColumn.getEntityIdForSlot(self, slotIdx)
    if slotIdx > self.count then
        error("Attempt to index out of bounds, slot idx not allocated")
    end
    local back = self._back[slotIdx]
    return self._slots[back]:withId(back)
end

---Gets the data in the given slot index
---@param slotIdx integer
---@return any
function ComponentColumn.getSlotData(self, slotIdx)
    if slotIdx > self.count then
        error("Attempt to index out of bounds, slot idx not allocated")
    end
    return self.data[slotIdx]
end

---@param self Sardine.ComponentColumn
---@return fun(state: Sardine.ComponentColumn, key: Sardine.IdEntity): (Sardine.IdEntity, any), Sardine.ComponentColumn, any
function ComponentColumn.iter(self)
    local next, t, _ = pairs(self.data)
    return function(self, p)
        local k, v = next(t, p and self._slots[p.index].index)
        return k and self._slots[self._back[k]]:withId(self._back[k]), k and v
    end, self, nil
end

-----------------------------
--#region Internal 
-----------------------------

---@param entityId Sardine.IdEntity
---@param value any
---@return any
function ComponentColumn._add(self, entityId, value)
    self.count = self.count + 1
    self._slots[entityId.index] = IdEntity.new(self.count, entityId.generation)
    self._back[self.count] = entityId.index
    self.data[self.count] = value
    return value
end

---@param entityId Sardine.IdEntity The identifier to update the value of
---@param value any The new value to associate
---@param slot Sardine.IdEntity
---@return any
function ComponentColumn._set(self, entityId, value, slot)
    slot.generation = entityId.generation
    self.data[slot.index] = value
    return value
end

---@param self Sardine.ComponentColumn
---@param slot Sardine.IdEntity
---@return any
function ComponentColumn._remove(self, slot)
    -- Check if it's already removed, no-op
    if (slot.index <= 0) then
        return nil
    end

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

function ComponentColumn._getSlot(self, entityId)
    return self._slots[entityId.index] or IdEntity.new(0,0)
end

-----------------------------
--#endregion Internal 
-----------------------------

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

---@alias Sardine.ComponentSet table<Sardine.IdComponent, any>

---@class ModuleComponentSet
local ComponentSet = {}

--- Checks if all components listed in `a` exist in `b`
---@param a Sardine.ComponentSet
---@param b Sardine.ComponentSet
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
---@param a Sardine.ComponentSet
---@param b Sardine.ComponentSet
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
---@param a Sardine.ComponentSet
---@param b Sardine.ComponentSet
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

---@alias Sardine.ComponentSetFilter {includes: Sardine.ComponentSet, excludes: Sardine.ComponentSet} | Sardine.ComponentSet

---@class Sardine.ModuleComponentSetFilter
local ComponentSetFilter = {}

---Returns the ComponentSet representing the included (required) components
---@param a Sardine.ComponentSetFilter
---@return Sardine.ComponentSet
---@nodiscard
function ComponentSetFilter.includes(a)
    return a.includes or a
end

---Returns the ComponentSet representing the excluded components
---@param a Sardine.ComponentSetFilter
---@return Sardine.ComponentSet
---@nodiscard
function ComponentSetFilter.excludes(a)
    return a.excludes or {}
end

---Checks if `a` will accept `b`
---@param a Sardine.ComponentSetFilter filter
---@param b Sardine.ComponentSet item
---@return boolean
---@nodiscard
function ComponentSetFilter.accepts(a, b)
    return ComponentSet.all(ComponentSetFilter.includes(a), b) and
       not ComponentSet.any(ComponentSetFilter.excludes(a), b)
end

---Checks if `a` is eaxctly the same as `b`
---@param a Sardine.ComponentSetFilter filter
---@param b Sardine.ComponentSetFilter filter
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

---@class Sardine.ComponentSetStorage
---@field _next integer
---@field _groups table<Sardine.IdComponent, {key: Sardine.ComponentSetFilter, idx: integer}[]>
---@field _data any[]
local ComponentSetStorage = {}
ComponentSetStorage.__index = ComponentSetStorage

function ComponentSetStorage.new()
    return setmetatable({_next = 1, _groups = {}, _data = {}}, ComponentSetStorage)
end

---Insert a new entry or replace an existing entry
---@param self Sardine.ComponentSetStorage
---@param k Sardine.ComponentSetFilter The composite key to associate with
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
---@param self Sardine.ComponentSetStorage
---@param components Sardine.ComponentSet The list of components search with
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
---@param self Sardine.ComponentSetStorage
---@param k Sardine.ComponentSetFilter The composite key to lookup
---@return any data The data associated with the given composite key, or nil if it doesn't exist
---@nodiscard
function ComponentSetStorage.getByKey(self, k)
    local idx = self:indexOf(k)
    return idx and self:getByIdx(idx)
end

---Gets data by the raw index
---@param self Sardine.ComponentSetStorage
---@param idx integer The index of the data to get
---@return any data The data stored at the given index, or nil if it doesn't exist
---@nodiscard
function ComponentSetStorage.getByIdx(self, idx)
    return self._data[idx]
end

---Finds the data index of the given key, or nil if it doesn't exist
---@param self Sardine.ComponentSetStorage
---@param k Sardine.ComponentSetFilter
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

---@class Sardine.IdArchetype

---@class Sardine.IdQuery

------------------------------------------------------------------------------
--#region ArchetypeTable
------------------------------------------------------------------------------

---@class Sardine.ArchetypeTable
---@field components Sardine.ComponentSet
---@field columns table<Sardine.IdComponent, Sardine.ComponentColumn>
local ArchetypeTable = {}
ArchetypeTable.__index = ArchetypeTable

--TODO flatten ComponentColumn into ArchetypeTable to remove redundant lookups and back tables

---@param components Sardine.ComponentSet
---@return Sardine.ArchetypeTable
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

---@param self Sardine.ArchetypeTable
---@param entity Sardine.IdEntity
---@param components Sardine.ComponentSet
function ArchetypeTable.insert(self, entity, components)
    if not ComponentSet.exact(self.components, components) then
        error("Inserted components do not match archetype columns")
    end
    for id,component in pairs(components) do
        self.columns[id]:set(entity, component)
    end
end

---@param self Sardine.ArchetypeTable
---@param entity Sardine.IdEntity
---@param component Sardine.IdComponent
---@return any
function ArchetypeTable.get(self, entity, component)
    return self.columns[component]:get(entity)
end

---@param self Sardine.ArchetypeTable
---@param entitySlot integer
---@param component Sardine.IdComponent
---@return any
function ArchetypeTable.getSlotData(self, entitySlot, component)
    return self.columns[component]:getSlotData(entitySlot)
end

---@param self Sardine.ArchetypeTable
---@param entitySlot integer
---@return any
function ArchetypeTable.getEntityIdForSlot(self, entitySlot)
    return self:_firstColumn():getEntityIdForSlot(entitySlot)
end

---@param self Sardine.ArchetypeTable
---@return Sardine.ComponentColumn
function ArchetypeTable._firstColumn(self)
    return select(2, next(self.columns))
end

---@param self Sardine.ArchetypeTable
---@return integer
function ArchetypeTable.count(self)
    return self:_firstColumn().count
end

---@param self Sardine.ArchetypeTable
---@param entity Sardine.IdEntity
---@return Sardine.ComponentSet
function ArchetypeTable.remove(self, entity)
    local components = {}
    for id,_ in pairs(self.components) do
        components[id] = self.columns[id]:set(entity, nil)
    end
    return components
end

------------------------------------------------------------------------------
--#endregion ArchetypeTable
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--#region ArchetypeStorage
------------------------------------------------------------------------------

---@class Sardine.ArchetypeStorage
---@field _archetypes Sardine.ComponentSetStorage
---@field _queries    Sardine.ComponentSetStorage
local ArchetypeStorage = {}
ArchetypeStorage.__index = ArchetypeStorage

---@return Sardine.ArchetypeStorage
function ArchetypeStorage.new()
    return setmetatable({
        _archetypes=ComponentSetStorage.new(),
        _queries=ComponentSetStorage.new()
    }, ArchetypeStorage)
end

---@param self Sardine.ArchetypeStorage
---@param id Sardine.IdArchetype
---@return Sardine.ArchetypeTable
function ArchetypeStorage.getTableById(self, id)
    return self._archetypes:getByIdx(id --[[@as integer]]) --[[@as Sardine.ArchetypeTable]]
end

---@param self Sardine.ArchetypeStorage
---@param components Sardine.ComponentSet
---@return Sardine.ArchetypeTable
---@return Sardine.IdArchetype
function ArchetypeStorage.getTable(self, components)
    local idx = self._archetypes:indexOf(components)
    return idx and self._archetypes:getByIdx(idx) --[[@as Sardine.ArchetypeTable]], idx --[[@as Sardine.IdArchetype]]
end

---@param self Sardine.ArchetypeStorage
---@param components Sardine.ComponentSet
---@return Sardine.ArchetypeTable
---@return Sardine.IdArchetype
function ArchetypeStorage.getOrCreateTable(self, components)
    local existing, idx = self:getTable(components)
    if existing == nil then
        existing = ArchetypeTable.new(components)
        idx = self._archetypes:insert(components, existing) --[[@as Sardine.IdArchetype]]
        for _,data in pairs(self._queries:query(components)) do
            table.insert(data, idx)
        end
    end
    return existing, idx
end

---Run a query (cached) over all archetype component sets
---@param self Sardine.ArchetypeStorage
---@param filter any The filter to run over the archetype component sets
---@param idCache Sardine.IdQuery? The cache index for the filter, faster if provided
---@return Sardine.IdArchetype[] archetypes List of archetype ids that match the filter
---@return Sardine.IdQuery idCache The cache index associated with the given filter
function ArchetypeStorage.query(self, filter, idCache)
    if idCache == nil then
        idCache = self._queries:indexOf(filter) --[[@as Sardine.IdQuery?]]
    end
    if idCache == nil then
        idCache = self._queries:insert(filter, self:queryRaw(filter)) --[[@as Sardine.IdQuery]]
    end
    return self._queries:getByIdx(idCache --[[@as integer]]), idCache
end

---Run a query (uncached) over all archetype component sets
---@param self Sardine.ArchetypeStorage
---@param filter Sardine.ComponentSetFilter
---@return Sardine.IdArchetype[]
function ArchetypeStorage.queryRaw(self, filter)
    local results = {}
    for idx,data in pairs(self._archetypes:query(ComponentSetFilter.includes(filter))) do
        local archetypeTable = data --[[@as Sardine.ArchetypeTable]]
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

---@class Sardine.QueryEntity
---@field _archetype Sardine.ArchetypeTable
---@field _entityRaw integer
local QueryEntity = {}
QueryEntity.__index = QueryEntity

function QueryEntity._new(archetype, entity)
    return setmetatable({_archetype=archetype, _entityRaw=entity}, QueryEntity)
end

---@param self Sardine.QueryEntity
---@param archetype Sardine.ArchetypeTable
---@param entitySlot integer
---@return Sardine.QueryEntity
function QueryEntity._reset(self, archetype, entitySlot)
    self._archetype = archetype
    self._entityRaw = entitySlot
    return self
end

function QueryEntity.id(self)
    return self._archetype:getEntityIdForSlot(self._entityRaw)
end

function QueryEntity.component(self, id)
    return self._archetype:getSlotData(self._entityRaw, id)
end

------------------------------------------------------------------------------
--#endregion QueryEntity
------------------------------------------------------------------------------

------------------------------------------------------------------------------
--#region Query
------------------------------------------------------------------------------

---@class Sardine.Query
---@field _id Sardine.IdQuery
local Query = {}
Query.__index = Query

function Query.new(id)
    return setmetatable({_id=id}, Query)
end

---@param self Sardine.Query
---@param world Sardine.World
---@return Sardine.IdEntity[]
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

---@class Sardine.QueryIterState
---@field archetypes Sardine.IdArchetype[]
---@field storage Sardine.ArchetypeStorage

---@class Sardine.QueryIterKey
---@field aCur Sardine.ArchetypeTable
---@field aIdx integer
---@field eIdx integer
---@field eQur Sardine.QueryEntity

---@param s Sardine.QueryIterState
---@param k Sardine.QueryIterKey
---@return Sardine.QueryIterKey, Sardine.QueryEntity
function Query._iterNext(s, k)
    k.eIdx = k.eIdx + 1
    while k.eIdx > k.aCur:count() do
        k.aIdx = k.aIdx + 1
        if k.aIdx > #s.archetypes then
            ---@diagnostic disable-next-line: return-type-mismatch
            return nil, nil
        end
        k.aCur = s.storage:getTableById(s.archetypes[k.aIdx])
        k.eIdx = 1
    end
    return k, k.eQur:_reset(k.aCur, k.eIdx)
end

---@param self Sardine.Query
---@param world Sardine.World
---@return (fun(s: Sardine.QueryIterState, k: Sardine.QueryIterKey): (Sardine.QueryIterKey, Sardine.QueryEntity)), Sardine.QueryIterState, Sardine.QueryIterKey
function Query.iter(self, world)
    local archetypes,_ = world._storage:query(nil, self._id)

    ---@type Sardine.QueryIterState
    local state = {
        archetypes=archetypes,
        storage=world._storage
    }

    ---@type Sardine.QueryIterKey
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
---@param includes Sardine.IdComponent[]
---@param excludes Sardine.IdComponent[]
---@return fun(userdata: table, args: table)
function SystemQuery(name, includes, excludes)
    local filter = {includes=includes or {}, excludes=excludes or {}}
    return function(userdata, args)
        local world = args.world --[[@as Sardine.World]]
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
---@field _world Sardine.World
---@field _entity Sardine.IdEntity
---@field _components Sardine.ComponentSet
local EntityBuilder = {}
EntityBuilder.__index = {}

---@param world Sardine.World
---@param entity Sardine.IdEntity
---@param components Sardine.ComponentSet?
---@return EntityBuilder
function EntityBuilder.new(world, entity, components)
    return setmetatable(
        {_world=world, _entity=entity, _components=(components or {})},
        EntityBuilder
    )
end

---@param self EntityBuilder
---@param id Sardine.IdComponent
---@param component any
---@return EntityBuilder
function EntityBuilder.attach(self, id, component)
    self._components[id] = component
    return self
end

---@param self EntityBuilder
---@param id Sardine.IdComponent
---@param op fun(any)
---@return EntityBuilder
function EntityBuilder.modify(self, id, op)
    op(self._components[id])
    return self
end

---@param self EntityBuilder
---@param id Sardine.IdComponent
---@return EntityBuilder
function EntityBuilder.detach(self, id)
    self._components[id] = nil
    return self
end

---@param self EntityBuilder
---@return Sardine.IdEntity
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

---@class Sardine.World
---@field _allocator EntityAllocator
---@field _storage Sardine.ArchetypeStorage
---@field _archetypeLookup Sardine.ComponentColumn
local World = {}
World.__index = {}

function World.new()
    return setmetatable(
        {_allocator=EntityAllocator.new(), _storage=ArchetypeStorage.new(), _archetypeLookup=ComponentColumn.new()},
        World
    )
end

---@param self Sardine.World
---@param components Sardine.ComponentSet?
---@return EntityBuilder
function World.entityBuild(self, components)
    local id = self._allocator:alloc()
    return EntityBuilder.new(self, id, components)
end

---@param self Sardine.World
---@param components Sardine.ComponentSet
---@return Sardine.IdEntity
function World.entitySpawn(self, components)
    local id = self._allocator:alloc()
    self:_initEntity(id, components)
    return id
end

---@param self Sardine.World
---@param entityId Sardine.IdEntity
function World.entityDestroy(self, entityId)
    -- self._archetypeLookup:set(entityId, nil)
    -- self._allocator:freeUnchecked(entityId)
end

---@param self Sardine.World
---@param entity Sardine.IdEntity
---@param components Sardine.ComponentSet
function World._initEntity(self, entity, components)
    --TODO how do we want to handle empty entities
    -- if components ~= nil and next(components) ~= nil then
    local archetype, id = self._storage:getOrCreateTable(components)
    archetype:insert(entity, components)
    self._archetypeLookup:set(entity, id)
end

function World.getComponent(self, entity, component)
    --TODO do we want to fail on bad entity and/or bad component lookup?
    local archetype = self._archetypeLookup:get(entity) --[[@as Sardine.IdArchetype?]]
    if archetype == nil then
        error("Entity does not exist")
    end
    return self._storage:getTableById(archetype):get(entity, component)
end

---@param self Sardine.World
---@param filter Sardine.ComponentSetFilter
---@return Sardine.Query
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

---@alias FuncInvoke fun(systemData: table, invokeArgs: any, ...: any)
---@alias FuncInit fun(systemData: table, initArgs: any, params: any[])

---@class System
---@field name string
---@field paramList any[]
---@field systemData any
---@field _handleInvoke FuncInvoke
---@field _handleInit FuncInit?
---@field _dependencies {[System]: true}
---@field _dependencyCount integer
local System = {}
System.__index = System

---Create a new system
---@param name string
---@param handleInvoke FuncInvoke
---@param systemData table?
---@return System
function System.new(name, handleInvoke, systemData)
    return setmetatable({
        name = name,
        paramList = {},
        systemData = systemData or {},
        _handleInvoke = handleInvoke,
        _handleInit   = nil,
        _dependencies    = {},
        _dependencyCount = 0
    }, System)
end

---@param self System
---@param init FuncInit
---@return self
function System.withInit(self, init)
    self._init = init
    return self
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

---Initializes the system from the given init args
---@param self System
---@param initArgs any
function System._init(self, initArgs)
    if self._handleInit ~= nil then
        self._handleInit(self.systemData, initArgs, self.paramList)
    end
end

---Invokes the system from the given args
---@param self System
---@param invokeArgs any
function System._invoke(self, invokeArgs)
    self._handleInvoke(self.systemData, invokeArgs, unpack(self.paramList or {}))
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
---@field _hasInit boolean
local Schedule = {}
Schedule.__index = Schedule

---@param systems System[]
---@return Schedule
function Schedule.new(name, systems)
    return setmetatable({name = name, _systems = systems, _hasInit = false}, Schedule)
end

function Schedule.init(self, ...)
    if self._hasInit then
        error("Schedule is already initialized")
    end

    local initParams = {...}
    for _,system in pairs(self._systems) do
        system:_init(initParams)
    end
    self._hasInit = true
end

--- Runs every system in-order with the given arguments
---@param ... any
function Schedule.run(self, ...)
    local invokeParams = {...}
    for _,system in pairs(self._systems) do
        system:_invoke(invokeParams)
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

    return Schedule.new(self.name, orderedSystems)
end

-------------------------------------------------------------------------------
--#endregion ScheduleBuilder
-------------------------------------------------------------------------------

--===========================================================================--
--#endregion Scheduling
--===========================================================================--

return {
    __HOMEPAGE    = 'https://github.com/notverymoe/love_libraries/',
    __DESCRIPTION = 'A simple archetype ECS library',
    __VERSION     = '2026.05.03',
    __LICENSE     = [[
        MIT License

        Copyright 2026 Natalie Baker

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
    ]],

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