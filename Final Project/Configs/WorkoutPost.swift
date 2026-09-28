//
//  WorkoutPost.swift
//  Final Project
//
//  Created by Waverly Hassman on 12/7/25.
//

import Foundation

struct WorkoutPost: Codable, Identifiable {
    let id: String           // Post ID (same as workoutId to link them)
    let userId: String       // Email of user who posted
    let userName: String     // Display name
    let workoutId: String    // Reference to workout in workouts collection
    var caption: String     // Optional caption
    var imageURL: String    // Local image reference (workoutId)
    let postedAt: Date       // When posted
    var likes: Int
    var likedBy: [String]
    
    init(id: String, userId: String, userName: String, workoutId: String,
         caption: String, imageURL: String, postedAt: Date, likes: Int, likedBy: [String]) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.workoutId = workoutId
        self.caption = caption
        self.imageURL = imageURL
        self.postedAt = postedAt
        self.likes = likes
        self.likedBy = likedBy
    }
}
