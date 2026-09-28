//
//  DividerView.swift
//  Final Project
//
//  Created by Luke Waehner on 11/12/25.
//

import UIKit

// Setup a 1 px line (must set width constraints externally)
class DividerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .separator
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
}
