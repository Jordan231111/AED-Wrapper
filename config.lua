----------------------------
-- AED Wrapper Configuration
----------------------------

-- Define global configuration
_G.CONFIG = {
    -- Source configuration (obfuscated)
    sourceType = "dynamic",
    sourceParams = {
        parts = {
            "Z2l0aHViLmNvbS9Kb3JkYW4yMzEx", -- Base domain and user (encoded)
            "MTEvQUVE",                     -- Repository name (encoded)
            "bWFpbi9tYWluLmx1YQ=="          -- Path and filename (encoded)
        },
        protocol = "https",
        mode = "raw",
        format = "base64"
    },
    
    -- Version information
    version = "1.0.0",
    
    -- Script options
    checkUpdates = true,
    obfuscateExecution = true,
    
    -- Security settings 
    validateChecksum = false,
    expectedChecksum = nil,  -- Can be used for script validation
    antiDebug = true,
    obfuscationLevel = 2     -- 1 = minimal, 2 = standard, 3 = maximum
}
