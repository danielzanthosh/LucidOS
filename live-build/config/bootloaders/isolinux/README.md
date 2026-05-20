# LucidOS isolinux Bootloader Configuration Placeholder
# =============================================================================
# This directory holds customizations for the isolinux bootloader.
# isolinux is used for BIOS (legacy) boot mode.
#
# For LucidOS Alpha 0.1, we use the default live-build isolinux configuration.
# Custom isolinux branding (boot screen, menu colors) is planned for Alpha 0.2.
#
# How live-build uses this directory:
# - Files placed here override the default isolinux files
# - You can add custom isolinux.cfg, splash.png, or other bootloader assets
#
# What to add here for Alpha 0.2:
# 1. A custom splash screen (splash.png â€” 640x480 PNG, 16-color indexed)
# 2. Custom isolinux.cfg with LucidOS menu entries
# 3. Custom color scheme for the boot menu
#
# Documentation:
# - live-build bootloader docs: man lb_config â†’ --bootloaders
# - isolinux docs: https://wiki.syslinux.org/wiki/index.php?title=ISOLINUX
#
# Currently live-build auto-generates:
# - isolinux.cfg (menu with "Live" and "Live (failsafe)" entries)
# - Default Syslinux theme
#
# To customize the boot menu entries in the future, create:
# isolinux/isolinux.cfg in this directory with custom content.
# =============================================================================
#
# TODO (Alpha 0.2): Add custom boot splash and LucidOS-branded menu
