//
//  TemplateDetailViewController.swift
//  Setlist
//
//  Created by Andrew Kenny on 11/13/25.
//

import UIKit

class TemplateDetailViewController: UIViewController {
    private var template: WorkoutTemplate
    private let firebaseManager = WorkoutFirebaseManager.shared
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    var isActiveSession: Bool = false {
        didSet {
            if isViewLoaded {
                setupNavigationBar()
                templateDetailView.exercisesTableView.reloadData()
            }
        }
    }
    
    var templateDetailView: TemplateDetailView {
        return view as! TemplateDetailView
    }

    init(template: WorkoutTemplate) {
        self.template = template
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = TemplateDetailView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        templateDetailView.configure(with: template)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeight()
    }

    private func updateTableViewHeight() {
        templateDetailView.exercisesTableView.layoutIfNeeded()
        let height = templateDetailView.exercisesTableView.contentSize.height

        if let existingConstraint = tableViewHeightConstraint {
            existingConstraint.isActive = false
        }

        tableViewHeightConstraint = templateDetailView.exercisesTableView.heightAnchor.constraint(
            equalToConstant: height)
        tableViewHeightConstraint?.isActive = true
    }

    private func setupNavigationBar() {
        title = "Template Details"
        if isActiveSession {
            title = "Active Workout"
            let finishButton = UIBarButtonItem(
                title: "Finish",
                style: .done,
                target: self,
                action: #selector(finishWorkoutTapped)
            )
            let addExerciseButton = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addExerciseTapped)
            )
            navigationItem.rightBarButtonItems = [
                finishButton, addExerciseButton,
            ]
        } else {
            title = "Template Details"
            let editButton = UIBarButtonItem(
                barButtonSystemItem: .edit,
                target: self,
                action: #selector(editTemplateTapped)
            )
            let deleteButton = UIBarButtonItem(
                barButtonSystemItem: .trash,
                target: self,
                action: #selector(deleteTemplateTapped)
            )
            deleteButton.tintColor = .systemRed
            navigationItem.rightBarButtonItems = [deleteButton, editButton]
        }
    }

    @objc private func addExerciseTapped() {
        let picker = ExercisePickerViewController()
        picker.delegate = self
        let nav = UINavigationController(rootViewController: picker)
        present(nav, animated: true)
    }

    @objc private func finishWorkoutTapped() {
        let alert = UIAlertController(
            title: "Finish Workout",
            message: "Are you sure you are done?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Finish", style: .default) { [weak self] _ in
                Task { @MainActor in
                    await ActiveWorkoutManager.shared.endWorkout()
                    self?.dismiss(animated: true)
                }
            }
        )
        present(alert, animated: true)
        let editButton = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editTemplateTapped)
        )
        editButton.tintColor = .black

        let deleteButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(deleteTemplateTapped)
        )
        deleteButton.tintColor = .systemRed
        navigationItem.rightBarButtonItems = [deleteButton, editButton]
    }

    @objc private func deleteTemplateTapped() {
        let alert = UIAlertController(
            title: "Delete Template",
            message:
                "Are you sure you want to delete \"\(template.name)\"? This action cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(
            UIAlertAction(title: "Delete", style: .destructive) {
                [weak self] _ in
                self?.deleteTemplate()
            }
        )

        present(alert, animated: true)
    }

    private func deleteTemplate() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                try await self.firebaseManager.deleteWorkoutTemplate(
                    named: self.template.name
                )
                self.dismiss(animated: true)
            } catch {
                self.showAlert(
                    title: "Error",
                    message:
                        "Failed to delete template: \(error.localizedDescription)"
                )
            }
        }
    }

    @objc private func editTemplateTapped() {
        let formVC = WorkoutTemplateFormViewController(editingTemplate: template)

        formVC.onTemplateSaved = { [weak self] updatedTemplate in
            self?.reloadTemplateFromFirebase(named: updatedTemplate.name)
        }

        let navController = UINavigationController(rootViewController: formVC)
        navController.modalPresentationStyle = .pageSheet

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        present(navController, animated: true)
    }

    private func reloadTemplateFromFirebase(named templateName: String) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                let templates = try await self.firebaseManager.fetchWorkoutTemplates()
                if let updatedTemplate = templates.first(where: { $0.name == templateName }) {
                    self.template = updatedTemplate
                    self.title = "Template Details"
                    self.templateDetailView.configure(with: updatedTemplate)
                    self.templateDetailView.exercisesTableView.reloadData()
                    self.updateTableViewHeight()
                }
            } catch {
                self.showAlert(
                    title: "Error",
                    message: "Failed to reload template: \(error.localizedDescription)"
                )
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupTableView() {
        templateDetailView.exercisesTableView.delegate = self
        templateDetailView.exercisesTableView.dataSource = self
        templateDetailView.exercisesTableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "ExerciseCell"
        )
    }
}

extension TemplateDetailViewController: UITableViewDataSource,
    UITableViewDelegate
{
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return template.exercises?.count ?? 0
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = UITableViewCell(
            style: .subtitle,
            reuseIdentifier: "ExerciseCell"
        )
        guard let exercise = template.exercises?[indexPath.row] else {
            return cell
        }

        cell.textLabel?.text = exercise.name
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        var detailParts: [String] = []
        detailParts.append(exercise.category)

        // Always show sets count, even if 0
        detailParts.append(
            "\(exercise.sets.count) set\(exercise.sets.count == 1 ? "" : "s")"
        )

        // Show set details if sets exist
        if exercise.sets.count > 0 {
            let setsWithData = exercise.sets.filter {
                $0.weight > 0 || $0.reps > 0
            }
            if setsWithData.count > 0 {
                let setsInfo = setsWithData.map {
                    "\(Int($0.weight))kg x \($0.reps)"
                }.joined(
                    separator: ", "
                )
                detailParts.append(setsInfo)
            }
        }

        if let notes = exercise.notes, !notes.isEmpty {
            detailParts.append("Notes: \(notes)")
        }

        cell.detailTextLabel?.text = detailParts.joined(separator: " • ")
        cell.detailTextLabel?.font = .systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.numberOfLines = 0

        cell.backgroundColor = .clear
        cell.accessoryType = .none
        cell.selectionStyle = .none

        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension TemplateDetailViewController: ExercisePickerDelegate {
    func exercisePicker(_ picker: ExercisePickerViewController, didSelectExercises exercises: [String]) {
        
    }
}
