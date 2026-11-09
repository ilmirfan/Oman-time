//
//  SettingsView.swift
//  OmanTime
//
//  Created by Irfan Ishak on 2026-11-09.
//

import SwiftUI
import Combine
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var clockManager = ClockManager.shared
    @State private var showingAddSheet = false
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack(spacing: 12) {
                Text("🇴🇲")
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: 2) {
                    Text("OmanTime Settings")
                        .font(.headline)
                    Text("Oman time is always displayed in your menu bar.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Additional Clocks Section
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Menu Clocks")
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                            Button {
                                showingAddSheet = true
                            } label: {
                                Label("Add Clock", systemImage: "plus")
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)
                        }
                        
                        Text("These clocks appear in the dropdown menu when clicking the menu bar icon.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if clockManager.clocks.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "clock.badge.questionmark")
                                    .font(.system(size: 28))
                                    .foregroundColor(.secondary)
                                Text("No additional clocks added yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Button("Add a clock") {
                                    showingAddSheet = true
                                }
                                .buttonStyle(.link)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(NSColor.controlBackgroundColor).opacity(0.5))
                            )
                        } else {
                            VStack(spacing: 8) {
                                ForEach(Array(clockManager.clocks.enumerated()), id: \.element.id) { index, clock in
                                    ClockRowView(
                                        clock: clock,
                                        is24Hour: clockManager.use24HourFormat,
                                        isFirst: index == 0,
                                        isLast: index == clockManager.clocks.count - 1,
                                        onMoveUp: {
                                            if index > 0 {
                                                clockManager.clocks.swapAt(index, index - 1)
                                            }
                                        },
                                        onMoveDown: {
                                            if index < clockManager.clocks.count - 1 {
                                                clockManager.clocks.swapAt(index, index + 1)
                                            }
                                        },
                                        onDelete: {
                                            clockManager.removeClock(id: clock.id)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Preferences Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preferences")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Toggle("Use 24-hour time format in menu", isOn: $clockManager.use24HourFormat)
                            .toggleStyle(.checkbox)
                        
                        Toggle("Launch at Login", isOn: Binding(
                            get: { launchAtLogin },
                            set: { newValue in
                                toggleLaunchAtLogin(enabled: newValue)
                            }
                        ))
                        .toggleStyle(.checkbox)
                    }
                }
                .padding()
            }
        }
        .frame(width: 520, height: 500)
        .sheet(isPresented: $showingAddSheet) {
            AddClockSheet(isPresented: $showingAddSheet)
        }
        .onReceive(timer) { input in
            currentTime = input
        }
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
    
    private func toggleLaunchAtLogin(enabled: Bool) {
        let service = SMAppService.mainApp
        do {
            if enabled {
                try service.register()
                launchAtLogin = true
            } else {
                try service.unregister()
                launchAtLogin = false
            }
        } catch {
            print("Failed to toggle launch at login: \(error)")
            launchAtLogin = service.status == .enabled
        }
    }
}

// MARK: - Clock Row View
struct ClockRowView: View {
    let clock: WorldClock
    let is24Hour: Bool
    let isFirst: Bool
    let isLast: Bool
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text(clock.emoji.isEmpty ? "🕒" : clock.emoji)
                .font(.system(size: 24))
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(clock.name)
                        .font(.system(size: 13, weight: .semibold))
                    Text(clock.gmtOffsetString())
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.secondary.opacity(0.15))
                        .cornerRadius(4)
                }
                
                Text("\(clock.timeZoneIdentifier) • \(clock.offsetRelativeToOman())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(clock.currentTimeString(is24Hour: is24Hour))
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .padding(.trailing, 4)
            
            HStack(spacing: 4) {
                Button(action: onMoveUp) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 10, weight: .semibold))
                }
                .buttonStyle(.plain)
                .disabled(isFirst)
                .opacity(isFirst ? 0.3 : 0.8)
                .help("Move Up")
                
                Button(action: onMoveDown) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                }
                .buttonStyle(.plain)
                .disabled(isLast)
                .opacity(isLast ? 0.3 : 0.8)
                .help("Move Down")
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .padding(.leading, 4)
                .help("Delete Clock")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Add Clock Sheet
struct AddClockSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var clockManager = ClockManager.shared
    
    @State private var name: String = ""
    @State private var emoji: String = "🕒"
    @State private var selectedTimeZoneId: String = "Asia/Manila"
    @State private var searchText: String = ""
    
    // Cached timezone options
    private let timeZoneOptions: [TimeZoneItem] = {
        let identifiers = TimeZone.knownTimeZoneIdentifiers.sorted()
        return identifiers.map { id in
            let tz = TimeZone(identifier: id) ?? TimeZone.current
            let seconds = tz.secondsFromGMT()
            let hours = seconds / 3600
            let minutes = abs((seconds % 3600) / 60)
            let sign = hours >= 0 ? "+" : "-"
            let gmtStr = minutes == 0 ? "UTC\(sign)\(abs(hours))" : String(format: "UTC%@%d:%02d", sign, abs(hours), minutes)
            
            let components = id.split(separator: "/")
            let city = components.dropFirst().joined(separator: " - ").replacingOccurrences(of: "_", with: " ")
            let region = String(components.first ?? "").replacingOccurrences(of: "_", with: " ")
            
            return TimeZoneItem(
                id: id,
                displayName: city.isEmpty ? id : "\(city) (\(gmtStr))",
                detail: "\(region) • \(id)",
                searchKeywords: "\(id) \(city) \(region) \(gmtStr)".lowercased()
            )
        }
    }()
    
    var filteredTimeZones: [TimeZoneItem] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return timeZoneOptions
        } else {
            let query = searchText.lowercased()
            return timeZoneOptions.filter { $0.searchKeywords.contains(query) }
        }
    }
    
    var previewClock: WorldClock {
        WorldClock(
            name: name.trimmingCharacters(in: .whitespaces).isEmpty ? "Preview Clock" : name,
            timeZoneIdentifier: selectedTimeZoneId,
            emoji: emoji.trimmingCharacters(in: .whitespaces).isEmpty ? "🕒" : emoji
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title Header
            HStack {
                Text("Add World Clock")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Presets
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick Presets")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 8)], spacing: 8) {
                            ForEach(ClockPreset.presets) { preset in
                                Button {
                                    applyPreset(preset)
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(preset.emoji)
                                        Text(preset.name)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Spacer()
                                    }
                                    .font(.system(size: 11))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(selectedTimeZoneId == preset.timeZoneIdentifier && name == preset.name ? Color.accentColor.opacity(0.2) : Color(NSColor.controlBackgroundColor))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(selectedTimeZoneId == preset.timeZoneIdentifier && name == preset.name ? Color.accentColor : Color.secondary.opacity(0.15), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Name & Emoji inputs
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Emoji / Icon")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                            TextField("🇵🇭", text: $emoji)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Clock Name")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                            TextField("e.g. Philippines", text: $name)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    
                    // Time Zone Picker with Search
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Time Zone")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Search city, country, or timezone...", text: $searchText)
                                .textFieldStyle(.plain)
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(6)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        
                        // Timezone list
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 2) {
                                ForEach(filteredTimeZones.prefix(100)) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(item.displayName)
                                                .font(.system(size: 12, weight: item.id == selectedTimeZoneId ? .bold : .regular))
                                            Text(item.detail)
                                                .font(.system(size: 10))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        if item.id == selectedTimeZoneId {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .contentShape(Rectangle())
                                    .background(item.id == selectedTimeZoneId ? Color.accentColor.opacity(0.1) : Color.clear)
                                    .cornerRadius(4)
                                    .onTapGesture {
                                        selectedTimeZoneId = item.id
                                    }
                                }
                            }
                            .padding(4)
                        }
                        .frame(height: 120)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Live Preview
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Preview")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            Text(previewClock.emoji)
                                .font(.system(size: 22))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(previewClock.name)
                                    .font(.system(size: 13, weight: .semibold))
                                Text("\(previewClock.currentDateString()) (\(previewClock.offsetRelativeToOman()))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(previewClock.currentTimeString(is24Hour: clockManager.use24HourFormat))
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        }
                        .padding(10)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer actions
            HStack {
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Add Clock") {
                    addClock()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 500, height: 560)
        .onAppear {
            if let firstPreset = ClockPreset.presets.first {
                applyPreset(firstPreset)
            }
        }
    }
    
    private func applyPreset(_ preset: ClockPreset) {
        emoji = preset.emoji
        name = preset.name
        selectedTimeZoneId = preset.timeZoneIdentifier
    }
    
    private func addClock() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let newClock = WorldClock(
            name: trimmedName,
            timeZoneIdentifier: selectedTimeZoneId,
            emoji: emoji.trimmingCharacters(in: .whitespaces).isEmpty ? "🕒" : emoji
        )
        
        clockManager.addClock(newClock)
        isPresented = false
    }
}

struct TimeZoneItem: Identifiable {
    let id: String
    let displayName: String
    let detail: String
    let searchKeywords: String
}
