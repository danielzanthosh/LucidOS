# LucidOS Wallpapers

This directory contains wallpapers for LucidOS.

## Current Wallpapers

| File | Description | Status |
|------|-------------|--------|
| `lucidos-wallpaper.svg` | Main Lucid Glass abstract wallpaper | âœ… Deployed to `/usr/share/backgrounds/` |

The primary wallpaper is located in the live-build includes:
```
live-build/config/includes.chroot/usr/share/backgrounds/lucidos-wallpaper.svg
```

## Design Guidelines for Future Wallpapers

All LucidOS wallpapers must follow these guidelines:

### âœ… Allowed
- Original abstract designs (gradients, geometric shapes, particle effects)
- Color palette from the Lucid Glass identity (navy, indigo, teal, violet, cyan)
- SVG format for resolution independence, or high-res PNG (3840Ã—2160 minimum)
- Dark themes that work well with KDE Breeze Dark

### âŒ Not Allowed
- Apple logos, macOS wallpapers, or any Apple-branded assets
- Copyrighted photographs without proper licensing
- Third-party brand logos
- Stock photos without verified Creative Commons or public domain license

## How to Add a New Wallpaper

1. Create the wallpaper file (SVG or PNG)
2. Copy it to `live-build/config/includes.chroot/usr/share/backgrounds/`
3. It will automatically be available in KDE System Settings â†’ Desktop Wallpaper
4. To make it the default, update the hook or skel config

## Wallpaper Resolutions

For best compatibility, provide wallpapers at:
- 1920Ã—1080 (Full HD)
- 2560Ã—1440 (QHD)
- 3840Ã—2160 (4K UHD) â€” recommended target resolution for SVG source

## Color Palette Reference

```
Background deep:   #060914 (Night black)
Background mid:    #0a1128 (Midnight blue)
Primary accent:    #3730a3 (Glass indigo)
Secondary accent:  #0d9488 (Glass teal)
Tertiary accent:   #7c3aed (Soft violet)
Highlight:         #06b6d4 (Luminous cyan)
Text/particle:     #e0e7ff (Ghost white)
```
