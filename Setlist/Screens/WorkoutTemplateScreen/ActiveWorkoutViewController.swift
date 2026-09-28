//
//  ActiveWorkoutViewController.swift
//  Setlist
//
//  Created by Luke Waehner on 12/7/25.
//

import UIKit

class ActiveWorkoutViewController: UIViewController {
    private var template: WorkoutTemplate
    private var tableViewHeightConstraint: NSLayoutConstraint?

    var activeWorkoutView: TemplateDetailView {
        return view as! TemplateDetailView
    }

    init(template: WorkoutTemplate) {
        self.template = template
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = TemplateDetailView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Active Workout"
        setupNavigationBar()
        setupTableView()
        activeWorkoutView.configure(with: template)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(workoutTemplateUpdated),
            name: ActiveWorkoutManager.workoutTemplateUpdatedNotification,
            object: nil
        )
    }

    @objc private func workoutTemplateUpdated() {
        if let current = ActiveWorkoutManager.shared.currentWorkout?.template {
            template = current
            activeWorkoutView.exercisesTableView.reloadData()
            view.layoutIfNeeded()
            updateTableViewHeight()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeight()
    }

    private func updateTableViewHeight() {
        activeWorkoutView.exercisesTableView.layoutIfNeeded()
        let height = activeWorkoutView.exercisesTableView.contentSize.height

        if let existingConstraint = tableViewHeightConstraint {
            existingConstraint.isActive = false
        }

        tableViewHeightConstraint = activeWorkoutView.exercisesTableView.heightAnchor.constraint(equalToConstant: height)
        tableViewHeightConstraint?.isActive = true
    }

    private func setupNavigationBar() {
        let finishButton = UIBarButtonItem(
            title: "Finish",
            style: .done,
            target: self,
            action: #selector(finishWorkoutTapped)
        )

        let addExerciseButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addExerciseTapped)
        )

        let renameButton = UIBarButtonItem(
            image: UIImage(systemName: "pencil"),
            style: .plain,
            target: self,
            action: #selector(renameWorkoutTapped)
        )

        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelWorkoutTapped)
        )
        cancelButton.tintColor = .systemRed

        navigationItem.rightBarButtonItems = [finishButton, addExerciseButton, renameButton]
        navigationItem.leftBarButtonItem = cancelButton
    }

    @objc private func cancelWorkoutTapped() {
        let alert = UIAlertController(title: "Cancel Workout", message: "Are you sure? This will discard the current session.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue Workout", style: .cancel))
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { [weak self] _ in
            ActiveWorkoutManager.shared.discardWorkout()
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func renameWorkoutTapped() {
        let alert = UIAlertController(title: "Rename Workout", message: "Enter a new name for this session", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Workout Name"
            tf.text = self.template.name
            tf.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                ActiveWorkoutManager.shared.renameWorkout(to: newName)
            }
        })
        present(alert, animated: true)
    }

    @objc private func addExerciseTapped() {
        let picker = ExercisePickerViewController()
        picker.delegate = self
        let nav = UINavigationController(rootViewController: picker)
        present(nav, animated: true)
    }

    @objc private func finishWorkoutTapped() {
        let alert = UIAlertController(
            title: "Finish Workout",
            message: "Are you sure you are done?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Finish", style: .default) { [weak self] _ in
                Task { @MainActor in
                    await ActiveWorkoutManager.shared.endWorkout()
                    self?.dismiss(animated: true)
                }
            }
        )
        present(alert, animated: true)
    }

    private func setupTableView() {
        activeWorkoutView.exercisesTableView.delegate = self
        activeWorkoutView.exercisesTableView.dataSource = self
        activeWorkoutView.exercisesTableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "ExerciseCell"
        )
    }

    private func showEditSetsAlert(for index: Int) {
        guard var exercise = template.exercises?[index] else { return }

        let alert = UIAlertController(
            title: "Edit Sets: \(exercise.name)",
            message: "Enter sets, reps, weight",
            preferredStyle: .alert
        )

        // Add text fields for Weight and Reps
        alert.addTextField { tf in
            tf.placeholder = "Weight (kg)"
            tf.keyboardType = .decimalPad
        }
        alert.addTextField { tf in
            tf.placeholder = "Reps"
            tf.keyboardType = .numberPad
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Add Set", style: .default) { _ in
                let weight = Double(alert.textFields?[0].text ?? "") ?? 0
                let reps = Int(alert.textFields?[1].text ?? "") ?? 0

                let newSet = WorkoutSet(
                    weight: weight,
                    reps: reps,
                    date: Date()
                )
                exercise.sets.append(newSet)

                // Update the template in the manager
                var newTemplate = self.template
                newTemplate.exercises?[index] = exercise
                ActiveWorkoutManager.shared.updateWorkoutTemplate(newTemplate)
            }
        )

        present(alert, animated: true)
    }
}

extension ActiveWorkoutViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return template.exercises?.count ?? 0
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = UITableViewCell(
            style: .subtitle,
            reuseIdentifier: "ExerciseCell"
        )
        guard let exercise = template.exercises?[indexPath.row] else {
            return cell
        }

        cell.textLabel?.text = exercise.name
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        var detailParts: [String] = []
        detailParts.append(exercise.category)

        // Always show sets count, even if 0
        detailParts.append(
            "\(exercise.sets.count) set\(exercise.sets.count == 1 ? "" : "s")"
        )

        // Show set details if sets exist
        if exercise.sets.count > 0 {
            let setsWithData = exercise.sets.filter {
                $0.weight > 0 || $0.reps > 0
            }
            if setsWithData.count > 0 {
                let setsInfo = setsWithData.map {
                    "\(Int($0.weight))kg x \($0.reps)"
                }.joined(
                    separator: ", "
                )
                detailParts.append(setsInfo)
            }
        }

        if let notes = exercise.notes, !notes.isEmpty {
            detailParts.append("Notes: \(notes)")
        }

        cell.detailTextLabel?.text = detailParts.joined(separator: " • ")
        cell.detailTextLabel?.font = .systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.numberOfLines = 0

        cell.backgroundColor = .clear

        let isCompleted = ActiveWorkoutManager.shared.isExerciseCompleted(
            at: indexPath.row
        )
        cell.accessoryType = isCompleted ? .checkmark : .detailButton // Use detailButton for edit
        cell.selectionStyle = .default

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        ActiveWorkoutManager.shared.toggleExerciseCompletion(
            at: indexPath.row
        )
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    // Handle accessory tap for editing sets
    func tableView(
        _: UITableView,
        accessoryButtonTappedForRowWith indexPath: IndexPath
    ) {
        showEditSetsAlert(for: indexPath.row)
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ActiveWorkoutViewController: ExercisePickerDelegate {
    func exercisePicker(
        _: ExercisePickerViewController,
        didSelectExercises exercises: [String]
    ) {
        // Add selected exercises to the current template
        var currentExercises = template.exercises ?? []

        for name in exercises {
            // Check if already exists? Or allow duplicates? Usually allow distinct entries.
            // Create a default WorkoutExercise
            let newExercise = WorkoutExercise(
                name: name,
                category: "General",
                sets: []
            )
            currentExercises.append(newExercise)
        }

        var newTemplate = template
        newTemplate.exercises = currentExercises

        ActiveWorkoutManager.shared.updateWorkoutTemplate(newTemplate)
    }
}
