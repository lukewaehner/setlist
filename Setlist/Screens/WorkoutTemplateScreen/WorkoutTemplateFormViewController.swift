import UIKit

class WorkoutTemplateFormViewController: UIViewController {
    private var isEditMode: Bool = false
    private var templateToEdit: WorkoutTemplate?
    var onTemplateSaved: ((WorkoutTemplate) -> Void)?
    
    var workoutTemplateFormView: WorkoutTemplateFormView {
        return view as! WorkoutTemplateFormView
    }

    private let firebaseManager = WorkoutFirebaseManager.shared

    private var workoutExercises: [WorkoutExercise] = [] {
        didSet {
            workoutTemplateFormView.updateExercisesSummary(count: workoutExercises.count)
            workoutTemplateFormView.exercisesTableView.reloadData()
            updateExercisesTableViewHeight()
        }
    }

    private var exercisesTableViewHeightConstraint: NSLayoutConstraint?
    
    init(editingTemplate: WorkoutTemplate? = nil) {
        self.templateToEdit = editingTemplate
        self.isEditMode = editingTemplate != nil
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateExercisesTableViewHeight() {
        let rowHeight: CGFloat = 50
        let minHeight: CGFloat = 100
        let maxHeight: CGFloat = 300
        let calculatedHeight = min(
            max(CGFloat(workoutExercises.count) * rowHeight, minHeight), maxHeight)

        // Update or create height constraint
        if let existingConstraint = exercisesTableViewHeightConstraint {
            existingConstraint.constant = calculatedHeight
        } else {
            exercisesTableViewHeightConstraint = workoutTemplateFormView.exercisesTableView
                .heightAnchor.constraint(equalToConstant: calculatedHeight)
            exercisesTableViewHeightConstraint?.isActive = true
        }
    }

    override func loadView() {
        view = WorkoutTemplateFormView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupDelegate()
        setupExercisesTableView()
        updateExercisesTableViewHeight()
        
        if isEditMode, let template = templateToEdit {
            prefillForm(with: template)
        }
    }

    private func setupDelegate() {
        workoutTemplateFormView.delegate = self
    }

    private func setupExercisesTableView() {
        workoutTemplateFormView.exercisesTableView.delegate = self
        workoutTemplateFormView.exercisesTableView.dataSource = self
        workoutTemplateFormView.exercisesTableView.register(
            UITableViewCell.self, forCellReuseIdentifier: "ExerciseCell")
        workoutTemplateFormView.exercisesTableView.allowsMultipleSelectionDuringEditing = false
        // Allow swipe-to-delete
        workoutTemplateFormView.exercisesTableView.isEditing = false
    }
    
    private func prefillForm(with template: WorkoutTemplate) {
        workoutTemplateFormView.nameTextField.text = template.name
        workoutTemplateFormView.notesTextField.text = template.description
        workoutExercises = template.exercises ?? []
        
        // Update the title and save button text
        title = "Edit Template"
    }

    private func presentExercisePicker() {
        let exercisePickerVC = ExercisePickerViewController()
        exercisePickerVC.delegate = self
        // Pass currently selected exercises so they show as selected
        exercisePickerVC.previouslySelectedExercises = workoutExercises.map { $0.name }

        let navController = UINavigationController(rootViewController: exercisePickerVC)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
        }

        present(navController, animated: true, completion: nil)
    }

    private func saveTemplate() {
        // Validate form
        guard
            let templateName = workoutTemplateFormView.nameTextField.text?.trimmingCharacters(
                in: .whitespacesAndNewlines),
            !templateName.isEmpty
        else {
            showAlert(title: "Missing Name", message: "Please enter a template name.")
            return
        }

        guard !workoutExercises.isEmpty else {
            showAlert(
                title: "No Exercises", message: "Please add at least one exercise to the template.")
            return
        }

        // Get notes (optional)
        let notes = workoutTemplateFormView.notesTextField.text?.trimmingCharacters(
            in: .whitespacesAndNewlines)
        let notesString = notes?.isEmpty == false ? notes : nil

        // Create the template - description is optional in struct, but init requires String
        // So we'll use empty string if notes is nil
        let template = WorkoutTemplate(
            name: templateName,
            description: notesString ?? "",
            exercises: workoutExercises
        )

        // Save the template
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                if self.isEditMode,
                   let oldTemplate = self.templateToEdit,
                   oldTemplate.name != templateName {
                    try await self.firebaseManager.deleteWorkoutTemplate(named: oldTemplate.name)
                }
                try await self.firebaseManager.saveWorkoutTemplate(template)
                self.onTemplateSaved?(template)
                self.dismiss(animated: true)
            } catch {
                self.showAlert(
                    title: "Error",
                    message: "Failed to save template: \(error.localizedDescription)")
            }
        }
    }
}

extension WorkoutTemplateFormViewController: WorkoutTemplateFormViewDelegate {
    func workoutTemplateFormView(
        _ view: WorkoutTemplateFormView, didTapAddExercisesButton button: UIButton
    ) {
        presentExercisePicker()
    }

    func workoutTemplateFormView(_ view: WorkoutTemplateFormView, didTapSaveButton button: UIButton)
    {
        saveTemplate()
    }

    // Helper function to categorize exercises
    private func getCategoryForExercise(_ exerciseName: String) -> String {
        let name = exerciseName.lowercased()

        // Chest exercises
        if name.contains("bench") || name.contains("press") && name.contains("chest")
            || name.contains("fly") || name.contains("push-up")
        {
            return "Chest"
        }

        // Shoulder exercises
        if name.contains("overhead") || name.contains("lateral") || name.contains("shoulder")
            || name.contains("press") && !name.contains("bench")
        {
            return "Shoulders"
        }

        // Tricep exercises
        if name.contains("tricep") || name.contains("dip") {
            return "Triceps"
        }

        // Back exercises
        if name.contains("row") || name.contains("pull") || name.contains("lat")
            || name.contains("deadlift")
        {
            return "Back"
        }

        // Bicep exercises
        if name.contains("bicep") || name.contains("curl") || name.contains("hammer") {
            return "Biceps"
        }

        // Leg exercises
        if name.contains("squat") || name.contains("leg") || name.contains("calf")
            || name.contains("romanian")
        {
            return "Legs"
        }

        // Default category
        return "Other"
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension WorkoutTemplateFormViewController: ExercisePickerDelegate {
    func exercisePicker(
        _ picker: ExercisePickerViewController, didSelectExercises exercises: [String]
    ) {
        // Convert exercise names to WorkoutExercise objects, preserving existing ones if they exist
        let existingExerciseNames = Set(workoutExercises.map { $0.name })
        let newExerciseNames = Set(exercises).subtracting(existingExerciseNames)

        // Add new exercises
        let newExercises = newExerciseNames.map { exerciseName in
            WorkoutExercise(
                name: exerciseName,
                category: getCategoryForExercise(exerciseName),
                notes: nil,
                sets: []
            )
        }

        // Keep existing exercises that are still selected, remove ones that aren't
        let updatedExercises = workoutExercises.filter { exercises.contains($0.name) }

        // Combine updated and new exercises
        workoutExercises = updatedExercises + newExercises
    }
}

extension WorkoutTemplateFormViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutExercises.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Use subtitle style cell to show detail text
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ExerciseCell")
        let exercise = workoutExercises[indexPath.row]

        cell.textLabel?.text = exercise.name
        cell.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)

        // Show category and sets info
        var detailParts: [String] = [exercise.category]
        let setsCount = exercise.sets.count
        // Always show sets count
        detailParts.append("\(setsCount) set\(setsCount == 1 ? "" : "s")")
        if let notes = exercise.notes, !notes.isEmpty {
            detailParts.append("Notes")
        }
        cell.detailTextLabel?.text = detailParts.joined(separator: " • ")
        cell.detailTextLabel?.font = .systemFont(ofSize: 13)
        cell.detailTextLabel?.textColor = .secondaryLabel

        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let exercise = workoutExercises[indexPath.row]
        showExerciseConfiguration(for: exercise, at: indexPath.row)
    }

    func tableView(
        _ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            workoutExercises.remove(at: indexPath.row)
        }
    }

    private func showExerciseConfiguration(for exercise: WorkoutExercise, at index: Int) {
        let alert = UIAlertController(
            title: "Configure Exercise", message: exercise.name, preferredStyle: .alert)

        // Add sets configuration
        alert.addTextField { textField in
            textField.placeholder = "Number of sets (default: 0)"
            textField.keyboardType = .numberPad
            textField.text = exercise.sets.count > 0 ? "\(exercise.sets.count)" : ""
        }

        // Add notes field
        alert.addTextField { textField in
            textField.placeholder = "Notes (optional)"
            textField.text = exercise.notes
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                guard let self = self else { return }
                let setsField = alert.textFields?[0]
                let notesField = alert.textFields?[1]

                let setsCount = Int(setsField?.text ?? "0") ?? 0
                let notes = notesField?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                let notesString = notes?.isEmpty == false ? notes : nil

                // Create sets if needed
                var sets: [WorkoutSet] = []
                if setsCount > 0 {
                    // Create placeholder sets (weight and reps will be set during actual workout)
                    sets = (0..<setsCount).map { _ in
                        WorkoutSet(weight: 0, reps: 0, date: Date())
                    }
                }

                // Update the exercise
                var updatedExercise = exercise
                updatedExercise.sets = sets
                updatedExercise.notes = notesString

                self.workoutExercises[index] = updatedExercise
            })

        present(alert, animated: true)
    }
}
