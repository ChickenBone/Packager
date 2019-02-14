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
import QuartzCore
import Digger

class TweaksViewController: UITableViewController, UITextFieldDelegate {
    
    private var downloadTask: URLSessionDownloadTask?

    private let fm = FileManager.default
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBOutlet weak var outputLog: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        
        textField.layer.borderWidth = 3/UIScreen.main.nativeScale
        textField.layer.borderColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.2).cgColor
        textField.layer.cornerRadius = textField.frame.height / 2
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func injectFiles(tweakDylib: URL, preferenceBundle: URL) {
        let installUtils = InstallUtils.init()
        
        self.log(message: "[i] Injecting TweakDylib...")
        installUtils.inject(tweakDylib.absoluteString)
        
        self.log(message: "[i] Injected TweakDylib!")
        self.log(message: "[i] Injecting PreferenceBundle...")

        installUtils.inject(preferenceBundle.absoluteString)
        
        self.log(message: "[i] Injected PreferenceBundle!")
        self.log(message: "[i] Giving permissions to PreferenceBundle!")
        
        installUtils.chmod(preferenceBundle.absoluteString)
        
        self.log(message: "[i] Cleaning up...")
        
        self.cleanUp()
        
        self.showSuccessMessage()
    }
    
    @IBAction func startDownload(_ sender: Any) {
        let url = textField.text ?? ""
        let downloadDirectory = "/var/containers/Bundle/tweaksupport/Library/packagertemp/"
        
        downloadButton.isEnabled = false
        outputLog.text = ""
        
        if(url != "") {
            self.log(message: "[*] Starting Installation")
            
            if(fm.fileExists(atPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/")) {
                self.cleanUp()
            } else {
                self.log(message: "[i] No Temporary Files To Clean.")
            }
            
            do {
                do{
                    try fm.createDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/", isDirectory: true), withIntermediateDirectories: false, attributes: nil)
                    
                    self.log(message: "[i] Created temporary directory")
                } catch _ {
                    self.log(message: "[!] Failed to create temporary directory.")
                    self.showInstallError(error: "Failed to create temporary directory.")
                }
                
                self.log(message: "[i] Downloading...")
                
                Digger.download(URL(string: url)!)
                .progress({ (progress) in
                    print(Float(progress.completedUnitCount) / Float(progress.totalUnitCount))
                    
                    let progress = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                    self.progressBar.progress = progress * 100
                })
                .completion ({ (result) in
                    switch result {
                        case .success(let url):
                            self.log(message: "[i] Downloaded!")
                        
                            do {
                                let fileArray = url.pathComponents
                                let finalFileName = fileArray.last!
                                
                                let downloadPath = downloadDirectory + finalFileName
                                
                                self.log(message: "[d] Final File Name = " + finalFileName)
                                self.log(message: "[d] Download Path = " + url.absoluteString)
                                self.log(message: "[d] Does Temporary Directory Exist = " + String(self.fm.fileExists(atPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/")))
                                self.log(message: "[d] Does File Downloaded URL Exist = " + String(self.fm.fileExists(atPath: url.absoluteString)))

                                try self.fm.copyItem(at: URL(fileURLWithPath: url.absoluteString), to: URL(fileURLWithPath: downloadPath))
                                try self.fm.unzipItem(at: URL(fileURLWithPath: downloadPath), to: URL(fileURLWithPath: downloadDirectory))
                            } catch let error{
                                self.log(message: error.localizedDescription)
                                self.showInstallError(error: error.localizedDescription)
                                self.downloadButton.isEnabled = true
                            }
                        
                            self.log(message: "[i] Unzipped!")
                        
                        case .failure(let error):
                            self.log(message: "[!] Failed to download!\n[!] Error:\n[!] " + error.localizedDescription)
                            self.showInstallError(error: "Failed to download file! " + error.localizedDescription)
                            self.downloadButton.isEnabled = true
                    }
                })
        
            } /*catch let error{
                self.log(message: error.localizedDescription)
                self.showInstallError(error: error.localizedDescription)
                self.downloadButton.isEnabled = true
            }*/
        } else {
            self.log(message: "[!] Tweak URL is Invalid!")
            self.showInstallError(error: "The URL you entered is invalid")
        }
    }
    
    func installTweak(url: URL, method: String) {
        if(method == "libraryFirst") {
            // Zip File Format:
            // zipfile.zip/Library/...
        } else if(method == "tweakNameFirst") {
            // Zip File Format:
            // zipfile.zip/TweakName/Library/...
            
            // Also check for:
            // Zip File Format:
            // zipfile.zip/TweakName/var/LIB/...
        } else if(method == "varFirst") {
            // Zip File Format:
            // zipfile.zip/var/LIB
        } else {
            // The ZIP is either a random one or not formatted correctly.
            self.log(message: "[!] Tweak is not formatted correctly!")
            self.showInstallError(error: "The tweak you provided is not supported by Packager.")
        }
    }
    
    func cleanUp() {
        do {
            try self.fm.removeItem(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/"))
            
            DiggerCache.cleanDownloadFiles()
            DiggerCache.cleanDownloadTempFiles()
            
            self.log(message: "[i] Cleared Temporary Files!")
        } catch let error {
            self.log(message: "[!] Failed to clear temporary files\n[!] Error:\n[!] " + error.localizedDescription)
            self.showInstallError(error: error.localizedDescription)
            self.downloadButton.isEnabled = true
        }
    }
    
    func log(message: String) {
        self.outputLog.text += message + "\n"
        print(message)
    }
    
    func showInstallError(error: String) {
        let alert2 = UIAlertController(title: "Packager Error", message: "There was an issue installing your tweak. Contact @ConorTheDev on Twitter. Error:\n" + error, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.log(message: "[i] Cleaning up...")
            
            self.cleanUp()
            
            alert2.dismiss(animated: true, completion: nil)
        }
        
        alert2.addAction(action)
        
        self.present(alert2, animated: true, completion: nil)
    }
    
    func showSuccessMessage() {
        let alert2 = UIAlertController(title: "Packager", message: "Your tweak was installed!", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Respring", style: UIAlertAction.Style.default) {
            UIAlertAction in
            InstallUtils.init().killsb()
        }
        
        let action2 = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
            UIAlertAction in
            alert2.dismiss(animated: false, completion: nil)
        }
        
        alert2.addAction(action)
        alert2.addAction(action2)
        
        self.present(alert2, animated: true, completion: nil)
    }
}
