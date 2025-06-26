--[[
This is the main menu scene to go between different scenes.
]]
import "../manager.lua"
import "numbered_boxes.lua"
local gfx <const> = playdate.graphics

class("MainMenu").extends(Room)

local menuItems = {
    { label = "Numbered Boxes",           scene = NumberedBoxes },
    { label = "Non-Functional Example 1", scene = nil },
    { label = "Non-Functional Example 2", scene = nil },
    { label = "Non-Functional Example 3", scene = nil },
}
local currentSceneIndex = 1
local container = nil
local sprite = nil

function MainMenu:enter(previous, ...)
    container = playout.tree:build(function(ui)
        local box = ui.box
        local text = ui.text

        local itemBoxes = {}
        for idx, item in ipairs(menuItems) do
            local itemBox = box(
                {
                    border = 1,
                    padding = 4,
                    id = "item" .. idx,
                    direction = playout.kDirectionHorizontal,
                },
                { text(item.label, { flex = 1 }) }
            )
            table.insert(itemBoxes, itemBox)
        end
        return box(
            { border = 1, maxWidth = 300 },
            {
                text("Main Menu", { font = gfx.getSystemFont(gfx.font.kVariantBold) }),
                box(
                    { border = 1, id = "items" },
                    itemBoxes
                )
            }
        )
    end)
    sprite = container:asSprite()
    sprite:moveTo(
        playdate.display.getWidth() / 2,
        playdate.display.getHeight() / 2
    )
    sprite:add()
end

function updateCurrentSelection()

end

function MainMenu:downButtonDown()
    currentSceneIndex = currentSceneIndex + 1
    if currentSceneIndex > #menuItems then
        currentSceneIndex = 1
    end
    updateCurrentSelection()
end

function MainMenu:upButtonDown()
    currentSceneIndex = currentSceneIndex - 1
    if currentSceneIndex < 1 then
        currentSceneIndex = #menuItems
    end
    updateCurrentSelection()
end

function MainMenu:AButtonDown()
    local selectedItem = menuItems[currentSceneIndex]
    SceneManager:push(selectedItem.scene())
end
