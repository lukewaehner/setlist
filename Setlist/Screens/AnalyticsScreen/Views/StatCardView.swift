//
//  StatCardView.swift
//  Setlist
//
//  Created by Andrew Kenny on 11/13/25.
//
import UIKit

class StatCardView: UIView {

    let titleLabel = UILabel()
    let valueLabel = UILabel()
    private let accentBar = UIView()
    private var accentColor: UIColor = .systemBlue
    
    init(title: String, accent: UIColor = .systemBlue) {
        self.accentColor = accent
        super.init(frame: .zero)
        setupView()
        configure(title: title)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 14
        layer.masksToBounds = false
        
        // Subtle shadow for depth
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        
        // Inner container to clip the accent bar
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 14
        containerView.layer.masksToBounds = true
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Accent bar on the left
        accentBar.backgroundColor = accentColor
        accentBar.layer.cornerRadius = 2
        containerView.addSubview(accentBar)
        accentBar.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading

        containerView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            accentBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            accentBar.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            accentBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14),
            accentBar.widthAnchor.constraint(equalToConstant: 4),
            
            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 12),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14)
        ])

        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .secondaryLabel

        valueLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.7
        valueLabel.text = "--"
    }

    func configure(title: String) {
        titleLabel.text = title.uppercased()
    }
    
    func setValue(_ value: String) {
        valueLabel.text = value
    }
    
    func setAccentColor(_ color: UIColor) {
        accentColor = color
        accentBar.backgroundColor = color
    }
}
