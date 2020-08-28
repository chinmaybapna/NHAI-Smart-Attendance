//
//  LoginViewController.swift
//  NHAI Smart Attendance
//
//  Created by Chinmay Bapna on 13/08/20.
//  Copyright © 2020 Chinmay Bapna. All rights reserved.
//

import UIKit
import FirebaseFirestore
import RNCryptor

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
        nextButton.layer.cornerRadius = 10
        phoneTextField.layer.cornerRadius = 5
        phoneTextField.layer.borderWidth = 1
        phoneTextField.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        phoneTextField.delegate = self
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 10
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    @IBAction func nextButtonPressed() {
        if phoneTextField.text!.count < 10 {
            let alert = UIAlertController(title: "Invalid Phone Number", message: "Please enter a valid phone number.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            phoneTextField.text = ""
        }
        else {
            guard let phoneNumber = phoneTextField.text else { return }
            let phone = "+91" + phoneNumber
            //print(phone)
            UserDefaults.standard.set(phone, forKey: "phoneNumber")
            db.collection("employees").whereField("mobile", isEqualTo: phone).getDocuments() { (querySnapshot, error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
                else {
                    if querySnapshot?.documents.count == 0 {
                        self.performSegue(withIdentifier: "phone_number_not_in_database", sender: nil)
                    }
                    else if querySnapshot!.documents.count == 1 {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            
                            let userId = document.documentID
                            UserDefaults.standard.set(userId, forKey: "userId")
                            
                            let isLoggingInFirstTime = data["isLoggingInFirstTime"] as! Bool
                            if isLoggingInFirstTime {
                                self.performSegue(withIdentifier: "phone_number_validated", sender: nil)
                                UserDefaults.standard.setValue(phone, forKey: "phoneNumber")
                            }
                            else {
                                //print("not logging in for the first time")
                                self.performSegue(withIdentifier: "enter_password", sender: nil)
                            }
                        }
                    }
                }
            }
        }
    }
}
