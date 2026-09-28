//
//  WorkoutMediaFormView.swift
//  Setlist
//
//  Created by Waverly Hassman on 12/7/25.
//

import UIKit

class WorkoutMediaFormView: UIView {
    var scrollView: UIScrollView!
    var contentView: UIView!
    var titleLabel: UILabel!
    var imageContainerView: UIView!
    var imageView: UIImageView!
    var addPhotoButton: UIButton!
    var removePhotoButton: UIButton!
    var loadingIndicator: UIActivityIndicatorView!
    var captionLabel: UILabel!
    var captionTextView: UITextView!
    var captionPlaceholder: UILabel!
    var buttonStackView: UIStackView!
    var cancelButton: UIButton!
    var saveButton: UIButton!
    var deleteButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        
        setupScrollView()
        setupTitle()
        setupImageContainer()
        setupCaptionSection()
        setupButtons()
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
    }
    
    private func setupTitle() {
        titleLabel = UILabel()
        titleLabel.text = "Add Workout Photo & Caption"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }
    
    private func setupImageContainer() {
        // Image container with border
        imageContainerView = UIView()
        imageContainerView.backgroundColor = .secondarySystemBackground
        imageContainerView.layer.cornerRadius = 12
        imageContainerView.layer.borderWidth = 2
        imageContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageContainerView)
        
        // Image view
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.addSubview(imageView)
        
        // Loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        imageContainerView.addSubview(loadingIndicator)
        
        // Add photo button
        addPhotoButton = UIButton(type: .system)
        addPhotoButton.setTitle("Add Photo", for: .normal)
        addPhotoButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        addPhotoButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addPhotoButton.tintColor = .systemBlue
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.addSubview(addPhotoButton)
        
        // Remove photo button
        removePhotoButton = UIButton(type: .system)
        removePhotoButton.setTitle("Remove Photo", for: .normal)
        removePhotoButton.setTitleColor(.systemRed, for: .normal)
        removePhotoButton.titleLabel?.font = .systemFont(ofSize: 14)
        removePhotoButton.isHidden = true
        removePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(removePhotoButton)
    }
    
    private func setupCaptionSection() {
        // Caption label
        captionLabel = UILabel()
        captionLabel.text = "Caption"
        captionLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(captionLabel)
        
        // Caption text view
        captionTextView = UITextView()
        captionTextView.font = .systemFont(ofSize: 15)
        captionTextView.layer.cornerRadius = 8
        captionTextView.layer.borderWidth = 1
        captionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        captionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        captionTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(captionTextView)
        
        // Placeholder for caption
        captionPlaceholder = UILabel()
        captionPlaceholder.text = "Add a caption for this workout..."
        captionPlaceholder.font = .systemFont(ofSize: 15)
        captionPlaceholder.textColor = .placeholderText
        captionPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        captionTextView.addSubview(captionPlaceholder)
    }
    
    private func setupButtons() {
        // Button stack view
        buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonStackView)
        
        // Cancel button
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelButton.backgroundColor = .secondarySystemBackground
        cancelButton.layer.cornerRadius = 8
        buttonStackView.addArrangedSubview(cancelButton)
        
        // Save button
        saveButton = UIButton(type: .system)
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 8
        buttonStackView.addArrangedSubview(saveButton)
        
        // Delete button (separate from the stack, below it)
        deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete Post", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        deleteButton.backgroundColor = .secondarySystemBackground
        deleteButton.layer.cornerRadius = 8
        deleteButton.isHidden = true // Hidden by default, shown only when editing
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deleteButton)
    }
    
    private func initConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            imageContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            imageContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            imageContainerView.heightAnchor.constraint(equalToConstant: 250),
            
            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            
            addPhotoButton.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
            addPhotoButton.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
            
            removePhotoButton.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 8),
            removePhotoButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            captionLabel.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 32),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            captionTextView.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 8),
            captionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            captionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            captionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            captionPlaceholder.topAnchor.constraint(equalTo: captionTextView.topAnchor, constant: 12),
            captionPlaceholder.leadingAnchor.constraint(equalTo: captionTextView.leadingAnchor, constant: 13),
            
            buttonStackView.topAnchor.constraint(equalTo: captionTextView.bottomAnchor, constant: 24),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50),
            
            deleteButton.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 16),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
}
