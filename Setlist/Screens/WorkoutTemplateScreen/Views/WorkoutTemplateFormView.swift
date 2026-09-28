import UIKit

protocol WorkoutTemplateFormViewDelegate: AnyObject {
    func workoutTemplateFormView(_ view: WorkoutTemplateFormView, didTapAddExercisesButton button: UIButton)
    func workoutTemplateFormView(_ view: WorkoutTemplateFormView, didTapSaveButton button: UIButton)
}

final class WorkoutTemplateFormView: UIView {
    weak var delegate: WorkoutTemplateFormViewDelegate?
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Template Name"
        label.font = .preferredFont(forTextStyle: .subheadline)
        return label
    }()

    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Push Day, Upper Body, etc."
        return tf
    }()

    let notesLabel: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        label.font = .preferredFont(forTextStyle: .subheadline)
        return label
    }()

    let notesTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.placeholder = "Optional description"
        return tf
    }()

    let addExercisesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Exercises", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        return button
    }()

    let exercisesSummaryLabel: UILabel = {
        let label = UILabel()
        label.text = "0 exercises added"
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Template", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        return button
    }()

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

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let exercisesTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private func setupView() {
        backgroundColor = .systemBackground
    }
    
    private func setupLayout() {
        // Add scroll view and content view
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup button targets
        addExercisesButton.addTarget(self, action: #selector(addExercisesButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Create a container for name section
        let nameStack = UIStackView(arrangedSubviews: [nameLabel, nameTextField])
        nameStack.axis = .vertical
        nameStack.spacing = 4
        nameStack.alignment = .leading
        nameStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Create a container for notes section
        let notesStack = UIStackView(arrangedSubviews: [notesLabel, notesTextField])
        notesStack.axis = .vertical
        notesStack.spacing = 4
        notesStack.alignment = .leading
        notesStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Group exercises section together
        let exercisesHeaderStack = UIStackView(arrangedSubviews: [addExercisesButton, exercisesSummaryLabel])
        exercisesHeaderStack.axis = .vertical
        exercisesHeaderStack.spacing = 8
        exercisesHeaderStack.alignment = .center
        exercisesHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [
            nameStack,
            notesStack,
            exercisesHeaderStack,
            exercisesTableView,
            saveButton,
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Stack constraints
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            nameTextField.widthAnchor.constraint(equalTo: stack.widthAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),

            notesTextField.widthAnchor.constraint(equalTo: stack.widthAnchor),
            notesTextField.heightAnchor.constraint(equalToConstant: 40),

            addExercisesButton.heightAnchor.constraint(equalToConstant: 44),
            addExercisesButton.widthAnchor.constraint(equalToConstant: 150),
            
            exercisesTableView.widthAnchor.constraint(equalTo: stack.widthAnchor),
            
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.widthAnchor.constraint(equalTo: stack.widthAnchor),
        ])
    }

    func updateExercisesSummary(count: Int) {
        exercisesSummaryLabel.text = "\(count) exercise\(count == 1 ? "" : "s") added"
    }
    
    @objc private func addExercisesButtonTapped() {
        delegate?.workoutTemplateFormView(self, didTapAddExercisesButton: addExercisesButton)
    }
    
    @objc private func saveButtonTapped() {
        delegate?.workoutTemplateFormView(self, didTapSaveButton: saveButton)
    }
}
