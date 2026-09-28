//
//  AnalyticsDashboardViewController.swift
//  Final Project
//
//  Created by Andrew Kenny on 11/13/25.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
import Foundation

class AnalyticsViewController: UIViewController {

    private let analyticsView = AnalyticsDashboardView()
    private let workoutManager = WorkoutFirebaseManager.shared

    private var allWorkouts: [Workout] = []

    override func loadView() {
        view = analyticsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Analytics"
        analyticsView.filterControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await loadWorkouts()
        }
    }

    private func loadWorkouts() async {
        do {
            let workouts = try await workoutManager.fetchAllWorkouts()
            print("Fetched \(workouts.count) workouts for analytics")

            await MainActor.run {
                self.allWorkouts = workouts
                self.updateAnalytics()
            }
        } catch {
            print("Failed to fetch workouts:", error)
        }
    }

    @objc private func filterChanged() {
        updateAnalytics()
    }

    private func updateAnalytics() {
        let fromDate = dateFromFilterSelection()
        let result = AnalyticsCalculator.compute(for: allWorkouts, since: fromDate)

        analyticsView.totalVolumeCard.setValue("\(Int(result.totalVolume)) kg")
        analyticsView.workoutsCard.setValue("\(result.totalWorkouts)")
        analyticsView.totalSetsCard.setValue("\(result.totalSets)")

        if let avg = result.avgDurationMinutes {
            analyticsView.avgDurationCard.setValue(String(format: "%.1f min", avg))
        } else {
            analyticsView.avgDurationCard.setValue("--")
        }

        if let best = result.bestVolumeDay {
            analyticsView.bestVolumeDayCard.setValue("\(Int(best.volume)) kg")
        } else {
            analyticsView.bestVolumeDayCard.setValue("--")
        }

        if let active = result.mostActiveDay {
            let workoutText = active.count == 1 ? "workout" : "workouts"
            analyticsView.mostActiveDayCard.setValue("\(active.count) \(workoutText)")
        } else {
            analyticsView.mostActiveDayCard.setValue("--")
        }

        analyticsView.avgSetsPerWorkoutCard.setValue(String(format: "%.1f", result.avgSetsPerWorkout))
        
        if result.consistencyPerDay > 0 && result.consistencyPerDay < 0.1 {
            analyticsView.consistencyCard.setValue("< 0.1 / Day")
        } else {
            analyticsView.consistencyCard.setValue(String(format: "%.1f / Day", result.consistencyPerDay))
        }

        if let totalDuration = result.totalDurationMinutes {
            analyticsView.durationCard.setValue(String(format: "%.1f min", totalDuration))
        } else {
            analyticsView.durationCard.setValue("--")
        }

        if let popular = result.mostPopularExercise {
            analyticsView.mostPopularExerciseCard.setValue("\(popular.name) (\(popular.count)x)")
        } else {
            analyticsView.mostPopularExerciseCard.setValue("--")
        }
    }

    private func dateFromFilterSelection() -> Date? {
        let now = Date()
        let segment = analyticsView.filterControl.selectedSegmentIndex
        let calendar = Calendar.current

        switch segment {
        case 0: return calendar.date(byAdding: .day, value: -1, to: now)
        case 1: return calendar.date(byAdding: .day, value: -7, to: now)
        case 2: return calendar.date(byAdding: .month, value: -1, to: now)
        case 3: return calendar.date(byAdding: .year, value: -1, to: now)
        default: return nil
        }
    }
}
