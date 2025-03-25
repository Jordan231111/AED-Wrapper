# AED Wrapper

This repository contains a wrapper solution for the AED tool that maintains full functionality while hiding implementation details. The wrapper automatically downloads and executes the original script without revealing its code to users.

## Features

- **Code Protection**: Hides the original script code from users
- **Same Performance**: Maintains identical speed and functionality as the original script
- **Auto-Updates**: Automatically downloads the latest version of the script
- **User-Friendly**: Includes a launcher with a clean interface
- **Security Features**: Additional protection against tampering
- **Error Handling**: Robust error handling for improved reliability

## Repository Contents

- **wrapper.lua** - The core wrapper script that downloads and executes the original script
- **config.lua** - Configuration file for customizing the wrapper behavior
- **launcher.lua** - User-friendly launcher with a menu interface
- **security.lua** - Security module with additional protection features

## Usage Options

### Option 1: Using the Launcher (Recommended)

1. Download only the `launcher.lua` file
2. Run the launcher in GameGuardian
3. The launcher will automatically download all necessary files and execute the script

### Option 2: Manual Setup

1. Download the `wrapper.lua` and `config.lua` files
2. Place both files in the same directory
3. Run the `wrapper.lua` script in GameGuardian

## How It Works

1. The wrapper downloads the original script from GitHub
2. It creates a temporary file with the script content
3. The script is executed with all original functionality intact
4. When execution completes, the temporary file is deleted

## Security Features

- **Script Obfuscation**: Prevents users from examining the original code
- **Anti-Debugging**: Detects attempts to debug or tamper with the script
- **Checksum Verification**: Optional validation of script integrity
- **Clean Execution**: Temporary files are automatically removed

## Customization

You can modify the `config.lua` file to change various settings:

- `scriptURL`: The URL to the raw Lua script on GitHub
- `checkUpdates`: Whether to check for updates on startup
- `validateChecksum`: Enable checksum validation for additional security

## Advanced Usage

For developers who want to extend the wrapper, the following components can be modified:

- **Security Module**: Add custom security features by modifying `security.lua`
- **Launcher**: Customize the user interface by editing `launcher.lua`
- **Config**: Add additional configuration options in `config.lua`

## Notes

- The wrapper runs the original script with the exact same speed and performance
- All features of the original script are maintained
- Users only interact with the wrapper, not the original script
- The solution is designed to be maintainable and extensible
