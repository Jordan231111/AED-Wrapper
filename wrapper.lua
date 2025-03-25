----------------------------
-- AED Script Wrapper
-- This wrapper loads and executes the original AED script
-- without revealing the original code
----------------------------

-- Cache frequently used GG functions for speed
local gg_clearResults = gg.clearResults
local gg_toast = gg.toast
local gg_alert = gg.alert
local gg_makeRequest = gg.makeRequest
local gg_isVisible = gg.isVisible
local gg_setVisible = gg.setVisible

-- Hide GG immediately for security
gg_setVisible(false)
gg_clearResults()

-- Initialize
local CONFIG_FILE = "config.lua"
local config = {}

-- Load config
local function loadConfig()
    if pcall(function() dofile(CONFIG_FILE) end) then
        if type(_G.CONFIG) == "table" then
            config = _G.CONFIG
            return true
        end
    end
    return false
end

-- Base64 decode function
local function decodeBase64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- Function to build the script URL from obfuscated config
local function buildScriptURL()
    local sourceParams = config.sourceParams
    
    if config.sourceType ~= "dynamic" or not sourceParams then
        gg_alert("Invalid source configuration")
        os.exit()
        return nil
    end
    
    -- Check required elements
    if not sourceParams.parts or not sourceParams.protocol or not sourceParams.mode then
        gg_alert("Missing required source parameters")
        os.exit()
        return nil
    end
    
    -- Decode parts based on format
    local decodedParts = {}
    for i, part in ipairs(sourceParams.parts) do
        if sourceParams.format == "base64" then
            decodedParts[i] = decodeBase64(part)
        else
            decodedParts[i] = part
        end
    end
    
    -- Build URL based on mode
    local baseURL = sourceParams.protocol .. "://"
    if sourceParams.mode == "raw" then
        baseURL = baseURL .. "raw.githubusercontent.com/"
    else
        baseURL = baseURL .. "github.com/"
    end
    
    -- Combine parts
    local combinedParts = table.concat(decodedParts, "/")
    
    -- Construct final URL
    local finalURL = baseURL .. combinedParts
    
    return finalURL
end

-- Function to download the original script
local function downloadScript()
    local scriptURL = buildScriptURL()
    
    -- Validate URL
    if not scriptURL or scriptURL == "" then
        gg_alert("Failed to build script URL")
        os.exit()
        return nil
    end
    
    -- Add a timestamp parameter to prevent caching
    local uniqueURL = scriptURL .. "?t=" .. os.time()
    
    -- Download the script
    gg_toast("Downloading script...")
    local response = gg_makeRequest(uniqueURL)
    
    if type(response) ~= "table" or not response.content then
        gg_alert("Failed to download script")
        os.exit()
        return nil
    end
    
    return response.content
end

-- Function to execute script content safely
local function executeScript(scriptContent)
    -- Apply obfuscation if enabled
    if config.obfuscateExecution then
        -- Add some random comments to obfuscate the script
        local obfuscated = "-- " .. os.time() .. "\n"
        
        -- Split the script into chunks with random markers
        local chunks = {}
        local chunkSize = 1000
        for i = 1, #scriptContent, chunkSize do
            chunks[#chunks + 1] = scriptContent:sub(i, i + chunkSize - 1)
        end
        
        -- Reassemble with random markers
        for i, chunk in ipairs(chunks) do
            obfuscated = obfuscated .. chunk
            if i < #chunks then
                obfuscated = obfuscated .. "\n-- " .. math.random(1000000, 9999999) .. "\n"
            end
        end
        
        scriptContent = obfuscated
    end
    
    -- Create a temporary file with the script content
    local tempScriptFile = gg.getFile():gsub("/[^/]+$", "/temp_" .. os.time() .. "_" .. math.random(1000, 9999) .. ".lua")
    local file = io.open(tempScriptFile, "w")
    if not file then
        gg_alert("Failed to create temporary script file")
        os.exit()
        return false
    end
    
    file:write(scriptContent)
    file:close()
    
    -- Execute the script
    gg_toast("Executing script...")
    local success, error = pcall(function() dofile(tempScriptFile) end)
    
    -- Remove the temporary file immediately
    os.remove(tempScriptFile)
    
    if not success then
        gg_alert("Error executing script: " .. tostring(error))
        os.exit()
        return false
    end
    
    return true
end

-- Main execution flow
gg_toast("Initializing wrapper...")

-- Load configuration
if not loadConfig() then
    gg_alert("Failed to load configuration")
    os.exit()
    return
end

-- Download script
local scriptContent = downloadScript()
if not scriptContent then
    return
end

-- Execute script
if not executeScript(scriptContent) then
    return
end

-- Script execution is now handled by the original script
-- The wrapper will terminate when the original script completes