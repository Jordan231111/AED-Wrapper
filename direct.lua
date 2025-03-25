----------------------------
-- Direct AED Script Launcher (Enhanced)
-- Ultra-simplified version with improved security
----------------------------

-- Cache gg functions for speed
local gg_toast = gg.toast
local gg_alert = gg.alert
local gg_setVisible = gg.setVisible
local gg_makeRequest = gg.makeRequest
local gg_sleep = gg.sleep

-- Initialize state variables
local tempFile = nil
local hasShownError = false

-- Hide GG immediately
gg_setVisible(false)

-- Display welcome message
gg_toast("Loading Tool...")
gg_alert("Welcome\n\nThis simplified tool will run securely without revealing source code.\n\nPress OK to continue.")

-- Obfuscated URL split into parts for security
local urlParts = {
    "https://r",
    "aw.githubuserco",
    "ntent.com/Jor", 
    "dan23", 
    "1111/A", 
    "ED/ma", 
    "in/main.lua"
}

-- Function to download and run the script
local function downloadAndRun()
    -- Show download message with randomized text
    local loadingTexts = {"Initializing...", "Preparing...", "Setting up...", "Loading components..."}
    gg_toast(loadingTexts[math.random(1, #loadingTexts)])
    
    -- Build URL from parts to prevent easy discovery
    local url = table.concat(urlParts) .. "?nocache=" .. os.time() .. "&r=" .. math.random(1000, 9999)
    
    -- Download the script without revealing the URL
    gg_toast("Downloading components...")
    local response = gg_makeRequest(url)
    
    -- Check if download was successful
    if type(response) ~= "table" or not response.content or response.content == "" then
        if not hasShownError then
            hasShownError = true
            gg_alert("Network error. Please check your connection and try again.")
        end
        return false
    end
    
    -- Create temporary file with random name for the script
    local randomName = "temp_" .. math.random(10000000, 99999999)
    tempFile = gg.getFile():gsub("/[^/]+$", "/" .. randomName .. ".lua")
    
    -- Try to create and write to the file
    local file, openError = io.open(tempFile, "w")
    if not file then
        if not hasShownError then
            hasShownError = true
            gg_alert("Storage error. Please check permissions.")
        end
        return false
    end
    
    -- Write script content to file
    file:write(response.content)
    file:close()
    
    -- Run the script
    gg_toast("Launching...")
    
    -- Try to execute the script
    -- We use loadfile + pcall instead of dofile to get better error handling
    local scriptFunc, loadError = loadfile(tempFile)
    
    if not scriptFunc then
        if not hasShownError then
            hasShownError = true
            gg_alert("Load error: " .. tostring(loadError))
        end
        -- Clean up tempfile
        pcall(function() os.remove(tempFile) end)
        tempFile = nil
        return false
    end
    
    -- Execute with pcall
    local success, runError = pcall(scriptFunc)
    
    -- We don't cleanup the temp file here because the script will continue running
    -- Cleanup will happen via the atexit function below
    
    if not success and not hasShownError then
        hasShownError = true
        gg_alert("Execution error: " .. tostring(runError))
        return false
    end
    
    return true
end

-- Setup cleanup function that will run when script exits
local oldExit = os.exit
os.exit = function(code)
    -- Clean up temp file
    if tempFile then
        pcall(function() os.remove(tempFile) end)
        tempFile = nil
    end
    
    -- Call original exit with the same code
    oldExit(code)
end

-- Install error handler to clean up if script crashes
local function errorHandler(err)
    -- Clean up temp file
    if tempFile then
        pcall(function() os.remove(tempFile) end)
        tempFile = nil
    end
    
    -- Show error if not shown already
    if not hasShownError then
        hasShownError = true
        gg_toast("An error occurred")
    end
    
    -- Return the original error for normal error handling
    return err
end

-- Run with error handling and cleanup
xpcall(downloadAndRun, errorHandler)

-- Final cleanup if we somehow get here 
-- (shouldn't happen as script should have taken over or exited)
if tempFile then
    pcall(function() os.remove(tempFile) end)
    tempFile = nil
end

-- No exit message to avoid leaking any info
