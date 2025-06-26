--[[
This is the main menu scene to go between different scenes.
]]
import "numbered_boxes.lua"
local gfx <const> = playdate.graphics

class("Menu").extends(Room)
local manager = Manager()

local menuItems = {
    { label = "Numbered Boxes", scene = NumberedBoxes },
}
local currentSceneIndex = 1
local container = nil
local sprite = nil

function Menu:enter(previous, ...)
    container = playout.tree:build(function(ui)
        local box = ui.box
        local text = ui.text

        local itemBoxes = {}
        for idx, item in ipairs(menuItems) do
            local itemBox = box(
                {
                    border = 1,
                    id = "item" .. idx
                },
                { text(item.label) }
            )
            table.insert(itemBoxes, itemBox)
        end
        return box(
            { border = 1 },
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

function Menu:update(dt)
end

function Menu:leave(next, ...)
    -- Logic to handle when leaving the menu can be added here if needed
end

function Menu:draw()
end
