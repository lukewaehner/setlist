import UIKit

class ExerciseSelectionView: UIView {
    var exercisesTableView: ExercisesTableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupExercisesTableView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupExercisesTableView()
        setupConstraints()
    }

    func setupExercisesTableView() {
        exercisesTableView = ExercisesTableView()
        exercisesTableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(exercisesTableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            exercisesTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            exercisesTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            exercisesTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            exercisesTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
