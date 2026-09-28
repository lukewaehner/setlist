//
//  Workout.swift
//  Setlist
//
//  Created by Waverly Hassman on 11/11/25.
//

import Foundation

// Data structure to represent a Workout
struct Workout: Codable {
    var wid: UUID
    var user: User  // Which user the workout belongs to
    var date: Date  // Date of workout
    var isCompleted: Bool  // Completed yet? Can have workouts in progress
    var template: WorkoutTemplate  // List of exercies in the workout
    var duration: TimeInterval?  // Duration
    var caption: String?  // Caption for workout - social feat
    var workoutPhotoURL: String?  // Optional photo URL for workout image

    init(
        wid: UUID = UUID(),
        user: User,
        date: Date,
        isCompleted: Bool,
        template: WorkoutTemplate,
        duration: TimeInterval,
        caption: String? = nil,
        workoutPhotoURL: String? = nil
    ) {
        self.wid = wid
        self.user = user
        self.date = date
        self.isCompleted = isCompleted
        self.template = template
        self.duration = duration
        self.caption = caption
        self.workoutPhotoURL = workoutPhotoURL
    }

    // Helper to get a formatted date string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

}

// Data structure to hold a template
struct WorkoutTemplate: Codable {
    var name: String  // "Upper Body", "Leg Day", etc.
    var description: String?  // Optional description
    var exercises: [WorkoutExercise]?

    init(
        name: String,
        description: String,
        exercises: [WorkoutExercise]
    ) {
        self.name = name
        self.description = description
        self.exercises = exercises
    }

    // Get exercise summary - shorthand display
    var exerciseSummary: String {
        let exerciseNames = exercises?.map { $0.name } ?? []
        if exerciseNames.isEmpty {
            return "No exercises"
        } else if exerciseNames.count <= 3 {
            return exerciseNames.joined(separator: ", ")
        } else {
            return exerciseNames.prefix(3).joined(separator: ", ")
                + " +\(exerciseNames.count - 3) more"
        }
    }

    // Helper to get total sets
    var totalSets: Int {
        return exercises?.reduce(0) { $0 + $1.sets.count } ?? 0
    }
}

// Data structure for exercises within a workout
struct WorkoutExercise: Codable {
    var name: String  // Name of exercise
    var category: String  // Category (e.g. "Chest", "Legs")
    var notes: String?  // Optional notes for the exercise
    var sets: [WorkoutSet]  // List of sets for the exercise

    init(
        name: String,
        category: String,
        notes: String? = nil,
        sets: [WorkoutSet]
    ) {
        self.name = name
        self.category = category
        self.notes = notes
        self.sets = sets
    }
}

// Data structure for sets within an exercise
struct WorkoutSet: Codable {
    var weight: Double
    var reps: Int
    var date: Date

    init(
        weight: Double,
        reps: Int,
        notes: String? = nil,
        date: Date
    ) {
        self.weight = weight
        self.reps = reps
        self.date = date
    }
}
