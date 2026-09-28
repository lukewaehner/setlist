//
//  WorkoutFeedTableViewCell.swift
//  Setlist
//
//  Created by Waverly Hassman on 11/11/25.
//

import UIKit

class WorkoutFeedTableViewCell: UITableViewCell {
    
    var wrapperCellView: UIView!
    var userNameLabel: UILabel!
    var dateLabel: UILabel!
    var workoutPhotoView: UIImageView!
    var splitNameLabel: UILabel!
    var exerciseSummaryLabel: UILabel!
    var captionLabel: UILabel!
    
    let imagePadding: CGFloat = 16
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        initConstraints()
    }
    
    private func setupViews() {
        // Wrapper
        wrapperCellView = UIView()
        wrapperCellView.backgroundColor = .clear
        wrapperCellView.layer.cornerRadius = 12
        wrapperCellView.layer.shadowColor = UIColor.black.cgColor
        wrapperCellView.layer.shadowOffset = CGSize(width: 0, height: 2)
        wrapperCellView.layer.shadowRadius = 4
        wrapperCellView.layer.shadowOpacity = 0.1
        wrapperCellView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrapperCellView)
        
        // Username
        userNameLabel = UILabel()
        userNameLabel.font = .boldSystemFont(ofSize: 16)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(userNameLabel)
        
        // Date
        dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .systemGray
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(dateLabel)
        
        // Workout Photo
        workoutPhotoView = UIImageView()
        workoutPhotoView.contentMode = .scaleAspectFill
        workoutPhotoView.clipsToBounds = true
        workoutPhotoView.layer.cornerRadius = 12
        workoutPhotoView.backgroundColor = .clear
        workoutPhotoView.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(workoutPhotoView)
        
        // Split Name
        splitNameLabel = UILabel()
        splitNameLabel.font = .boldSystemFont(ofSize: 20)
        splitNameLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(splitNameLabel)
        
        // Exercise Summary
        exerciseSummaryLabel = UILabel()
        exerciseSummaryLabel.font = .systemFont(ofSize: 14)
        exerciseSummaryLabel.textColor = .systemGray
        exerciseSummaryLabel.numberOfLines = 2
        exerciseSummaryLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(exerciseSummaryLabel)
        
        // Caption
        captionLabel = UILabel()
        captionLabel.font = .systemFont(ofSize: 15)
        captionLabel.textColor = .darkGray
        captionLabel.numberOfLines = 0
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        wrapperCellView.addSubview(captionLabel)
    }
    
    func configure(with post: WorkoutPost, workout: Workout, image: UIImage?, caption: String, profileImage: UIImage? = nil) {
        userNameLabel.text = post.userName
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        dateLabel.text = formatter.localizedString(for: post.postedAt, relativeTo: Date())
        
        // Workout photo - ALWAYS set the image, even if nil
        workoutPhotoView.image = image
        
        // Show/hide photo based on whether image exists
        if image != nil {
            workoutPhotoView.isHidden = false
            workoutPhotoView.image = image
            workoutPhotoView.backgroundColor = .clear
        } else {
            workoutPhotoView.image = nil
            workoutPhotoView.backgroundColor = .systemGray6
            workoutPhotoView.isHidden = true
            
        }
        
        splitNameLabel.text = workout.template.name
        exerciseSummaryLabel.text = "\(workout.template.totalSets) sets • \(workout.template.exerciseSummary)"
        captionLabel.text = caption
        
        // Force layout update
        layoutIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Clear all content
        userNameLabel.text = nil
        dateLabel.text = nil
        workoutPhotoView.image = nil
        workoutPhotoView.isHidden = false
        splitNameLabel.text = nil
        exerciseSummaryLabel.text = nil
        captionLabel.text = nil
    }
    
    private func initConstraints() {
        let padding: CGFloat = 12
        
        NSLayoutConstraint.activate([
            // Wrapper
            wrapperCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            wrapperCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            wrapperCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            wrapperCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // USERNAME - Top left, inside the card
            userNameLabel.topAnchor.constraint(equalTo: wrapperCellView.topAnchor, constant: padding),
            userNameLabel.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: padding),
            userNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: wrapperCellView.trailingAnchor, constant: -padding),
            
            // DATE - Directly under username
            dateLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            
            // WORKOUT PHOTO - Below the header (username + date)
            workoutPhotoView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            workoutPhotoView.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: imagePadding),
            workoutPhotoView.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -imagePadding),
            workoutPhotoView.heightAnchor.constraint(equalTo: workoutPhotoView.widthAnchor), // 1:1 square
            
            // SPLIT NAME
            splitNameLabel.topAnchor.constraint(equalTo: workoutPhotoView.bottomAnchor, constant: 16),
            splitNameLabel.leadingAnchor.constraint(equalTo: wrapperCellView.leadingAnchor, constant: padding),
            splitNameLabel.trailingAnchor.constraint(equalTo: wrapperCellView.trailingAnchor, constant: -padding),
            
            // EXERCISE SUMMARY
            exerciseSummaryLabel.topAnchor.constraint(equalTo: splitNameLabel.bottomAnchor, constant: 6),
            exerciseSummaryLabel.leadingAnchor.constraint(equalTo: splitNameLabel.leadingAnchor),
            exerciseSummaryLabel.trailingAnchor.constraint(equalTo: splitNameLabel.trailingAnchor),
            
            // CAPTION
            captionLabel.topAnchor.constraint(equalTo: exerciseSummaryLabel.bottomAnchor, constant: 12),
            captionLabel.leadingAnchor.constraint(equalTo: splitNameLabel.leadingAnchor),
            captionLabel.trailingAnchor.constraint(equalTo: splitNameLabel.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
