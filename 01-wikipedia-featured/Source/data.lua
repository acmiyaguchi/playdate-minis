local pd <const> = playdate
local file = playdate.file

local function getDateString()
    local time = pd.getTime()
    return string.format("%04d-%02d-%02d", time.year, time.month, time.day)
end

local function getCachePath()
    return getDateString() .. ".json"
end

local function parseFeaturedEvent(jsonString)
    local ok, data = pcall(json.decode, jsonString)
    if ok and data and data.onthisday and #data.onthisday > 0 then
        local event = data.onthisday[1]
        return "On this day in " .. event.year .. ":\n\n" .. event.text
    else
        return "Failed to parse 'on this day' data."
    end
end

function fetchOnThisDay(onDone, onProgress)
    local cachePath = getCachePath()
    if file.exists(cachePath) then
        local f = file.open(cachePath, file.kFileRead)
        if f then
            local fileSize = f:seek(0, file.kSeekFromEnd)
            if fileSize and fileSize > 0 then
                f:seek(0, file.kSeekSet)
                local jsonString, _ = f:read(fileSize)
                f:close()
                if onDone then onDone(parseFeaturedEvent(jsonString), true) end
                return
            else
                f:close()
                file.delete(cachePath)
                -- continue to fetch from HTTP below
            end
        else
            if onDone then onDone("Failed to open cache file.", false) end
            return
        end
    end

    local time = pd.getTime()
    local server = "api.wikimedia.org"
    local path = string.format("/feed/v1/wikipedia/en/featured/%d/%02d/%02d", time.year, time.month, time.day)
    local http = pd.network.http.new(server, 443, true, "Need to fetch Wikipedia data")

    local responseChunks = {}

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
        if onProgress and http then
            local bytesRead, totalBytes = http:getProgress()
            onProgress(bytesRead or 0, totalBytes or 0)
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
            if onDone then onDone(parseFeaturedEvent(body), true) end
        else
            if onDone then onDone("Error fetching data.\nStatus code: " .. tostring(status), false) end
        end
        http:close()
    end)

    http:get(path, { ["User-Agent"] = "Playdate" })
end

return fetchOnThisDay
