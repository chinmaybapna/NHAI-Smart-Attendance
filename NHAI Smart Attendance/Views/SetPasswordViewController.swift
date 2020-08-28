//
//  SetPasswordViewController.swift
//  NHAI Smart Attendance
//
//  Created by Chinmay Bapna on 13/08/20.
//  Copyright © 2020 Chinmay Bapna. All rights reserved.
//

import UIKit
import FirebaseFirestore
import RNCryptor

class SetPasswordViewController: UIViewController {

    let db = Firestore.firestore()
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberLabel.text = UserDefaults.standard.string(forKey: "phoneNumber")!
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)

        nextButton.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        self.navigationItem.hidesBackButton = true
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    func isValidPassword(testStr:String?) -> Bool {
        guard testStr != nil else { return false }
        // at least one digit
        // 8 characters total
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[0-9]).{8,}")
        return passwordTest.evaluate(with: testStr)
    }
    
    
    @IBAction func nextButtonPressed() {
        if let userPassword = passwordTextField.text {
            if isValidPassword(testStr: userPassword) {
                let pass = userPassword.data(using: .utf8)
                //print(pass!)
                let password = "helloworld"
                let ciphertext = RNCryptor.encrypt(data: pass!, withPassword: password)
                db.collection("employees").document(UserDefaults.standard.string(forKey: "userId")!).setData([
                    "password": ciphertext.base64EncodedString(),
                    "isLoggingInFirstTime": false
                ], merge: true)
            } else {
                let alert = UIAlertController(title: "Invalid Password", message: "The password is not in a valid format. It must be atleast 8 characters. You can't use a password that contains only numbers and alphanumeric characters.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
                passwordTextField.text = ""
            }
        }
    }
}
