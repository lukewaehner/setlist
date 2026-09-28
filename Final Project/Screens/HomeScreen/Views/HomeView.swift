//
//  HomeView.swift
//  Final Project
//
//  Created by Luke Waehner on 11/12/25.
//

import UIKit

class HomeView: UIView {
    // Setup view wrappers
    var scrollView: UIScrollView!
    var contentView: UIStackView!

    // User info header
    var profileHeaderContainer: UIView!
    var nameLabel: UILabel!
    var weightLabel: UILabel!
    var profileButton: UIButton!

    // Today bar / quick start workout
    var todaySectionContainer: UIView!
    var todayLabel: UILabel!
    var dateLabel: UILabel!
    var workoutButton: UIButton!

    // Active workout banner (conditional)
    var activeWorkoutBanner: UIView!
    var activeLabel: UILabel!
    var splitLabel: UILabel!
    var timeLabel: UILabel!
    var tapLabel: UILabel!
    var progressView: UIProgressView!

    // Recent workouts stored
    var recentWorkoutsHeaderContainer: UIView!
    var recentWorkoutsHeaderLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground

        // Setup all the UI components
        setupScrollView()
        setupContentView()
        setupProfileHeader()
        setupTodaySection()
        setupActiveWorkoutBanner()
        setupRecentWorkoutsSection()
        initConstraints()
    }

    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
    }

    func setupContentView() {
        contentView = UIStackView()
        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }

    func setupProfileHeader() {
        profileHeaderContainer = UIView()
        profileHeaderContainer.translatesAutoresizingMaskIntoConstraints = false

        // User name and weight labels
        nameLabel = UILabel()
        nameLabel.text = "Hello, User!"
        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        weightLabel = UILabel()
        weightLabel.text = "70.0 kg"
        weightLabel.font = .systemFont(ofSize: 12)
        weightLabel.textColor = .secondaryLabel
        weightLabel.translatesAutoresizingMaskIntoConstraints = false

        // Profile button in top right
        profileButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 32)
        profileButton.setImage(
            UIImage(
                systemName: "person.circle.fill",
                withConfiguration: config
            ),
            for: .normal
        )
        profileButton.tintColor = .systemBlue
        profileButton.translatesAutoresizingMaskIntoConstraints = false

        // Stack the name and weight vertically
        let textStackView = UIStackView(arrangedSubviews: [
            nameLabel, weightLabel,
        ])
        textStackView.axis = .vertical
        textStackView.alignment = .trailing
        textStackView.spacing = 2
        textStackView.translatesAutoresizingMaskIntoConstraints = false

        // Horizontal stack with text on left, button on right
        let headerStackView = UIStackView(arrangedSubviews: [
            textStackView, profileButton,
        ])
        headerStackView.axis = .horizontal
        headerStackView.spacing = 12
        headerStackView.alignment = .center
        headerStackView.translatesAutoresizingMaskIntoConstraints = false

        profileHeaderContainer.addSubview(headerStackView)

        NSLayoutConstraint.activate([
            headerStackView.trailingAnchor.constraint(
                equalTo: profileHeaderContainer.trailingAnchor,
                constant: -16
            ),
            headerStackView.topAnchor.constraint(
                equalTo: profileHeaderContainer.topAnchor,
                constant: 10
            ),
            headerStackView.bottomAnchor.constraint(
                equalTo: profileHeaderContainer.bottomAnchor
            ),
            headerStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: profileHeaderContainer.leadingAnchor,
                constant: 16
            ),
        ])

        contentView.addArrangedSubview(profileHeaderContainer)
    }

    func setupTodaySection() {
        todaySectionContainer = UIView()
        todaySectionContainer.backgroundColor = .systemBackground
        todaySectionContainer.layer.cornerRadius = 12
        todaySectionContainer.translatesAutoresizingMaskIntoConstraints = false

        // Get current weekday
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: Date())

        todayLabel = UILabel()
        todayLabel.text = "Today, \(weekday)"
        todayLabel.font = .systemFont(ofSize: 22, weight: .bold)
        todayLabel.translatesAutoresizingMaskIntoConstraints = false

        // Format the actual date
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateStyle = .short
        dateFormatter2.timeStyle = .none

        dateLabel = UILabel()
        dateLabel.text = dateFormatter2.string(from: Date())
        dateLabel.font = .systemFont(ofSize: 15)
        dateLabel.textColor = .secondaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        // Stack date info vertically
        let dateStackView = UIStackView(arrangedSubviews: [
            todayLabel, dateLabel,
        ])
        dateStackView.axis = .vertical
        dateStackView.spacing = 4
        dateStackView.alignment = .leading
        dateStackView.translatesAutoresizingMaskIntoConstraints = false

        // Quick start workout button
        workoutButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22)
        workoutButton.setImage(
            UIImage(systemName: "dumbbell.fill", withConfiguration: config),
            for: .normal
        )
        workoutButton.tintColor = .white
        workoutButton.backgroundColor = .systemBlue
        workoutButton.layer.cornerRadius = 20
        workoutButton.translatesAutoresizingMaskIntoConstraints = false

        // Horizontal layout: date on left, button on right
        let sectionStackView = UIStackView(arrangedSubviews: [
            dateStackView, workoutButton,
        ])
        sectionStackView.axis = .horizontal
        sectionStackView.alignment = .center
        sectionStackView.translatesAutoresizingMaskIntoConstraints = false

        todaySectionContainer.addSubview(sectionStackView)

        NSLayoutConstraint.activate([
            sectionStackView.topAnchor.constraint(
                equalTo: todaySectionContainer.topAnchor,
                constant: 16
            ),
            sectionStackView.leadingAnchor.constraint(
                equalTo: todaySectionContainer.leadingAnchor,
                constant: 16
            ),
            sectionStackView.trailingAnchor.constraint(
                equalTo: todaySectionContainer.trailingAnchor,
                constant: -16
            ),
            sectionStackView.bottomAnchor.constraint(
                equalTo: todaySectionContainer.bottomAnchor,
                constant: -16
            ),
            workoutButton.widthAnchor.constraint(equalToConstant: 44),
            workoutButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        contentView.addArrangedSubview(todaySectionContainer)
        NSLayoutConstraint.activate([
            todaySectionContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            todaySectionContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
        ])
    }

    func setupActiveWorkoutBanner() {
        // Green banner showing active workout
        activeWorkoutBanner = UIView()
        activeWorkoutBanner.backgroundColor = .systemGreen
        activeWorkoutBanner.layer.cornerRadius = 12
        activeWorkoutBanner.translatesAutoresizingMaskIntoConstraints = false
        activeWorkoutBanner.isHidden = true

        // Left side: workout name and split
        activeLabel = UILabel()
        activeLabel.text = "Active Workout"
        activeLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        activeLabel.textColor = .white
        activeLabel.translatesAutoresizingMaskIntoConstraints = false

        splitLabel = UILabel()
        splitLabel.text = "Split Label"
        splitLabel.font = .systemFont(ofSize: 15)
        splitLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        splitLabel.translatesAutoresizingMaskIntoConstraints = false

        // Right side: time and tap hint
        timeLabel = UILabel()
        timeLabel.text = "00:00"
        timeLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        timeLabel.textColor = .white
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        tapLabel = UILabel()
        tapLabel.text = "Tap to resume"
        tapLabel.font = .systemFont(ofSize: 12)
        tapLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        tapLabel.translatesAutoresizingMaskIntoConstraints = false

        // Stack left side labels
        let leftStackView = UIStackView(arrangedSubviews: [
            activeLabel, splitLabel,
        ])
        leftStackView.axis = .vertical
        leftStackView.spacing = 4
        leftStackView.alignment = .leading
        leftStackView.translatesAutoresizingMaskIntoConstraints = false

        // Stack right side labels
        let rightStackView = UIStackView(arrangedSubviews: [
            timeLabel, tapLabel,
        ])
        rightStackView.axis = .vertical
        rightStackView.spacing = 4
        rightStackView.alignment = .trailing
        rightStackView.translatesAutoresizingMaskIntoConstraints = false

        // Progress bar at bottom
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.6
        progressView.progressTintColor = .white
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        progressView.translatesAutoresizingMaskIntoConstraints = false

        // Top row: left and right stacks
        let topStackView = UIStackView(arrangedSubviews: [
            leftStackView, rightStackView,
        ])
        topStackView.axis = .horizontal
        topStackView.distribution = .equalSpacing
        topStackView.translatesAutoresizingMaskIntoConstraints = false

        // Full banner: top row + progress bar
        let bannerStackView = UIStackView(arrangedSubviews: [
            topStackView, progressView,
        ])
        bannerStackView.axis = .vertical
        bannerStackView.spacing = 8
        bannerStackView.translatesAutoresizingMaskIntoConstraints = false

        activeWorkoutBanner.addSubview(bannerStackView)

        NSLayoutConstraint.activate([
            bannerStackView.topAnchor.constraint(
                equalTo: activeWorkoutBanner.topAnchor,
                constant: 16
            ),
            bannerStackView.leadingAnchor.constraint(
                equalTo: activeWorkoutBanner.leadingAnchor,
                constant: 16
            ),
            bannerStackView.trailingAnchor.constraint(
                equalTo: activeWorkoutBanner.trailingAnchor,
                constant: -16
            ),
            bannerStackView.bottomAnchor.constraint(
                equalTo: activeWorkoutBanner.bottomAnchor,
                constant: -16
            ),
            progressView.heightAnchor.constraint(equalToConstant: 4),
        ])

        contentView.addArrangedSubview(activeWorkoutBanner)
        NSLayoutConstraint.activate([
            activeWorkoutBanner.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            activeWorkoutBanner.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
        ])
    }

    func setupRecentWorkoutsSection() {
        // Section header for recent workouts
        recentWorkoutsHeaderLabel = UILabel()
        recentWorkoutsHeaderLabel.text = "Recent Workouts"
        recentWorkoutsHeaderLabel.font = .systemFont(ofSize: 22, weight: .bold)
        recentWorkoutsHeaderLabel.translatesAutoresizingMaskIntoConstraints =
            false

        recentWorkoutsHeaderContainer = UIView()
        recentWorkoutsHeaderContainer.backgroundColor = .systemBackground
        recentWorkoutsHeaderContainer
            .translatesAutoresizingMaskIntoConstraints = false
        recentWorkoutsHeaderContainer.addSubview(recentWorkoutsHeaderLabel)

        NSLayoutConstraint.activate([
            recentWorkoutsHeaderLabel.topAnchor.constraint(
                equalTo: recentWorkoutsHeaderContainer.topAnchor,
                constant: 16
            ),
            recentWorkoutsHeaderLabel.leadingAnchor.constraint(
                equalTo: recentWorkoutsHeaderContainer.leadingAnchor,
                constant: 16
            ),
            recentWorkoutsHeaderLabel.trailingAnchor.constraint(
                equalTo: recentWorkoutsHeaderContainer.trailingAnchor,
                constant: -16
            ),
            recentWorkoutsHeaderLabel.bottomAnchor.constraint(
                equalTo: recentWorkoutsHeaderContainer.bottomAnchor,
                constant: -16
            ),
        ])

        contentView.addArrangedSubview(recentWorkoutsHeaderContainer)
    }

    // Add a workout card to the recent workouts section
    func addWorkoutCard(_ cardView: UIView) {
        contentView.addArrangedSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
        ])
    }

    // Add a divider between workout cards
    // func addDivider(_ divider: UIView) { ... }

    // Clear all workout cards but keep the static sections
    func clearWorkoutCards() {
        let arrangedSubviews = contentView.arrangedSubviews
        for subview in arrangedSubviews {
            // Keep the main sections, remove only workout cards and dividers
            if subview != profileHeaderContainer,
                subview != todaySectionContainer,
                subview != activeWorkoutBanner,
                subview != recentWorkoutsHeaderContainer
            {
                contentView.removeArrangedSubview(subview)
                subview.removeFromSuperview()
            }
        }
    }

    func initConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor
            ),
            contentView.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: scrollView.bottomAnchor
            ),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
