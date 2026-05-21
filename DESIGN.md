# Design

## Theme

Lucid Linux Alpha 0.2 is used during installation, first boot, and early desktop exploration, often inside a VM or on a fresh machine where the user is deciding whether the system feels trustworthy. The scene is a dim-to-neutral desktop environment with a cinematic glass wallpaper, clear controls, and calm onboarding. The default theme is dark with luminous accents because the system is meant to feel focused at boot, login, terminal, and installer time.

## Color

Use a restrained product palette with tinted dark neutrals and cool luminous accents.

- Surface: `oklch(0.17 0.02 255)`
- Surface raised: `oklch(0.23 0.025 255)`
- Surface glass: `oklch(0.24 0.035 250 / 0.78)`
- Text primary: `oklch(0.92 0.01 250)`
- Text secondary: `oklch(0.72 0.025 250)`
- Accent cyan: `oklch(0.78 0.13 215)`
- Accent violet: `oklch(0.68 0.16 285)`
- Success: `oklch(0.72 0.13 165)`
- Warning: `oklch(0.78 0.13 75)`
- Error: `oklch(0.68 0.17 25)`

Do not use pure black or pure white. Keep saturated accents for selection, focus, primary actions, logo glow, and small boot/login highlights.

## Typography

Use Noto Sans for system UI and Hack for terminal. Keep the hierarchy compact: large clock/login text can be expressive, but labels, buttons, launchers, and onboarding copy should use predictable product UI sizing.

## Layout

Use a macOS-inspired structure without copying proprietary details:

- top panel for status and session controls
- centered bottom dock-style panel for primary apps
- clean desktop with minimal icons
- left-side window controls
- restrained glass login and onboarding panels
- no nested cards

## Components

Buttons are rounded rectangles with clear hover/focus states. Login fields and onboarding prompts use stable dimensions and readable labels. Terminal onboarding uses ASCII art, concise copy, and plain choices that work without graphics.

## Motion

Use KDE-native blur, fades, and shadows only where stable. Motion should communicate state changes, not decorate. The system must remain usable with effects disabled.

## Assets

Logo direction: original geometric prism or aperture mark with a Lucid `L` signal. Wallpaper direction: original cinematic glass landscape or aurora-prism vista, quiet enough for desktop readability. No Apple-like fruit marks, no copied mountains, no proprietary screenshots.
