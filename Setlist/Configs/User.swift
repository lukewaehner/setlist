//
//  User.swift
//  Setlist
//
//  Created by Waverly Hassman on 11/11/25.
//

import Foundation

// Data structure to represent a User in the app
struct User: Codable {
    var name: String
    var email: String
    var profilePhotoURL: String?
    var weight: Int32?
    var height: Int32?
    var savedWorkouts: [Workout]? // Optionally save finished templates to pre-fill a workout from
    var savedWorkoutTemplates: [WorkoutTemplate]?
    
    init(name: String, email: String, profilePhotoURL: String? = nil) {
        self.name = name
        self.email = email
        self.profilePhotoURL = profilePhotoURL
    }
}
