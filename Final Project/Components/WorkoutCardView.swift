//
//  WorkoutCardView.swift
//  Final Project
//
//  Created by Luke Waehner on 11/12/25.
//

import UIKit

class WorkoutCardView: UIView {
    private var nameLabel: UILabel!
    private var dateLabel: UILabel!
    private var editButton: UIButton!
    private var durationLabel: UILabel!
    private var setsLabel: UILabel!
    private var completedLabel: UILabel!

    var onEdit: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        translatesAutoresizingMaskIntoConstraints = false

        // Top row: Name, Edit, Date
        // Name Label: Workout Split Name
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // Date Label: Date of Workout
        dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        // Edit Button: Pencil icon to edit workout
        editButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12)
        editButton.setImage(UIImage(systemName: "pencil", withConfiguration: config), for: .normal)
        editButton.tintColor = .systemBlue
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)

        // Setup stack view
        let topStackView = UIStackView(arrangedSubviews: [nameLabel, editButton, dateLabel])
        topStackView.axis = .horizontal
        topStackView.spacing = 8
        topStackView.distribution = .fill
        topStackView.translatesAutoresizingMaskIntoConstraints = false

        let clockImageView = UIImageView()
        clockImageView.image = UIImage(systemName: "clock")
        clockImageView.tintColor = .secondaryLabel
        clockImageView.contentMode = .scaleAspectFit
        clockImageView.translatesAutoresizingMaskIntoConstraints = false

        // Bottom row: Duration, Sets, Completed
        // Duration Label: Time taken for workout
        durationLabel = UILabel()
        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.textColor = .secondaryLabel
        durationLabel.translatesAutoresizingMaskIntoConstraints = false

        // Sets Label: Number of sets and exercises
        setsLabel = UILabel()
        setsLabel.font = .systemFont(ofSize: 12)
        setsLabel.textColor = .secondaryLabel
        setsLabel.translatesAutoresizingMaskIntoConstraints = false

        // Completed Label: Checkmark icon and "Completed" text
        let checkmarkImageView = UIImageView()
        checkmarkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkImageView.tintColor = .systemGreen
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false

        completedLabel = UILabel()
        completedLabel.text = "Completed"
        completedLabel.font = .systemFont(ofSize: 12)
        completedLabel.textColor = .systemGreen
        completedLabel.translatesAutoresizingMaskIntoConstraints = false

        // Duration Label + Icon
        let durationStackView = UIStackView(arrangedSubviews: [clockImageView, durationLabel])
        durationStackView.axis = .horizontal
        durationStackView.spacing = 4
        durationStackView.translatesAutoresizingMaskIntoConstraints = false

        // Completed Label + Icon
        let completedStackView = UIStackView(arrangedSubviews: [checkmarkImageView, completedLabel])
        completedStackView.axis = .horizontal
        completedStackView.spacing = 4
        completedStackView.translatesAutoresizingMaskIntoConstraints = false

        // Push to stack
        let bottomStackView = UIStackView(arrangedSubviews: [
            durationStackView, setsLabel, completedStackView,
        ])
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .equalSpacing
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false

        // Stack the rows
        let cardStackView = UIStackView(arrangedSubviews: [topStackView, bottomStackView])
        cardStackView.axis = .vertical
        cardStackView.spacing = 8
        cardStackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(cardStackView)

        NSLayoutConstraint.activate([
            cardStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            cardStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cardStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cardStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            clockImageView.widthAnchor.constraint(equalToConstant: 12),
            clockImageView.heightAnchor.constraint(equalToConstant: 12),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 12),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 12),
        ])
    }

    @objc private func editButtonTapped() {
        // Send a call to onEdit -> different definitions for different uses
        onEdit?()
    }

    // Configure the card with workout metadata
    func configure(
        splitName: String, date: String, duration: String, sets: String, showEditButton: Bool = true
    ) {
        nameLabel.text = splitName
        dateLabel.text = date
        durationLabel.text = duration
        setsLabel.text = sets
        editButton.isHidden = !showEditButton
    }

    // Configure the card directly from a workout object
    func configure(from workout: Workout, showEditButton: Bool = true) {
        // Setup date string for display
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: workout.date)

        // Format the duration (handle optional)
        let durationString: String
        if let duration = workout.duration {
            durationString = WorkoutCardView.formatDuration(duration)
        } else {
            durationString = "N/A"
        }

        // Use totalSets and exercises.count from Workout struct
        let setsString = "\(workout.template.totalSets) sets • \(workout.template.exercises?.count) exercises"

        // Outsource to overloaded method
        configure(
            splitName: workout.template.name,
            date: dateString,
            duration: durationString,
            sets: setsString,
            showEditButton: showEditButton
        )
    }

    // Seconds -> "1h 30m" or "45m"
    static func formatDuration(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
