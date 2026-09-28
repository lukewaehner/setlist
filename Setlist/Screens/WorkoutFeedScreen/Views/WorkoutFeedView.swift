//
//  WorkoutFeedView.swift
//  Setlist
//
//  Created by Waverly Hassman on 11/11/25.
//


import UIKit

class WorkoutFeedView: UIView {
    var workoutFeedTable: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setupTableViewWorkoutFeed()
        initConstraints()
    }
    
    func setupTableViewWorkoutFeed() {
        workoutFeedTable = UITableView()
        workoutFeedTable.register(WorkoutFeedTableViewCell.self, forCellReuseIdentifier: "WorkoutFeedCell")
        workoutFeedTable.separatorStyle = .none
        workoutFeedTable.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(workoutFeedTable)
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            
            workoutFeedTable.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: Design.Space.md),
            workoutFeedTable.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            workoutFeedTable.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            workoutFeedTable.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
