import "../manager.lua"
local gfx <const> = playdate.graphics

class("NumberedBoxes").extends(Room)

local function createMenu(ui)
    local box = ui.box
    local text = ui.text

    local n = 8;

    local container = box()
    for i = 1, n do
        local row = box({ direction = playout.kDirectionHorizontal })
        for j = 1, n do
            k = (i - 1) * n + j
            local bgColor = gfx.kColorBlack
            local fgColor = gfx.kColorWhite
            if (i + j) % 2 == 0 then
                bgColor = gfx.kColorWhite
                fgColor = gfx.kColorBlack
            end
            local col = box({ border = 1, minHeight = 25, minWidth = 25, backgroundColor = bgColor })
            col:appendChild(text("" .. k, { color = fgColor }))
            row:appendChild(col)
        end
        container:appendChild(row)
    end
    return container
end

function NumberedBoxes:enter(previous, ...)
    local scene = playout.tree:build(createMenu)
    local sprite = scene:asSprite()
    sprite:moveTo(
        playdate.display.getWidth() / 2,
        playdate.display.getHeight() / 2
    )
    sprite:add()
end

function NumberedBoxes:BButtonDown()
    SceneManager:pop()
end
