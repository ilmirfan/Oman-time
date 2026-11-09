//
//  ClockManager.swift
//  OmanTime
//
//  Created by Irfan Ishak on 2026-11-09.
//

import Foundation
import Combine
import SwiftUI

class ClockManager: ObservableObject {
    static let shared = ClockManager()
    
    private let clocksStorageKey = "saved_world_clocks"
    private let formatStorageKey = "use_24_hour_format"
    
    @Published var clocks: [WorldClock] = [] {
        didSet {
            saveClocks()
        }
    }
    
    @Published var use24HourFormat: Bool = true {
        didSet {
            UserDefaults.standard.set(use24HourFormat, forKey: formatStorageKey)
        }
    }
    
    init() {
        if UserDefaults.standard.object(forKey: formatStorageKey) != nil {
            self.use24HourFormat = UserDefaults.standard.bool(forKey: formatStorageKey)
        } else {
            self.use24HourFormat = true
        }
        
        loadClocks()
    }
    
    private func loadClocks() {
        if let data = UserDefaults.standard.data(forKey: clocksStorageKey) {
            do {
                let decoded = try JSONDecoder().decode([WorldClock].self, from: data)
                self.clocks = decoded
                return
            } catch {
                print("Failed to decode clocks: \(error)")
            }
        }
        
        // Default initial clock: Philippines as requested
        self.clocks = [
            WorldClock(name: "Philippines", timeZoneIdentifier: "Asia/Manila", emoji: "🇵🇭")
        ]
    }
    
    private func saveClocks() {
        do {
            let data = try JSONEncoder().encode(clocks)
            UserDefaults.standard.set(data, forKey: clocksStorageKey)
        } catch {
            print("Failed to encode clocks: \(error)")
        }
    }
    
    func addClock(_ clock: WorldClock) {
        clocks.append(clock)
    }
    
    func removeClock(id: UUID) {
        clocks.removeAll { $0.id == id }
    }
    
    func removeClock(at offsets: IndexSet) {
        clocks.remove(atOffsets: offsets)
    }
    
    func moveClock(from source: IndexSet, to destination: Int) {
        clocks.move(fromOffsets: source, toOffset: destination)
    }
}
