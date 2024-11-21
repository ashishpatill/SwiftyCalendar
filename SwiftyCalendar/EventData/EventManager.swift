//
//  EventManager.swift
//  SwiftyCalendar
//
//  Created by Ashish Pisey on 06/11/24.
//


import Foundation
import UIKit

class EventManager {
    static let shared = EventManager()
    private var events: [Date: [Event]] = [:]
    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        return cal
    }()
    
    private init() {}
    
    func hasEvents(on date: Date) -> Bool {
        let key = startOfDay(for: date)
        return !(events[key]?.isEmpty ?? true)
    }
    
    func addEvent(_ event: Event) {
        let key = normalizeDate(event.startTime)
        events[key, default: []].append(event)
    }

    func fetchEvents(on date: Date) -> [Event] {
        let key = normalizeDate(date)
        return events[key] ?? []
    }

    private func normalizeDate(_ date: Date) -> Date {
        // Normalize to midnight in UTC to avoid time zone issues
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components)!
    }
    
    private func startOfDay(for date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }
    
    func clearEvents(on date: Date) {
        let key = startOfDay(for: date)
        events[key] = []
    }
}
