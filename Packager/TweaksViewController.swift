//
//  TweaksViewController.swift
//  Packager
//
//  Created by Conor Byrne on 09/02/2019.
//  Copyright © 2019 Conor Byrne. All rights reserved.
//

import UIKit
import Foundation
import ZIPFoundation

class TweaksViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func showTweakError() {
        let alert2 = UIAlertController(title: "Packager Error", message: "There was an issue with the Tweak you Provided, contact @ConorTheDev on Twitter with the URL.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            alert2.dismiss(animated: true, completion: nil)
        }
        
        alert2.addAction(action)
        
        self.present(alert2, animated: true, completion: nil)
    }
    
    @IBAction func startDownload(_ sender: Any) {
        let fm = FileManager.default
        let url = textField.text ?? ""
        let downloadPath = "/var/containers/Bundle/tweaksupport/Library/packagertemp/1.zip"
        let injectShPath = "/var/containers/Bundle/tweaksupport/Library/Packager/inject.sh"
        let scriptDownloadURL = URL(string: "https://conorthedev.club/apps/Packager/inject.sh")
    
        if(url != "") {
            do {
                if(!fm.fileExists(atPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/")) {
                    try fm.createDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/", isDirectory: true), withIntermediateDirectories: false, attributes: nil)
                }
                
                Downloader.load(url: URL(string: url)!, to: URL(fileURLWithPath: downloadPath)) {
                    print("File downloaded!")
                    let alert = UIAlertController(title: "Packager Info", message: "File downloaded!", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Inject & Respring", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        alert.dismiss(animated: true, completion: nil)
                        do {
                            try fm.unzipItem(at: URL(fileURLWithPath: downloadPath), to: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1"))
                            
                            print("Unzipped!")
                            
                            print("Moving files...")
                            
                            if(fm.fileExists(atPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/Library")) {
                                
                                print("Library Exists! Doing lib method!")
                            } else {
                                print("Library Doesnt Exist! Doing non-lib method!")
                                
                                if(fm.fileExists(atPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/MobileSubstrate")) {
                                    print("MobileSubstrate Exists! Continuing...")
                                } else {
                                    print("MobileSubstrate doesn't exist! Suspending...")
                                    
                                    self.showTweakError()
                                }
                            }
                        } catch let error {
                            print(error)
                        }
                        
                        if(!fm.fileExists(atPath: injectShPath)) {
                            Downloader.load(url: scriptDownloadURL!, to: URL(fileURLWithPath: injectShPath)) {
                                print("Script downloaded!")
                            }
                        }
                    }
                    
                    alert.addAction(okAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            } catch let error {
                print(error)
            }
        }
    }
}

