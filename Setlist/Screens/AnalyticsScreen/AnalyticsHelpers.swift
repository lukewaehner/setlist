//
//  AnalyticsHelpers.swift
//  Setlist
//
//  Created by Andrew Kenny on 12/7/25.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
import Foundation

extension Workout {
    var totalVolume: Double {
        guard let exercises = template.exercises else { return 0 }
        return exercises.reduce(0) { workoutSum, exercise in
            workoutSum + exercise.sets.reduce(0) { setSum, set in
                setSum + set.weight * Double(set.reps)
            }
        }
    }

    var totalSets: Int {
        return template.totalSets
    }
}

struct AnalyticsCalculator {

    struct AnalyticsResult {
        let totalVolume: Double
        let totalWorkouts: Int
        let totalSets: Int
        let avgDurationMinutes: Double?
        let totalDurationMinutes: Double?
        let bestVolumeDay: (date: Date, volume: Double)?
        let mostActiveDay: (date: Date, count: Int)?
        let avgSetsPerWorkout: Double
        let consistencyPerDay: Double
        let mostPopularExercise: (name: String, count: Int)?
    }

    static func compute(for workouts: [Workout], since fromDate: Date?) -> AnalyticsResult {
        let filtered = workouts.filter { workout in
            guard workout.isCompleted else { return false }
            if let from = fromDate { return workout.date >= from }
            return true
        }

        if filtered.isEmpty {
            return AnalyticsResult(
                totalVolume: 0,
                totalWorkouts: 0,
                totalSets: 0,
                avgDurationMinutes: nil,
                totalDurationMinutes: nil,
                bestVolumeDay: nil,
                mostActiveDay: nil,
                avgSetsPerWorkout: 0,
                consistencyPerDay: 0,
                mostPopularExercise: nil
            )
        }

        let totalVolume = filtered.reduce(0) { $0 + $1.totalVolume }
        let totalSets = filtered.reduce(0) { $0 + $1.totalSets }
        let totalWorkouts = filtered.count

        // Duration
        let durations = filtered.compactMap { $0.duration }
        let avgDurationMinutes = durations.isEmpty
            ? nil
            : (durations.reduce(0, +) / Double(durations.count) / 60.0)
        let totalDurationMinutes = durations.isEmpty
            ? nil
            : (durations.reduce(0, +) / 60.0)
        
        // Most popular exercise
        var exerciseCounts: [String: Int] = [:]
        for workout in filtered {
            if let exercises = workout.template.exercises {
                for exercise in exercises {
                    exerciseCounts[exercise.name, default: 0] += 1
                }
            }
        }
        let mostPopularExercise = exerciseCounts.max(by: { $0.value < $1.value })

        let calendar = Calendar.current

        // Best volume day
        let volumeByDay = Dictionary(grouping: filtered) { calendar.startOfDay(for: $0.date) }
            .mapValues { dayWorkouts in
                dayWorkouts.reduce(0) { $0 + $1.totalVolume }
            }
        let bestDay = volumeByDay.max(by: { $0.value < $1.value })

        // Most active day
        let workoutsByDay = Dictionary(grouping: filtered) { calendar.startOfDay(for: $0.date) }
        let activeDay = workoutsByDay.max(by: { $0.value.count < $1.value.count })

        // Avg sets / workout
        let avgSetsPerWorkout = Double(totalSets) / Double(totalWorkouts)

        // Consistency
        var consistencyPerDay = 0.0
        if let fromDate = fromDate {
            let days = max(1, calendar.dateComponents([.day], from: fromDate, to: Date()).day ?? 1)
            consistencyPerDay = Double(totalWorkouts) / Double(days)
        }

        return AnalyticsResult(
            totalVolume: totalVolume,
            totalWorkouts: totalWorkouts,
            totalSets: totalSets,
            avgDurationMinutes: avgDurationMinutes,
            totalDurationMinutes: totalDurationMinutes,
            bestVolumeDay: bestDay.map { ($0.key, $0.value) },
            mostActiveDay: activeDay.map { ($0.key, $0.value.count) },
            avgSetsPerWorkout: avgSetsPerWorkout,
            consistencyPerDay: consistencyPerDay,
            mostPopularExercise: mostPopularExercise.map { ($0.key, $0.value) }
        )
    }
}

