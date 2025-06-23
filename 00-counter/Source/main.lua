local pd <const> = playdate
local gfx <const> = playdate.graphics

local counter = 0
local lastCrank = pd.getCrankPosition()
local crankAccum = 0

function pd.update()
    local currentCrank = pd.getCrankPosition()
    local delta = currentCrank - lastCrank

    -- Handle wrap-around
    if delta > 180 then
        delta = delta - 360
    elseif delta < -180 then
        delta = delta + 360
    end

    crankAccum = crankAccum + delta
    lastCrank = currentCrank

    if crankAccum >= 360 then
        local steps = math.floor(crankAccum / 360)
        counter = counter + steps
        crankAccum = crankAccum - steps * 360
    elseif crankAccum < 0 then
        crankAccum = 0
    end

    gfx.clear()
    gfx.drawText("Counter: " .. tostring(counter), 100, 120)
end

function pd.AButtonDown()
    counter = counter + 1
end
