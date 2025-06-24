local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/object"
-- Import the sprite and timer libraries, which are now used
import "CoreLibs/sprites"
import "CoreLibs/timer"


gfx.setFont(gfx.getSystemFont())

import "playout.lua"
import "wikipedia.lua"


STATE_LOADING = 1
STATE_ARTICLE_READER = 2

local gameState = STATE_LOADING
local jsonData = nil

---
-- Article Reader State
---
local contentSprite = nil -- This will hold the sprite for our scrollable text
local scrollY = 0
local contentHeight = 0
local viewportHeight = 240
local contentInitialY = 0
local PADDING = 10

function setup_article_reader(article)
    playdate.display.setScale(1) -- Add this line
    local titleFont = gfx.font.new("Asheville-Sans-24-Bold.fnt")
    local bodyFont = gfx.font.new("Asheville-Sans-14-Light.fnt")

    -- 1. Create the container with just the content that will scroll.
    --    This will be rendered into a single, tall sprite.
    local contentContainer = playout.box.new({
        id = "content",
        -- The width is constrained by the screen, minus padding
        width = 400 - (PADDING * 2),
        direction = playout.kDirectionVertical,
        spacing = 8,
        font = bodyFont,
    })

    contentContainer:appendChild(playout.text.new(article.normalizedtitle, { font = titleFont }))
    contentContainer:appendChild(playout.text.new(article.extract))

    -- 2. Use the playout.tree:asSprite() interface to create a sprite from the layout
    local contentTree = playout.tree.new(contentContainer)
    contentSprite = contentTree:asSprite()

    -- 3. Set the sprite's initial position and add it to the display list
    contentInitialY = PADDING
    contentSprite:moveTo(PADDING, contentInitialY)
    contentSprite:add()

    -- 4. Store the calculated height of the content for scrolling limits
    contentHeight = contentTree.rect.height
    viewportHeight = 240 - (PADDING * 2)

    -- 5. Set a clipping rectangle to create the "viewport" effect
    --    This ensures the tall sprite is only visible within this area.
    gfx.sprite.setClipRectsInRange(PADDING, PADDING, 400 - (PADDING * 2), viewportHeight, 0, 32767)
end

-- This function runs EVERY FRAME while in the STATE_ARTICLE_READER.
function update_article_reader()
    -- 1. Handle Input
    local crankChange, _ = pd.getCrankChange()
    scrollY = scrollY + crankChange

    -- 2. Clamp scroll value
    local maxScroll = contentHeight - viewportHeight
    if maxScroll < 0 then maxScroll = 0 end
    scrollY = math.max(0, math.min(scrollY, maxScroll))

    -- 3. Move the sprite
    --    The sprite interface simplifies drawing. We just move the sprite
    --    and the sprite.update() call handles the rest.
    contentSprite:moveTo(PADDING, contentInitialY - scrollY)

    -- The screen is cleared automatically when sprites are in use,
    -- but we can draw the debug bar on top.
    draw_debug_bar()
end

---
-- Loading State (no changes)
---
local requested = false
local displayText = "Loading..."
local progressText = ""

function update_loading()
    gfx.clear()
    gfx.drawText(displayText, 20, 20)
    if progressText ~= "" then
        gfx.drawText(progressText, 20, 220)
    end

    if not requested then
        requested = true
        displayText = "Fetching featured content from Wikipedia..."
        progressText = "Connecting..."

        wikipedia.fetchFeatured(
            function(text, ok)
                if ok then
                    displayText = "Parsing data..."
                    jsonData = json.decode(text)

                    setup_article_reader(jsonData.tfa)

                    gameState = STATE_ARTICLE_READER
                else
                    displayText = text
                    progressText = ""
                end
            end,
            function(bytesRead, totalBytes)
                if totalBytes and totalBytes > 0 then
                    progressText = string.format("Progress: %d / %d bytes", bytesRead, totalBytes)
                else
                    progressText = string.format("Progress: %d bytes", bytesRead)
                end
            end
        )
    end
end

function draw_debug_bar()
    local debugInfo = string.format(
        "State: %s | Scroll: %.0f", -- Use %.0f to format the float as an integer
        gameState == STATE_LOADING and "LOADING" or "ARTICLE",
        scrollY or 0
    )
    if jsonData and jsonData.tfa and jsonData.tfa.normalizedtitle then
        debugInfo = debugInfo .. " | Title: " .. tostring(jsonData.tfa.normalizedtitle)
    end
    -- Draw debug text in an area that won't be cleared by the sprite system
    gfx.drawText(debugInfo, 5, 223)
end

---
-- Main Update Loop
---
function pd.update()
    if gameState == STATE_LOADING then
        update_loading()
    elseif gameState == STATE_ARTICLE_READER then
        update_article_reader()
    end

    -- This line is essential for any project using sprites.
    -- It tells the graphics system to update sprite positions and redraw them.
    gfx.sprite.update()
end
