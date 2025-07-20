# Wallify Installer Build

This directory contains the build script to create release installers for Wallify.

## Quick Start

To build all installer formats:

```bash
./build_installer.sh
```

This will create:
- `build/Wallify.app` - Standalone application
- `build/Wallify.pkg` - Package installer (3.3MB)
- `build/Wallify.zip` - Compressed archive (3.3MB)  
- `build/Wallify-Installer.dmg` - DMG installer (112MB)

## Prerequisites

- Xcode with Command Line Tools
- `create-dmg` (installed via `brew install create-dmg`)

## Usage

The `build_installer.sh` script will:
1. Clean previous builds
2. Build the app in Release mode
3. Create all installer formats
4. Generate a release summary

## Distribution

- **For end users**: Use `Wallify-Installer.dmg`
- **For system administrators**: Use `Wallify.pkg`
- **For developers**: Use `Wallify.zip` or `Wallify.app` 