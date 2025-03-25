# AED Wrapper

This repository contains a wrapper script for the AED tool that maintains full functionality while hiding implementation details. The wrapper automatically downloads and executes the original script without revealing its code to users.

## Features

- Maintains same speed and performance as the original script
- Hides implementation details from users
- Automatically downloads the latest version of the script
- Simple configuration through config.lua

## Usage

1. Download the `wrapper.lua` and `config.lua` files
2. Run the `wrapper.lua` script in GameGuardian
3. The wrapper will automatically download and execute the original script

## Configuration

You can modify the `config.lua` file to change various settings:

- `scriptURL`: The URL to the raw Lua script on GitHub
- `checkUpdates`: Whether to check for updates on startup
- `validateChecksum`: Enable checksum validation for additional security

## Notes

- The wrapper maintains all functionality of the original script
- Automatically cleans up temporary files after execution
- Includes error handling for improved reliability
