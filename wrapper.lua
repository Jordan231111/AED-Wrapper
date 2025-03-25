----------------------------
-- AED Script Wrapper (Fixed Version)
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

-- Load config with error handling
local function loadConfig()
    -- Check if config file exists first
    local f = io.open(CONFIG_FILE, "r")
    if not f then
        gg_toast("Config file not found")
        return false
    end
    f:close()
    
    -- Try to load the config using pcall for error handling
    local success, err = pcall(function() 
        dofile(CONFIG_FILE) 
    end)
    
    if not success then
        gg_alert("Error loading config: " .. tostring(err))
        return false
    end
    
    if type(_G.CONFIG) == "table" then
        config = _G.CONFIG
        return true
    end
    
    return false
end

-- Base64 decode function with error handling
local function decodeBase64(data)
    if not data or type(data) ~= "string" then
        return nil
    end
    
    local success, result = pcall(function()
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
    end)
    
    if not success then
        gg_toast("Error decoding data")
        return nil
    end
    
    return result
end

-- Function to build the script URL from config
local function buildScriptURL()
    -- First try obfuscated URL approach
    if config.sourceType == "dynamic" and config.sourceParams then
        local sourceParams = config.sourceParams
        
        -- Check required elements
        if not sourceParams.parts or not sourceParams.protocol or not sourceParams.mode then
            gg_toast("Using fallback URL")
            return "https://raw.githubusercontent.com/Jordan231111/AED/main/main.lua"
        end
        
        -- Try to decode parts
        local decodedParts = {}
        local decodeSuccess = true
        
        for i, part in ipairs(sourceParams.parts) do
            if sourceParams.format == "base64" then
                local decoded = decodeBase64(part)
                if decoded then
                    decodedParts[i] = decoded
                else
                    decodeSuccess = false
                    break
                end
            else
                decodedParts[i] = part
            end
        end
        
        -- If decoding succeeded, build URL
        if decodeSuccess then
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
            return baseURL .. combinedParts
        end
    end
    
    -- Fallback URL if obfuscation fails
    gg_toast("Using fallback URL")
    return "https://raw.githubusercontent.com/Jordan231111/AED/main/main.lua"
end

-- Function to download the original script with retry mechanism
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
    
    -- Retry up to 3 times
    local success = false
    local content = nil
    local attempts = 0
    local maxAttempts = 3
    
    while not success and attempts < maxAttempts do
        attempts = attempts + 1
        
        -- Show retry message after first attempt
        if attempts > 1 then
            gg_toast("Retry attempt " .. attempts .. " of " .. maxAttempts)
        else
            gg_toast("Downloading script...")
        end
        
        -- Download the script
        local response = gg_makeRequest(uniqueURL .. "&attempt=" .. attempts)
        
        -- Check if successful
        if type(response) == "table" and response.content and response.content ~= "" then
            success = true
            content = response.content
        else
            -- Wait a bit before retrying
            gg.sleep(1000 * attempts)
        end
    end
    
    if not success then
        gg_alert("Failed to download script after " .. maxAttempts .. " attempts")
        os.exit()
        return nil
    end
    
    return content
end

-- Function to execute script content safely
local function executeScript(scriptContent)
    if not scriptContent then
        gg_alert("No script content to execute")
        os.exit()
        return false
    end
    
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
    
    -- Generate a unique temp filename to avoid conflicts
    local tempScriptFile = gg.getFile():gsub("/[^/]+$", "/temp_" .. os.time() .. "_" .. math.random(1000, 9999) .. ".lua")
    
    -- Use pcall for error handling when writing the file
    local writeSuccess, writeError = pcall(function()
        local file = io.open(tempScriptFile, "w")
        if not file then
            error("Failed to create temporary script file")
        end
        
        file:write(scriptContent)
        file:close()
    end)
    
    if not writeSuccess then
        gg_alert("Error creating temporary file: " .. tostring(writeError))
        os.exit()
        return false
    end
    
    -- Execute the script with pcall for error handling
    gg_toast("Executing script...")
    local execSuccess, execError = pcall(function() 
        dofile(tempScriptFile) 
    end)
    
    -- Always try to remove the temporary file
    local removeSuccess, removeError = pcall(function() 
        os.remove(tempScriptFile) 
    end)
    
    if not removeSuccess then
        gg_toast("Warning: Failed to remove temporary file")
    end
    
    if not execSuccess then
        gg_alert("Error executing script: " .. tostring(execError))
        os.exit()
        return false
    end
    
    return true
end

-- Main execution flow with error handling
local function main()
    gg_toast("Initializing wrapper...")
    
    -- Load configuration
    if not loadConfig() then
        gg_alert("Failed to load configuration. Using direct method.")
        
        -- Download script directly
        local scriptContent = downloadScript()
        if not scriptContent then
            return
        end
        
        -- Execute script
        if not executeScript(scriptContent) then
            return
        end
        
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
end

-- Run the main function with error handling
local success, error = pcall(main)
if not success then
    gg_alert("Critical error in wrapper: " .. tostring(error))
end

-- Script execution is now handled by the original script
-- The wrapper will terminate when the original script completes
