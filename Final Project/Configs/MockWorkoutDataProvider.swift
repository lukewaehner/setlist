//
//  MockWorkoutDataProvider.swift
//  Final Project
//
//  Created by Luke Waehner on 11/16/25.
//

import Foundation

/// Creates Mock Workout Data to simulate conditional UI rendering
/// before backend logic is finished
class MockWorkoutDataProvider {
    static let shared = MockWorkoutDataProvider()

    // This flag can be toggled to stop using mock data quickly in @WorkoutFirebaseManager.swift
    static var useMockData = false

    private init() {}

    // Sample user for mock workouts
    private let mockUser = User(
        name: "John Doe",
        email: "john.doe@example.com",
        profilePhotoURL: nil
    )

    // Generate mock workouts
    func generateMockWorkouts() -> [Workout] {
        let calendar = Calendar.current
        let now = Date()

        var workouts: [Workout] = []

        // Push Day - 2 days ago
        if let pushDayDate = calendar.date(byAdding: .day, value: -2, to: now) {
            workouts.append(createPushDayWorkout(date: pushDayDate))
        }

        // Pull Day - 3 days ago
        if let pullDayDate = calendar.date(byAdding: .day, value: -3, to: now) {
            workouts.append(createPullDayWorkout(date: pullDayDate))
        }

        // Leg Day - 5 days ago
        if let legDayDate = calendar.date(byAdding: .day, value: -5, to: now) {
            workouts.append(createLegDayWorkout(date: legDayDate))
        }

        // Upper Body - 7 days ago
        if let upperDate = calendar.date(byAdding: .day, value: -7, to: now) {
            workouts.append(createUpperBodyWorkout(date: upperDate))
        }

        // Push Day - 9 days ago
        if let pushDayDate2 = calendar.date(byAdding: .day, value: -9, to: now)
        {
            workouts.append(
                createPushDayWorkout(
                    date: pushDayDate2,
                    notes: "Felt strong today!"
                )
            )
        }

        return workouts
    }

    // Create a Push Day workout
    private func createPushDayWorkout(date: Date, notes: String? = nil)
        -> Workout
    {
        let exercises = WorkoutTemplate(
            name: "Push Day",
            description: "Test",
            exercises: [
                WorkoutExercise(
                    name: "Bench Press",
                    category: "Chest",
                    notes: nil,
                    sets: [
                        WorkoutSet(
                            weight: 80,
                            reps: 8,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 80,
                            reps: 8,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 80,
                            reps: 6,
                            notes: nil,
                            date: date
                        ),
                    ]
                ),
                WorkoutExercise(
                    name: "Overhead Press",
                    category: "Shoulders",
                    notes: nil,
                    sets: [
                        WorkoutSet(
                            weight: 50,
                            reps: 10,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 50,
                            reps: 10,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 50,
                            reps: 8,
                            notes: nil,
                            date: date
                        ),
                    ]
                ),
                WorkoutExercise(
                    name: "Tricep Dips",
                    category: "Triceps",
                    notes: nil,
                    sets: [
                        WorkoutSet(
                            weight: 0,
                            reps: 12,
                            notes: "Bodyweight",
                            date: date
                        ),
                        WorkoutSet(
                            weight: 0,
                            reps: 12,
                            notes: "Bodyweight",
                            date: date
                        ),
                        WorkoutSet(
                            weight: 0,
                            reps: 10,
                            notes: "Bodyweight",
                            date: date
                        ),
                    ]
                ),
            ]
        )

        return Workout(
            user: mockUser,
            date: date,
            isCompleted: true,
            template: exercises,
            duration: (60 * 60),
            caption: "Great push session!",
            workoutPhotoURL: nil
        )
    }

    // Create a Pull Day workout
    private func createPullDayWorkout(date: Date) -> Workout {
        let exercises = WorkoutTemplate(
            name: "Back",
            description: "Focus on your back muscles.",
            exercises: [
                WorkoutExercise(
                    name: "Deadlift",
                    category: "Back",
                    notes: nil,
                    sets: [
                        WorkoutSet(
                            weight: 120,
                            reps: 5,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 120,
                            reps: 5,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 120,
                            reps: 5,
                            notes: nil,
                            date: date
                        ),
                    ]
                ),
                WorkoutExercise(
                    name: "Pull-ups",
                    category: "Back",
                    notes: nil,
                    sets: [
                        WorkoutSet(
                            weight: 0,
                            reps: 10,
                            notes: "Bodyweight",
                            date: date
                        ),
                        WorkoutSet(
                            weight: 0,
                            reps: 8,
                            notes: "Bodyweight",
                            date: date
                        ),
                        WorkoutSet(
                            weight: 0,
                            reps: 8,
                            notes: "Bodyweight",
                            date: date
                        ),
                    ]
                ),
                WorkoutExercise(
                    name: "Barbell Rows",
                    category: "Back",
                    notes: nil,
                    sets: [
                        WorkoutSet(
                            weight: 70,
                            reps: 10,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 70,
                            reps: 10,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 70,
                            reps: 8,
                            notes: nil,
                            date: date
                        ),
                    ]
                ),
                WorkoutExercise(
                    name: "Bicep Curls",
                    category: "Biceps",
                    notes: nil,
                    sets: [
                        WorkoutSet(
                            weight: 20,
                            reps: 12,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 20,
                            reps: 12,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 20,
                            reps: 10,
                            notes: nil,
                            date: date
                        ),
                    ]
                ),
            ]
        )

        return Workout(
            user: mockUser,
            date: date,
            isCompleted: true,
            template: exercises,
            duration: (65 * 60),
            caption: "Back day complete!",
            workoutPhotoURL: nil
        )
    }

    // Create a Leg Day workout
    private func createLegDayWorkout(date: Date) -> Workout {
        let exercises = WorkoutTemplate(
            name: "Leg",
            description: "leg day",
            exercises: [
                WorkoutExercise(
                    name: "Squats",
                    category: "Legs",
                    notes: nil,
                    sets: [
                        WorkoutSet(
                            weight: 100,
                            reps: 8,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 100,
                            reps: 8,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 100,
                            reps: 6,
                            notes: nil,
                            date: date
                        ),
                    ]
                ),
                WorkoutExercise(
                    name: "Romanian Deadlifts",
                    category: "Legs",
                    notes: nil,
                    sets: [
                        WorkoutSet(
                            weight: 80,
                            reps: 10,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 80,
                            reps: 10,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 80,
                            reps: 8,
                            notes: nil,
                            date: date
                        ),
                    ]
                ),
                WorkoutExercise(
                    name: "Leg Press",
                    category: "Legs",
                    notes: nil,
                    sets: [
                        WorkoutSet(
                            weight: 150,
                            reps: 12,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 150,
                            reps: 12,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 150,
                            reps: 10,
                            notes: nil,
                            date: date
                        ),
                    ]
                ),
            ]
        )

        return Workout(
            user: mockUser,
            date: date,
            isCompleted: true,
            template: exercises,
            duration: (70 * 60),
            caption: nil,
            workoutPhotoURL: nil
        )
    }

    // Create an Upper Body workout
    private func createUpperBodyWorkout(date: Date) -> Workout {
        let exercises = WorkoutTemplate(
            name: "Upper Body",
            description: "Test",
            exercises: [
                WorkoutExercise(
                    name: "Bench Press",
                    category: "Chest",
                    notes: nil,
                    sets: [
                        WorkoutSet(
                            weight: 75,
                            reps: 10,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 75,
                            reps: 8,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 75,
                            reps: 8,
                            notes: nil,
                            date: date
                        ),
                    ]
                ),
                WorkoutExercise(
                    name: "Lat Pulldowns",
                    category: "Back",
                    notes: nil,
                    sets: [
                        WorkoutSet(
                            weight: 60,
                            reps: 12,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 60,
                            reps: 10,
                            notes: nil,
                            date: date
                        ),
                        WorkoutSet(
                            weight: 60,
                            reps: 10,
                            notes: nil,
                            date: date
                        ),
                    ]
                ),
            ]
        )

        return Workout(
            user: mockUser,
            date: date,
            isCompleted: true,
            template: exercises,
            duration: (45 * 60),
            caption: nil,
            workoutPhotoURL: nil
        )
    }

    // Search mock workouts by query
    func searchMockWorkouts(query: String) -> [Workout] {
        let allWorkouts = generateMockWorkouts()
        let lowercasedQuery = query.lowercased()

        return allWorkouts.filter { workout in
            workout.template.name.lowercased().contains(lowercasedQuery)
                || ((workout.template.exercises?.contains {
                    $0.name.lowercased().contains(lowercasedQuery)
                }) != nil)
        }
    }
}
