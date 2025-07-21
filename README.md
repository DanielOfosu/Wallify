# Wallify

A macOS app that lets you set video files as your desktop wallpaper.

> ⚠️ **Warning**  
> We don't have an Apple Developer account yet. The application will show a popup on first start. Click Okay, then, go to Settings / Privacy & Security and scroll down until you see a button called Open anyway. You'll only have to do this once.
> 
## Features

- Set any video file as your desktop wallpaper
- Drag and drop support for video files
- Menu bar quick access
- Recent wallpapers management
- Customizable playback settings
- True black background support

## Installation

### For Users

1. Download the latest release from the [Releases page](https://github.com/yourusername/wallify/releases)
2. Open `Wallify-Installer.dmg`
3. Drag Wallify to your Applications folder
4. Launch Wallify from Applications

### For Developers

```bash
# Clone the repository
git clone https://github.com/yourusername/wallify.git
cd wallify

# Open in Xcode
open Wallify.xcodeproj

# Build and run
xcodebuild -project Wallify.xcodeproj -scheme Wallify -configuration Debug
```

## Usage

1. Launch Wallify from your Applications folder
2. Click "Select New Video..." or drag and drop a video file
3. Adjust settings in the preferences panel
4. Use the menu bar icon for quick access

### Supported Formats

- MP4 (H.264, H.265)
- MOV
- AVI
- MKV
- WebM

## Requirements

- macOS 12.0 (Monterey) or later
- Xcode 14.0 or later (for development)

## Building

```bash
# Build release version
./build_installer.sh

# This creates:
# - build/Wallify.app (standalone app)
# - build/Wallify.pkg (package installer)
# - build/Wallify.zip (compressed archive)
# - build/Wallify-Installer.dmg (DMG installer)
```

## Contributing

We welcome contributions! Please open an issue or pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Roadmap

TBD 
