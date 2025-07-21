# Video Resources

This directory contains sample 4K videos that are bundled with the Wallify app.

## Supported Formats
- MP4 (H.264/H.265)
- MOV
- AVI
- MKV
- WebM

## File Naming Convention
Use descriptive names that indicate the content:
- `nature_forest_4k.mp4`
- `ocean_waves_4k.mp4`
- `city_timelapse_4k.mp4`

## Size Considerations
- Keep individual files under 100MB for reasonable app bundle size
- Consider using compressed formats (H.265/HEVC) for better compression
- Test on target devices to ensure smooth playback

## Adding Videos to Xcode Project
1. Drag video files into this Resources folder
2. In Xcode, add them to your target's "Copy Bundle Resources" build phase
3. Ensure "Add to target" is checked for your main app target

## Loading Bundled Videos
The app will automatically detect and load these videos on first launch. 