class("NumberedBoxes").extends(Room)
local gfx <const> = playdate.graphics


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
    local menu = playout.tree:build(createMenu)
    local menuSprite = menu:asSprite()
    menuSprite:moveTo(
        playdate.display.getWidth() / 2,
        playdate.display.getHeight() / 2
    )
    menuSprite:add()
end

function NumberedBoxes:update(dt) end

function NumberedBoxes:leave(next, ...) end

function NumberedBoxes:draw() end
