//
//  ViewController.swift
//  SwiftyCalendar
//
//  Created by Ashish Pisey on 06/11/24.
//

import UIKit

protocol DayEventsDelegate: AnyObject {
    func didUpdateSelectedDate(_ date: Date)
}

class WeeklyCalendarVC: UIViewController {
    
    private var selectedDate = Date()
    private var didScrollToToday = false
    var events: [Event] = []
    
    private let calendar: Calendar = EventManager.shared.calendar

    // Define a large number for infinite scrolling
    private let totalWeeks = 10000  // Total number of weeks
    private let baseWeekIndex = 5000  // Center index
    private let totalDays = 70000 // Total number of days

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        return layout
    }()

    private lazy var weekCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = false // We'll handle paging manually
        collectionView.decelerationRate = .fast // For smoother paging
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(DayCell.self, forCellWithReuseIdentifier: DayCell.identifier)
        return collectionView
    }()

    private let selectedDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var pageController: UIPageViewController!
    private var isSyncingSelection = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedDate = Date()
        setupLayout()
        updateSelectedDateLabel()
        EventLoader.preloadEvents()  // Preload events for the specified date range
        weekCollectionView.reloadData()
        
        // Scroll to the base index aligned with the current week starting on Sunday
        guard let startOfWeek = getStartOfWeek(for: Date()) else { return }
        let daysSinceStartOfWeek = calendar.dateComponents([.day], from: startOfWeek, to: Date()).day ?? 0
        let initialIndexPath = IndexPath(item: baseWeekIndex * 7 + daysSinceStartOfWeek, section: 0)
        weekCollectionView.scrollToItem(at: initialIndexPath, at: .left, animated: false)
        
        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        addPageControllerToView()
        
        // Set the initial day view
        let initialDayVC = dayViewController(for: selectedDate)
        pageController.setViewControllers([initialDayVC], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let totalHorizontalPadding: CGFloat = 40 // 20 leading + 20 trailing
        let availableWidth = view.frame.width - totalHorizontalPadding - (6 * layout.minimumLineSpacing)
        let width = availableWidth / 7
        layout.itemSize = CGSize(width: width, height: 100)
        layout.invalidateLayout()
        
        if !didScrollToToday {
            didScrollToToday = true
            scrollToToday()
        }
    }
    
    private func setupLayout() {
        view.addSubview(weekCollectionView)
        view.addSubview(selectedDateLabel)
        
        NSLayoutConstraint.activate([
            weekCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            weekCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weekCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            weekCollectionView.heightAnchor.constraint(equalToConstant: 100),
            
            selectedDateLabel.topAnchor.constraint(equalTo: weekCollectionView.bottomAnchor, constant: 10),
            selectedDateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func datesForCurrentWeek() -> [Date] {
        var dates: [Date] = []
        let weekday = calendar.component(.weekday, from: selectedDate)
        let daysOffset = weekday - calendar.firstWeekday
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysOffset, to: selectedDate) else { return dates }
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private func updateSelectedDateLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        selectedDateLabel.text = formatter.string(from: selectedDate)
    }
    
    private func addPageControllerToView() {
        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageController.view.topAnchor.constraint(equalTo: selectedDateLabel.bottomAnchor, constant: 20),
            pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        pageController.didMove(toParent: self)
    }
    
    private func getStartOfWeek(for date: Date) -> Date? {
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = calendar.firstWeekday // Sunday
        return calendar.date(from: components)
    }
    
    private func scrollToToday() {
        selectedDate = Date() // Set selectedDate to today
        guard let startOfWeekForToday = getStartOfWeek(for: selectedDate) else { return }

        // Calculate the number of weeks between the base week and today's week
        let weeksFromBase = calendar.dateComponents([.weekOfYear], from: getStartOfWeek(for: Date())!, to: startOfWeekForToday).weekOfYear ?? 0

        // Calculate the index path for the first day (Sunday) of today's week
        let indexOfFirstDayOfWeek = (baseWeekIndex + weeksFromBase) * 7

        let indexPath = IndexPath(item: indexOfFirstDayOfWeek, section: 0)

        // Scroll to the first day of the current week (Sunday) without centering
        weekCollectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }
    
    private func scrollToSelectedDate() {
        // Ensure the selected date's week is visible, starting from Sunday
        guard let startOfWeekForSelectedDate = getStartOfWeek(for: selectedDate) else { return }

        // Calculate the number of weeks between the base week and the selected date's week
        let weeksFromBase = calendar.dateComponents([.weekOfYear], from: getStartOfWeek(for: Date())!, to: startOfWeekForSelectedDate).weekOfYear ?? 0

        // Calculate the index path for the first day (Sunday) of the selected date's week
        let indexOfFirstDayOfWeek = (baseWeekIndex + weeksFromBase) * 7

        let indexPath = IndexPath(item: indexOfFirstDayOfWeek, section: 0)

        // Scroll to the first day of the selected week (Sunday) without centering
        weekCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        weekCollectionView.reloadData()
    }
    
    private func dayViewController(for date: Date) -> DayEventsVC {
        let dayVC = DayEventsVC()
        dayVC.date = date
        dayVC.delegate = self
        return dayVC
    }
}

extension WeeklyCalendarVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalDays
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayCell.identifier, for: indexPath) as! DayCell

        // Calculate the week and day offsets
        let weekOffset = (indexPath.item / 7) - baseWeekIndex
        let dayOfWeek = indexPath.item % 7

        // Get the start of the week for today
        guard let startOfWeek = getStartOfWeek(for: Date()) else { return cell }

        // Calculate the date for the cell
        guard let weekStartDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfWeek),
              let date = calendar.date(byAdding: .day, value: dayOfWeek, to: weekStartDate) else { return cell }

        // Fetch events for the date
        events = EventManager.shared.fetchEvents(on: date)
        cell.configure(with: date, selectedDate: selectedDate, events: events)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isSyncingSelection else { return }
        isSyncingSelection = true

        // Calculate the week and day offsets
        let weekOffset = (indexPath.item / 7) - baseWeekIndex
        let dayOfWeek = indexPath.item % 7

        // Get the start of the week for today
        guard let startOfWeek = getStartOfWeek(for: Date()) else { return }

        // Calculate the selected date
        guard let weekStartDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfWeek),
              let date = calendar.date(byAdding: .day, value: dayOfWeek, to: weekStartDate) else { return }

        selectedDate = date

        updateSelectedDateLabel()
        weekCollectionView.reloadData()

        // Remove the call to scrollToSelectedDate() to prevent scrolling
        // scrollToSelectedDate()

        let dayVC = dayViewController(for: selectedDate)
        pageController.setViewControllers([dayVC], direction: .forward, animated: true) { [weak self] completed in
            self?.isSyncingSelection = false
        }
    }
}

extension WeeklyCalendarVC: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let totalHorizontalPadding: CGFloat = 40 // 20 leading + 20 trailing
        let availableWidth = view.frame.width - totalHorizontalPadding - (6 * layout.minimumLineSpacing)
        let itemWidth = availableWidth / 7 + layout.minimumLineSpacing
        let pageWidth = itemWidth * 7
        
        // Calculate the proposed page index
        let approximatePageIndex = (targetContentOffset.pointee.x + scrollView.contentInset.left) / pageWidth
        let pageIndex = round(approximatePageIndex)
        
        // Calculate the new target content offset
        let xOffset = pageIndex * pageWidth - scrollView.contentInset.left
        targetContentOffset.pointee.x = xOffset
    }
}

extension WeeklyCalendarVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let dayVC = viewController as? DayEventsVC,
              let previousDate = calendar.date(byAdding: .day, value: -1, to: dayVC.date) else {
            return nil
        }
        
        return dayViewController(for: previousDate)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let dayVC = viewController as? DayEventsVC,
              let nextDate = calendar.date(byAdding: .day, value: 1, to: dayVC.date) else {
            return nil
        }
        
        return dayViewController(for: nextDate)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = pageController.viewControllers?.first as? DayEventsVC {
            selectedDate = currentVC.date
            updateSelectedDateLabel()
            EventLoader.preloadEvents()
            weekCollectionView.reloadData()
            scrollToSelectedDate()
        }
    }
}

extension WeeklyCalendarVC: DayEventsDelegate {
    func didUpdateSelectedDate(_ date: Date) {
        selectedDate = date
        updateSelectedDateLabel()
        scrollToSelectedDate()
    }
}
