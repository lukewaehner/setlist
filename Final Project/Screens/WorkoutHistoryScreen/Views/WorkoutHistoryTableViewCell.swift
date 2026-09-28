//
//  WorkoutHistoryTableViewCell.swift
//  Final Project
//
//  Created by Luke Waehner on 11/12/25.
//

import UIKit

class WorkoutHistoryTableViewCell: UITableViewCell {
    var cardView: UIView!
    var nameLabel: UILabel!
    var dateLabel: UILabel!
    var editButton: UIButton!
    var statsStackView: UIStackView!
    var notesLabel: UILabel!

    var onEdit: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        selectionStyle = .none

        // Card container with rounded corners
        cardView = UIView()
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        // Workout name label
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        // Date label
        dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 15)
        dateLabel.textColor = .secondaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        // Edit button in top right
        editButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        editButton.setImage(UIImage(systemName: "pencil", withConfiguration: config), for: .normal)
        editButton.tintColor = .systemBlue
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)

        // Stack name and date vertically
        let headerStackView = UIStackView(arrangedSubviews: [nameLabel, dateLabel])
        headerStackView.axis = .vertical
        headerStackView.spacing = 4
        headerStackView.alignment = .leading
        headerStackView.translatesAutoresizingMaskIntoConstraints = false

        // Top row: header on left, edit button on right
        let topStackView = UIStackView(arrangedSubviews: [headerStackView, editButton])
        topStackView.axis = .horizontal
        topStackView.distribution = .equalSpacing
        topStackView.translatesAutoresizingMaskIntoConstraints = false

        // Stats pills (duration, sets, exercises, volume)
        statsStackView = UIStackView()
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 20
        statsStackView.translatesAutoresizingMaskIntoConstraints = false

        // Optional notes label
        notesLabel = UILabel()
        notesLabel.font = .systemFont(ofSize: 12)
        notesLabel.textColor = .secondaryLabel
        notesLabel.numberOfLines = 0
        notesLabel.translatesAutoresizingMaskIntoConstraints = false

        // Full card layout: top row, stats, notes
        let cardStackView = UIStackView(arrangedSubviews: [
            topStackView, statsStackView, notesLabel,
        ])
        cardStackView.axis = .vertical
        cardStackView.spacing = 12
        cardStackView.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(cardStackView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            cardStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            cardStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardStackView.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor, constant: -16),
            cardStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
        ])
    }

    @objc private func editButtonTapped() {
        onEdit?()
    }

    // Configure cell with workout data
    func configure(with workout: Workout, durationFormatter: (TimeInterval?) -> String) {
        // Set workout name and date
        nameLabel.text = workout.template.name

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateLabel.text = dateFormatter.string(from: workout.date)

        // Clear existing stats pills to overwrite (updater function)
        statsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Create stat pills for duration, sets, exercises, and volume
        let durationPill = createStatPill(
            icon: "clock", value: durationFormatter(workout.duration), label: "Duration")
        let setsPill = createStatPill(icon: "repeat", value: "\(workout.template.totalSets)", label: "Sets")
        let exercisesPill = createStatPill(
            icon: "dumbbell.fill", value: "\(workout.template.exercises?.count ?? 0)", label: "Exercises")

        // Calculate total volume (weight * reps for all sets)
        let totalVolume = workout.template.exercises?.flatMap { $0.sets }.reduce(0.0) {
            $0 + ($1.weight * Double($1.reps))
        } ?? 0
        let volumePill = createStatPill(
            icon: "scalemass", value: String(format: "%.0f kg", totalVolume), label: "Volume")

        // Add all stat pills to the stack
        statsStackView.addArrangedSubview(durationPill)
        statsStackView.addArrangedSubview(setsPill)
        statsStackView.addArrangedSubview(exercisesPill)
        statsStackView.addArrangedSubview(volumePill)

        // Show notes if they exist, hide otherwise
        if let notes = workout.template.description, !notes.isEmpty {
            notesLabel.text = notes
            notesLabel.isHidden = false
        } else {
            notesLabel.isHidden = true
        }
    }

    // Create a stat pill with icon, value, and label
    private func createStatPill(icon: String, value: String, label: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Icon image
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = .secondaryLabel
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        // Value label
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        // Label text
        let labelLabel = UILabel()
        labelLabel.text = label
        labelLabel.font = .systemFont(ofSize: 10)
        labelLabel.textColor = .secondaryLabel
        labelLabel.translatesAutoresizingMaskIntoConstraints = false

        // Top row: icon + value
        let topStackView = UIStackView(arrangedSubviews: [iconImageView, valueLabel])
        topStackView.axis = .horizontal
        topStackView.spacing = 4
        topStackView.alignment = .center
        topStackView.translatesAutoresizingMaskIntoConstraints = false

        // Full pill: top row + label below
        let pillStackView = UIStackView(arrangedSubviews: [topStackView, labelLabel])
        pillStackView.axis = .vertical
        pillStackView.spacing = 2
        pillStackView.alignment = .center
        pillStackView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(pillStackView)

        NSLayoutConstraint.activate([
            pillStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pillStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pillStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pillStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            iconImageView.widthAnchor.constraint(equalToConstant: 10),
            iconImageView.heightAnchor.constraint(equalToConstant: 10),
        ])

        return containerView
    }
}
