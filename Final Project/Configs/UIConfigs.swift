//
//  UIConfigs.swift
//  Final Project
//
//  Created by Waverly Hassman on 11/11/25.
//

import Foundation
import UIKit

// Enum for tracking UI design, and setting globals, biting tailwind here
enum Design {
    enum Space {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
    }
    enum Typog {
        static let title: UIFont = UIFont.systemFont(ofSize: 24)
        static let body: UIFont = UIFont.systemFont(ofSize: 18)
        static let subtext: UIFont = UIFont.systemFont(ofSize: 12)
    }
}
