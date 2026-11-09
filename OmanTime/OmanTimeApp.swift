//
//  OmanTimeApp.swift
//  OmanTime
//
//  Created by Irfan Ishak on 2026-05-20.
//

import SwiftUI
import AppKit
import ServiceManagement

@main
struct OmanTimeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var timer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            updateTime()
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }
        
        // Update time every minute (no need for seconds)
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }
    
    @objc func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(identifier: "Asia/Muscat")
        
        let timeString = formatter.string(from: Date())
        statusItem?.button?.title = "🇴🇲 \(timeString)"
    }
    
    @objc func statusBarButtonClicked() {
        // Create menu
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        let is24Hour = ClockManager.shared.use24HourFormat
        
        // Oman Time (Primary status bar clock)
        let omanTimeFormatter = DateFormatter()
        omanTimeFormatter.dateFormat = is24Hour ? "HH:mm" : "h:mm a"
        omanTimeFormatter.timeZone = TimeZone(identifier: "Asia/Muscat")
        let omanTimeStr = omanTimeFormatter.string(from: Date())
        
        let omanDateFormatter = DateFormatter()
        omanDateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        omanDateFormatter.timeZone = TimeZone(identifier: "Asia/Muscat")
        let omanDateStr = omanDateFormatter.string(from: Date())
        
        let omanTitleItem = NSMenuItem(title: "🇴🇲 Oman  \(omanTimeStr)", action: nil, keyEquivalent: "")
        omanTitleItem.attributedTitle = NSAttributedString(
            string: "🇴🇲 Oman  \(omanTimeStr)",
            attributes: [
                .font: NSFont.boldSystemFont(ofSize: 13),
                .foregroundColor: NSColor.labelColor
            ]
        )
        omanTitleItem.isEnabled = true
        menu.addItem(omanTitleItem)
        
        let omanDateItem = NSMenuItem(title: "    \(omanDateStr) (UTC+4)", action: nil, keyEquivalent: "")
        omanDateItem.isEnabled = false
        menu.addItem(omanDateItem)
        
        // Additional configured clocks
        if !ClockManager.shared.clocks.isEmpty {
            menu.addItem(NSMenuItem.separator())
            
            for clock in ClockManager.shared.clocks {
                let timeStr = clock.currentTimeString(is24Hour: is24Hour)
                let dateStr = clock.currentDateString()
                let offsetStr = clock.offsetRelativeToOman()
                let emoji = clock.emoji.trimmingCharacters(in: .whitespaces).isEmpty ? "🕒" : clock.emoji
                
                let title = "\(emoji) \(clock.name)  \(timeStr)"
                let clockItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                clockItem.attributedTitle = NSAttributedString(
                    string: title,
                    attributes: [
                        .font: NSFont.systemFont(ofSize: 13, weight: .medium),
                        .foregroundColor: NSColor.labelColor
                    ]
                )
                clockItem.isEnabled = true
                menu.addItem(clockItem)
                
                let detailText = offsetStr.isEmpty ? "    \(dateStr)" : "    \(dateStr) (\(offsetStr))"
                let detailItem = NSMenuItem(title: detailText, action: nil, keyEquivalent: "")
                detailItem.isEnabled = false
                menu.addItem(detailItem)
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Settings item
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        settingsItem.isEnabled = true
        menu.addItem(settingsItem)
        
        // Launch at Login toggle
        let launchAtLoginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        launchAtLoginItem.state = isLaunchAtLoginEnabled() ? .on : .off
        launchAtLoginItem.isEnabled = true
        menu.addItem(launchAtLoginItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit OmanTime", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        quitItem.isEnabled = true
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    @objc func openSettings() {
        SettingsWindowController.shared.show()
    }
    
    @objc func toggleLaunchAtLogin() {
        let service = SMAppService.mainApp
        let currentStatus = service.status
        
        do {
            if currentStatus == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            print("Failed to toggle launch at login: \(error)")
        }
    }
    
    func isLaunchAtLoginEnabled() -> Bool {
        let service = SMAppService.mainApp
        return service.status == .enabled
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
