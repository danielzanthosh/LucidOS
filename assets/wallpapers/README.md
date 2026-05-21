# Lucid Linux Wallpapers

This directory documents wallpaper assets for Lucid Linux.

## Current Wallpapers

| File | Description | Status |
|------|-------------|--------|
| `lucid-wallpaper.svg` | Original Lucid Linux Alpha 0.2 glass/prism vista | Deployed to `/usr/share/backgrounds/` |

The primary wallpaper is located in the live-build includes:

```txt
live-build/config/includes.chroot/usr/share/backgrounds/lucid-wallpaper.svg
```

## Alpha 0.2 Asset Policy

Alpha 0.2 wallpapers are original Lucid Linux assets. They are macOS-inspired only in mood and broad desktop layout: quiet, cinematic, glassy, and readable behind desktop controls. They do not include Apple marks, copied macOS wallpapers, copied mountains, proprietary UI marks, stock imagery, or copied third-party artwork.

## Design Guidelines for Future Wallpapers

### Allowed

- Original abstract or cinematic glass/prism scenes.
- Restrained dark glass palette with cyan and violet accents.
- Readable corners and a lower horizon so desktop panels, docks, and icons remain legible.
- SVG format for resolution independence, or high-res PNG at 3840x2160 minimum.
- Dark themes that work well with KDE Breeze Dark.

### Not Allowed

- Apple logos, fruit shapes, macOS wallpapers, or Apple-branded assets.
- Copied mountains, copied wallpaper compositions, or proprietary screenshots.
- Copyrighted photographs without proper licensing.
- Third-party brand logos.
- Stock photos without verified Creative Commons or public domain licensing.

## How to Add a New Wallpaper

1. Create the wallpaper file as original artwork.
2. Copy it to `live-build/config/includes.chroot/usr/share/backgrounds/`.
3. It will be available in KDE System Settings > Desktop Wallpaper.
4. To make it the default, update the hook or skel config.

## Wallpaper Resolution

The recommended target resolution for Alpha 0.2 source artwork is 3840x2160.
