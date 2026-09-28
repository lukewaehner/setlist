//
//  WorkoutHistoryViewController.swift
//  Setlist
//
//  Created by Luke Waehner on 11/12/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class WorkoutHistoryViewController: UIViewController {
    let workoutHistoryView = WorkoutHistoryView()
    var completedWorkouts: [Workout] = []
    var selectedWorkout: Workout?
    private let firebaseManager = WorkoutFirebaseManager.shared

    override func loadView() {
        view = workoutHistoryView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        title = "History"

        // table view setup
        workoutHistoryView.tableView.delegate = self
        workoutHistoryView.tableView.dataSource = self
        workoutHistoryView.tableView.register(
            WorkoutHistoryTableViewCell.self, forCellReuseIdentifier: "WorkoutHistoryCell")
        workoutHistoryView.tableView.rowHeight = UITableView.automaticDimension
        workoutHistoryView.tableView.estimatedRowHeight = 150

        // Load workouts
        loadWorkouts()

        // Setup observer to track changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(workoutDataChanged),
            name: NSNotification.Name("workoutHistoryChanged"),
            object: nil
        )
    }

    // Reload workouts when data changes
    @objc private func workoutDataChanged() {
        loadWorkouts()
    }

    // Load workouts from Firebase
    private func loadWorkouts() {
        Task { @MainActor [weak self] in
            do {
                let workouts = try await self?.firebaseManager.fetchAllWorkouts()
                // Only get completed workouts, then sort by date
                self?.completedWorkouts = workouts?.filter { $0.isCompleted } ?? []
                self?.completedWorkouts.sort { $0.date > $1.date }
                self?.workoutHistoryView.tableView.reloadData()
                self?.updateEmptyState()
            } catch {
                print("Error fetching workouts: \(error)")
            }
        }
    }

    // Swap between empty state and table view
    private func updateEmptyState() {
        workoutHistoryView.emptyStateView.isHidden = !completedWorkouts.isEmpty
        workoutHistoryView.tableView.isHidden = completedWorkouts.isEmpty
    }

    // Format duration for display
    private func formatDuration(_ seconds: TimeInterval?) -> String {
        guard let seconds = seconds else {
            return "N/A"
        }
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // Handle edit workout - show modal
    private func handleEditWorkout(_ workout: Workout) {
        let modal = WorkoutMediaModalViewController(workout: workout)
        modal.modalPresentationStyle = .pageSheet
        
        if let sheet = modal.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        modal.onSave = { [weak self] image, caption in
            self?.saveWorkoutMedia(workout: workout, image: image!, caption: caption)
        }
        
        present(modal, animated: true)
    }
    
    // Save the image and caption to the workout
    private func saveWorkoutMedia(workout: Workout, image: UIImage, caption: String) {
        // Show loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Saving...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: loadingAlert.view.topAnchor, constant: 50)
        ])
        present(loadingAlert, animated: true)
        
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            var updatedWorkout = workout
            updatedWorkout.caption = caption.isEmpty ? nil : caption
            
            do {
                // Save image locally and get the reference (workoutId)
                let imageReference = try self.firebaseManager.saveImageLocally(
                    image,
                    workoutId: workout.wid.uuidString
                )
                // Store the workout ID as the reference
                updatedWorkout.workoutPhotoURL = imageReference
            
                // Update workout in Firestore
                try await self.firebaseManager.updateWorkout(updatedWorkout)
                
                // Create or update workout post if there's a caption or image
                try await self.createWorkoutPost(from: updatedWorkout, imageReference: updatedWorkout.workoutPhotoURL!, caption: caption)
                
                // Refresh the table to show updated data
                self.loadWorkouts()
                
                loadingAlert.dismiss(animated: true)
            } catch {
                loadingAlert.dismiss(animated: true) {
                    self.showError("Failed to save: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Create a workout post from a workout (posts are separate from workouts)
    private func createWorkoutPost(from workout: Workout, imageReference: String, caption: String) async throws {
        guard let userEmail = Auth.auth().currentUser?.email else {
            throw NSError(domain: "Auth", code: 1, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
        }
        
        // Get user's display name
        let userName = Auth.auth().currentUser?.displayName ?? userEmail.components(separatedBy: "@").first ?? "User"
        
        // Create workout post with reference to workout
        let post = WorkoutPost(
            id: workout.wid.uuidString,
            userId: userEmail,
            userName: userName,
            workoutId: workout.wid.uuidString,  // Reference only
            caption: caption,
            imageURL: imageReference,
            postedAt: Date(),
            likes: 0,
            likedBy: []
        )
        
        // Save to Firebase
        try await firebaseManager.saveWorkoutPost(post)
    }
    
    // Show error alert
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// Table view delegate and data source
extension WorkoutHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return completedWorkouts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "WorkoutHistoryCell", for: indexPath)
            as! WorkoutHistoryTableViewCell
        let workout = completedWorkouts[indexPath.row]
        cell.configure(with: workout, durationFormatter: formatDuration)
        cell.onEdit = { [weak self] in
            self?.handleEditWorkout(workout)
        }
        return cell
    }

    // Update workout in Firebase
    func updateWorkout(_ workout: Workout) {
        Task { @MainActor [weak self] in
            do {
                try await self?.firebaseManager.updateWorkout(workout)
            } catch {
                print("Error updating workout: \(error)")
                self?.showError("Failed to update workout: \(error.localizedDescription)")
            }
        }
    }

    // Delete workout from Firebase
    func deleteWorkout(workoutId: String) {
        Task { @MainActor [weak self] in
            do {
                try await self?.firebaseManager.deleteWorkout(workoutId: workoutId)
            } catch {
                print("Error deleting workout: \(error)")
            }
        }
    }
}
