//
//  RegisterFirebaseManager.swift
//  Final Project
//
//  Created by Waverly Hassman on 11/11/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit

extension AuthViewController {

    func registerNewAccount() {
        //MARK: create a Firebase user with email and password...
        if let name = authView.textFieldName.text,
            let email = authView.textFieldEmail.text,
            let password = authView.textFieldPassword.text
        {
            // Basic validations before attempting registration
            if name.isEmpty || email.isEmpty || password.isEmpty {
                showAlert(title: "Error", message: "All fields are required.")
                return
            }

            //MARK: display the progress indicator only when starting the network call
            showActivityIndicator()

            Auth.auth().createUser(
                withEmail: email.lowercased(),
                password: password,
                completion: { result, error in
                    if let error = error {
                        //MARK: there is an error creating the user...
                        self.hideActivityIndicator()
                        self.showAlert(
                            title: "Registration Failed",
                            message: error.localizedDescription
                        )
                        return
                    }

                    //MARK: the user creation is successful...
                    self.setNameOfTheUserInFirebaseAuth(name: name)
                    // MARK: Goes to database
                    self.saveUserToDatabase(name: name, email: email)
                }
            )
        } else {
            showAlert(title: "Error", message: "Please fill all fields.")
        }
    }

    //MARK: We set the name of the user after we create the account...
    func setNameOfTheUserInFirebaseAuth(name: String) {
        let changeRequest = Auth.auth().currentUser?
            .createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges(completion: { (error) in
            if error == nil {
                //MARK: the profile update is successful...
                NotificationCenter.default.post(name: NSNotification.Name("authStateChanged"), object: nil)
                //MARK: hide the progress indicator...
                self.hideActivityIndicator()

                //MARK: dismiss or pop depending on how view was presented
                if self.navigationController != nil {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            } else {
                //MARK: there was an error updating the profile...
                self.hideActivityIndicator()
                self.showAlert(
                    title: "Profile Update Failed",
                    message: error?.localizedDescription ?? "Unknown error"
                )
            }
        })
    }

    // Push user to DB
    func saveUserToDatabase(name: String, email: String) {
        db.collection("users").document(email.lowercased()).setData([
            "name": name,
            "email": email.lowercased(),
        ]) { error in
            if let error = error {
                print("Error saving user: \(error.localizedDescription)")
            } else {
                print("User successfully saved with email as document ID")
            }
        }
    }
}
