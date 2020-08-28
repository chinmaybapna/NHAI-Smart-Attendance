//
//  LoginStatusViewController.swift
//  NHAI Smart Attendance
//
//  Created by Chinmay Bapna on 13/08/20.
//  Copyright © 2020 Chinmay Bapna. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginStatusViewController: UIViewController {
    
    @IBOutlet weak var getOtpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        getOtpButton.layer.cornerRadius = 10
        
    }
    
    @IBAction func getOtpButtonPressed() {
        //Auth.auth().settings!.isAppVerificationDisabledForTesting = true
        PhoneAuthProvider.provider().verifyPhoneNumber(UserDefaults.standard.string(forKey: "phoneNumber")!, uiDelegate: nil) { (verificationId, error) in
            if error == nil {
                guard let verifyId = verificationId else { return }
                //print(verifyId)
                UserDefaults.standard.setValue(verifyId, forKey: "verificationId")
            } else {
                print("error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
}
