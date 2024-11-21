//
//  DayEventsViewController.swift
//  SwiftyCalendar
//
//  Created by Ashish Pisey on 06/11/24.
//

import UIKit

class DayEventsVC: UIViewController {
    
    var date: Date!
    weak var delegate: DayEventsDelegate?
    
    private let eventsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.clipsToBounds = false // Allow separator lines to be visible
        return tableView
    }()
    
    var events: [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        loadEventsForDate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadEventsForDate()
    }
    
    private func setupTableView() {
        view.addSubview(eventsTableView)
        eventsTableView.rowHeight = 60 
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.register(TimelineCell.self, forCellReuseIdentifier: TimelineCell.identifier)
        
        NSLayoutConstraint.activate([
            eventsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            eventsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eventsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eventsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func loadEventsForDate() {
        // Fetch events from EventManager
        events = EventManager.shared.fetchEvents(on: date)
        eventsTableView.reloadData()

        // Scroll to upcoming event after data is loaded
        DispatchQueue.main.async {
            self.scrollToUpcomingEvent()
        }
    }
    
    /*
    func addMockEvents() {
        let calendar = Calendar.current
        guard let baseDate = date else { return }
        
        // Clear existing events for the date
        EventManager.shared.clearEvents(on: baseDate)
        
        // Define colors for events
        let eventColor = appColor.greenColor
        // Create events with overlapping times
        // Event 1: 9:00 AM - 11:00 AM (2 hours)
        let event1Start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: baseDate)!
        let event1End = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: baseDate)!
        let event1 = Event(name: "Event 1", startTime: event1Start, endTime: event1End, color: eventColor, hasLivestream: true)
        
        // Event 2: 9:30 AM - 10:30 AM (Overlaps with Event 1)
        let event2Start = calendar.date(bySettingHour: 9, minute: 30, second: 0, of: baseDate)!
        let event2End = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!
        let event2 = Event(name: "Event 2", startTime: event2Start, endTime: event2End, color: eventColor)
        
        // Event 3: 10:00 AM - 12:00 PM (Overlaps with Event 1 and Event 2)
        let event3Start = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: baseDate)!
        let event3End = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: baseDate)!
        let event3 = Event(name: "Event 3", startTime: event3Start, endTime: event3End, color: eventColor)
        
        // Event 4: 10:15 AM - 11:15 AM (Overlaps with Event 1, 2, and 3)
        let event4Start = calendar.date(bySettingHour: 10, minute: 15, second: 0, of: baseDate)!
        let event4End = calendar.date(bySettingHour: 11, minute: 15, second: 0, of: baseDate)!
        let event4 = Event(name: "Event 4", startTime: event4Start, endTime: event4End, color: eventColor, hasLivestream: true)
        
        // Event 5: 10:30 AM - 11:00 AM (Overlaps with Event 1, 2, 3, and 4)
        let event5Start = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: baseDate)!
        let event5End = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: baseDate)!
        let event5 = Event(name: "Event 5", startTime: event5Start, endTime: event5End, color: eventColor)
        
        // Event with same start and end time (Zero duration)
        let event6Start = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: baseDate)!
        let event6End = event6Start // Same start and end time
        let event6 = Event(name: "Zero Duration Event", startTime: event6Start, endTime: event6End, color: eventColor)
        
        // Event partially overlapping with others
        // Event 7: 8:45 AM - 9:15 AM (Partial overlap with Event 1)
        let event7Start = calendar.date(bySettingHour: 8, minute: 45, second: 0, of: baseDate)!
        let event7End = calendar.date(bySettingHour: 9, minute: 15, second: 0, of: baseDate)!
        let event7 = Event(name: "Event 7", startTime: event7Start, endTime: event7End, color: eventColor)
        
        let mockEvents = [event1, event2, event3, event4, event5, event6, event7]
        
        // Add mock events to EventManager
        for event in mockEvents {
            EventManager.shared.addEvent(event)
        }
    }
    */
    
    private func scrollToUpcomingEvent() {
        let currentTime = Date()
        let calendar = Calendar.current

        // Find upcoming events based on current time
        let upcomingEvents = events.filter { $0.startTime >= currentTime }
        
        let targetEvent: Event?
        
        if !upcomingEvents.isEmpty {
            // Get the first upcoming event
            targetEvent = upcomingEvents.min(by: { $0.startTime < $1.startTime })
        } else if let lastEvent = events.max(by: { $0.endTime < $1.endTime }), lastEvent.endTime >= calendar.startOfDay(for: currentTime) {
            // All events are in the past, scroll to the last event of the day
            targetEvent = lastEvent
        } else {
            // No events for today, do not scroll
            return
        }
        
        guard let eventToScrollTo = targetEvent else { return }
        
        let eventHour = calendar.component(.hour, from: eventToScrollTo.startTime)
        let indexPath = IndexPath(row: eventHour, section: 0)
        
        DispatchQueue.main.async {
            self.eventsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

extension DayEventsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24  // 24 hours in a day
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: TimelineCell.identifier, for: indexPath) as! TimelineCell
        let hour = indexPath.row
        cell.configure(with: hour, events: events)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60  // Adjust based on the desired height for each hour block
    }
}
