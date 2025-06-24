local pd <const> = playdate
local gfx <const> = playdate.graphics

local fetchOnThisDay = import "data.lua"

local requested = false
local displayText = "Loading 'On this day' from Wikipedia..."
local progressText = ""

function pd.update()
    gfx.clear()
    gfx.drawText(displayText, 20, 20)
    if progressText ~= "" then
        gfx.drawText(progressText, 20, 220)
    end

    if not requested then
        requested = true
        displayText = "Fetching 'On this day' from Wikipedia..."
        progressText = "Connecting..."
        fetchOnThisDay(
            function(text, ok)
                displayText = text
                if ok then
                    progressText = "Done."
                else
                    progressText = ""
                end
            end,
            function(bytesRead, totalBytes)
                if totalBytes and totalBytes > 0 then
                    progressText = string.format("Progress: %d / %d bytes", bytesRead, totalBytes)
                elseif bytesRead and bytesRead > 0 then
                    progressText = string.format("Progress: %d bytes", bytesRead)
                else
                    progressText = "Progress: waiting..."
                end
            end
        )
    end
end
