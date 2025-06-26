import "CoreLibs/graphics"
import "../toyboxes/toyboxes.lua"
import "scenes/NumberedBoxes.lua"

local gfx <const> = playdate.graphics
local manager = Manager()
manager:enter(NumberedBoxes)

-- frame callback
function playdate.update()
    gfx.sprite.update()
    playdate.drawFPS()
end
