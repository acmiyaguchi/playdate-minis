local pd <const> = playdate
local file <const> = playdate.file
local json <const> = pd.json

-- Helper function to get the expected path for today's cache file.
local function getCachePath()
    local time = pd.getTime()
    local dateString = string.format("%04d-%02d-%02d", time.year, time.month, time.day)
    return dateString .. ".json"
end

---
-- Responsibility #1: Handle fetching data from the local cache.
---
local function fetchFromCache(onDone)
    local cachePath = getCachePath()
    if not file.exists(cachePath) then
        return false -- Cache miss
    end

    local f, open_err = file.open(cachePath, file.kFileRead)
    if not f then
        print("Error opening cache file: " .. tostring(open_err))
        return false
    end

    f:seek(0, file.kSeekFromEnd)
    local size = f:tell()

    if not size or size <= 0 then
        f:close()
        file.delete(cachePath)
        return false -- Silently treat 0-byte file as a cache miss
    end

    f:seek(0, file.kSeekSet)
    local jsonString, read_err = f:read(size)
    f:close()

    if not jsonString then
        print("Error reading from file: " .. tostring(read_err))
        return false
    end

    if onDone then onDone(jsonString, true) end
    return true
end

---
-- Responsibility #2: Handle fetching data from the network.
-- Logic is now consolidated into a single, robust callback.
---
local function fetchFromNetwork(onDone, onProgress)
    local cachePath = getCachePath()
    local time = pd.getTime()
    local server = "api.wikimedia.org"
    local path = string.format("/feed/v1/wikipedia/en/featured/%d/%02d/%02d", time.year, time.month, time.day)
    local http = pd.network.http.new(server, 443, true)

    local headers = { ["User-Agent"] = "DailyWiki-Playdate-App/1.0" }

    -- FIX: Use a single, unified callback to handle all response events.
    http:setRequestCallback(function(response)
        if response.isComplete then
            -- The request is finished. Handle success or failure.
            if response.statusCode == 200 then
                local f = file.open(cachePath, file.kFileWrite)
                if f then
                    f:write(response.body)
                    f:close()
                end
                if onDone then onDone(response.body, true) end
            else
                local errorMessage = "Error fetching data.\nStatus code: " .. tostring(response.statusCode)
                if onDone then onDone(errorMessage, false) end
            end
        elseif onProgress then
            -- The request is still in progress.
            local bytesRead, totalBytes = http:getProgress()
            onProgress(bytesRead or 0, totalBytes or 0)
        end
    end)

    http:get(path, headers)
end


---
-- Public "Coordinator" Function
---
function fetchFeatured(onDone, onProgress)
    local wasFetchedFromCache = fetchFromCache(onDone)
    if not wasFetchedFromCache then
        fetchFromNetwork(onDone, onProgress)
    end
end

-- Expose the public API of the module
wikipedia = {
    fetchFeatured = fetchFeatured
}
