-- Copyright 2026 Natalie Baker -- MIT --

---@class TimerFixed
---@field fixedDelta number
---@field iterLimit number
---@field accum number
---@field now number
local TimerFixed = {
    __HOMEPAGE    = 'https://github.com/notverymoe/love_libraries/',
    __DESCRIPTION = 'A simple accumulation based fixed-rate timer.',
    __VERSION = '2026.03.15',
    __LICENSE = [[
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
    ]]
}

TimerFixed.__index = TimerFixed

--- Create a new fixed timer
---@param fixedDelta number | nil The fixed trigger rate to apply (1/60)
---@param iterLimit  number | nil The max number of iterations per process
---@param now        number | nil The start time of the fixed update
---@return TimerFixed
function TimerFixed.new(fixedDelta, iterLimit, now)
    return setmetatable(
        {
            fixedDelta = fixedDelta or (1/60),
            iterLimit  = iterLimit  or 4,
            now        = now        or 0,
            accum      = 0,
        },
        TimerFixed
    )
end

--- Accumulate and process pending fixed update triggers
---@param dt number
---@param callback fun(dt: number)
function TimerFixed.process(self, dt, callback)

    self.accum = self.accum + dt
    local iterRequired = math.floor(self.accum/self.fixedDelta)
    local iter         = math.min(iterRequired, self.iterLimit)
    for _ = 1, iter do
        self.now = self.now + self.fixedDelta
        callback(self.fixedDelta)
    end

    -- We subtract the total iterRequired as, otherwise
    -- we may end up attempting to catchup forever after
    -- a lag spike.
    self.accum = self.accum - iterRequired * self.fixedDelta
end

return TimerFixed