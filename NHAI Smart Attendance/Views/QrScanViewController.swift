//
//  QrScanViewController.swift
//  NHAI Smart Attendance
//
//  Created by Chinmay Bapna on 13/08/20.
//  Copyright © 2020 Chinmay Bapna. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseFirestore

class QrScanViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    
    var canClockIn: Bool?
    var canClockOut: Bool?
    var currentClockIn: String?
    
    let homeVC = HomeViewController()
    
    let db = Firestore.firestore()
    
    var qrCodeFrameView: UIView?
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //decryptQrString(encodedString: "abcd")
        
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
                        
                        self.canClockIn = data["canClockIn"] as? Bool
                        self.canClockOut = data["canClockOut"] as? Bool
                        self.currentClockIn = data["currentClockIn"] as? String
                        
                        //print(self.canClockIn!)
                        //print(self.canClockOut!)
                    }
                }
            }
        }
        
        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            //print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = cameraView.layer.bounds
        cameraView.layer.addSublayer(previewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            cameraView.addSubview(qrCodeFrameView)
            cameraView.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    func decryptQrString(encodedString: String) -> String {
        var decodedString = ""
        for i in 0...encodedString.count-1 {
//            print(encodedString.characterAtIndex(index: i)!.asciiValue!)
//            print(Character(Unicode.Scalar(encodedString.characterAtIndex(index: i)!.asciiValue!+UInt8(i+1))))
            decodedString += String(Character(Unicode.Scalar(encodedString.characterAtIndex(index: i)!.asciiValue!-UInt8(i+1))))
        }
        //print(decodedString)
        return decodedString
    }
}

extension QrScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let date = Date()
            let calendar = Calendar.current
            var hour = calendar.component(.hour, from: date)
            var during = "A.M."
            if hour >= 12 {
                hour = hour - 12
                during = "P.M."
            }
            let minutes = calendar.component(.minute, from: date)
            //print(hour)
            //print(minutes)
            //print(during)
            let time = String(hour) + ":" + String(minutes) + " " + during
            //print(time)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let resultDate = formatter.string(from: date)
            
            let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                //print(metadataObj.stringValue!)
                //print(decryptQrString(encodedString: metadataObj.stringValue!))
                if decryptQrString(encodedString: metadataObj.stringValue!) == resultDate || decryptQrString(encodedString: metadataObj.stringValue!) == "NHAIDELHIHQPHYSICALQR" {
                    captureSession.stopRunning()

                    if let canClockIn = canClockIn {
                        if canClockIn {
                            db.collection("employees").document(UserDefaults.standard.string(forKey: "userId")!).setData([
                                "currentClockIn": time,
                                "canClockIn": false,
                                "canClockOut": true,
                                "clockInHour": hour,
                                "clockInMinutes": minutes,
                                "clockInDuring": during,
                                "lastClockedIn": resultDate
                            ], merge: true)
                            
                            navigationController?.popViewController(animated: true)
                        }
                        else {
                            //print("clocked out")
                            if let name = UserDefaults.standard.string(forKey: "name"), let mobile = UserDefaults.standard.string(forKey: "mobile"), let department = UserDefaults.standard.string(forKey: "department"), let designation = UserDefaults.standard.string(forKey: "designation"), let type = UserDefaults.standard.string(forKey: "type"), let clockIn = currentClockIn {
                                db.collection("attendance").document().setData([
                                    "name": name,
                                    "date": resultDate,
                                    "mobile": mobile,
                                    "designation": designation,
                                    "department": department,
                                    "type": type,
                                    "clockIn": clockIn,
                                    "clockOut": time
                                ])
                            }
                            
                            db.collection("employees").document(UserDefaults.standard.string(forKey: "userId")!).setData([
                                "canClockIn": true,
                                "canClockOut": false,
                                "currentClockOut": time,
                                "lastDayMarked": resultDate
                            ], merge: true)
                            
                            navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension StringProtocol {
    var asciiValues: [UInt8] { compactMap(\.asciiValue) }
}

extension String {
    func characterAtIndex(index: Int) -> Character? {
        var cur = 0
        for char in self {
            if cur == index {
                return char
            }
            cur += 1
        }
        return nil
    }
}

