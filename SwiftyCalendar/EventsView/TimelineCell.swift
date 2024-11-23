//
//  EventCell.swift
//  SwiftyCalendar
//
//  Created by Ashish Pisey on 06/11/24.
//

import UIKit

class TimelineCell: UITableViewCell {
    
    static let identifier = "TimelineCell"
    
    private let hourLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        view.tag = 999
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let eventsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var eventViews: [UIView] = []
    private let calendar = EventManager.shared.calendar
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Force layout updates to ensure frames are set
        eventsContainerView.layoutIfNeeded()
    }

    // MARK: - Configuration
    
    func configure(with hour: Int, eventsForHour: [Event], for date: Date) {
        setupHourLabel(for: hour)
        clearEventViews()
        
        guard let startOfHour = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date) else { return }
        
        guard !eventsForHour.isEmpty else { return }
        
        let columns = assignEventsToColumns(events: eventsForHour)
        createEventViews(columns: columns, startOfHour: startOfHour)
    }
    
    // MARK: - Helper Methods
    
    private func setupLayout() {
        contentView.addSubview(hourLabel)
        contentView.addSubview(separatorView)
        contentView.addSubview(eventsContainerView)
        
        NSLayoutConstraint.activate([
            hourLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            hourLabel.widthAnchor.constraint(equalToConstant: 40),
            hourLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            hourLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: hourLabel.trailingAnchor, constant: 8),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            separatorView.centerYAnchor.constraint(equalTo: hourLabel.centerYAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            eventsContainerView.leadingAnchor.constraint(equalTo: hourLabel.trailingAnchor, constant: 8),
            eventsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            eventsContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            eventsContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    private func setupHourLabel(for hour: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        guard let hourDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) else { return }
        hourLabel.text = formatter.string(from: hourDate)
    }
    
    private func clearEventViews() {
        for view in eventViews {
            view.removeFromSuperview()
        }
        eventViews.removeAll()
    }
    
    private func filterEvents(for events: [Event], in startOfHour: Date) -> [Event] {
        guard let endOfHour = calendar.date(byAdding: .hour, value: 1, to: startOfHour) else { return [] }
        let eventsForHour = events.filter { event in
            return event.endTime > startOfHour && event.startTime < endOfHour
        }
        return eventsForHour
    }
    
    private func assignEventsToColumns(events: [Event]) -> [[Event]] {
        let sortedEvents = events.sorted { $0.startTime < $1.startTime }
        var columns: [[Event]] = []
        
        for event in sortedEvents {
            var placed = false
            for i in 0..<columns.count {
                if let lastEvent = columns[i].last, lastEvent.endTime > event.startTime {
                    // Overlapping, cannot place in this column
                    continue
                } else {
                    // No overlap, place in this column
                    columns[i].append(event)  // Modify columns[i] directly
                    placed = true
                    break
                }
            }
            if !placed {
                // Create new column
                columns.append([event])
            }
        }
        return columns
    }
    
    private func createEventViews(columns: [[Event]], startOfHour: Date) {
        eventsContainerView.layoutIfNeeded() // Ensure layout is up to date
        
        let numberOfColumns = columns.count
        let eventWidth = eventsContainerView.frame.width / CGFloat(numberOfColumns)
        let hourHeight = eventsContainerView.frame.height
        
        for (columnIndex, column) in columns.enumerated() {
            for event in column {
                let eventView = createEventView(for: event)
                eventsContainerView.addSubview(eventView)
                layoutEventView(
                    eventView,
                    for: event,
                    at: columnIndex,
                    totalColumns: numberOfColumns,
                    startOfHour: startOfHour,
                    eventWidth: eventWidth,
                    hourHeight: hourHeight
                )
            }
        }
    }
    
    private func createEventView(for event: Event) -> UIView {
        let eventView = UIView()
        eventView.backgroundColor = event.color
        eventView.layer.cornerRadius = 5
        eventView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the image view for the livestream icon
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        
        if event.hasLivestream {
            // Set the image for the livestream icon
            iconImageView.image = UIImage(systemName: "video.fill") 
            iconImageView.tintColor = .white
        }
        
        // Add subviews to the eventView
        if event.hasLivestream {
            eventView.addSubview(iconImageView)
        }
        
        let eventLabel = UILabel()
        eventLabel.text = event.name
        eventLabel.font = UIFont.systemFont(ofSize: 13)
        eventLabel.textColor = .white
        eventLabel.numberOfLines = 1
        eventLabel.translatesAutoresizingMaskIntoConstraints = false
        eventView.addSubview(eventLabel)
        
        // Set up constraints
        if event.hasLivestream {
            NSLayoutConstraint.activate([
                iconImageView.leadingAnchor.constraint(equalTo: eventView.leadingAnchor, constant: 5),
                iconImageView.centerYAnchor.constraint(equalTo: eventView.centerYAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 16),
                iconImageView.heightAnchor.constraint(equalToConstant: 16),
                
                eventLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 5),
                eventLabel.trailingAnchor.constraint(equalTo: eventView.trailingAnchor, constant: -5),
                eventLabel.centerYAnchor.constraint(equalTo: eventView.centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                eventLabel.leadingAnchor.constraint(equalTo: eventView.leadingAnchor, constant: 5),
                eventLabel.trailingAnchor.constraint(equalTo: eventView.trailingAnchor, constant: -5),
                eventLabel.centerYAnchor.constraint(equalTo: eventView.centerYAnchor)
            ])
        }
        
        eventViews.append(eventView)
        return eventView
    }
    
    private func layoutEventView(
        _ eventView: UIView,
        for event: Event,
        at columnIndex: Int,
        totalColumns: Int,
        startOfHour: Date,
        eventWidth: CGFloat,
        hourHeight: CGFloat
    ) {
        //guard let endOfHour = calendar.date(byAdding: .hour, value: 1, to: startOfHour) else { return }
        let minimumEventHeight = 5.0
        // Calculate start and end minutes within the hour
        let startMinutes = max(0, calendar.dateComponents([.minute], from: startOfHour, to: event.startTime).minute ?? 0)
        let endMinutes = min(60, calendar.dateComponents([.minute], from: startOfHour, to: event.endTime).minute ?? 60)
        let durationMinutes = max(1, endMinutes - startMinutes) // Ensure at least 1 minute duration
        
        // Calculate positions and sizes
        let topOffset = (CGFloat(startMinutes) / 60.0) * hourHeight + 2  // Add 2 px top padding
        // Adjust eventHeight to ensure it's at least a minimal height
        let eventHeight = max(((CGFloat(durationMinutes) / 60.0) * hourHeight) - 4, minimumEventHeight)
        let leadingOffset: CGFloat
        let eventWidthWithPadding: CGFloat
        
        if totalColumns == 1 {
            // No overlapping events, event occupies full width
            leadingOffset = 0
            eventWidthWithPadding = eventsContainerView.frame.width
        } else {
            // Overlapping events, add horizontal padding
            leadingOffset = (CGFloat(columnIndex) * eventWidth) + 2  // Add 2 px left padding
            eventWidthWithPadding = eventWidth - 4  // Subtract 4 px for left and right padding
        }
        
        NSLayoutConstraint.activate([
            eventView.topAnchor.constraint(equalTo: eventsContainerView.topAnchor, constant: topOffset),
            eventView.heightAnchor.constraint(equalToConstant: eventHeight),
            eventView.leadingAnchor.constraint(equalTo: eventsContainerView.leadingAnchor, constant: leadingOffset),
            eventView.widthAnchor.constraint(equalToConstant: eventWidthWithPadding)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearEventViews()
    }
}
