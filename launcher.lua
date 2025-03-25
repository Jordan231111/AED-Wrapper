----------------------------
-- AED Script Launcher (Fixed Version)
-- This launcher provides a user-friendly interface
-- while hiding the original code
----------------------------

-- Cache frequently used GG functions for speed
local gg_toast = gg.toast
local gg_alert = gg.alert
local gg_choice = gg.choice
local gg_setVisible = gg.setVisible
local gg_isVisible = gg.isVisible
local gg_sleep = gg.sleep
local gg_makeRequest = gg.makeRequest

-- Hide GG immediately
gg_setVisible(false)

-- Script information
local SCRIPT_NAME = "AED Tool"
local SCRIPT_VERSION = "2.0.0"

-- Direct URLs (with simple obfuscation)
local WRAPPER_URL = "https://raw.githubusercontent.com/Jordan231111/AED-Wrapper/main/wrapper.lua"
local CONFIG_URL = "https://raw.githubusercontent.com/Jordan231111/AED-Wrapper/main/config.lua"

-- Display welcome message with animation
local function showWelcome()
    local dots = {".", "..", "..."}
    for _, dot in ipairs(dots) do
        gg_toast(SCRIPT_NAME .. " Loading" .. dot)
        gg_sleep(300)
    end
    
    -- Display welcome message
    gg_alert("Welcome to " .. SCRIPT_NAME .. " v" .. SCRIPT_VERSION .. 
             "\n\nThis launcher will download and execute the latest version of the script." ..
             "\n\nPress OK to continue.")
end

-- Function to download a file from URL with retry mechanism
local function downloadFile(url, filename)
    gg_toast("Downloading " .. filename .. "...")
    
    -- Add timestamp parameter to prevent caching
    local uniqueURL = url .. "?t=" .. os.time()
    
    -- Retry up to 3 times with increasing delay
    local success = false
    local response = nil
    local attempts = 0
    local maxAttempts = 3
    
    while not success and attempts < maxAttempts do
        attempts = attempts + 1
        
        -- Add attempt number to URL for debugging
        local attemptURL = uniqueURL .. "&attempt=" .. attempts
        
        -- Show retry message after first attempt
        if attempts > 1 then
            gg_toast("Retry attempt " .. attempts .. " for " .. filename)
        end
        
        -- Download the file
        response = gg_makeRequest(attemptURL)
        
        -- Check if successful
        if type(response) == "table" and response.content and response.content ~= "" then
            success = true
        else
            -- Wait longer between retries
            gg_sleep(1000 * attempts) 
        end
    end
    
    if not success then
        gg_alert("Failed to download " .. filename .. " after " .. maxAttempts .. " attempts.\n\nPlease check your internet connection and try again.")
        return nil
    end
    
    return response.content
end

-- Function to save content to a file with error handling
local function saveFile(content, filename)
    if not content then
        gg_alert("No content to save to " .. filename)
        return false
    end
    
    -- Use pcall for error handling
    local success, err = pcall(function()
        local file = io.open(filename, "w")
        if not file then
            error("Failed to open file for writing")
        end
        
        file:write(content)
        file:close()
    end)
    
    if not success then
        gg_alert("Error saving file: " .. tostring(err))
        return false
    end
    
    return true
end

-- Function to check and download required files
local function prepareFiles()
    -- Get base directory from launcher location
    local baseDir = gg.getFile():gsub("/[^/]+$", "/")
    
    -- Define file paths
    local wrapperPath = baseDir .. "wrapper.lua"
    local configPath = baseDir .. "config.lua"
    
    -- Create a direct version of the script if download fails
    local function createDirectScript()
        gg_toast("Creating direct version...")
        
        -- Create a simplified wrapper that directly downloads the original script
        local directWrapper = [[
----------------------------
-- Direct AED Script Wrapper
----------------------------

-- Hide GG immediately
gg.setVisible(false)

-- Download and run the original script
local url = "https://raw.githubusercontent.com/Jordan231111/AED/main/main.lua"
local response = gg.makeRequest(url)

if type(response) ~= "table" or not response.content then
    gg.alert("Failed to download script")
    os.exit()
end

-- Create temp file
local tempFile = gg.getFile():gsub("/[^/]+$", "/temp_script.lua")
local file = io.open(tempFile, "w")
if not file then
    gg.alert("Failed to create temporary file")
    os.exit()
end

file:write(response.content)
file:close()

-- Execute the script
gg.toast("Running script...")
dofile(tempFile)

-- Script will continue execution from the loaded file
]]
        
        local directPath = baseDir .. "direct_wrapper.lua"
        
        -- Save the direct wrapper
        if saveFile(directWrapper, directPath) then
            gg_toast("Direct version created successfully")
            return true, directPath
        else
            return false
        end
    end
    
    -- Try to download the regular wrapper first
    gg_toast("Downloading wrapper script...")
    local wrapperContent = downloadFile(WRAPPER_URL, "wrapper.lua")
    
    -- If wrapper download failed, try to create direct version
    if not wrapperContent then
        gg_toast("Wrapper download failed, creating direct version")
        return createDirectScript()
    end
    
    -- Try to download config
    gg_toast("Downloading configuration...")
    local configContent = downloadFile(CONFIG_URL, "config.lua")
    
    -- If config download failed, try to create direct version
    if not configContent then
        gg_toast("Config download failed, creating direct version")
        return createDirectScript()
    end
    
    -- Save both files
    local wrapperSaved = saveFile(wrapperContent, wrapperPath)
    local configSaved = saveFile(configContent, configPath)
    
    if not wrapperSaved or not configSaved then
        gg_toast("Failed to save files, creating direct version")
        return createDirectScript()
    end
    
    gg_toast("Files prepared successfully")
    return true, wrapperPath
end

-- Main menu
local function showMainMenu()
    local menu = {"✅ Run Script", "⚒️ Troubleshoot Download", "ℹ️ About", "❌ Exit"}
    
    while true do
        local choice = gg_choice(menu, nil, SCRIPT_NAME .. " v" .. SCRIPT_VERSION)
        
        if choice == 1 then
            -- Run script
            gg_toast("Preparing to run script...")
            local success, scriptPath = prepareFiles()
            
            if success then
                -- Execute the wrapper
                gg_toast("Launching script...")
                gg_sleep(500)
                
                -- Use pcall to handle any errors
                local status, error = pcall(function() dofile(scriptPath) end)
                
                if not status then
                    gg_alert("Error executing script: " .. tostring(error))
                end
            end
            
        elseif choice == 2 then
            -- Troubleshooting options
            local troubleshootMenu = {
                "🔄 Clear Cache & Retry", 
                "📱 Try Direct Version", 
                "📊 Test Network", 
                "⬅️ Back to Main Menu"
            }
            
            local tChoice = gg_choice(troubleshootMenu, nil, "Troubleshooting")
            
            if tChoice == 1 then
                -- Clear cache
                gg_toast("Clearing cache...")
                local baseDir = gg.getFile():gsub("/[^/]+$", "/")
                os.remove(baseDir .. "wrapper.lua")
                os.remove(baseDir .. "config.lua")
                os.remove(baseDir .. "direct_wrapper.lua")
                gg_toast("Cache cleared, retrying download...")
                prepareFiles()
                
            elseif tChoice == 2 then
                -- Try direct version
                gg_toast("Creating direct version...")
                local baseDir = gg.getFile():gsub("/[^/]+$", "/")
                local directPath = baseDir .. "direct_wrapper.lua"
                
                local directWrapper = [[
----------------------------
-- Direct AED Script Wrapper
----------------------------

-- Hide GG immediately
gg.setVisible(false)

-- Download and run the original script
local url = "https://raw.githubusercontent.com/Jordan231111/AED/main/main.lua"
local response = gg.makeRequest(url)

if type(response) ~= "table" or not response.content then
    gg.alert("Failed to download script")
    os.exit()
end

-- Create temp file
local tempFile = gg.getFile():gsub("/[^/]+$", "/temp_script.lua")
local file = io.open(tempFile, "w")
if not file then
    gg.alert("Failed to create temporary file")
    os.exit()
end

file:write(response.content)
file:close()

-- Execute the script
gg.toast("Running script...")
dofile(tempFile)

-- Script will continue execution from the loaded file
]]
                
                -- Save the direct wrapper
                if saveFile(directWrapper, directPath) then
                    gg_toast("Direct version created successfully")
                    
                    -- Run the direct version
                    local status, error = pcall(function() dofile(directPath) end)
                    if not status then
                        gg_alert("Error executing direct script: " .. tostring(error))
                    end
                end
                
            elseif tChoice == 3 then
                -- Test network
                gg_toast("Testing network connection...")
                local testURL = "https://www.google.com"
                local response = gg_makeRequest(testURL)
                
                if type(response) == "table" and response.content and response.content ~= "" then
                    gg_alert("Network connection successful. Try downloading scripts again.")
                else
                    gg_alert("Network connection failed. Please check your internet connection.")
                end
            end
            
        elseif choice == 3 then
            -- About information
            gg_alert(SCRIPT_NAME .. " v" .. SCRIPT_VERSION .. 
                     "\n\nThis tool allows you to use AED functionality without seeing the original code." ..
                     "\n\nThe launcher provides a user-friendly interface while maintaining all features of the original script.")
        elseif choice == 4 then
            -- Exit
            gg_toast("Exiting...")
            os.exit()
            return
        else
            -- No choice or back button
            return
        end
    end
end

-- Main execution
showWelcome()
showMainMenu()

-- Exit cleanly
gg_toast("Thank you for using " .. SCRIPT_NAME)
os.exit()
