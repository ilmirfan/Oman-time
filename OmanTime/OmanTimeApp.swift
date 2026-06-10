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
            EmptyView()
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        formatter.timeZone = TimeZone(identifier: "Asia/Muscat")
        let dateString = formatter.string(from: Date())
        
        menu.addItem(NSMenuItem(title: "Oman Time", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: dateString, action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        // Add Launch at Login toggle
        let launchAtLoginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchAtLoginItem.target = self
        launchAtLoginItem.state = isLaunchAtLoginEnabled() ? .on : .off
        menu.addItem(launchAtLoginItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
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
