//
//  Connectivity.swift
//  NHAI Smart Attendance
//
//  Created by Chinmay Bapna on 21/08/20.
//  Copyright © 2020 Chinmay Bapna. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
