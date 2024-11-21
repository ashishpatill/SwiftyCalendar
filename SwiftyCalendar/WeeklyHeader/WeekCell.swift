//
//  WeekCellDelegate.swift
//  SwiftyCalendar
//
//  Created by Ashish Pisey on 06/11/24.
//

/*
import UIKit

protocol WeekCellDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}

class WeekCell: UICollectionViewCell {

    static let identifier = "WeekCell"

    weak var delegate: DayCellDelegate?

    private var dayCells: [DayCell] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDayCells()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupDayCells() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20), // Adjust padding if needed
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        for _ in 0..<7 {
            let dayCell = DayCell()
            dayCell.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(dayCell)
            dayCells.append(dayCell)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dayCellTapped(_:)))
            dayCell.addGestureRecognizer(tapGesture)
        }
    }

    func configure(with dates: [Date], selectedDate: Date) {
        for (index, date) in dates.enumerated() {
            let events = EventManager.shared.fetchEvents(on: date)
            dayCells[index].configure(with: date, selectedDate: selectedDate, events: events)
        }
    }

    @objc private func dayCellTapped(_ sender: UITapGestureRecognizer) {
        guard let dayCell = sender.view as? DayCell,
              let date = dayCell.date else { return }
        delegate?.didSelectDate(date)
    }
}
*/
