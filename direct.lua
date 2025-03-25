----------------------------
-- Secure Execution Environment
-- Maximum security with memory execution
----------------------------

-- Cache gg functions for speed
local gg_toast = gg.toast
local gg_alert = gg.alert
local gg_setVisible = gg.setVisible
local gg_makeRequest = gg.makeRequest
local gg_sleep = gg.sleep
local gg_choice = gg.choice

-- State tracking
local isRunning = true
local errorOccurred = false
local cleanupInterval = 500 -- milliseconds
local lastCleanupTime = os.time()
local tempFilePath = nil

-- Secure temporary file path generation
local function generateSecurePath()
    -- Get the GameGuardian directory
    local ggDir = gg.getFile():gsub("/[^/]+$", "/")
    
    -- Create a unique but non-descriptive filename
    -- Using 8 random hex characters
    local randomChars = ""
    for i = 1, 8 do
        randomChars = randomChars .. string.format("%x", math.random(0, 15))
    end
    
    -- Hidden prefix to make it harder to spot
    return ggDir .. "." .. randomChars .. ".tmp"
end

-- Hide GG immediately
gg_setVisible(false)

-- Show a simple menu that doesn't reveal purpose
local function showMenu()
    local menu = {"▶️ Start", "❌ Exit"}
    local choice = gg_choice(menu, nil, "Quick Launcher")
    
    if choice == 2 or choice == nil then
        gg_toast("Exiting...")
        os.exit()
    end
end

-- Show menu first
showMenu()

-- Display minimal loading message
gg_toast("Initializing...")

-- Obfuscated URL components
local urlComponents = {
    protocol = "https",
    domain = {
        "raw", "githubusercontent", "com"
    },
    path = {
        "Jordan231111", "AED", "main", "main.lua"
    }
}

-- Build URL without revealing it
local function buildSecureUrl()
    local url = urlComponents.protocol .. "://"
    url = url .. table.concat(urlComponents.domain, ".")
    url = url .. "/"
    url = url .. table.concat(urlComponents.path, "/")
    
    -- Add cache-busting parameters that look generic
    url = url .. "?v=" .. math.random(100000, 999999)
    
    return url
end

-- Download content securely
local function downloadSecurely()
    local url = buildSecureUrl()
    
    -- Random loading messages
    local messages = {
        "Processing...",
        "Please wait...",
        "Working...",
        "Preparing environment..."
    }
    gg_toast(messages[math.random(1, #messages)])
    
    -- Perform request
    local response = gg_makeRequest(url)
    
    -- Validate response
    if type(response) ~= "table" or not response.content or response.content == "" then
        errorOccurred = true
        gg_alert("Connection error. Please check network and try again.")
        return nil
    end
    
    return response.content
end

-- Create temporary file with secure practices
local function createTempFile(content)
    if not content then return false end
    
    -- Generate secure path
    tempFilePath = generateSecurePath()
    
    -- Create file with error handling
    local success, err = pcall(function()
        local file = io.open(tempFilePath, "w")
        if not file then error("Failed to create temporary file") end
        file:write(content)
        file:close()
    end)
    
    if not success then
        errorOccurred = true
        gg_alert("Initialization error. Please try again.")
        return false
    end
    
    return true
end

-- Cleanup function
local function secureCleaner()
    if not tempFilePath then return end
    
    -- Use pcall to ensure errors don't stop execution
    pcall(function()
        -- Check if file exists
        local f = io.open(tempFilePath, "r")
        if f then
            f:close()
            os.remove(tempFilePath)
        end
        tempFilePath = nil
    end)
end

-- Setup background cleaner
local function backgroundCleanup()
    if not isRunning then return end
    
    local currentTime = os.time()
    if currentTime - lastCleanupTime >= 1 then
        lastCleanupTime = currentTime
        secureCleaner()
    end
    
    -- Reschedule if still running
    if isRunning then
        gg.setTimeout(backgroundCleanup, cleanupInterval)
    end
end

-- Override os.exit
local oldExit = os.exit
os.exit = function(code)
    isRunning = false
    secureCleaner()
    oldExit(code or 0)
end

-- Run a secure execution context
local function secureExecution()
    -- Start background cleaner
    gg.setTimeout(backgroundCleanup, cleanupInterval)
    
    -- Download content
    local content = downloadSecurely()
    if not content then return false end
    
    -- Create temp file
    if not createTempFile(content) then return false end
    
    -- Load the file
    local scriptFunc, loadErr = loadfile(tempFilePath)
    
    if not scriptFunc then
        errorOccurred = true
        gg_alert("Loading error.")
        secureCleaner()
        return false
    end
    
    -- Use protected call to execute
    gg_toast("Starting...")
    
    -- Execute script with isolated environment for extra security
    local env = setmetatable({}, {__index = _G})
    setfenv(scriptFunc, env)
    
    local success, execErr = pcall(scriptFunc)
    
    if not success and not errorOccurred then
        errorOccurred = true
        gg_toast("Execution error. Try again.")
    end
    
    return success
end

-- Error handler
local function errorHandler(err)
    isRunning = false
    
    -- Clean up
    secureCleaner()
    
    -- Only show error if it hasn't been shown
    if not errorOccurred then
        errorOccurred = true
        gg_toast("Process error. Try again.")
    end
    
    return err
end

-- Run with maximum protection
xpcall(secureExecution, errorHandler)

-- Ensure cleanup when script ends
isRunning = false
secureCleaner()
