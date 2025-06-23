local pd <const> = playdate
local gfx <const> = playdate.graphics

local counter = 0

function pd.update()
    gfx.clear()
    gfx.drawText("Counter: " .. tostring(counter), 100, 120)
end

function pd.AButtonDown()
    counter = counter + 1
end
