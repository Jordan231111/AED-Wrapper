----------------------------
-- Direct AED Script Launcher
-- Ultra-simplified version for maximum compatibility
----------------------------

-- Cache gg functions for speed
local gg_toast = gg.toast
local gg_alert = gg.alert
local gg_setVisible = gg.setVisible
local gg_makeRequest = gg.makeRequest

-- Hide GG immediately
gg_setVisible(false)

-- Display welcome message
gg_toast("Loading AED Tool...")
gg_alert("Welcome to AED Tool\n\nThis simplified version will download and run the script directly.\n\nPress OK to continue.")

-- Direct URL to original script
local SCRIPT_URL = "https://raw.githubusercontent.com/Jordan231111/AED/main/main.lua"

-- Function to download and run the script
local function downloadAndRun()
    -- Show download message
    gg_toast("Downloading script...")
    
    -- Add timestamp to URL to prevent caching
    local url = SCRIPT_URL .. "?t=" .. os.time()
    
    -- Download the script
    local response = gg_makeRequest(url)
    
    -- Check if download was successful
    if type(response) ~= "table" or not response.content or response.content == "" then
        gg_alert("Failed to download script. Please check your internet connection and try again.")
        return false
    end
    
    -- Create temporary file for the script
    local tempFile = gg.getFile():gsub("/[^/]+$", "/direct_temp_" .. os.time() .. ".lua")
    
    -- Try to create and write to the file
    local file = io.open(tempFile, "w")
    if not file then
        gg_alert("Failed to create temporary file. Please check storage permissions.")
        return false
    end
    
    -- Write script content to file
    file:write(response.content)
    file:close()
    
    -- Run the script
    gg_toast("Running script...")
    
    -- Try to execute the script
    local success, error = pcall(function()
        dofile(tempFile)
    end)
    
    -- Always try to clean up
    pcall(function()
        os.remove(tempFile)
    end)
    
    -- Check if execution was successful
    if not success then
        gg_alert("Error executing script: " .. tostring(error))
        return false
    end
    
    return true
end

-- Run with error handling
local success, error = pcall(downloadAndRun)
if not success then
    gg_alert("Critical error: " .. tostring(error))
end

-- Exit message
gg_toast("Done")
