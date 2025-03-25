----------------------------
-- AED Wrapper Configuration (Fixed Version)
----------------------------

-- Define global configuration
_G.CONFIG = {
    -- Source configuration - simplified for reliability
    sourceType = "direct",
    sourceParams = {
        protocol = "https",
        mode = "raw",
        format = "plain"
    },
    
    -- Direct source URL as backup
    directSourceURL = "https://raw.githubusercontent.com/Jordan231111/AED/main/main.lua",
    
    -- Version information
    version = "1.0.0",
    
    -- Script options
    checkUpdates = true,
    obfuscateExecution = true,
    
    -- Security settings 
    validateChecksum = false,
    expectedChecksum = nil,  -- Can be used for script validation
    antiDebug = true,
    obfuscationLevel = 1     -- Reduced for reliability (1 = minimal, 2 = standard, 3 = maximum)
}

-- Override the config to use direct access for improved reliability
_G.CONFIG.sourceType = "direct"
