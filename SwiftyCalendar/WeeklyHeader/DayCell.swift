//
//  DayCell.swift
//  SwiftyCalendar
//
//  Created by Ashish Pisey on 06/11/24.
//

import UIKit

class DayCell: UICollectionViewCell {
    
    static let identifier = "DayCell"
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let eventIndicator: UIView = {
        let dot = UIView()
        dot.backgroundColor = .darkGray
        dot.layer.cornerRadius = 3
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.isHidden = true
        return dot
    }()
    
    private let dayVerticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let calendar = Calendar.current
    var date: Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        dayVerticalStackView.addArrangedSubview(dayLabel)
        dayVerticalStackView.addArrangedSubview(dateLabel)
        contentView.addSubview(dayVerticalStackView)
        contentView.addSubview(eventIndicator)
        
        NSLayoutConstraint.activate([
            dayLabel.heightAnchor.constraint(equalToConstant: 30),
            dateLabel.heightAnchor.constraint(equalToConstant: 30),
            
            dayVerticalStackView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            dayVerticalStackView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            dayVerticalStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayVerticalStackView.heightAnchor.constraint(equalToConstant: 60),
            
            eventIndicator.topAnchor.constraint(equalTo: dayVerticalStackView.bottomAnchor, constant: 4),
            eventIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            eventIndicator.widthAnchor.constraint(equalToConstant: 6),
            eventIndicator.heightAnchor.constraint(equalToConstant: 6),
        ])
        
        dayVerticalStackView.layer.cornerRadius = 8
        dayVerticalStackView.layer.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        isAccessibilityElement = true
    }
    
    func configure(with date: Date, selectedDate: Date, events: [Event]) {
        self.date = date
        let formatter = DateFormatter()
        
        // Configure day and date labels
        formatter.dateFormat = "E"
        if let firstChar = formatter.string(from: date).first {
            dayLabel.text = String(firstChar).uppercased()
        }
        
        formatter.dateFormat = "d"
        dateLabel.text = formatter.string(from: date)
        
        // State Styling
        let isToday = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        
        let blueColor = appColor.blueColor
        
        // Today's Date Styling
        if isToday {
            dayVerticalStackView.layer.borderColor = blueColor.cgColor
            dayVerticalStackView.layer.borderWidth = 2
        } else {
            dayVerticalStackView.layer.borderColor = UIColor.clear.cgColor
            dayVerticalStackView.layer.borderWidth = 0
        }
        
        // Selected Date Styling
        if isSelected {
            dayVerticalStackView.backgroundColor = blueColor
            dayLabel.textColor = .white
            dateLabel.textColor = .white
        } else {
            dayVerticalStackView.backgroundColor = .clear
            dayLabel.textColor = .lightGray
            dateLabel.textColor = .black
        }
        
        // Event Indicator
        eventIndicator.isHidden = events.isEmpty
        
        // Accessibility
        let fullDateFormatter = DateFormatter()
        fullDateFormatter.dateStyle = .full
        accessibilityLabel = fullDateFormatter.string(from: date)
        accessibilityTraits = isSelected ? [.button, .selected] : [.button]
    }
}
