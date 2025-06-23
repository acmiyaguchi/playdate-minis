local pd <const> = playdate
local gfx <const> = playdate.graphics
local file = playdate.file

local displayText = "Loading 'On this day' from Wikipedia..."
local requested = false
local progressText = ""
local fetching = false
local http = nil

local responseChunks = nil -- move to file scope

local function getDateString()
    local time = pd.getTime()
    return string.format("%04d-%02d-%02d", time.year, time.month, time.day)
end

local function getCachePath()
    return getDateString() .. ".json"
end

local function parseAndDisplay(jsonString)
    local ok, data = pcall(json.decode, jsonString)
    if ok and data and data.onthisday and #data.onthisday > 0 then
        local event = data.onthisday[1]
        displayText = "On this day in " .. event.year .. ":\n\n" .. event.text
    else
        displayText = "Failed to parse 'on this day' data."
    end
end

function fetchOnThisDay()
    local cachePath = getCachePath()
    if file.exists(cachePath) then
        local f = file.open(cachePath, file.kFileRead)
        if f then
            local fileSize = f:seek(0, file.kSeekFromEnd)
            if fileSize and fileSize > 0 then
                f:seek(0, file.kSeekSet)
                local jsonString, _ = f:read(fileSize)
                f:close()
                parseAndDisplay(jsonString)
                progressText = ""
                return
            else
                f:close()
                file.delete(cachePath)
                -- continue to fetch from HTTP below
            end
        else
            displayText = "Failed to open cache file."
            progressText = ""
            return
        end
    end

    displayText = "Fetching 'On this day' from Wikipedia..."
    progressText = "Connecting..."
    fetching = true
    local time = pd.getTime()
    local server = "api.wikimedia.org"
    local path = string.format("/feed/v1/wikipedia/en/featured/%d/%02d/%02d", time.year, time.month, time.day)
    http = pd.network.http.new(server, 443, true, "Need to fetch Wikipedia data")

    responseChunks = {}

    http:setRequestCallback(function()
        while true do
            local available = http:getBytesAvailable()
            if not available or available == 0 then break end
            local chunk = http:read(available)
            if chunk and #chunk > 0 then
                table.insert(responseChunks, chunk)
            else
                break
            end
        end
    end)

    http:setRequestCompleteCallback(function()
        local status = http:getResponseStatus()
        if status == 200 then
            local body = table.concat(responseChunks)
            -- Save to disk
            local f = file.open(cachePath, file.kFileWrite)
            if f then
                f:write(body)
                f:close()
            end
            parseAndDisplay(body)
            progressText = "Done."
        else
            displayText = "Error fetching data.\nStatus code: " .. tostring(status)
            progressText = ""
        end
        fetching = false
        http:close()
        http = nil
        responseChunks = nil
    end)

    http:get(path, { ["User-Agent"] = "Playdate" })
end

function pd.update()
    gfx.clear()
    gfx.drawText(displayText, 20, 20)

    -- Show progress at the bottom of the screen
    if fetching and http then
        local bytesRead, totalBytes = http:getProgress()
        if totalBytes and totalBytes > 0 then
            progressText = string.format("Progress: %d / %d bytes", bytesRead, totalBytes)
        elseif bytesRead and bytesRead > 0 then
            progressText = string.format("Progress: %d bytes", bytesRead)
        else
            progressText = "Progress: waiting..."
        end
    end

    if progressText ~= "" then
        gfx.drawText(progressText, 20, 220)
    end

    if not requested then
        requested = true
        fetchOnThisDay()
    end
end
