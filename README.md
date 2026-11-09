# OmanTime 🇴🇲

A simple macOS menu bar app that displays the current time in Oman (Gulf Standard Time, UTC+4).

## Features

- 🇴🇲 Shows Oman time in the menu bar (HH:mm format)
- 🌐 Displays additional custom world clocks in the dropdown menu (e.g. Philippines, UK, Singapore, etc.)
- ⚙️ Settings window to add, remove, and reorder clocks with time zone search and quick presets
- 📅 Displays full date and offset relative to Oman time on click
- 🚀 Launch at Login option
- ⚡️ Lightweight and native macOS app
- 🎯 Menu bar only (doesn't appear in Dock)
- 🌍 Works correctly regardless of your Mac's location

## Installation

### From DMG (Recommended)
1. Download the latest DMG from [Releases](../../releases)
2. Mount the DMG file
3. Drag `OmanTime.app` to your Applications folder
4. **Important**: Right-click the app and select "Open" the first time (this bypasses Gatekeeper for unsigned apps)
5. Enable "Launch at Login" from the menu bar icon if desired

### Manual Installation on Other Macs
If you get a security warning:
- **Method 1**: Right-click the app → "Open" → Click "Open" in the dialog
- **Method 2**: System Settings → Privacy & Security → Click "Open Anyway"
- **Method 3**: Terminal command: `xattr -cr /Applications/OmanTime.app`

## Building from Source

### Requirements
- macOS 13.0 or later
- Xcode 14.0 or later
- Swift 5.0+
