//
//  OtpViewController.swift
//  NHAI Smart Attendance
//
//  Created by Chinmay Bapna on 13/08/20.
//  Copyright © 2020 Chinmay Bapna. All rights reserved.
//

import UIKit
import FirebaseAuth
import CountdownLabel

class OtpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var countdown : CountdownLabel!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var contactUsButton: UIButton!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneNumberLabel.text = UserDefaults.standard.string(forKey: "phoneNumber")!
        
        resendButton.isHidden = true
        label1.isHidden = true
        label2.isHidden = true
        contactUsButton.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
        verifyButton.layer.cornerRadius = 10
        contactUsButton.layer.cornerRadius = 10
        otpTextField.layer.borderWidth = 1
        otpTextField.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        otpTextField.layer.cornerRadius = 5
        otpTextField.delegate = self
        
        countdown.setCountDownTime(minutes: 30)
        countdown.start()
        
        loopToCheckTimer()
        
        //unhide resend button after 30 seconds
        unhideResend()
    }
    
    func unhideResend() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            self.resendButton.isHidden = false
            self.label1.isHidden = false
            self.label2.isHidden = false
            self.contactUsButton.isHidden = false
        }
    }
    
    func loopToCheckTimer() {
        DispatchQueue.main.async {
            if self.countdown.isFinished {
                //print("finished")
            } else {
                self.loopToCheckTimer()
            }
        }
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 6
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    @IBAction func verifyButtonPressed() {
        guard let otpCode = otpTextField.text else { return }
        guard let verificationId = UserDefaults.standard.string(forKey: "verificationId") else { return }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: otpCode)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (success, error) in
            if error == nil {
                //perform segue
                self.performSegue(withIdentifier: "otp_verified", sender: nil)
            } else {
                print("could not sign in", error?.localizedDescription)
                let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified, please try again", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
                self.otpTextField.text = ""
            }
        }
    }
    
    @IBAction func resendButtonPressed() {
        guard let phoneNumber = UserDefaults.standard.string(forKey: "phoneNumber") else { return }
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationId, error) in
            if error == nil {
                guard let verifyId = verificationId else { return }
                //print(verifyId)
                UserDefaults.standard.setValue(verifyId, forKey: "verificationId")
                UserDefaults.standard.synchronize()
            } else {
                print("error: \(String(describing: error?.localizedDescription))")
            }
        }
        
        resendButton.isHidden = true
        label1.isHidden = true
        label2.isHidden = true
        contactUsButton.isHidden = true
        
        loopToCheckTimer()
        
        countdown.setCountDownTime(minutes: 30)
        countdown.start()
        
        unhideResend()
    }
}
