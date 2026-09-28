//
//  AnalyticsDashboardView.swift
//  Final Project
//
//  Created by Andrew Kenny on 11/13/25.
//
import UIKit

class AnalyticsDashboardView: UIView {

    // MARK: - Accent Colors
    private struct AccentColors {
        static let volume = UIColor.systemOrange
        static let workouts = UIColor.systemBlue
        static let duration = UIColor.systemPurple
        static let sets = UIColor.systemTeal
        static let records = UIColor.systemGreen
        static let activity = UIColor.systemPink
    }
    
    // MARK: - Subviews

    let filterControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["1D", "1W", "1M", "1Y"])
        control.selectedSegmentIndex = 1
        return control
    }()

    private let scrollView = UIScrollView()
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    // Volume related - Orange
    let totalVolumeCard = StatCardView(title: "Total Volume", accent: AccentColors.volume)
    let bestVolumeDayCard = StatCardView(title: "Best Volume Day", accent: AccentColors.volume)
    
    // Workout count related - Blue
    let workoutsCard = StatCardView(title: "Workouts", accent: AccentColors.workouts)
    let consistencyCard = StatCardView(title: "Consistency", accent: AccentColors.workouts)
    
    // Duration related - Purple
    let avgDurationCard = StatCardView(title: "Avg Duration", accent: AccentColors.duration)
    let durationCard = StatCardView(title: "Total Duration", accent: AccentColors.duration)
    
    // Sets related - Teal
    let totalSetsCard = StatCardView(title: "Total Sets", accent: AccentColors.sets)
    let avgSetsPerWorkoutCard = StatCardView(title: "Avg Sets/Workout", accent: AccentColors.sets)
    
    // Activity related - Pink/Green
    let mostActiveDayCard = StatCardView(title: "Most Active Day", accent: AccentColors.activity)
    let mostPopularExerciseCard = StatCardView(title: "Most Popular Exercise", accent: AccentColors.records)

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
        setupCards()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupLayout()
        setupCards()
    }


    private func setupView() {
        backgroundColor = .systemBackground

        addSubview(filterControl)
        addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
    }

    private func setupLayout() {
        filterControl.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            filterControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            filterControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            filterControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            scrollView.topAnchor.constraint(equalTo: filterControl.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -12),

            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }

    private func setupCards() {
        // Helper to create a row with two cards
        func makeRow(left: StatCardView, right: StatCardView) -> UIStackView {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 12

            row.addArrangedSubview(left)
            row.addArrangedSubview(right)

            return row
        }

        // Rows of 2 cards
        let row1 = makeRow(left: totalVolumeCard, right: workoutsCard)
        let row2 = makeRow(left: avgDurationCard, right: totalSetsCard)
        let row3 = makeRow(left: bestVolumeDayCard, right: consistencyCard)
        let row4 = makeRow(left: avgSetsPerWorkoutCard, right: mostActiveDayCard)


        // Add to vertical stack
        [row1, row2, row3, row4,
         durationCard, mostPopularExerciseCard].forEach {
            contentStackView.addArrangedSubview($0)
        }
    }
}
