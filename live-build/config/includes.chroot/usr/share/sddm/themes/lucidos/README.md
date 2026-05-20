# LucidOS SDDM Theme — Starter Placeholder

This is the **starter SDDM login theme** for LucidOS Alpha 0.1.

## Current Status

This is a **placeholder theme** that sets up the correct structure and references the LucidOS wallpaper as the login screen background. The actual QML interface falls back to the Breeze default if `Main.qml` is not fully implemented.

**Alpha 0.2 goal:** Implement a proper Lucid Glass SDDM theme with:
- Custom login card with glass blur effect
- LucidOS branding (original logo SVG)
- Smooth animation on login
- Clock widget with modern typography

## Files in This Theme

```
lucidos/
├── theme.conf        ← Theme configuration (background, colors)
├── Main.qml          ← QML UI for the login screen
├── preview.png       ← Theme preview image (placeholder)
└── README.md         ← This file
```

## How to Apply This Theme

### Method 1: Via /etc/sddm.conf.d (recommended for system-wide)
```bash
# Create the config directory if it doesn't exist
sudo mkdir -p /etc/sddm.conf.d

# Create the configuration file
sudo tee /etc/sddm.conf.d/lucidos.conf << 'EOF'
[Theme]
Theme=lucidos
EOF
```

### Method 2: Via System Settings (GUI)
1. Open **System Settings**
2. Navigate to **Startup and Shutdown** → **Login Screen (SDDM)**
3. Select the **LucidOS** theme
4. Click **Apply**

### Method 3: Via SDDM greeter config file
```bash
sudo nano /etc/sddm.conf
```
Add or modify:
```ini
[Theme]
Theme=lucidos
```

## Testing the Theme

To preview the SDDM theme without logging out:
```bash
# Preview the theme (requires SDDM to be running)
sddm-greeter --test-mode --theme /usr/share/sddm/themes/lucidos
```

## Developing the Theme (Alpha 0.2)

SDDM themes use QML (Qt Modeling Language). To improve this theme:

1. Study the Breeze SDDM theme as a reference:
   ```bash
   ls /usr/share/sddm/themes/breeze/
   ```

2. Edit `Main.qml` to add custom elements

3. Test changes with:
   ```bash
   sddm-greeter --test-mode --theme /usr/share/sddm/themes/lucidos
   ```

4. Resources:
   - SDDM theme documentation: https://github.com/sddm/sddm/wiki/Theming
   - QML documentation: https://doc.qt.io/qt-5/qmlapplications.html
   - KDE Plasma SDDM themes: https://store.kde.org/browse/cat/101/

## Color Palette Reference

Use these colors when developing the theme to maintain consistency with the Lucid Glass identity:

| Name | Hex | Usage |
|------|-----|-------|
| Night base | `#060914` | Background, dark panels |
| Midnight blue | `#0a1128` | Secondary background |
| Glass indigo | `#3730a3` | Primary accent |
| Teal glass | `#0d9488` | Secondary accent |
| Soft violet | `#7c3aed` | Highlight accent |
| Cyan light | `#06b6d4` | Focus rings, active states |
| Glass white | `#e0e7ff` | Text, icons |
| Muted text | `#94a3b8` | Secondary text |
