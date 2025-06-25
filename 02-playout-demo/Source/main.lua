--[[
modified version of https://github.com/potch/playout/blob/main/demo/main.lua to have a copy of functional code in the repo.
]]
-- sdk libs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

-- local libs
import "../toyboxes/toyboxes.lua"

fonts = {
    normal = gfx.getSystemFont(gfx.font.kVariantNormal),
    bold = gfx.getSystemFont(gfx.font.kVariantBold)
}

local button = {
    padding = 4,
    paddingLeft = 16,
    borderRadius = 12,
    border = 2,
    shadow = 3,
    shadowAlpha = 1 / 4,
    backgroundColor = gfx.kColorWhite,
    font = fonts.bold
}

local menu = nil
local menuImg, menuSprite, menuTimer
local selectedIndex = 1

local pointer
local pointerPos = nil
local pointerTimer

local selected

local function setPointerPos()
    selected = menu.tabIndex[selectedIndex]
    local menuRect = menuSprite:getBoundsRect()

    pointerPos = getRectAnchor(selected.rect, playout.kAnchorCenterLeft):
    offsetBy(getRectAnchor(menuRect, playout.kAnchorTopLeft):unpack())
end

local function nextMenuItem()
    selectedIndex = selectedIndex + 1
    if selectedIndex > #menu.tabIndex then
        selectedIndex = 1
    end
    setPointerPos()
end

local function prevMenuItem()
    selectedIndex = selectedIndex - 1
    if selectedIndex < 1 then
        selectedIndex = #menu.tabIndex
    end
    setPointerPos()
end


local function createMenu(ui)
    local box = ui.box
    local image = ui.image
    local text = ui.text

    return box({
        maxWidth = 380,
        backgroundColor = gfx.kColorWhite,
        borderRadius = 9,
        border = 2,
        direction = playout.kDirectionHorizontal,
        vAlign = playout.kAlignStretch,
        shadow = 8,
        shadowAlpha = 1 / 3
    }, {
        box({
            padding = 12,
            spacing = 10,
            backgroundColor = gfx.kColorBlack,
            backgroundAlpha = 7 / 8,
            borderRadius = 9,
            border = 2
        }, {
            box({
                paddingLeft = 6,
                paddingTop = 3,
                paddingBottom = 1,
            }, { text("playout", { stroke = 4 }) }),
        }),
        box({
            spacing = 12,
            paddingTop = 16,
            paddingLeft = 20,
            hAlign = playout.kAlignStart
        }, {
            text("Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
            box({
                direction = playout.kDirectionHorizontal,
                spacing = 12,
                paddingLeft = 16,
                paddingTop = 12,
                paddingBottom = 0,
                vAlign = playout.kAlignEnd,
            }, {
                box({ style = button }, { text("cancel", { id = "no", stroke = 2, tabIndex = 1 }) }),
                box({ flex = 1 }),
                box({ style = button }, { text("okay", { id = "yes", stroke = 2, tabIndex = 2 }) }),
            })
        })
    })
end

local inputHandlers = {
    rightButtonDown = nextMenuItem,
    downButtonDown = nextMenuItem,
    leftButtonDown = prevMenuItem,
    upButtonDown = prevMenuItem,
    AButtonDown = function()
        local selected = menu.tabIndex[selectedIndex]
        if selected == menu:get("yes") then
            menuSprite:moveBy(0, 4)
            menuSprite:update()
        end
        if selected == menu:get("no") then
            menuSprite:moveBy(0, -4)
            menuSprite:update()
        end
        setPointerPos()
    end
}

function setup()
    -- attach input handlers
    playdate.inputHandlers.push(inputHandlers)

    -- setup menu
    menu = playout.tree:build(createMenu)
    menu:computeTabIndex()
    menuImg = menu:draw()
    menuSprite = gfx.sprite.new(menuImg)
    menuSprite:moveTo(200, 400)
    menuSprite:add()

    -- setup pointer as a small triangle sprite
    local pointerImg = gfx.image.new(16, 16, gfx.kColorClear)
    gfx.pushContext(pointerImg)
    gfx.fillTriangle(8, 0, 0, 16, 16, 16)
    gfx.popContext()
    pointer = gfx.sprite.new(pointerImg)
    pointer:setRotation(90)
    pointer:setZIndex(1)
    pointer:add()
    setPointerPos()

    -- setup pointer animation
    pointerTimer = playdate.timer.new(500, -18, -14, playdate.easingFunctions.inOutSine)
    pointerTimer.repeats = true
    pointerTimer.reverses = true

    -- setup menu animation
    menuTimer = playdate.timer.new(500, 400, 100, playdate.easingFunctions.outCubic)
    menuTimer.timerEndedCallback = setPointerPos
end

-- frame callback
function playdate.update()
    if menuTimer.timeLeft > 0 then
        menuSprite:moveTo(200, menuTimer.value)
        menuSprite:update()
    end

    pointer:moveTo(
        pointerPos:offsetBy(pointerTimer.value, 0)
    )
    pointer:update()

    playdate.timer.updateTimers()
    playdate.drawFPS()
end

setup()
