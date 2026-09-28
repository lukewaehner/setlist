//
//  WorkoutFeedTableViewController.swift
//  Final Project
//
//  Created by Waverly Hassman on 11/11/25.
//

import UIKit

extension WorkoutFeedViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutPosts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutFeedCell", for: indexPath)
            as! WorkoutFeedTableViewCell
        
        let post = workoutPosts[indexPath.row]
        
        // Safely get the workout from cache
        guard let workout = workoutsCache[post.workoutId] else {
            // Return a blank cell or show loading state
            return cell
        }
        
        // Load local image if available
        let image = firebaseManager.loadImageLocally(workoutId: post.imageURL)
        
        let caption = post.caption
        
        // Configure cell with post data, workout, and image
        cell.configure(with: post, workout: workout, image: image, caption: caption)
        cell.selectionStyle = .none
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
