//
//  MainTabBarController.swift
//  Setlist
//
//  Created by Luke Waehner on 11/12/25.
//

import UIKit

// App's main tab bar wrapper to add the bar at bottom to switch screens
class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    private func setupTabBar() {
        // Add in home view
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house.fill"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        // Add in workout feed
        let workoutFeedVC = WorkoutFeedViewController()
        workoutFeedVC.tabBarItem = UITabBarItem(
            title: "Feed",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )

        // Add in history
        let workoutHistoryVC = WorkoutHistoryViewController()
        workoutHistoryVC.tabBarItem = UITabBarItem(
            title: "History",
            image: UIImage(systemName: "clock"),
            selectedImage: UIImage(systemName: "clock")
        )

        // NOTE: Add in analytics here

        let analyticsVC = AnalyticsViewController()
        analyticsVC.tabBarItem = UITabBarItem(
            title: "Analytics",
            image: UIImage(systemName: "chart.bar"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )

        let workoutTemplateVC = ExerciseSelectionViewController()
        workoutTemplateVC.tabBarItem = UITabBarItem(
            title: "Templates",
            image: UIImage(systemName: "square.grid.2x2"),
            selectedImage: UIImage(systemName: "square.grid.2x2.fill")
        )

        // Wrap each in navigation controller to maintain navigation bars
        let homeNav = UINavigationController(rootViewController: homeVC)
        let workoutFeedNav = UINavigationController(rootViewController: workoutFeedVC)
        let workoutHistoryNav = UINavigationController(rootViewController: workoutHistoryVC)
        let analyticsNav = UINavigationController(rootViewController: analyticsVC)
        let workoutTemplateNav = UINavigationController(rootViewController: workoutTemplateVC)

        // Assign view controllers to tab bar
        viewControllers = [
            homeNav, workoutFeedNav, workoutHistoryNav, analyticsNav, workoutTemplateNav,
        ]
    }
}
