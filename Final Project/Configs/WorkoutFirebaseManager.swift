//
//  WorkoutFirebaseManager.swift
//  Final Project
//
//  Created by Luke Waehner on 11/12/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import FirebaseStorage

// NOTE: For now all the methods are stubs, will create logic later
// Set MockWorkoutDataProvider.useMockData = true to use mock data for UI testing
class WorkoutFirebaseManager {
    static let shared = WorkoutFirebaseManager()

    private let mockProvider = MockWorkoutDataProvider.shared

    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    private let storage = Storage.storage()

    private init() {
    }

    // Get recent workouts for current user - home page recents
    func fetchRecentWorkouts(limit: Int = 5) async throws -> [Workout] {
        guard let userEmail = user?.email else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "No user email found, check logged in"
                ]
            )
        }

        let workoutsRef = db.collection("users")
            .document(userEmail)
            .collection("workouts")

        let snapshot = try await workoutsRef
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments()

        return try snapshot.documents.map { doc in
            try doc.data(as: Workout.self)
        }
    }

    // Get all workouts for current user - analytics / history
    func fetchAllWorkouts() async throws -> [Workout] {
        guard let userEmail = user?.email else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "No user email found, check logged in"
                ]
            )
        }

        let templatesRef = db.collection("users")
            .document(userEmail)
            .collection("workouts")

        // Fetch all documents asynchronously
        let snapshot = try await templatesRef.getDocuments()

        // Map Firestore documents → Workout model
        do {
            return try snapshot.documents.map { doc in
                try doc.data(as: Workout.self)
            }
        } catch {
            throw NSError(
                domain: "FirestoreDecode",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to decode a workout: \(error)"
                ]
            )
        }
    }

    // Get a specific workout by ID
    func fetchWorkout(byId workoutId: String) async throws -> Workout? {
        guard let userEmail = user?.email?.lowercased() else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "No user email found, check logged in"
                ]
            )
        }
        
        let docRef = db.collection("users")
            .document(userEmail)
            .collection("workouts")
            .document(workoutId)
        
        let snapshot = try await docRef.getDocument()
        
        guard snapshot.exists else {
            return nil
        }
        
        return try snapshot.data(as: Workout.self)
    }

    // Create a new workout
    func createWorkout(workout: Workout) async throws {
        // Save to UserDefaults
        guard let userEmail = user?.email else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "No user email found, check logged in"
                ]
            )
        }

        // Grab ref to the templates
        let templatesRef = db.collection("users").document(userEmail)
            .collection("workouts")
        // Grab ref to document (if exists)
        let docRef = templatesRef.document(workout.wid.uuidString)

        do {
            // Overwrite with merge: true
            try docRef.setData(from: workout, merge: true)
            // Post notification that templates changed
            NotificationCenter.default.post(
                name: NSNotification.Name("workoutHistoryChanged"),
                object: nil
            )
        } catch {
            throw NSError(
                domain: "WorkoutFirebaseManager",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to save workout template: \(error.localizedDescription)"
                ]
            )
        }
    }

    // Update an existing workout
    func updateWorkout(_: Workout) async throws {
        if MockWorkoutDataProvider.useMockData {
            // Just return nothing
            return
        }
        // NOTE: Implement actual Firebase update
    }

    // Delete a workout by Id
    func deleteWorkout(workoutId _: String) async throws {
        if MockWorkoutDataProvider.useMockData {
            // Just return nothing
            return
        }
        // NOTE: Implement actual Firebase delete
    }

    // Search workouts w/ q string
    func searchWorkouts(query: String) async throws -> [Workout] {
        if MockWorkoutDataProvider.useMockData {
            // Replicates search logic within mock data
            //            return mockProvider.searchMockWorkouts(query: query)
        }
        // NOTE: Implement actual Firebase search
        return []
    }

    // MARK: - Workout Template Methods

    private let templatesKey = "savedWorkoutTemplates"

    // Save a workout template to UserDefaults
    func saveWorkoutTemplate(_ template: WorkoutTemplate) async throws {

        // Save to UserDefaults
        guard let userEmail = user?.email!.lowercased() else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "No user email found, check logged in"
                ]
            )
        }

        // Grab ref to the templates
        let templatesRef = db.collection("users").document(userEmail)
            .collection("workoutTemplates")
        // Grab ref to document (if exists)
        let docRef = templatesRef.document(template.name)

        do {
            // Overwrite with merge: true
            try docRef.setData(from: template, merge: true)
            // Post notification that templates changed
            NotificationCenter.default.post(
                name: NSNotification.Name("workoutTemplatesChanged"),
                object: nil
            )
        } catch {
            throw NSError(
                domain: "WorkoutFirebaseManager",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to save workout template: \(error.localizedDescription)"
                ]
            )
        }
    }

    // Fetch all saved workout templates from UserDefaults
    func fetchWorkoutTemplates() async throws -> [WorkoutTemplate] {
        guard let userEmail = user?.email?.lowercased() else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "No user email found, check logged in"
                ]
            )
        }
        let collectionRef = db.collection("users").document(userEmail)
            .collection(
                "workoutTemplates"
            )
        let snapshot = try await collectionRef.getDocuments()
        let templates: [WorkoutTemplate] = try snapshot.documents.map {
            doc in
            try doc.data(as: WorkoutTemplate.self)
        }
        return templates
    }

    // Delete a workout template by name
    func deleteWorkoutTemplate(named name: String) async throws {
        guard let userEmail = user?.email?.lowercased() else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "No user email found, check logged in"
                ]
            )
        }

        let ref = db.collection("users")
            .document(userEmail)
            .collection("workoutTemplates")
            .document(name)

        try await ref.delete()

        NotificationCenter.default.post(
            name: NSNotification.Name("workoutTemplatesChanged"),
            object: nil
        )
    }

    // MARK: - Custom Exercise Methods

    // Save a custom exercise to Firebase
    func saveCustomExercise(_ exercise: String) async throws {

        guard let userEmail = user?.email else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "No user email found, check logged in"
                ]
            )
        }

        // Grab ref to the exercises
        let exercisesRef = db.collection("users").document(userEmail)
            .collection("customExercises")
        // Grab ref to document (if exists)
        let docRef = exercisesRef.document(exercise)

        do {
            // Overwrite with merge: true
            try await docRef.setData(["name": exercise], merge: true)
            // Post notification that exercises changed
            NotificationCenter.default.post(
                name: NSNotification.Name("customExercisesChanged"),
                object: nil
            )
        } catch {
            throw NSError(
                domain: "WorkoutFirebaseManager",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to save custom exercise: \(error.localizedDescription)"
                ]
            )
        }
    }

    // Fetch all custom exercises from Firebase
    func fetchCustomExercises() async throws -> [String] {
        guard let userEmail = user?.email?.lowercased() else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "No user email found, check logged in"
                ]
            )
        }
        let collectionRef = db.collection("users").document(userEmail)
            .collection(
                "customExercises"
            )
        let snapshot = try await collectionRef.getDocuments()
        let exercises: [String] = snapshot.documents.compactMap { doc in
            doc.data()["name"] as? String
        }
        return exercises.sorted()
    }

    // Delete a custom exercise by name
    func deleteCustomExercise(named name: String) async throws {
        guard let userEmail = user?.email?.lowercased() else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "No user email found, check logged in"
                ]
            )
        }

        let ref = db.collection("users")
            .document(userEmail)
            .collection("customExercises")
            .document(name)

        try await ref.delete()

        NotificationCenter.default.post(
            name: NSNotification.Name("customExercisesChanged"),
            object: nil
        )
    }
    
    // MARK: Workout Posts Methods
    
    // Create or update a workout post under the user's collection
    // This references a workout but doesn't modify the workout itself
    func saveWorkoutPost(_ post: WorkoutPost) async throws {
        guard let userEmail = user?.email?.lowercased() else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "No user email found, check logged in"
                ]
            )
        }
        
        // Store under users/{email}/workoutPosts/{postId}
        let postsRef = db.collection("users")
            .document(userEmail)
            .collection("workoutPosts")
        let docRef = postsRef.document(post.id)
        
        do {
            try docRef.setData(from: post, merge: true)
            
            // Post notification that posts changed
            NotificationCenter.default.post(
                name: NSNotification.Name("workoutPostsChanged"),
                object: nil
            )
        } catch {
            throw NSError(
                domain: "WorkoutFirebaseManager",
                code: 5,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Failed to save workout post: \(error.localizedDescription)"
                ]
            )
        }
    }

    // Delete a workout post from the user's collection
    func deleteWorkoutPost(postId: String) async throws {
        guard let userEmail = user?.email?.lowercased() else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "No user email found, check logged in"
                ]
            )
        }
        
        let docRef = db.collection("users")
            .document(userEmail)
            .collection("workoutPosts")
            .document(postId)
        
        try await docRef.delete()
        
        // Also delete the local image if it exists
        try? deleteImageLocally(workoutId: postId)
        
        // Post notification that posts changed
        NotificationCenter.default.post(
            name: NSNotification.Name("workoutPostsChanged"),
            object: nil
        )
    }

    // Fetch all workout posts for the current user
    func fetchMyWorkoutPosts(limit: Int = 50) async throws -> [WorkoutPost] {
        guard let userEmail = user?.email?.lowercased() else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "No user email found, check logged in"
                ]
            )
        }
        
        let postsRef = db.collection("users")
            .document(userEmail)
            .collection("workoutPosts")
            .order(by: "postedAt", descending: true)
            .limit(to: limit)
        
        let snapshot = try await postsRef.getDocuments()
        
        return try snapshot.documents.map { doc in
            try doc.data(as: WorkoutPost.self)
        }
    }

    func fetchAllWorkoutPosts(limit: Int = 50) async throws -> [WorkoutPost] {
        
        // First, get all user documents
        let usersSnapshot = try await db.collection("users").getDocuments()
        
        var allPosts: [WorkoutPost] = []
        
        // For each user, fetch their workout posts
        for userDoc in usersSnapshot.documents {
            let userEmail = userDoc.documentID
            
            do {
                let postsSnapshot = try await db.collection("users")
                    .document(userEmail)
                    .collection("workoutPosts")
                    .getDocuments()
                
                let userPosts = try postsSnapshot.documents.map { doc in
                    try doc.data(as: WorkoutPost.self)
                }
                
                allPosts.append(contentsOf: userPosts)
            } catch {
            }
        }
        
        // Sort all posts by date (most recent first)
        allPosts.sort { $0.postedAt > $1.postedAt }
        
        return Array(allPosts.prefix(limit))
    }
    
    // Fetch workout posts for a specific user (for viewing their profile)
    func fetchWorkoutPostsForUser(userEmail: String, limit: Int = 20) async throws -> [WorkoutPost] {
        let postsRef = db.collection("users")
            .document(userEmail.lowercased())
            .collection("workoutPosts")
            .order(by: "postedAt", descending: true)
            .limit(to: limit)
        
        let snapshot = try await postsRef.getDocuments()
        
        return try snapshot.documents.map { doc in
            try doc.data(as: WorkoutPost.self)
        }
    }
    
    // Fetch a specific workout post by ID for the current user
    func fetchWorkoutPost(postId: String) async throws -> WorkoutPost? {
        guard let userEmail = user?.email?.lowercased() else {
            throw NSError(
                domain: "Auth",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "No user email found, check logged in"
                ]
            )
        }
        
        let docRef = db.collection("users")
            .document(userEmail)
            .collection("workoutPosts")
            .document(postId)
        
        do {
            let document = try await docRef.getDocument()
            
            if document.exists {
                return try document.data(as: WorkoutPost.self)
            } else {
                return nil
            }
        } catch {
            // If document doesn't exist or there's a decoding error, return nil
            print("Error fetching workout post: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Replace uploadWorkoutImage with this:
    func saveImageLocally(_ image: UIImage, workoutId: String) throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw NSError(
                domain: "WorkoutFirebaseManager",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"]
            )
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagesFolderPath = documentsPath.appendingPathComponent("workout_images", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: imagesFolderPath, withIntermediateDirectories: true)
        
        let imagePath = imagesFolderPath.appendingPathComponent("\(workoutId).jpg")
        try imageData.write(to: imagePath)
        
        // Return just the filename to store in Firestore
        return workoutId
    }

    // Function to load the image later
    func loadImageLocally(workoutId: String) -> UIImage? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = documentsPath.appendingPathComponent("workout_images/\(workoutId).jpg")
        
        guard let imageData = try? Data(contentsOf: imagePath) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    // Delete local image
    func deleteImageLocally(workoutId: String) throws {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = documentsPath.appendingPathComponent("workout_images/\(workoutId).jpg")
        try FileManager.default.removeItem(at: imagePath)
    }
}
