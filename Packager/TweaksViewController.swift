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
    
    func showInstallError(error: String) {
        let alert2 = UIAlertController(title: "Packager Error", message: "There was an issue installing your tweak. Contact @ConorTheDev on Twitter. Error:\n" + error, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            alert2.dismiss(animated: true, completion: nil)
        }
        
        alert2.addAction(action)
        
        self.present(alert2, animated: true, completion: nil)
    }
    
    func showSuccessMessage() {
        let alert2 = UIAlertController(title: "Packager", message: "Your tweak was installed! Respring?", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Respring!", style: UIAlertAction.Style.default) {
            UIAlertAction in
            
            let kilallSB = "killall SpringBoard"
            
            print(kilallSB.run()!)
        }
        
        let action2 = UIAlertAction(title: "Don't respring yet.", style: UIAlertAction.Style.default) {
            UIAlertAction in
            alert2.dismiss(animated: false, completion: nil)
        }
        
        alert2.addAction(action)
        alert2.addAction(action2)
        
        self.present(alert2, animated: true, completion: nil)
    }
    
    @IBAction func startDownload(_ sender: Any) {
        let fm = FileManager.default
        let url = textField.text ?? ""
        let downloadPath = "/var/containers/Bundle/tweaksupport/Library/packagertemp/1.zip"
    
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
                                
                                var DynamicLibs = [URL(string: "")]
                                
                                let mobileSubstrateDynamicLibs = try fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/Library/MobileSubstrate/DynamicLibraries"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                                
                                for file in mobileSubstrateDynamicLibs {
                                    DynamicLibs.removeFirst()
                                    DynamicLibs.append(file.absoluteURL)
                                }
                                
                                for file in DynamicLibs {
                                    print("Found files in Mobile Substrate:", file!)
                                }
                                
                                var PreferenceFiles = [URL(string: "")]
                                
                                let preferenceLoaderFiles = try fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/Library/PreferenceLoader/Preferences"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                                
                                PreferenceFiles.removeFirst()
                                
                                for file in preferenceLoaderFiles {
                                    if(file.absoluteString.hasSuffix(".bundle")) {
                                        PreferenceFiles.append(file.absoluteURL)
                                    }
                                }
                                
                                for file in preferenceLoaderFiles {
                                    print("Found files in PreferenceLoader:", file)
                                }
                                
                                let preferenceBundleFiles = try fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/Library/PreferenceBundles/"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                                
                                for file in preferenceBundleFiles {
                                    DynamicLibs.removeFirst()
                                    DynamicLibs.append(file.absoluteURL)
                                }
                                
                                for file in DynamicLibs {
                                    print("Found files in Mobile Substrate:", file!)
                                }
                                
                                print("Found required files, moving files...")
                                
                                for url in mobileSubstrateDynamicLibs {
                                    let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries/" + url.lastPathComponent)
                                    
                                    print("File URL:", url)
                                    print("Destination URL:", path)
                                    
                                   try fm.moveItem(at: url, to: path)
                                }
                                
                                print("Moved mobileSubstrateDynamicLibs...")
                                
                                for url in preferenceLoaderFiles {
                                    let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/PreferenceLoader/Preferences/" + url.lastPathComponent)
                                    
                                    print("File URL:", url)
                                    print("Destination URL:", path)
                                    
                                    try fm.moveItem(at: url, to: path)
                                }
                                
                                print("Moved preferenceLoaderFiles...")
                                
                                for url in preferenceBundleFiles {
                                    let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/PreferenceBundles/" + url.lastPathComponent)
                                    
                                    print("File URL:", url)
                                    print("Destination URL:", path)
                                    
                                    try fm.moveItem(at: url, to: path)
                                }
                                
                                let preferenceBundle = preferenceBundleFiles[0].absoluteURL
                                let tweakDylib = mobileSubstrateDynamicLibs[0].absoluteURL

                                if(tweakDylib != URL(string: "") && preferenceBundle != URL(string: "")) {
                                    print("Moved all files... INJECTING!")
                                    
                                    print("Injecting TweakDylib...")
                                    
                                    let command = "inject " + (tweakDylib.absoluteURL.absoluteString)
                                    
                                    if(command == "inject ") {
                                        self.showInstallError(error: "Inject command is empty!")
                                    } else {
                                        print(command.run()!)
                                    }
                                    
                                    print("Injected TweakDylib!")
                                    
                                    print("Injecting PreferenceBundle...")
                                    
                                    let command2 = "inject " + (preferenceBundle.absoluteURL.absoluteString)
                                    
                                    if(command2 == "inject ") {
                                        self.showInstallError(error: "Inject2 command is empty!")
                                    } else {
                                        print(command2.run()!)
                                    }
                                    
                                    print("Sucessfully Injected Tweak!")
                                    
                                    print("Cleaning up!")
                                    try fm.removeItem(at: URL(fileURLWithPath: downloadPath))
                                    try fm.removeItem(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1"))
                                    
                                    self.showSuccessMessage()
                                } else {
                                    self.showInstallError(error: "TweakDylib or PreferenceBundle is nil!")
                                }
                            } else {
                                print("Library Doesnt Exist! Doing non-lib method!")
                                
                                if(fm.fileExists(atPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/MobileSubstrate")) {
                                    print("MobileSubstrate Exists! Continuing...")
                                } else {
                                    print("MobileSubstrate doesn't exist! Suspending...")
                                    self.showInstallError(error: "MobileSubstrate doesn't exist!")
                                }
                            }
                        } catch let error2 {
                            print(error2)
                            self.showInstallError(error: error2.localizedDescription)
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

extension String {
    func run() -> String? {
        let pipe = Pipe()
        let process = NSTask()
        process!.setLaunchPath("/var/")
        process!.setArguments(["-c", self])
        process!.setStandardOutput(pipe)
        
        let fileHandle = pipe.fileHandleForReading
        process!.launch()
        
        return String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
    }
}
