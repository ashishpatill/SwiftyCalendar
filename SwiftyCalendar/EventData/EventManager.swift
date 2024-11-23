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
    let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        cal.firstWeekday = 1
        return cal
    }()
    
    private init() {}
    
    func hasEvents(on date: Date) -> Bool {
        let key = startOfDay(for: date)
        return !(events[key]?.isEmpty ?? true)
    }
    
    func addEvent(_ event: Event) {
        let key = startOfDay(for: event.startTime)
        events[key, default: []].append(event)
    }
    
    func getMonth(byAdding month: Int, to date: Date = Date()) -> Date? {
        return calendar.date(byAdding: .month, value: month, to: Date())
    }
    
    func getDay(byAdding day: Int, to date: Date = Date()) -> Date? {
        return calendar.date(byAdding: .day, value: day, to: date)
    }

    func fetchEvents(on date: Date) -> [Event] {
        let key = startOfDay(for: date)
        return events[key] ?? []
    }
    
    func getEvents(forHour hour: Int, on date: Date) -> [Event] {
        // Ensure the hour is within 0-23
        guard hour >= 0 && hour < 24 else { return [] }
        
        // Define the start and end of the hour
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = 0
        components.second = 0
        
        guard let startOfHour = calendar.date(from: components),
              let endOfHour = calendar.date(byAdding: .hour, value: 1, to: startOfHour) else { return [] }
        
        // Filter events that overlap with this hour
        let todaysEvents = fetchEvents(on: date)
        let eventsForHour = todaysEvents.filter { event in
            return event.startTime < endOfHour && event.endTime > startOfHour
        }
        
        return eventsForHour
    }
    
    private func startOfDay(for date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }
    
    func clearEvents(on date: Date) {
        let key = startOfDay(for: date)
        events[key] = []
    }
}
