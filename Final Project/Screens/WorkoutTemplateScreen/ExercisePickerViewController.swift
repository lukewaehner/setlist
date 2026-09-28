//
//  ExercisePickerViewController.swift
//  Final Project
//
//  Created by Andrew Kenny on 11/13/25.
//

import UIKit

protocol ExercisePickerDelegate: AnyObject {
    func exercisePicker(_ picker: ExercisePickerViewController, didSelectExercises exercises: [String])
}

class ExercisePickerViewController: UIViewController {
    weak var delegate: ExercisePickerDelegate?
    
    private let exerciseSelectionView = ExerciseSelectionView()
    private let firebaseManager = WorkoutFirebaseManager.shared
    
    // Predefined exercises list - cannot be deleted
    private let predefinedExercises = [
        "Bench Press", "Incline Dumbbell Press", "Overhead Press", "Lateral Raises",
        "Tricep Dips", "Tricep Pushdowns", "Barbell Rows", "Pull-ups",
        "Lat Pulldowns", "Bicep Curls", "Hammer Curls", "Squats",
        "Leg Press", "Romanian Deadlifts", "Leg Curls", "Calf Raises",
        "Deadlifts", "Barbell Curls", "Cable Flyes", "Push-ups"
    ]
    
    // Combined list of predefined + custom exercises
    private var availableExercises: [String] = []
    
    private var selectedExercises: Set<String> = []
    
    private func loadExercises() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let customExercises = try await self.firebaseManager.fetchCustomExercises()
                self.availableExercises = (self.predefinedExercises + customExercises).sorted()
                
                // Reload table on main actor
                if let tableView = self.exerciseSelectionView.exercisesTableView?.tableView {
                    await MainActor.run {
                        tableView.reloadData()
                    }
                }
            } catch {
                print("Failed to load exercises: \(error)")
            }
        }
    }
    
    // Allow setting previously selected exercises
    var previouslySelectedExercises: [String] = [] {
        didSet {
            selectedExercises = Set(previouslySelectedExercises)
        }
    }
    
    override func loadView() {
        view = exerciseSelectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Select Exercises"
        
        loadExercises()
        setupTableView()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload table to show checkmarks for previously selected exercises
        if let tableView = exerciseSelectionView.exercisesTableView?.tableView {
            tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        guard let tableView = exerciseSelectionView.exercisesTableView?.tableView else {
            return
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsMultipleSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExerciseCell")
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        // Add button to add custom exercise
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addCustomExerciseTapped)
        )
        if let doneButton = navigationItem.rightBarButtonItem {
            navigationItem.rightBarButtonItems = [doneButton, addButton]
        } else {
            navigationItem.rightBarButtonItem = addButton
        }
    }
    
    @objc private func addCustomExerciseTapped() {
        let alert = UIAlertController(
            title: "Add Custom Exercise",
            message: "Enter the name of your exercise",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Exercise name"
            textField.autocapitalizationType = .words
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let exerciseName = textField.text?
                    .trimmingCharacters(in: .whitespacesAndNewlines),
                  !exerciseName.isEmpty else {
                return
            }
            
            // Run async Firebase work in a Task so we can use `await`
            Task { [weak self] in
                guard let self = self else { return }
                
                do {
                    // async call – this is now legal because we're inside Task
                    try await self.firebaseManager.saveCustomExercise(exerciseName)
                    
                    // Reload exercises after saving
                    self.loadExercises()   // if `loadExercises` is async
                    // OR just `self.loadExercises()` if you changed it to non-async
                    
                    // Automatically select the new exercise
                    self.selectedExercises.insert(exerciseName)
                    
                    // UI updates on main actor
                    await MainActor.run {
                        if let tableView = self.exerciseSelectionView.exercisesTableView?.tableView {
                            tableView.reloadData()
                        }
                    }
                } catch {
                    print("Error saving custom exercise: \(error)")
                }
            }
        })
        
        present(alert, animated: true)
    }

    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func doneTapped() {
        let selected = Array(selectedExercises)
        delegate?.exercisePicker(self, didSelectExercises: selected)
        dismiss(animated: true)
    }
}

extension ExercisePickerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableExercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath)
        let exercise = availableExercises[indexPath.row]
        cell.textLabel?.text = exercise
        cell.accessoryType = selectedExercises.contains(exercise) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let exercise = availableExercises[indexPath.row]
        
        if selectedExercises.contains(exercise) {
            selectedExercises.remove(exercise)
        } else {
            selectedExercises.insert(exercise)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let exercise = availableExercises[indexPath.row]
            
            // Delete from persistent storage if it's a custom exercise
            if !predefinedExercises.contains(exercise) {
                Task { [weak self] in
                    guard let self = self else { return }
                    do {
                        try await self.firebaseManager.deleteCustomExercise(named: exercise)
                        
                        self.selectedExercises.remove(exercise)
                        self.loadExercises()  // or self.loadExercises() if non-async
                        
                        await MainActor.run {
                            tableView.reloadData()
                        }
                    } catch {
                        print("Error deleting custom exercise: \(error)")
                    }
                }
            } else {
                // For predefined ones you don't call delete, just update selection / UI if needed
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Allow deletion of custom exercises (those not in the predefined list)
        let exercise = availableExercises[indexPath.row]
        return !predefinedExercises.contains(exercise)
    }
}

