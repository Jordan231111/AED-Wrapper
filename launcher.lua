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

-- Obfuscated wrapper URL (Base64 encoded parts)
local WRAPPER_URL_PARTS = {
    "aHR0cHM6Ly9yYXcuZ2l0aHVidX", -- Part 1
    "Nlcm",                       -- Part 2
    "NvbnRlbnQuY29tL0pvcmR",      -- Part 3
    "hbjIzMTExMS9BRUQtV3JhcHBlci9tYWlu", -- Part 4
    "L3dyYXBwZXIubHVh"            -- Part 5
}

-- Obfuscated config URL (Base64 encoded parts)
local CONFIG_URL_PARTS = {
    "aHR0cHM6Ly9yYXcuZ2l0aHVidX", -- Part 1
    "Nlcm",                       -- Part 2
    "NvbnRlbnQuY29tL0pvcmR",      -- Part 3
    "hbjIzMTExMS9BRUQtV3JhcHBlci9tYWlu", -- Part 4
    "L2NvbmZpZy5sdWE="            -- Part 5
}

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

-- Function to build URL from encoded parts
local function buildURL(parts)
    local url = ""
    for _, part in ipairs(parts) do
        url = url .. decodeBase64(part)
    end
    return url
end

-- Construct full URLs
local WRAPPER_URL = buildURL(WRAPPER_URL_PARTS)
local CONFIG_URL = buildURL(CONFIG_URL_PARTS)

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
