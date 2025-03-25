----------------------------
-- AED Script Launcher
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

-- Function to download a file from URL
local function downloadFile(url, filename)
    gg_toast("Downloading " .. filename .. "...")
    
    -- Add timestamp parameter to prevent caching
    local uniqueURL = url .. "?t=" .. os.time()
    
    -- Download the file
    local response = gg_makeRequest(uniqueURL)
    
    if type(response) ~= "table" or not response.content then
        gg_alert("Failed to download " .. filename)
        return nil
    end
    
    return response.content
end

-- Function to save content to a file
local function saveFile(content, filename)
    local file = io.open(filename, "w")
    if not file then
        gg_alert("Failed to create file: " .. filename)
        return false
    end
    
    file:write(content)
    file:close()
    
    return true
end

-- Function to check and download required files
local function prepareFiles()
    -- Get base directory from launcher location
    local baseDir = gg.getFile():gsub("/[^/]+$", "/")
    
    -- Define file paths
    local wrapperPath = baseDir .. "wrapper.lua"
    local configPath = baseDir .. "config.lua"
    
    -- Download wrapper script
    local wrapperContent = downloadFile(WRAPPER_URL, "wrapper.lua")
    if not wrapperContent then
        return false
    end
    
    -- Download config file
    local configContent = downloadFile(CONFIG_URL, "config.lua")
    if not configContent then
        return false
    end
    
    -- Save files
    if not saveFile(wrapperContent, wrapperPath) then
        return false
    end
    
    if not saveFile(configContent, configPath) then
        return false
    end
    
    gg_toast("Files prepared successfully")
    return true, wrapperPath
end

-- Main menu
local function showMainMenu()
    local menu = {"✅ Run Script", "ℹ️ About", "❌ Exit"}
    
    while true do
        local choice = gg_choice(menu, nil, SCRIPT_NAME .. " v" .. SCRIPT_VERSION)
        
        if choice == 1 then
            -- Run script
            gg_toast("Preparing to run script...")
            local success, wrapperPath = prepareFiles()
            
            if success then
                -- Execute the wrapper
                gg_toast("Launching script...")
                gg_sleep(500)
                
                -- Use pcall to handle any errors
                local status, error = pcall(function() dofile(wrapperPath) end)
                
                if not status then
                    gg_alert("Error executing script: " .. tostring(error))
                end
            end
            
            -- Script is running or failed, return to menu
            
        elseif choice == 2 then
            -- About information
            gg_alert(SCRIPT_NAME .. " v" .. SCRIPT_VERSION .. 
                     "\n\nThis tool allows you to use AED functionality without seeing the original code." ..
                     "\n\nThe launcher provides a user-friendly interface while maintaining all features of the original script.")
        elseif choice == 3 then
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
