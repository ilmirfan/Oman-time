//
//  WorldClock.swift
//  OmanTime
//
//  Created by Irfan Ishak on 2026-11-09.
//

import Foundation

struct WorldClock: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var timeZoneIdentifier: String
    var emoji: String
    
    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? TimeZone(identifier: "UTC") ?? TimeZone.current
    }
    
    func currentTimeString(is24Hour: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = is24Hour ? "HH:mm" : "h:mm a"
        formatter.timeZone = timeZone
        return formatter.string(from: Date())
    }
    
    func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        formatter.timeZone = timeZone
        return formatter.string(from: Date())
    }
    
    func gmtOffsetString() -> String {
        let seconds = timeZone.secondsFromGMT(for: Date())
        let hours = seconds / 3600
        let minutes = abs((seconds % 3600) / 60)
        let sign = hours >= 0 ? "+" : "-"
        if minutes == 0 {
            return "UTC\(sign)\(abs(hours))"
        } else {
            return String(format: "UTC%@%d:%02d", sign, abs(hours), minutes)
        }
    }
    
    func offsetRelativeToOman() -> String {
        guard let omanTZ = TimeZone(identifier: "Asia/Muscat") else { return "" }
        let now = Date()
        let targetSeconds = timeZone.secondsFromGMT(for: now)
        let omanSeconds = omanTZ.secondsFromGMT(for: now)
        let diffHours = Double(targetSeconds - omanSeconds) / 3600.0
        
        if diffHours == 0 {
            return "Same time as Oman"
        } else if diffHours > 0 {
            let formatted = diffHours.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(diffHours))" : String(format: "%.1f", diffHours)
            return "+\(formatted)h vs Oman"
        } else {
            let formatted = abs(diffHours).truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(abs(diffHours)))" : String(format: "%.1f", abs(diffHours))
            return "-\(formatted)h vs Oman"
        }
    }
}

struct ClockPreset: Identifiable, Hashable {
    var id: String { timeZoneIdentifier }
    let emoji: String
    let name: String
    let timeZoneIdentifier: String
    
    static let presets: [ClockPreset] = [
        ClockPreset(emoji: "🇵🇭", name: "Philippines", timeZoneIdentifier: "Asia/Manila"),
        ClockPreset(emoji: "🇸🇬", name: "Singapore", timeZoneIdentifier: "Asia/Singapore"),
        ClockPreset(emoji: "🇲🇾", name: "Malaysia", timeZoneIdentifier: "Asia/Kuala_Lumpur"),
        ClockPreset(emoji: "🇮🇳", name: "India", timeZoneIdentifier: "Asia/Kolkata"),
        ClockPreset(emoji: "🇦🇪", name: "UAE / Dubai", timeZoneIdentifier: "Asia/Dubai"),
        ClockPreset(emoji: "🇸🇦", name: "Saudi Arabia", timeZoneIdentifier: "Asia/Riyadh"),
        ClockPreset(emoji: "🇬🇧", name: "United Kingdom", timeZoneIdentifier: "Europe/London"),
        ClockPreset(emoji: "🇺🇸", name: "US Eastern (NY)", timeZoneIdentifier: "America/New_York"),
        ClockPreset(emoji: "🇺🇸", name: "US Pacific (LA)", timeZoneIdentifier: "America/Los_Angeles"),
        ClockPreset(emoji: "🇯🇵", name: "Japan", timeZoneIdentifier: "Asia/Tokyo"),
        ClockPreset(emoji: "🇫🇷", name: "France", timeZoneIdentifier: "Europe/Paris"),
        ClockPreset(emoji: "🇩🇪", name: "Germany", timeZoneIdentifier: "Europe/Berlin"),
        ClockPreset(emoji: "🇦🇺", name: "Sydney", timeZoneIdentifier: "Australia/Sydney"),
        ClockPreset(emoji: "🇵🇰", name: "Pakistan", timeZoneIdentifier: "Asia/Karachi"),
        ClockPreset(emoji: "🇧🇩", name: "Bangladesh", timeZoneIdentifier: "Asia/Dhaka"),
        ClockPreset(emoji: "🇪🇬", name: "Egypt", timeZoneIdentifier: "Africa/Cairo"),
        ClockPreset(emoji: "🇮🇩", name: "Indonesia", timeZoneIdentifier: "Asia/Jakarta"),
        ClockPreset(emoji: "🇹🇭", name: "Thailand", timeZoneIdentifier: "Asia/Bangkok")
    ]
}

