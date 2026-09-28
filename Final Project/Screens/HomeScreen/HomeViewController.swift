//
//  HomeViewController.swift
//  Final Project
//
//  Created by Luke Waehner on 11/11/25.
//

import FirebaseAuth
import UIKit

class HomeViewController: UIViewController {
    let homeView = HomeView()

    // Init firebase
    private let firebaseManager = WorkoutFirebaseManager.shared
    private let activeWorkoutManager = ActiveWorkoutManager.shared

    override func loadView() {
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecentWorkouts()

        // Setup observer to track changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(workoutDataChanged),
            name: NSNotification.Name("workoutDataChanged"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authStateChanged),
            name: NSNotification.Name("authStateChanged"),
            object: nil
        )

        // Push login/register/logout modal on profile button press
        homeView.profileButton.addTarget(
            self,
            action: #selector(onProfileButtonTapped),
            for: .touchUpInside
        )

        // Quick Start
        homeView.workoutButton.addTarget(
            self,
            action: #selector(onQuickStartTapped),
            for: .touchUpInside
        )

        // Banner Tap
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(onBannerTapped)
        )
        homeView.activeWorkoutBanner.addGestureRecognizer(tapGesture)

        setupActiveWorkoutObservers()
        tryGrabUserProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBannerState()
    }

    private func setupActiveWorkoutObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(workoutDidStart),
            name: ActiveWorkoutManager.workoutDidStartNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(workoutDidTick(_:)),
            name: ActiveWorkoutManager.workoutDidTickNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(workoutDidEnd),
            name: ActiveWorkoutManager.workoutDidEndNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(workoutProgressChanged(_:)),
            name: ActiveWorkoutManager.workoutProgressChangedNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(workoutTemplateUpdated),
            name: ActiveWorkoutManager.workoutTemplateUpdatedNotification,
            object: nil
        )
    }

    @objc private func workoutTemplateUpdated() {
        updateBannerState()
    }

    @objc private func workoutDidStart() {
        updateBannerState()
    }

    @objc private func workoutDidTick(_: Notification) {
        homeView.timeLabel.text = activeWorkoutManager.formattedDuration()
    }

    @objc private func workoutDidEnd() {
        updateBannerState()
        loadRecentWorkouts()
    }

    @objc private func workoutProgressChanged(_ notification: Notification) {
        if let progress = notification.userInfo?["progress"] as? Float {
            homeView.progressView.setProgress(progress, animated: true)
        }
    }

    private func updateBannerState() {
        if let workout = activeWorkoutManager.currentWorkout {
            homeView.activeWorkoutBanner.isHidden = false
            homeView.activeLabel.text = "Active: \(workout.template.name)"
            homeView.splitLabel.text = workout.template.exerciseSummary
            homeView.timeLabel.text = activeWorkoutManager.formattedDuration()

            let total = workout.template.exercises?.count ?? 0
            let completed = activeWorkoutManager.completedExerciseIndices.count
            let progress = total > 0 ? Float(completed) / Float(total) : 0.0
            homeView.progressView.progress = progress
        } else {
            homeView.activeWorkoutBanner.isHidden = true
        }
    }

    private func presentActiveWorkout() {
        if let workout = activeWorkoutManager.currentWorkout {
            let detailVC = ActiveWorkoutViewController(
                template: workout.template
            )

            let nav = UINavigationController(rootViewController: detailVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }

    @objc private func onBannerTapped() {
        if let workout = activeWorkoutManager.currentWorkout {
            let detailVC = ActiveWorkoutViewController(template: workout.template)

            let nav = UINavigationController(rootViewController: detailVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }

    @objc private func onQuickStartTapped() {
        let startVC = WorkoutStartViewController()

        // Handle closure callbacks
        startVC.onSelectEmpty = { [weak self] in
            let emptyTemplate = WorkoutTemplate(
                name: "Empty Workout",
                description: "",
                exercises: []
            )
            self?.activeWorkoutManager.startWorkout(template: emptyTemplate)
            self?.presentActiveWorkout()
        }

        startVC.onSelectTemplate = { [weak self] template in
            self?.activeWorkoutManager.startWorkout(template: template)
            self?.presentActiveWorkout()
        }

        let nav = UINavigationController(rootViewController: startVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    @objc private func onUserLoggedOut() {
        homeView.nameLabel.text = "Welcome, Guest!"
    }

    @objc private func authStateChanged() {
        tryGrabUserProfile()
    }

    @objc private func onProfileButtonTapped() {
        if Auth.auth().currentUser == nil {
            let loginVC = AuthViewController()
            loginVC.mode = .login
            loginVC.modalPresentationStyle = .pageSheet

            if let sheet = loginVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
            present(loginVC, animated: true)
        } else {
            let logoutVC = AuthViewController()
            logoutVC.mode = .logout
            logoutVC.modalPresentationStyle = .formSheet

            if let sheet = logoutVC.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = false
                sheet.preferredCornerRadius = 20
            }

            present(logoutVC, animated: true)
        }
    }

    // Reload workouts when data changes
    @objc private func workoutDataChanged() {
        loadRecentWorkouts()
    }

    // Get 5 most recent workouts for display
    private func loadRecentWorkouts() {
        // Run all tasks on the main actor
        Task { @MainActor [weak self] in
            do {
                let workouts = try await self?.firebaseManager
                    .fetchRecentWorkouts(limit: 5)
                self?.displayWorkouts(workouts?.filter { $0.isCompleted } ?? [])
            } catch {
                print("Error fetching recent workouts: \(error)")
            }
        }
    }

    private func tryGrabUserProfile() {
        let user = Auth.auth().currentUser
        let displayName = user?.displayName ?? "Guest"
        homeView.nameLabel.text = "Welcome, \(displayName)!"
    }

    // Create a WorkoutCard for each item
    private func displayWorkouts(_ workouts: [Workout]) {
        homeView.clearWorkoutCards()

        for (_, workout) in workouts.enumerated() {
            let card = WorkoutCardView()
            // Dont toggle edit button for home screen
            card.configure(from: workout, showEditButton: false)
            card.onEdit = { [] in
                // NOTE: Change if we want editing capabilities for home screen
            }
            homeView.addWorkoutCard(card)
        }
    }
}
