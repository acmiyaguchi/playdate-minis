local pd <const> = playdate
local gfx <const> = playdate.graphics

import "CoreLibs/graphics"
import "CoreLibs/object"

import "playout.lua"
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
local viewportFrame = nil


function setup_article_reader(article)
    local viewport = playout.box.new({
        id = "viewport",
        width = 400,
        height = 240,
        padding = 10
    })

    local contentContainer = playout.box.new({
        id = "content",
        direction = playout.kDirectionVertical,
        spacing = 8
    })

    contentContainer:appendChild(playout.text.new(article.displaytitle, { font_size = 20, font_weight = "bold" }))

    for paragraph in string.gmatch(article.extract, "[^\\n]+") do
        contentContainer:appendChild(playout.text.new(paragraph))
    end

    viewport:appendChild(contentContainer)

    articleUiTree = playout.tree.new(viewport)
    articleUiTree:layout()

    -- FINAL FIX: Use the properties that are explicitly in the documentation.
    -- The tree's .rect property represents the frame of the root node (our viewport).
    viewportFrame = articleUiTree.rect

    -- The root node's .childRects table holds the calculated frames of its children.
    -- The content container is the first and only child.
    local contentFrame = articleUiTree.root.childRects[1]
    contentHeight = contentFrame.height
end

-- This function runs EVERY FRAME while in the STATE_ARTICLE_READER.
-- It should be very lightweight.
function update_article_reader()
    -- 1. Handle Input (no changes here)
    local crankChange = pd.getCrankChange()
    scrollY = scrollY + crankChange

    local maxScroll = contentHeight - viewportFrame.height
    if maxScroll < 0 then maxScroll = 0 end
    scrollY = math.max(0, math.min(scrollY, maxScroll))

    -- 2. Draw Graphics
    gfx.clear(gfx.kColorWhite)

    gfx.pushContext()
    gfx.setClipRect(viewportFrame.x, viewportFrame.y, viewportFrame.width, viewportFrame.height)
    gfx.setDrawOffset(0, -scrollY)

    -- FIX: Draw the entire tree. Playout will handle drawing all the children.
    -- Our clipping and translation will handle the "viewport" effect.
    articleUiTree:draw()

    gfx.popContext()
end

---
-- Loading State
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
                    jsonData = json.decode(text) -- Decode the JSON string into a Lua table

                    -- Now that we have the data, set up the next view
                    setup_article_reader(jsonData.tfa)

                    -- Finally, change the game state
                    gameState = STATE_ARTICLE_READER
                else
                    displayText = text -- Will contain the error message
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

---
-- Main Update Loop
---
function pd.update()
    if gameState == STATE_LOADING then
        update_loading()
    elseif gameState == STATE_ARTICLE_READER then
        update_article_reader()
    end
end
