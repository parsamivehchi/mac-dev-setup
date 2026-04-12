#!/usr/bin/env bash
set -euo pipefail

# Apply developer-friendly macOS defaults.
# Most changes require a logout or restart to take effect.

echo "  Applying macOS system preferences..."

# --- Dock --------------------------------------------------------------------

# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true

# Set Dock icon size to 36 pixels
defaults write com.apple.dock tilesize -int 36

# Remove the auto-hide delay
defaults write com.apple.dock autohide-delay -float 0

# Speed up the auto-hide animation
defaults write com.apple.dock autohide-time-modifier -float 0.3

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Minimize windows using scale effect
defaults write com.apple.dock mineffect -string "scale"

echo -e "  \033[1;32m✓\033[0m Dock: auto-hide, small icons, no recents"

# --- Finder ------------------------------------------------------------------

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar at the bottom of Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Default to list view in Finder (icnv=icon, Nlsv=list, clmv=column, glyv=gallery)
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show the ~/Library folder
chflags nohidden ~/Library 2>/dev/null || true

echo -e "  \033[1;32m✓\033[0m Finder: extensions, path bar, list view"

# --- Keyboard ----------------------------------------------------------------

# Fast key repeat rate (lower = faster; 2 is very fast)
defaults write NSGlobalDomain KeyRepeat -int 2

# Short delay until key repeat (lower = shorter; 15 is short)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable auto-capitalize
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

echo -e "  \033[1;32m✓\033[0m Keyboard: fast repeat, no auto-correct"

# --- Screenshots -------------------------------------------------------------

# Save screenshots to ~/Screenshots
mkdir -p "${HOME}/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Save screenshots in PNG format
defaults write com.apple.screencapture type -string "png"

# Disable screenshot shadow
defaults write com.apple.screencapture disable-shadow -bool true

echo -e "  \033[1;32m✓\033[0m Screenshots: saved to ~/Screenshots as PNG"

# --- Trackpad / Scrolling ----------------------------------------------------

# Disable natural (reverse) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Enable tap-to-click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

echo -e "  \033[1;32m✓\033[0m Trackpad: natural scroll off, tap-to-click on"

# --- Mission Control ---------------------------------------------------------

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

echo -e "  \033[1;32m✓\033[0m Mission Control: fixed space order"

# --- Restart affected apps ---------------------------------------------------

echo "  Restarting Dock and Finder to apply changes..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

echo -e "  \033[1;32m✓\033[0m macOS defaults applied (some changes need logout/restart)"
