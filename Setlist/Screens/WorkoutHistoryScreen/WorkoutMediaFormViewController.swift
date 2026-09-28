//
//  WorkoutMediaFormViewController.swift
//  Setlist
//
//  Created by Waverly Hassman on 12/7/25.
//

import UIKit
import PhotosUI

class WorkoutMediaModalViewController: UIViewController {
    let workoutMediaView = WorkoutMediaFormView()
    var workout: Workout
    var existingPost: WorkoutPost?
    var onSave: ((UIImage?, String) -> Void)?
    
    private var selectedImage: UIImage?
    private var isLoadingImage = false
    
    init(workout: Workout) {
        self.workout = workout
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = workoutMediaView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActions()
        setupKeyboardHandling()
        
        // Set text view delegate
        workoutMediaView.captionTextView.delegate = self
        
        // Initially disable save button
        updateSaveButtonState()
        
        // Fetch existing post if one exists
        loadExistingPost()
    }
    
    private func loadExistingPost() {
        // Show loading state
        workoutMediaView.loadingIndicator.startAnimating()
        workoutMediaView.addPhotoButton.isHidden = true
        
        Task {
            do {
                // Try to fetch existing post using workout ID
                existingPost = try await WorkoutFirebaseManager.shared.fetchWorkoutPost(postId: workout.wid.uuidString)
                
                DispatchQueue.main.async { [weak self] in
                    self?.workoutMediaView.loadingIndicator.stopAnimating()
                    
                    // Show delete button only if post exists
                    self?.workoutMediaView.deleteButton.isHidden = (self?.existingPost == nil)
                    
                    // Load existing data if post exists
                    self?.loadExistingData()
                    
                    // Show add photo button if no existing post
                    if self?.existingPost == nil {
                        self?.workoutMediaView.addPhotoButton.isHidden = false
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.workoutMediaView.loadingIndicator.stopAnimating()
                    self?.workoutMediaView.addPhotoButton.isHidden = false
                    self?.workoutMediaView.deleteButton.isHidden = true
                    print("Error loading existing post: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func setupActions() {
        workoutMediaView.addPhotoButton.addTarget(
            self,
            action: #selector(addPhotoTapped),
            for: .touchUpInside
        )
        
        workoutMediaView.removePhotoButton.addTarget(
            self,
            action: #selector(removePhotoTapped),
            for: .touchUpInside
        )
        
        workoutMediaView.saveButton.addTarget(
            self,
            action: #selector(saveTapped),
            for: .touchUpInside
        )
        
        workoutMediaView.cancelButton.addTarget(
            self,
            action: #selector(cancelTapped),
            for: .touchUpInside
        )
        
        workoutMediaView.deleteButton.addTarget(
            self,
            action: #selector(deleteTapped),
            for: .touchUpInside
        )
    }
    
    private func loadExistingData() {
        // Prioritize loading from existingPost if available
        if let post = existingPost {
            // Load caption from post
            if !post.caption.isEmpty {
                workoutMediaView.captionTextView.text = post.caption
                workoutMediaView.captionPlaceholder.isHidden = true
            }
            
            // Load image from post
            if !post.imageURL.isEmpty {
                loadImageFromLocalStorage(post.imageURL)
            }
        } else {
            // Fallback to loading from workout (legacy support)
            if let caption = workout.caption, !caption.isEmpty {
                workoutMediaView.captionTextView.text = caption
                workoutMediaView.captionPlaceholder.isHidden = true
            }
            
            if let photoURL = workout.workoutPhotoURL, !photoURL.isEmpty {
                loadImageFromURL(photoURL)
            }
        }
    }
    
    private func loadImageFromLocalStorage(_ workoutId: String) {
        isLoadingImage = true
        workoutMediaView.loadingIndicator.startAnimating()
        workoutMediaView.addPhotoButton.isHidden = true
        
        // Load image on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let image = WorkoutFirebaseManager.shared.loadImageLocally(workoutId: workoutId)
            
            DispatchQueue.main.async {
                self?.isLoadingImage = false
                self?.workoutMediaView.loadingIndicator.stopAnimating()
                
                if let image = image {
                    self?.selectedImage = image
                    self?.workoutMediaView.imageView.image = image
                    self?.workoutMediaView.imageView.isHidden = false
                    self?.workoutMediaView.removePhotoButton.isHidden = false
                    self?.updateSaveButtonState()
                } else {
                    self?.workoutMediaView.addPhotoButton.isHidden = false
                }
            }
        }
    }
    
    private func loadImageFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        isLoadingImage = true
        workoutMediaView.loadingIndicator.startAnimating()
        workoutMediaView.addPhotoButton.isHidden = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoadingImage = false
                self?.workoutMediaView.loadingIndicator.stopAnimating()
                
                if let data = data, let image = UIImage(data: data) {
                    self?.selectedImage = image
                    self?.workoutMediaView.imageView.image = image
                    self?.workoutMediaView.imageView.isHidden = false
                    self?.workoutMediaView.removePhotoButton.isHidden = false
                    self?.updateSaveButtonState()
                } else {
                    self?.workoutMediaView.addPhotoButton.isHidden = false
                }
            }
        }.resume()
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // Check if both image and caption are present
    private func updateSaveButtonState() {
        let hasImage = selectedImage != nil
        let hasCaption = !(workoutMediaView.captionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        
        let canSave = hasImage && hasCaption
        
        workoutMediaView.saveButton.isEnabled = canSave
        workoutMediaView.saveButton.alpha = canSave ? 1.0 : 0.5
    }
    
    @objc private func addPhotoTapped() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func removePhotoTapped() {
        selectedImage = nil
        workoutMediaView.imageView.image = nil
        workoutMediaView.imageView.isHidden = true
        workoutMediaView.addPhotoButton.isHidden = false
        workoutMediaView.removePhotoButton.isHidden = true
        updateSaveButtonState()
    }
    
    @objc private func saveTapped() {
        // Double check both are present
        guard let image = selectedImage else {
            showAlert(message: "Please add a photo")
            return
        }
        
        let caption = workoutMediaView.captionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !caption.isEmpty else {
            showAlert(message: "Please add a caption")
            return
        }
        
        onSave?(image, caption)
        dismiss(animated: true)
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "Delete Post",
            message: "Are you sure you want to delete this workout post? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Delete from Firebase
            Task {
                do {
                    try await WorkoutFirebaseManager.shared.deleteWorkoutPost(postId: self.workout.wid.uuidString)
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showAlert(message: "Failed to delete post: \(error.localizedDescription)")
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Required", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        workoutMediaView.scrollView.contentInset = contentInsets
        workoutMediaView.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        workoutMediaView.scrollView.contentInset = .zero
        workoutMediaView.scrollView.scrollIndicatorInsets = .zero
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextViewDelegate
extension WorkoutMediaModalViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        workoutMediaView.captionPlaceholder.isHidden = !textView.text.isEmpty
        updateSaveButtonState() // Check if save should be enabled
    }
}

// MARK: - PHPickerViewControllerDelegate
extension WorkoutMediaModalViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self?.selectedImage = image
                    self?.workoutMediaView.imageView.image = image
                    self?.workoutMediaView.imageView.isHidden = false
                    self?.workoutMediaView.addPhotoButton.isHidden = true
                    self?.workoutMediaView.removePhotoButton.isHidden = false
                    self?.updateSaveButtonState() // Check if save should be enabled
                }
            }
        }
    }
}
