import "CoreLibs/graphics"
import "manager.lua"
import "scenes/menu.lua"

local gfx <const> = playdate.graphics
SceneManager:hook()
SceneManager:enter(MainMenu())

-- frame callback
function playdate.update()
    SceneManager:emit("update")
    gfx.sprite.update()
    playdate.drawFPS()
end
