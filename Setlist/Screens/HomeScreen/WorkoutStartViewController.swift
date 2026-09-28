//
//  WorkoutStartViewController.swift
//  Setlist
//
//  Created by Luke Waehner on 12/7/25.
//

import UIKit

class WorkoutStartViewController: UIViewController {
    // callbacks for selection
    var onSelectTemplate: ((WorkoutTemplate) -> Void)?
    var onSelectEmpty: (() -> Void)?

    private let firebaseManager = WorkoutFirebaseManager.shared
    private var templates: [WorkoutTemplate] = []

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "TemplateCell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Start Workout"
        view.backgroundColor = .systemGroupedBackground

        setupNavigationBar()
        setupTableView()
        loadTemplates()
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func loadTemplates() {
        Task { @MainActor [weak self] in
            do {
                self?.templates = try await self?.firebaseManager.fetchWorkoutTemplates() ?? []
                self?.tableView.reloadData()
            } catch {
                print("Error loading templates: \(error)")
            }
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

extension WorkoutStartViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 2 // 1 for Empty, 2 for Templates
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return templates.count
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "New" }
        return "My Templates"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateCell", for: indexPath)

        if indexPath.section == 0 {
            cell.textLabel?.text = "Start Empty Workout"
            cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            cell.textLabel?.textColor = .systemBlue
            cell.imageView?.image = UIImage(systemName: "plus.square.fill")
        } else {
            let template = templates[indexPath.row]
            cell.textLabel?.text = template.name
            cell.textLabel?.textColor = .label
            cell.imageView?.image = nil
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            // Dismiss first, then call action
            dismiss(animated: true) { [weak self] in
                self?.onSelectEmpty?()
            }
        } else {
            let template = templates[indexPath.row]
            dismiss(animated: true) { [weak self] in
                self?.onSelectTemplate?(template)
            }
        }
    }
}
