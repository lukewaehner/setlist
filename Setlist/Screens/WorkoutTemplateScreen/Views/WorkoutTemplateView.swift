//
//  WorkoutTemplateView.swift
//  Setlist
//
//  Created by Andrew Kenny on 11/13/25.
//
import UIKit

protocol WorkoutTemplatesViewDelegate: AnyObject {
    func workoutTemplatesView(_ view: WorkoutTemplatesView, didTapCreateButton button: UIButton)
    func workoutTemplatesView(_ view: WorkoutTemplatesView, didSelectTemplate template: WorkoutTemplate)
}

class WorkoutTemplatesView: UIView {
    weak var delegate: WorkoutTemplatesViewDelegate?
    // Stored templates section
    let templatesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Workout Templates"
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()

    let templatesContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.6)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    let templatesTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No templates yet. Create your first template!"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("New Template", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupLayout()
    }

    private func setupView() {
        backgroundColor = .systemBackground

        addSubview(templatesTitleLabel)
        addSubview(createButton)
        addSubview(templatesContainerView)
        templatesContainerView.addSubview(templatesTableView)
        templatesContainerView.addSubview(emptyStateLabel)
        
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
    }
    
    @objc private func createButtonTapped() {
        delegate?.workoutTemplatesView(self, didTapCreateButton: createButton)
    }

    private func setupLayout() {
        templatesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        templatesContainerView.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Title and button at the top
            templatesTitleLabel.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor, constant: 16
            ),
            templatesTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            createButton.centerYAnchor.constraint(equalTo: templatesTitleLabel.centerYAnchor),
            createButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Templates container takes up the rest of the screen
            templatesContainerView.topAnchor.constraint(
                equalTo: templatesTitleLabel.bottomAnchor, constant: 16
            ),
            templatesContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            templatesContainerView.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -16
            ),
            templatesContainerView.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16
            ),

            templatesTableView.topAnchor.constraint(equalTo: templatesContainerView.topAnchor, constant: 8),
            templatesTableView.leadingAnchor.constraint(equalTo: templatesContainerView.leadingAnchor, constant: 8),
            templatesTableView.trailingAnchor.constraint(equalTo: templatesContainerView.trailingAnchor, constant: -8),
            templatesTableView.bottomAnchor.constraint(equalTo: templatesContainerView.bottomAnchor, constant: -8),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: templatesContainerView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: templatesContainerView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: templatesContainerView.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: templatesContainerView.trailingAnchor, constant: -16),
        ])
    }
    
    func updateTemplatesDisplay(hasTemplates: Bool) {
        templatesTableView.isHidden = !hasTemplates
        emptyStateLabel.isHidden = hasTemplates
    }
}
