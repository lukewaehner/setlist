//
//  ActiveWorkoutManager.swift
//  Setlist
//
//  Created by Luke Waehner on 12/7/25.
//

import FirebaseAuth
import Foundation

class ActiveWorkoutManager {
    static let shared = ActiveWorkoutManager()
    private let firebaseManager = WorkoutFirebaseManager.shared

    var currentWorkout: Workout?
    var timer: Timer?
    var elapsedTime: TimeInterval = 0

    var completedExerciseIndices: Set<Int> = []

    // MARK: - Notifications

    static let workoutDidStartNotification = Notification.Name("ActiveWorkoutManagerDidStart")
    static let workoutDidTickNotification = Notification.Name("ActiveWorkoutManagerDidTick")
    static let workoutDidEndNotification = Notification.Name("ActiveWorkoutManagerDidEnd")
    static let workoutProgressChangedNotification = Notification.Name("ActiveWorkoutManagerProgressChanged")
    static let workoutTemplateUpdatedNotification = Notification.Name("ActiveWorkoutManagerTemplateUpdated")

    private init() {}

    // MARK: - Actions

    func startWorkout(template: WorkoutTemplate) {
        // Ensure no existing workout
        guard currentWorkout == nil else { return }

        // Create User object from Auth
        let firebaseUser = Auth.auth().currentUser
        let user = User(
            name: firebaseUser?.displayName ?? "Guest",
            email: firebaseUser?.email ?? "guest@example.com"
        )

        // Initialize new Workout
        currentWorkout = Workout(
            user: user,
            date: Date(),
            isCompleted: false,
            template: template,
            duration: 0
        )

        elapsedTime = 0
        completedExerciseIndices.removeAll()

        startTimer()

        NotificationCenter.default.post(name: Self.workoutDidStartNotification, object: nil)
        postProgressUpdate()
    }

    func endWorkout() async {
        guard var workout = currentWorkout else { return }

        stopTimer()

        // Finalize workout data
        workout.duration = elapsedTime
        workout.isCompleted = true

        do {
            try await firebaseManager.createWorkout(workout: workout)
        } catch {
            print("Failed to save workout")
        }

        currentWorkout = nil
        elapsedTime = 0
        completedExerciseIndices.removeAll()

        NotificationCenter.default.post(name: Self.workoutDidEndNotification, object: nil)
    }

    func discardWorkout() {
        guard currentWorkout != nil else { return }

        stopTimer()
        currentWorkout = nil
        elapsedTime = 0
        completedExerciseIndices.removeAll()

        NotificationCenter.default.post(name: Self.workoutDidEndNotification, object: nil)
    }

    func renameWorkout(to name: String) {
        currentWorkout?.template.name = name
        NotificationCenter.default.post(name: Self.workoutTemplateUpdatedNotification, object: nil)
    }

    // Update the workout template (add exercise, edit sets, etc)
    func updateWorkoutTemplate(_ template: WorkoutTemplate) {
        currentWorkout?.template = template
        NotificationCenter.default.post(name: Self.workoutTemplateUpdatedNotification, object: nil)
        postProgressUpdate()
    }

    // Toggle exercise completion
    func toggleExerciseCompletion(at index: Int) {
        if completedExerciseIndices.contains(index) {
            completedExerciseIndices.remove(index)
        } else {
            completedExerciseIndices.insert(index)
        }
        postProgressUpdate()
    }

    func isExerciseCompleted(at index: Int) -> Bool {
        return completedExerciseIndices.contains(index)
    }

    // MARK: - Timer Logic

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        elapsedTime += 1
        // Notify listeners (UI)
        NotificationCenter.default.post(
            name: Self.workoutDidTickNotification,
            object: nil,
            userInfo: ["elapsedTime": elapsedTime]
        )
    }

    private func postProgressUpdate() {
        let total = currentWorkout?.template.exercises?.count ?? 0
        let completed = completedExerciseIndices.count
        let progress = total > 0 ? Float(completed) / Float(total) : 0.0

        NotificationCenter.default.post(
            name: Self.workoutProgressChangedNotification,
            object: nil,
            userInfo: ["progress": progress]
        )
    }

    // Helper for formatting time
    func formattedDuration() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60

        if hours > 0 {
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
