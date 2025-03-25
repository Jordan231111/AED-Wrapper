----------------------------
-- AED Wrapper Configuration
----------------------------

-- Define global configuration
_G.CONFIG = {
    -- URL to the raw Lua script on GitHub
    scriptURL = "https://raw.githubusercontent.com/Jordan231111/AED/main/main.lua",
    
    -- Version information
    version = "1.0.0",
    
    -- Add other configuration options as needed
    checkUpdates = true,
    
    -- Additional security checks
    validateChecksum = false,
    expectedChecksum = nil  -- Can be used for script validation
}
