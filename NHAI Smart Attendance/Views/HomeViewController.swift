//
//  HomeViewController.swift
//  NHAI Smart Attendance
//
//  Created by Chinmay Bapna on 13/08/20.
//  Copyright © 2020 Chinmay Bapna. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var clockInView: UIView!
    @IBOutlet weak var clockOutView: UIView!
    @IBOutlet weak var clockInInfoLabel: UILabel!
    @IBOutlet weak var clockOutInfoLabel: UILabel!
    @IBOutlet weak var clockInLabel: UILabel!
    @IBOutlet weak var clockOutLabel: UILabel!
    @IBOutlet weak var goodMorningLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var noConnectionLabel: UILabel!
    @IBOutlet weak var onlineStatus: UILabel!
    
    var canClockIn: Bool?
    var canClockOut: Bool?
    
    var clockInHr: Int?
    var clockInMins: Int?
    var clockInDuring: String?
    
    var lastDayMarked: String?
    var todaysDate: String?
    
    
    var location: CLLocation?
    
    var currentClockIn: String?
    var currentClockOut: String?
    
    let db = Firestore.firestore()
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set("yes", forKey: "isLoggedIn")
        
        getEmployeeData()
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        todaysDate = formatter.string(from: date)
        //print(todaysDate!)
        
        formatter.dateFormat = "LLLL"
        let monthString = formatter.string(from: date)
        //print(monthString)

        formatter.dateFormat = "EEEE"
        let dayOfTheWeekString = formatter.string(from: date)
        //print(dayOfTheWeekString)
        
        formatter.dateFormat = "yyyy"
        let yearString = formatter.string(from: date)
        //print(yearString)
        
        formatter.dateFormat = "dd"
        let dateString = formatter.string(from: date)
        //print(dateString)
        
        dateLabel.text = dayOfTheWeekString + ", " + monthString + " " + dateString + " " + yearString
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        clockInView.layer.cornerRadius = 15
        clockInView.layer.masksToBounds = true
        clockInView.layer.borderWidth = 2.5
        clockInView.backgroundColor = .clear
        
        clockOutView.layer.cornerRadius = 15
        clockOutView.layer.masksToBounds = true
        clockOutView.layer.borderWidth = 2.5
        clockOutView.backgroundColor = .clear
        
        let tapGestureForProfile = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGestureForProfile)
        
        checkConnectivity()
        
    }
    
    func checkConnectivity() {
        DispatchQueue.main.async {
            self.displayConnectivity()
            self.checkConnectivity()
        }
    }
    
    func displayConnectivity() {
        if Connectivity.isConnectedToInternet() {
            noConnectionLabel.isHidden = true
            view.isUserInteractionEnabled = true
            onlineStatus.text = "Online"
            onlineStatus.textColor = #colorLiteral(red: 0, green: 0.8687019944, blue: 0, alpha: 1)
            clockInView.isHidden = false
            clockOutView.isHidden = false
            profileImageView.isHidden = false
        } else {
            noConnectionLabel.isHidden = false
            view.isUserInteractionEnabled = false
            onlineStatus.text = "Offline"
            onlineStatus.textColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            clockInView.isHidden = true
            clockOutView.isHidden = true
            profileImageView.isHidden = true
        }
    }
    
    func isUserAttendanceAlreadyMarkedForToday() -> Bool {
        if todaysDate! != lastDayMarked! {
            return false
        } else {
            return true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkConnectivity()
        
        //print("is eligible for clock out", isEligibleForClockOut())
        db.collection("employees").whereField("mobile", isEqualTo: UserDefaults.standard.string(forKey: "phoneNumber")!).getDocuments() { (querySnapshot, error) in
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
                        
                        self.canClockIn = data["canClockIn"] as? Bool
                        self.canClockOut = data["canClockOut"] as? Bool
                        
                        self.currentClockIn = data["currentClockIn"] as? String
                        self.currentClockOut = data["currentClockOut"] as? String
                        
                        self.clockInHr = data["clockInHour"] as? Int
                        self.clockInMins = data["clockInMinutes"] as? Int
                        self.clockInDuring = data["clockInDuring"] as? String
                        
                        self.lastDayMarked = data["lastDayMarked"] as? String
                        let lastClockedIn = data["lastClockedIn"] as? String
                         
                        //print(self.canClockIn!)
                        //print(self.canClockOut!)
                        //print(self.lastDayMarked!)
                        
                        if let canClockIn = self.canClockIn {
                            if canClockIn && !self.isUserAttendanceAlreadyMarkedForToday() {
                                self.clockInViewEnabled()
                            } else {
                                self.clockInViewDisabled()
                            }
                        }

                        if let canClockOut = self.canClockOut {
                            if canClockOut && !self.isUserAttendanceAlreadyMarkedForToday() && self.isEligibleForClockOut() {
                                self.clockOutViewEnabled()
                            } else {
                                self.clockOutViewDisabled()
                            }
                        }
                        
                        if let lastClockedIn = lastClockedIn, let todaysDate = self.todaysDate, let canClockIn = self.canClockIn, let canClockOut = self.canClockOut {
                            if lastClockedIn != todaysDate && canClockIn == false &&  canClockOut == true {
                                print("you need to reset the buttons now.")
                                self.clockInViewEnabled()
                                self.clockOutViewDisabled()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue = manager.location else { return }
        location = locValue
        //print("locations = \(locValue.coordinate.latitude) \(locValue.coordinate.longitude)")
    }
    
    @objc func profileImageTapped() {
        performSegue(withIdentifier: "show_profile_view", sender: nil)
    }
    
    @objc func showQrScanner() {
        let dist = Double(location!.distance(from: CLLocation(latitude: CLLocationDegrees(exactly: 24.5741)!, longitude: CLLocationDegrees(exactly: 73.7308)!)))
        //let dist = 10.0
        //print("dist", dist)
        if dist < 25.0  {
            performSegue(withIdentifier: "show_qr_scanner", sender: nil)
        } else {
            let alert = UIAlertController(title: "Invalid location", message: "You need to be atleast 25 metres close to the location.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func clockInViewEnabled() {
        clockInView.layer.borderColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        clockInLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        clockInView.isUserInteractionEnabled = true
        let tapGestureForQr = UITapGestureRecognizer(target: self, action: #selector(showQrScanner))
        clockInView.isUserInteractionEnabled = true
        clockInView.addGestureRecognizer(tapGestureForQr)
        self.clockInInfoLabel.text = "Scan the QR code on any guard's phone and enter"
        self.clockOutInfoLabel.text = "Scan the QR code on any guard's phone and exit"
    }
    
    func clockInViewDisabled() {
        clockInView.layer.borderColor = #colorLiteral(red: 0.4197152853, green: 0.455994606, blue: 0.5045749545, alpha: 1)
        clockInLabel.textColor = #colorLiteral(red: 0.4197152853, green: 0.455994606, blue: 0.5045749545, alpha: 1)
        clockInView.isUserInteractionEnabled = false
        if currentClockIn != "" {
            self.clockInInfoLabel.text = "You clocked in at \(currentClockIn!) today"
        }
    }
    
    func clockOutViewEnabled() {
        clockOutView.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        clockOutLabel.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        clockOutView.isUserInteractionEnabled = true
        let tapGestureForQr = UITapGestureRecognizer(target: self, action: #selector(showQrScanner))
        clockOutView.isUserInteractionEnabled = true
        clockOutView.addGestureRecognizer(tapGestureForQr)
    }
    
    func clockOutViewDisabled() {
        clockOutView.layer.borderColor = #colorLiteral(red: 0.4197152853, green: 0.455994606, blue: 0.5045749545, alpha: 1)
        clockOutLabel.textColor = #colorLiteral(red: 0.4197152853, green: 0.455994606, blue: 0.5045749545, alpha: 1)
        clockOutView.isUserInteractionEnabled = false
        if currentClockOut != "" && isUserAttendanceAlreadyMarkedForToday() {
            self.clockOutInfoLabel.text = "You clocked out at \(currentClockOut!) today"
        }
    }
    
    func getEmployeeData() {
        db.collection("employees").whereField("mobile", isEqualTo: UserDefaults.standard.string(forKey: "phoneNumber")!).getDocuments() { (querySnapshot, error) in
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
                        
                        let userId = document.documentID
                        UserDefaults.standard.set(userId, forKey: "userId")
                        
                        let name = data["name"] as! String
                        //print(name)
                        let mobile = data["mobile"] as! String
                        let email = data["email"] as! String
                        let designation = data["designation"] as! String
                        let department = data["department"] as! String
                        let type = data["type"] as! String
                        
                        UserDefaults.standard.set(name, forKey: "name")
                        UserDefaults.standard.set(mobile, forKey: "mobile")
                        UserDefaults.standard.set(email, forKey: "email")
                        UserDefaults.standard.set(designation, forKey: "designation")
                        UserDefaults.standard.set(department, forKey: "department")
                        UserDefaults.standard.set(type, forKey: "type")
                        
                        let date = Date()
                        let calendar = Calendar.current
                        let hour = calendar.component(.hour, from: date)
                        
                        if hour < 11 {
                            self.goodMorningLabel.text = "Good Morning, " + name
                        }
                        else if hour > 11 && hour < 17 {
                            self.goodMorningLabel.text = "Good Afternoon, " + name
                        }
                        else {
                            self.goodMorningLabel.text = "Good Evening, " + name
                        }
                    }
                }
            }
        }
    }
    
    func isEligibleForClockOut() -> Bool {
        let date = Date()
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        var minutes = calendar.component(.minute, from: date)
        var during = "A.M."
        if hour >= 12 {
            hour = hour - 12
            during = "P.M."
        }
        //print(hour)
        //print(minutes)
        
        if let clockInHr = clockInHr, let clockInMins = clockInMins, let clockInDuring = clockInDuring {
            if clockInHr == 12 {
                if hour - clockInHr == 0 {
                    if minutes - clockInMins > 30 {
                        return true
                    }
                }
                else {
                    hour += 12
                    if hour - clockInHr == 1 {
                        minutes += 60
                        if minutes - clockInMins > 30 {
                            return true
                        }
                    }
                    else if hour - clockInHr > 1 {
                        return true
                    }
                }
            }
            else if clockInDuring == during {
                if hour - clockInHr == 0 {
                    if minutes - clockInMins > 30 {
                        return true
                    } else {
                        return false
                    }
                }
                else if hour - clockInHr == 1 {
                    minutes += 60
                    if minutes - clockInMins > 30 {
                        return true
                    }
                }
                else if hour - clockInHr > 1 {
                    return true
                }
            } else {
                hour = hour + 12
                if hour - clockInHr == 0 {
                    if minutes - clockInMins > 30 {
                        return true
                    } else {
                        return false
                    }
                }
                else if hour - clockInHr == 1 {
                    minutes += 60
                    if minutes - clockInMins > 30 {
                        return true
                    }
                }
                else if hour - clockInHr > 1 {
                    return true
                }
            }
        }
        return false
    }
}
