//
//  AuthView.swift
//  Final Project
//
//  Created by Waverly Hassman on 11/24/25.
//

import UIKit

class AuthView: UIView {
    var textFieldName: UITextField!
    var textFieldEmail: UITextField!
    var textFieldPassword: UITextField!
    var textFieldPasswordConf: UITextField!
    var buttonRegister: UIButton!
    var buttonLogin: UIButton!
    var buttonAuth: UIButton!
    var buttonToggleMode: UIButton!
    var logoutMessageLabel: UILabel!

    var nameHeightConstraint: NSLayoutConstraint!
    var passwordConfHeightConstraint: NSLayoutConstraint!
    var logoutButtonConstraints: [NSLayoutConstraint] = []

    var isRegisterMode: Bool = false {
        didSet {
            updateUIForMode()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 12

        setuptextFieldName()
        setuptextFieldEmail()
        setuptextFieldPassword()

        setupbuttonAuth()
        setupbuttonToggleMode()
        setupLogoutMessage()

        initConstraints()
        updateUIForMode()
    }

    func setuptextFieldName() {
        textFieldName = UITextField()
        textFieldName.placeholder = "Name"
        textFieldName.keyboardType = .default
        textFieldName.borderStyle = .roundedRect
        textFieldName.translatesAutoresizingMaskIntoConstraints = false
        textFieldName.alpha = 0
        self.addSubview(textFieldName)
    }

    func setuptextFieldEmail() {
        textFieldEmail = UITextField()
        textFieldEmail.placeholder = "Email"
        textFieldEmail.keyboardType = .emailAddress
        textFieldEmail.borderStyle = .roundedRect
        textFieldEmail.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textFieldEmail)
    }

    func setuptextFieldPassword() {
        textFieldPassword = UITextField()
        textFieldPassword.placeholder = "Password"
        textFieldPassword.textContentType = .password
        textFieldPassword.isSecureTextEntry = true
        textFieldPassword.borderStyle = .roundedRect
        textFieldPassword.translatesAutoresizingMaskIntoConstraints = false

        textFieldPasswordConf = UITextField()
        textFieldPasswordConf.placeholder = "Confirm Password"
        textFieldPasswordConf.textContentType = .password
        textFieldPasswordConf.isSecureTextEntry = true
        textFieldPasswordConf.borderStyle = .roundedRect
        textFieldPasswordConf.translatesAutoresizingMaskIntoConstraints = false
        textFieldPasswordConf.alpha = 0

        self.addSubview(textFieldPassword)
        self.addSubview(textFieldPasswordConf)
    }

    func setupbuttonAuth() {
        buttonAuth = UIButton(type: .system)
        buttonAuth.setTitle("Sign In", for: .normal)
        buttonAuth.titleLabel?.font = .boldSystemFont(ofSize: 16)
        buttonAuth.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonAuth)
    }

    func setupbuttonToggleMode() {
        buttonToggleMode = UIButton(type: .system)
        buttonToggleMode.setTitle("Don't have an account? Register", for: .normal)
        buttonToggleMode.titleLabel?.font = .systemFont(ofSize: 14)
        buttonToggleMode.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonToggleMode)
    }
    
    func setupLogoutMessage() {
        logoutMessageLabel = UILabel()
        logoutMessageLabel.text = "Are you sure you want to log out?"
        logoutMessageLabel.font = .systemFont(ofSize: 16)
        logoutMessageLabel.textAlignment = .center
        logoutMessageLabel.numberOfLines = 0
        logoutMessageLabel.textColor = .label
        logoutMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutMessageLabel.isHidden = true
        self.addSubview(logoutMessageLabel)
    }
    
    func configureForLogout() {
        // Hide auth fields
        textFieldName.isHidden = true
        textFieldEmail.isHidden = true
        textFieldPassword.isHidden = true
        textFieldPasswordConf.isHidden = true
        buttonToggleMode.isHidden = true
        
        // Show and configure logout message
        logoutMessageLabel.isHidden = false
        
        // Style the logout button
        buttonAuth.setTitle("Log Out", for: .normal)
        buttonAuth.titleLabel?.font = .boldSystemFont(ofSize: 18)
        buttonAuth.backgroundColor = .systemRed
        buttonAuth.setTitleColor(.white, for: .normal)
        buttonAuth.layer.cornerRadius = 12
        buttonAuth.contentEdgeInsets = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        
        // Update button constraints for logout mode
        NSLayoutConstraint.deactivate(logoutButtonConstraints)
        logoutButtonConstraints = [
            logoutMessageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            logoutMessageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -40),
            logoutMessageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            logoutMessageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            
            buttonAuth.topAnchor.constraint(equalTo: logoutMessageLabel.bottomAnchor, constant: 24),
            buttonAuth.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttonAuth.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7)
        ]
        NSLayoutConstraint.activate(logoutButtonConstraints)
    }


    func initConstraints() {
        nameHeightConstraint = textFieldName.heightAnchor.constraint(equalToConstant: 0)
        passwordConfHeightConstraint = textFieldPasswordConf.heightAnchor.constraint(
            equalToConstant: 0)

        NSLayoutConstraint.activate([
            textFieldName.topAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 32),
            textFieldName.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            textFieldName.widthAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),

            textFieldEmail.topAnchor.constraint(equalTo: textFieldName.bottomAnchor, constant: 16),
            textFieldEmail.centerXAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            textFieldEmail.widthAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),

            textFieldPassword.topAnchor.constraint(
                equalTo: textFieldEmail.bottomAnchor, constant: 16),
            textFieldPassword.centerXAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            textFieldPassword.widthAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),

            textFieldPasswordConf.topAnchor.constraint(
                equalTo: textFieldPassword.bottomAnchor, constant: 16),
            textFieldPasswordConf.centerXAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            textFieldPasswordConf.widthAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),

            // buttonRegister.topAnchor.constraint(
            //     equalTo: textFieldPasswordConf.bottomAnchor, constant: 32),
            // buttonRegister.centerXAnchor.constraint(
            //     equalTo: self.safeAreaLayoutGuide.centerXAnchor),

            textFieldName.widthAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            // nameHeightConstraint,

            textFieldEmail.topAnchor.constraint(equalTo: textFieldName.bottomAnchor, constant: 16),
            textFieldEmail.centerXAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            textFieldEmail.widthAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            textFieldEmail.heightAnchor.constraint(equalToConstant: 40),

            textFieldPassword.topAnchor.constraint(
                equalTo: textFieldEmail.bottomAnchor, constant: 16),
            textFieldPassword.centerXAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            textFieldPassword.widthAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            textFieldPassword.heightAnchor.constraint(equalToConstant: 40),

            textFieldPasswordConf.topAnchor.constraint(
                equalTo: textFieldPassword.bottomAnchor, constant: 16),
            textFieldPasswordConf.centerXAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            textFieldPasswordConf.widthAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
            passwordConfHeightConstraint,

            buttonAuth.topAnchor.constraint(
                equalTo: textFieldPasswordConf.bottomAnchor, constant: 24),
            buttonAuth.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),

            buttonToggleMode.topAnchor.constraint(equalTo: buttonAuth.bottomAnchor, constant: 12),
            buttonToggleMode.centerXAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            buttonToggleMode.bottomAnchor.constraint(
                lessThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    func updateUIForMode() {
        UIView.animate(withDuration: 0.3) {
            if self.isRegisterMode {
                // Register mode - show all fields
                self.textFieldName.alpha = 1
                self.textFieldPasswordConf.alpha = 1
                self.nameHeightConstraint.constant = 40
                self.passwordConfHeightConstraint.constant = 40
                self.buttonAuth.setTitle("Register", for: .normal)
                self.buttonToggleMode.setTitle("Already have an account? Sign In", for: .normal)
            } else {
                // Sign in mode - hide extra fields
                self.textFieldName.alpha = 0
                self.textFieldPasswordConf.alpha = 0
                self.nameHeightConstraint.constant = 0
                self.passwordConfHeightConstraint.constant = 0
                self.buttonAuth.setTitle("Sign In", for: .normal)
                self.buttonToggleMode.setTitle("Don't have an account? Register", for: .normal)
            }
            self.layoutIfNeeded()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
