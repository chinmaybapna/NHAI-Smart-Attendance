//
//  ProfileViewController.swift
//  NHAI Smart Attendance
//
//  Created by Chinmay Bapna on 13/08/20.
//  Copyright © 2020 Chinmay Bapna. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var tableView: UITableView!
    
    let entryFields = ["Name", "Mobile Number", "Email ID", "Designation", "Department", "Type"]
    var valueFields : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let buttonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonPressed(_:)))
        navigationItem.rightBarButtonItem = buttonItem
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "profile_cell")

        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = false
        
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
                        
                        let name = data["name"] as! String
                        self.valueFields.append(name)
                        //print(name)
                        
                        let mobile = data["mobile"] as! String
                        self.valueFields.append(mobile)
                        
                        let email = data["email"] as! String
                        self.valueFields.append(email)
                        
                        let designation = data["designation"] as! String
                        self.valueFields.append(designation)
                        
                        let department = data["department"] as! String
                        self.valueFields.append(department)
                        
                        let type = data["type"] as! String
                        self.valueFields.append(type)
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @objc func logoutButtonPressed(_ sender: UIBarButtonItem) {
        print("log out pressed")
        UserDefaults.standard.set("no", forKey: "isLoggedIn")
        performSegue(withIdentifier: "logout", sender: nil)
    }
}

//MARK:- table view datasource

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valueFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profile_cell", for: indexPath) as! ProfileTableViewCell
        cell.entryLabel.text = entryFields[indexPath.row]
        cell.valueLabel.text = valueFields[indexPath.row]
        return cell
    }
}
