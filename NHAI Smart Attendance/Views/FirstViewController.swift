//
//  FirstViewController.swift
//  NHAI Smart Attendance
//
//  Created by Chinmay Bapna on 13/08/20.
//  Copyright © 2020 Chinmay Bapna. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 10
    }
}
