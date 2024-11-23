//
//  EventLoader.swift
//  SwiftyCalendar
//
//  Created by Ashish Pisey on 22/11/24.
//


import Foundation

public class EventLoader {
    public static func preloadEvents() {
        let eventManager = EventManager.shared

        // Define the date range
        guard let startDate = eventManager.getMonth(byAdding: -1),
              let endDate = eventManager.getMonth(byAdding: 7) else { return }

        var date = startDate
        while date <= endDate {
            // Randomly decide whether to add events for this date
            if Bool.random() {
                // Add mock events for this date
                addMockEvents(for: date)
            }
            if let nextDate = eventManager.getDay(byAdding: 1, to: date) {
                date = nextDate
            } else {
                break
            }
        }
    }

    private static func addMockEvents(for baseDate: Date) {
        let calendar = EventManager.shared.calendar

        // Define color for events
        let eventColor = appColor.greenColor

        // Clear existing events for the date
        EventManager.shared.clearEvents(on: baseDate)

        // Randomly decide the number of events for this date (0 to 5)
        let numberOfEvents = Int.random(in: 1...5)

        var mockEvents: [Event] = []

        // Possible event titles
        let eventTitles = ["Meeting", "Workshop", "Conference", "Lunch", "Training", "Call", "Webinar", "Seminar", "Presentation", "Networking", "Team Building", "Strategy Session", "Planning", "Review", "Client Meeting"]

        for _ in 1...numberOfEvents {
            // Randomly select a title
            let title = eventTitles.randomElement() ?? "Event"

            // Randomly decide hasLivestream
            let hasLivestream = Bool.random()

            // Random start hour between 8 AM and 5 PM
            let startHour = Int.random(in: 8...17)
            // Random start minute (0, 15, 30, 45)
            let startMinuteOptions = [0, 15, 30, 45]
            let startMinute = startMinuteOptions.randomElement() ?? 0

            // Random duration between 30 minutes to 2 hours (in minutes)
            let durationOptions = [30, 45, 60, 90, 120]
            let duration = durationOptions.randomElement() ?? 60

            // Generate start and end times
            guard let eventStart = calendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: baseDate),
                  let eventEnd = calendar.date(byAdding: .minute, value: duration, to: eventStart) else { continue }

            let event = Event(
                name: title,
                startTime: eventStart,
                endTime: eventEnd,
                color: eventColor,
                hasLivestream: hasLivestream
            )

            mockEvents.append(event)
        }

        // Add mock events to EventManager
        for event in mockEvents {
            EventManager.shared.addEvent(event)
        }
    }
}
