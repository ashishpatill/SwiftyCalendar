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
        events.sort { $0.startTime < $1.startTime }

        // Scroll to upcoming event after data is loaded
        DispatchQueue.main.async {
            self.eventsTableView.reloadData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToUpcomingEvent()
        }
    }
    
    private func scrollToUpcomingEvent() {
        DispatchQueue.main.async {
            let now = Date()
            let calendar = EventManager.shared.calendar
            let startOfToday = calendar.startOfDay(for: now)
            let startOfSelectedDay = calendar.startOfDay(for: self.date)
            
            print("Scrolling to events for date: \(String(describing: self.date))")
            
            if startOfSelectedDay == startOfToday {
                // Selected date is today, find the first upcoming event
                if let firstUpcomingEvent = self.events.first(where: { $0.endTime >= now }) {
                    let eventHour = calendar.component(.hour, from: firstUpcomingEvent.startTime)
                    print("First upcoming event is at hour: \(eventHour)")
                    let indexPath = IndexPath(row: eventHour, section: 0)
                    // Ensure the index is within bounds
                    if indexPath.row < self.eventsTableView.numberOfRows(inSection: 0) {
                        self.eventsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                } else {
                    print("scrollToUpcomingEvent: No upcoming events for today.")
                }
            } else {
                // Selected date is in the future or past, scroll to the first event's hour
                if let firstEvent = self.events.first {
                    let eventHour = calendar.component(.hour, from: firstEvent.startTime)
                    let indexPath = IndexPath(row: eventHour, section: 0)
                    if indexPath.row < self.eventsTableView.numberOfRows(inSection: 0) {
                        self.eventsTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
                } else {
                    // No events, scroll to the top
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.eventsTableView.scrollToRow(at: indexPath, at: .top, animated: false)
                }
            } 
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
        let eventsForHour = EventManager.shared.getEvents(forHour: hour, on: date)
        cell.configure(with: hour, eventsForHour: eventsForHour, for: date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60  // Adjust based on the desired height for each hour block
    }
}
