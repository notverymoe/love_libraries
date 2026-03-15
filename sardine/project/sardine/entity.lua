-- Copyright 2026 Natalie Baker -- MIT --

local ffi = require("ffi")

-------------------------------------------------------------------------------
--#region GenId
-------------------------------------------------------------------------------

local genid_t = ffi.typeof[[struct { 
    uint32_t index; 
    uint32_t generation;
}]]

---@class GenId
---@field index integer
---@field generation integer
local GenId = {}
GenId.__index = GenId
ffi.metatype(genid_t, GenId)

--- Create a new GenId. 
--- An index or generation of 0 is an "invalid" identifier.
---@param index      integer | nil Index of the identifier, defaults to 1
---@param generation integer | nil Generation of the identifier, defaults to 1
---@return GenId
function GenId.new(index, generation)
    if index      == nil then index      = 1 end
    if generation == nil then generation = 1 end
    return genid_t(index, generation) --[[@as GenId]]
end

--- Gets the GenId with the next generation
---@param id integer
---@return GenId
function GenId.withId(self, id)
    return GenId.new(id, self.generation)
end

--- Gets the GenId with the next generation
---@return GenId
function GenId.next(self)
    return GenId.new(self.index, self.generation+1)
end

--- An index or generation of 0 is an "invalid" identifier.
---@return boolean
function GenId.isValid(self)
    return self.index > 0 and self.generation > 0
end

-------------------------------------------------------------------------------
--#endregion GenId
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--#region GenIdAllocator
-------------------------------------------------------------------------------

---@class GenIdAllocator
---@field _freelist GenId[]
---@field _freecount integer
---@field _next integer
local GenIdAllocator = {}
GenIdAllocator.__index = GenIdAllocator

---Creates a new GenId allocator
---@return GenIdAllocator
function GenIdAllocator.new()
    return setmetatable(
        {_next = 0, _freelist = {}, _freecount = 0},
        GenIdAllocator
    )
end

---Allocates a single new GenId
---@return GenId
function GenIdAllocator.alloc(self)
    if self._freecount > 0 then
        self._freecount = self._freecount-1
        return table.remove(self._freelist, self._freecount+1)
    else
        self._next = self._next + 1
        return GenId.new(self._next)
    end
end

---Frees a single GenId for reuse with a newer generation
---@param id GenId The identifier to free for reuse
---@warning This method cannot verify if an id has been freed previously or is still valid
function GenIdAllocator.freeUnchecked(self, id)
    self._freecount = self._freecount + 1
    table.insert(self._freelist, self._freecount, id:next())
end


-------------------------------------------------------------------------------
--#endregion GenIdAllocator
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--#region GenIdStorage
-------------------------------------------------------------------------------

---@generic T
---@class GenIdStorage
---@field count integer
---@field _slots GenId[]
---@field data any[]
---@field _back integer[]
local GenIdStorage = {}
GenIdStorage.__index = GenIdStorage

---Creates a new storage for GenId-associated data
---@return GenIdStorage
function GenIdStorage.new()
    return setmetatable(
        {count = 0, data = {}, _slots = {}, _back = {}},
        GenIdStorage
    ) --[[@as GenIdStorage]]
end

---@param self GenIdStorage
---@return fun(state: GenIdStorage, key: integer): (integer, any), GenIdStorage, any
function GenIdStorage.iterFast(self)
    return pairs(self.data)
end

---@param self GenIdStorage
---@return fun(state: GenIdStorage, key: GenId): (GenId, any), GenIdStorage, any
function GenIdStorage.iter(self)
    local next, t, _ = pairs(self.data)
    return function(self, p)
        local k, v = next(t, p and self._slots[p.index].index)
        return k and self._slots[self._back[k]]:withId(self._back[k]), k and v
    end, self, nil
end

local ZERO_SLOT = GenId.new(0,0)

function GenIdStorage._getSlot(self, tuid)
    return self._slots[tuid.index] or ZERO_SLOT
end

---Adds a new value associated with the given GenId
---@param tuid GenId
---@param value any
function GenIdStorage.add(self, tuid, value)
    if(self:_getSlot(tuid).generation > tuid.generation) then
        error("Slot already used with newer generation, cannot reuse older generation")
    end
    self.count = self.count + 1
    self._slots[tuid.index] = GenId.new(self.count, tuid.generation)
    self._back[self.count] = tuid.index
    self.data[self.count] = value
end

---Sets data currently associated with the given GenId to a new value
---@param tuid GenId The identifier to update the value of
---@param value any The new value to associate
function GenIdStorage.set(self, tuid, value)
    self.count = self.count + 1
    local slot = self:_getSlot(tuid)
    if (slot.index      <= 0              ) then error("GenId is not allocated") end
    if (slot.generation ~= tuid.generation) then error("GenId generation does not match slot generation") end
    self.data[slot.index] = value
end

---Adds or sets data currently associated with the given GenId to a new value
---@param tuid GenId The identifier to update the value of
---@param value any The new value to associate
function GenIdStorage.addOrSet(self, tuid, value)
    self.count = self.count + 1
    local slot = self:_getSlot(tuid)
    if (slot.index <= 0) or (slot.generation ~= tuid.generation) then
        self:add(tuid, value)
    else
        self.data[slot.index] = value
    end
end

---Gets the data currently associated with the given GenId
---@param tuid GenId
---@return any
function GenIdStorage.get(self, tuid)
    self.count = self.count + 1
    local slot = self:_getSlot(tuid)
    if (slot.index      <=               0) then error("GenId is not allocated") end
    if (slot.generation ~= tuid.generation) then error("GenId generation does not match slot generation") end
    return self.data[slot.index]
end

---Tries to get the data currently associated with the given GenId, or nil if not assigned
---@param tuid GenId
---@return any
function GenIdStorage.tryGet(self, tuid)
    self.count = self.count + 1
    local slot = self:_getSlot(tuid)
    if (slot.index      <=               0) then return nil end
    if (slot.generation ~= tuid.generation) then return nil end
    return self.data[slot.index]
end

---Gets the data currently associated with the given GenId
---@param tuid GenId
---@return any
function GenIdStorage.getOrSet(self, tuid, defVal)
    self.count = self.count + 1
    local slot = self:_getSlot(tuid)
    if (slot.index <= 0) or (slot.generation ~= tuid.generation) then
        local val = defVal()
        self:add(tuid, val)
        return val
    else
        return self.data[slot.index]
    end
end

--- Removes the data associated with the current GenId and prevents
--- reusing the GenId in future new associations.
---@param tuid GenId
---@return any _ The last value associated with the given id
function GenIdStorage.remove(self, tuid)
    local slot = self:_getSlot(tuid)
    if slot.index <= 0 then error("GenId is not allocated") end

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
--#endregion GenIdStorage
-------------------------------------------------------------------------------

--@TODO Entity wrapper type that provides access to components 
--@TODO GenId generation overflow check
--@TODO GenId investigate 4-byte size
--@TODO Track allocated GenId to prevent double-free or retired-free

---@class SardineModuleEntity
---@field GenId GenId
---@field GenIdAllocator GenIdAllocator
---@field GenIdStorage GenIdStorage

return {
    GenId          = GenId,
    GenIdAllocator = GenIdAllocator,
    GenIdStorage   = GenIdStorage,
}