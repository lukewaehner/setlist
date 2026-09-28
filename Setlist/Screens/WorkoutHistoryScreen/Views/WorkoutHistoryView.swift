//
//  WorkoutHistoryView.swift
//  Setlist
//
//  Created by Luke Waehner on 11/12/25.
//

import UIKit

class WorkoutHistoryView: UIView {
    var tableView: UITableView!
    var emptyStateView: UIView!
    var emptyIconImageView: UIImageView!
    var emptyTitleLabel: UILabel!
    var emptyDescriptionLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground

        // Setup all the UI components
        setupTableView()
        setupEmptyState()
        initConstraints()
    }

    func setupTableView() {
        // Table view to display workout history cards
        tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
    }

    func setupEmptyState() {
        // Empty state shown when there are no workouts
        emptyStateView = UIView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false

        // Icon for empty state
        emptyIconImageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 64)
        emptyIconImageView.image = UIImage(
            systemName: "clock.arrow.circlepath", withConfiguration: config)
        emptyIconImageView.tintColor = .secondaryLabel
        emptyIconImageView.contentMode = .scaleAspectFit
        emptyIconImageView.translatesAutoresizingMaskIntoConstraints = false

        // Title and description
        emptyTitleLabel = UILabel()
        emptyTitleLabel.text = "No Workout History"
        emptyTitleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        emptyTitleLabel.textColor = .secondaryLabel
        emptyTitleLabel.textAlignment = .center
        emptyTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        emptyDescriptionLabel = UILabel()
        emptyDescriptionLabel.text = "Complete your first workout to see it here"
        emptyDescriptionLabel.font = .systemFont(ofSize: 15)
        emptyDescriptionLabel.textColor = .secondaryLabel
        emptyDescriptionLabel.textAlignment = .center
        emptyDescriptionLabel.numberOfLines = 0
        emptyDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Stack everything vertically and center
        let emptyStackView = UIStackView(arrangedSubviews: [
            emptyIconImageView, emptyTitleLabel, emptyDescriptionLabel,
        ])
        emptyStackView.axis = .vertical
        emptyStackView.spacing = 20
        emptyStackView.alignment = .center
        emptyStackView.translatesAutoresizingMaskIntoConstraints = false

        emptyStateView.addSubview(emptyStackView)

        NSLayoutConstraint.activate([
            emptyStackView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStackView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor),
            emptyStackView.leadingAnchor.constraint(
                greaterThanOrEqualTo: emptyStateView.leadingAnchor, constant: 16),
            emptyStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: emptyStateView.trailingAnchor, constant: -16),
        ])

        addSubview(emptyStateView)
    }

    func initConstraints() {
        NSLayoutConstraint.activate([

            // Table view
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Empty state
            emptyStateView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
