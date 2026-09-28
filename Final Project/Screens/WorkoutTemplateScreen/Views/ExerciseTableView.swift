//
//  ExerciseTableView.swift
//  Final Project
//
//  Created by Andrew Kenny on 11/13/25.
//
import UIKit

class ExercisesTableView: UIView {
    var wrapperView: UIView!
    var tableView: UITableView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupWrapperView()
        setupTableView()

        initConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Setup Views

    func setupWrapperView() {
        wrapperView = UIView()
        wrapperView.backgroundColor = .white
        wrapperView.layer.cornerRadius = 8.0
        wrapperView.layer.shadowColor = UIColor.gray.cgColor
        wrapperView.layer.shadowOffset = .zero
        wrapperView.layer.shadowRadius = 4.0
        wrapperView.layer.shadowOpacity = 0.3
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(wrapperView)
    }

    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(tableView)
    }

    // MARK: - Constraints

    func initConstraints() {
        let gap: CGFloat = Design.Space.xs

        NSLayoutConstraint.activate([
            // Wrapper view fills this custom view with padding
            wrapperView.topAnchor.constraint(equalTo: self.topAnchor, constant: gap),
            wrapperView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: gap),
            wrapperView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -gap),
            wrapperView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -gap),

            // Table view fills wrapper
            tableView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor),
        ])
    }
}
