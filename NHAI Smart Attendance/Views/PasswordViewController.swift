//
//  PasswordViewController.swift
//  NHAI Smart Attendance
//
//  Created by Chinmay Bapna on 20/08/20.
//  Copyright © 2020 Chinmay Bapna. All rights reserved.
//

import UIKit
import FirebaseFirestore
import RNCryptor

class PasswordViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func nextButtonPressed() {
        db.collection("employees").whereField("mobile", isEqualTo: UserDefaults.standard.string(forKey: "phoneNumber")!).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            }
            else {
                if querySnapshot?.documents.count == 0 {
                    //show alert
                }
                else if querySnapshot!.documents.count == 1 {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        
                        let password = "helloworld"
                        let encryptedPass = data["password"] as! String
                        //print(encryptedPass)
                        
                        let encryptedPassword = Data(base64Encoded: encryptedPass)
                        do {
                            let originalData = try RNCryptor.decrypt(data: encryptedPassword!, withPassword: password)
                            let decodedPassword = String(data: originalData, encoding: .utf8)
                            //print("decoded passsword:", decodedPassword!)
                            
                            if let enteredPassword = self.passwordTextField.text {
                                if enteredPassword == decodedPassword! {
                                    self.performSegue(withIdentifier: "password_verified", sender: nil)
                                }
                                else {
                                    let alert = UIAlertController(title: "Incorrect Password", message: "Please enter the correct password", preferredStyle: .alert)
                                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                    alert.addAction(action)
                                    self.present(alert, animated: true, completion: nil)
                                    self.passwordTextField.text = ""
                                }
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
    }
}
