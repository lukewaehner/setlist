//
//  ExerciseSelectionViewController.swift
//  Final Project
//
//  Created by Andrew Kenny on 11/13/25.
//

import UIKit

class ExerciseSelectionViewController: UIViewController {
    var workoutTemplatesView: WorkoutTemplatesView {
        return view as! WorkoutTemplatesView
    }
    
    private let firebaseManager = WorkoutFirebaseManager.shared
    private var templates: [WorkoutTemplate] = []

    override func loadView() {
        view = WorkoutTemplatesView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        setupTableView()
        loadTemplates()
        
        // Listen for template changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(templatesChanged),
            name: NSNotification.Name("workoutTemplatesChanged"),
            object: nil
        )
    }
    
    private func setupDelegate() {
        workoutTemplatesView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTemplates()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupTableView() {
        workoutTemplatesView.templatesTableView.delegate = self
        workoutTemplatesView.templatesTableView.dataSource = self
        // Use .subtitle style to show both title and detail
        workoutTemplatesView.templatesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TemplateCell")
    }
    
    private func loadTemplates() {
        Task { @MainActor [weak self] in
            do {
                let loadedTemplates = try await self?.firebaseManager.fetchWorkoutTemplates() ?? []
                self?.templates = loadedTemplates
                self?.workoutTemplatesView.templatesTableView.reloadData()
                self?.workoutTemplatesView.updateTemplatesDisplay(hasTemplates: !loadedTemplates.isEmpty)
            } catch {
                print("Error loading templates: \(error)")
            }
        }
    }
    
    @objc private func templatesChanged() {
        loadTemplates()
    }
    
    private func presentTemplateForm() {
        let modal = WorkoutTemplateFormViewController()
        modal.modalPresentationStyle = .pageSheet

        if let sheet = modal.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        present(modal, animated: true, completion: nil)
    }
    
    private func presentTemplateDetail(for template: WorkoutTemplate) {
        let detailVC = TemplateDetailViewController(template: template)
        let navController = UINavigationController(rootViewController: detailVC)
        present(navController, animated: true)
    }
}

extension ExerciseSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateCell", for: indexPath)
        let template = templates[indexPath.row]
        
        // Configure cell with template name and exercise count
        let exerciseCount = template.exercises?.count ?? 0
        cell.textLabel?.text = "\(template.name) • \(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")"
        cell.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        cell.textLabel?.numberOfLines = 0
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .clear
        cell.selectionStyle = .default
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let template = templates[indexPath.row]
        presentTemplateDetail(for: template)
    }
}

extension ExerciseSelectionViewController: WorkoutTemplatesViewDelegate {
    func workoutTemplatesView(_ view: WorkoutTemplatesView, didTapCreateButton button: UIButton) {
        presentTemplateForm()
    }
    
    func workoutTemplatesView(_ view: WorkoutTemplatesView, didSelectTemplate template: WorkoutTemplate) {
        presentTemplateDetail(for: template)
    }
}
