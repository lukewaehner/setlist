//
//  WorkoutFeedViewController.swift
//  Setlist
//
//  Created by Waverly Hassman on 11/11/25.
//

import UIKit

class WorkoutFeedViewController: UIViewController {

    let workoutFeedView = WorkoutFeedView()
    var workoutPosts: [WorkoutPost] = []
    var workoutsCache: [String: Workout] = [:]
    let firebaseManager = WorkoutFirebaseManager.shared

    override func loadView() {
        view = workoutFeedView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Feed"

        // Setup table view
        workoutFeedView.workoutFeedTable.delegate = self
        workoutFeedView.workoutFeedTable.dataSource = self
        
        // Load workout posts
        loadWorkoutPosts()
        
        // Setup observer to refresh when posts change
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(workoutPostsChanged),
            name: NSNotification.Name("workoutPostsChanged"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func workoutPostsChanged() {
        print("📢 workoutPostsChanged notification received")
        loadWorkoutPosts()
    }
    
    private func loadWorkoutPosts() {
        Task { @MainActor [weak self] in
            do {
                // Fetch all workout posts from all users
                let posts = try await self?.firebaseManager.fetchAllWorkoutPosts(limit: 50)
                
                self?.workoutPosts = posts ?? []
                
                // Preload workouts for all posts
                await self?.preloadWorkouts()
                
                self?.workoutFeedView.workoutFeedTable.reloadData()
            } catch {
                self?.showError("Failed to load feed: \(error.localizedDescription)")
            }
        }
    }
    
    // Preload all workouts to avoid loading them individually in cells
    private func preloadWorkouts() async {
        for post in workoutPosts {
            // Skip if already cached
            if workoutsCache[post.workoutId] != nil {
                continue
            }
            
            do {
                if let workout = try await firebaseManager.fetchWorkout(byId: post.workoutId) {
                    workoutsCache[post.workoutId] = workout
                }
            } catch {
                print("Error loading workout \(post.workoutId): \(error)")
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
