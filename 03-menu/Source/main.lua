import "CoreLibs/graphics"
import "../toyboxes/toyboxes.lua"
import "scenes/menu.lua"

local gfx <const> = playdate.graphics
local manager = Manager()
manager:enter(Menu)

-- frame callback
function playdate.update()
    manager:emit("update")
    gfx.sprite.update()
    playdate.drawFPS()
end
