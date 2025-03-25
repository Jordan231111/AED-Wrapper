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

-- Function to download the original script
local function downloadScript()
    local scriptURL = config.scriptURL
    
    -- Validate URL
    if not scriptURL or scriptURL == "" then
        gg_alert("Invalid script URL in config")
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
    -- Create a temporary file with the script content
    local tempScriptFile = gg.getFile():gsub("/[^/]+$", "/temp_script.lua")
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