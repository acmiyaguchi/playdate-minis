local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/object"
-- Import the sprite and timer libraries, which are now used
import "CoreLibs/sprites"
import "CoreLibs/timer"


gfx.setFont(gfx.getSystemFont())

import "../toyboxes/toyboxes.lua"
import "wikipedia.lua"


STATE_LOADING = 1
STATE_ARTICLE_READER = 2

local gameState = STATE_LOADING
local jsonData = nil

---
-- Article Reader State
---
local articleUiTree = nil
local scrollY = 0
local contentHeight = 0
local viewportHeight = 240
local viewportWidth = 400
local PADDING = 10

function setup_article_reader(article)
    local titleFont = gfx.font.new("Asheville-Sans-24-Bold.fnt")
    local bodyFont = gfx.font.new("Asheville-Sans-14-Light.fnt")

    local contentWidth = viewportWidth - (PADDING * 2)
    local contentContainer = playout.box.new({
        id = "content",
        width = contentWidth,
        direction = playout.kDirectionVertical,
        spacing = 8,
        font = bodyFont,
    })

    contentContainer:appendChild(playout.text.new(article.normalizedtitle, { font = titleFont }))
    contentContainer:appendChild(playout.text.new(article.extract))

    local contentTree = playout.tree.new(contentContainer)
    local contentSprite = contentTree:asSprite()
    contentHeight = contentTree.rect.height
    viewportHeight = 240 - (PADDING * 2)

    -- Move the sprite to the correct position and add it to the display list
    contentSprite:moveTo(PADDING, PADDING)
    contentSprite:setCenter(0, 0) -- Ensure origin is top-left
    contentSprite:add()

    -- Set a clip rect for the viewport area so the sprite is only visible within this region
    gfx.sprite.setClipRectsInRange(PADDING, PADDING, contentWidth, viewportHeight, 0, 32767)

    _G.contentSprite = contentSprite
end

-- This function runs EVERY FRAME while in the STATE_ARTICLE_READER.
function update_article_reader()
    -- Handle Input
    local crankChange, _ = pd.getCrankChange()
    scrollY = scrollY + crankChange

    local maxScroll = contentHeight - viewportHeight
    if maxScroll < 0 then maxScroll = 0 end
    scrollY = math.max(0, math.min(scrollY, maxScroll))

    -- Move the sprite vertically to scroll
    if _G.contentSprite then
        _G.contentSprite:moveTo(PADDING, PADDING - scrollY)
    end

    -- The sprite system will handle drawing, so just draw the debug bar
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

    -- Required for sprite-based rendering
    gfx.sprite.update()
end
