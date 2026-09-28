//
//  AuthViewController.swift
//  Final Project
//
//  Created by Waverly Hassman on 11/24/25.
//

import FirebaseAuth
import FirebaseFirestore
import UIKit

enum AuthMode {
    case login
    case logout
}

class AuthViewController: UIViewController {

    let authView = AuthView()
    let childProgressView = ProgressSpinnerViewController()
    let db = Firestore.firestore()
    
    var mode: AuthMode = .login

    override func loadView() {
        view = authView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch mode {
            case .login:
                setupLoginMode()
            case .logout:
                setupLogoutMode()
        }
    }
    
    func setupLoginMode() {
        title = "Sign In"

        authView.buttonAuth.addTarget(self, action: #selector(onAuthTapped), for: .touchUpInside)
        authView.buttonToggleMode.addTarget(self, action: #selector(onToggleModeTapped), for: .touchUpInside)
    }
    
    func setupLogoutMode() {
        title = "Log Out"
        
        authView.configureForLogout()

        authView.buttonAuth.addTarget(self, action: #selector(onLogoutConfirmed), for: .touchUpInside)
    }

    @objc func onToggleModeTapped() {
        authView.isRegisterMode.toggle()
        title = authView.isRegisterMode ? "Register" : "Sign In"
        
        // Clear fields when switching modes
        authView.textFieldName.text = ""
        authView.textFieldPasswordConf.text = ""
    }

    @objc func onAuthTapped() {
        if authView.isRegisterMode {
            handleRegister()
        } else {
            handleSignIn()
        }
    }
    
    @objc func onLogoutConfirmed() {
        do {
            try Auth.auth().signOut()
            NotificationCenter.default.post(name: NSNotification.Name("authStateChanged"), object: nil)
            dismiss(animated: true)
        } catch {
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    func handleSignIn() {
        guard let email = authView.textFieldEmail.text, !email.isEmpty,
              let password = authView.textFieldPassword.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        showActivityIndicator()
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.hideActivityIndicator()
            
            if let error = error {
                self.showAlert(title: "Sign In Failed", message: error.localizedDescription)
                return
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("authStateChanged"), object: nil)
            
            // Successfully signed in - dismiss or pop depending on presentation
            if self.navigationController != nil {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
    }
    
    func handleRegister() {
        // Check that passwords match before proceeding
        if authView.textFieldPassword.text != authView.textFieldPasswordConf.text {
            showAlert(title: "Error", message: "Passwords do not match.")
            return
        }
        
        registerNewAccount()
    }

    func showAlert(title: String = "Notice", message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
