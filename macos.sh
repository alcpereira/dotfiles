#!/usr/bin/env bash

# macOS Configuration Script
# Run this once on a fresh macOS install to configure system preferences

set -e

echo "Configuring macOS settings..."
echo ""

# Close System Settings/Preferences to prevent overriding settings
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || osascript -e 'tell application "System Preferences" to quit' 2>/dev/null

###############################################################################
# Dock                                                                        #
###############################################################################

echo "→ Configuring Dock..."

# Enable autohide
defaults write com.apple.dock autohide -bool true

# Remove autohide delay (instant show)
defaults write com.apple.dock autohide-delay -float 0

# Speed up autohide animation
defaults write com.apple.dock autohide-time-modifier -float 0.01

# Set icon size to 52 pixels
defaults write com.apple.dock tilesize -int 52

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

###############################################################################
# Keyboard                                                                    #
###############################################################################

echo "→ Configuring Keyboard..."

# Set key repeat rate (2 = fast)
defaults write NSGlobalDomain KeyRepeat -int 2

# Set delay until key repeat (15 = short)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

###############################################################################
# Trackpad                                                                    #
###############################################################################

echo "→ Configuring Trackpad..."

# Enable tap to click for this user and login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad speed
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 0.875

###############################################################################
# Finder                                                                      #
###############################################################################

echo "→ Configuring Finder..."

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Use list view by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Show Library folder
chflags nohidden ~/Library

###############################################################################
# System                                                                      #
###############################################################################

echo "→ Configuring System..."

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Finish                                                                      #
###############################################################################

echo ""
echo "→ Restarting affected applications..."

# Restart affected applications
killall Dock
killall Finder
killall SystemUIServer 2>/dev/null || true

echo ""
echo "✓ Done! Some changes may require a logout/restart to take effect."
