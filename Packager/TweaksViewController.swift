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
    
    let fm = FileManager.default
    let downloadPath = "/var/containers/Bundle/tweaksupport/Library/packagertemp/1.zip"
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBOutlet weak var outputLog: UITextView!
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
    
    func log(message: String) {
        self.outputLog.text += message + "\n"
        print(message)
    }
    
    func showInstallError(error: String) {
        let alert2 = UIAlertController(title: "Packager Error", message: "There was an issue installing your tweak. Contact @ConorTheDev on Twitter. Error:\n" + error, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.log(message: "Cleaning up!")
            do {
                try self.fm.removeItem(at: URL(fileURLWithPath: self.downloadPath))
                try self.fm.removeItem(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1"))
            } catch _ {
                self.showInstallError(error: "Failed to clean temporary files!")
            }
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
    
    func injectFiles(tweakDylib: URL, preferenceBundle: URL) {
        //self.log(message: "Injecting isn't supported yet.... Skipping.")
        
        let installUtils = InstallUtils.init()
        
        self.log(message: "Injecting TweakDylib...")
        installUtils.inject(tweakDylib.absoluteString)
        
        self.log(message: "Injected TweakDylib!")
        
        self.log(message: "Injecting PreferenceBundle...")
        
        installUtils.inject(preferenceBundle.absoluteString)
        
        self.log(message: "Injected PreferenceBundle!")
        
        self.log(message: "Cleaning up!")
        do {
            try fm.removeItem(at: URL(fileURLWithPath: downloadPath))
            try fm.removeItem(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1"))
        } catch _ {
            self.showInstallError(error: "Failed to clean temporary files!")
        }
        self.showSuccessMessage()
    }
    
    @IBAction func startDownload(_ sender: Any) {
        downloadButton.isEnabled = false
        outputLog.text = ""
        let url = textField.text ?? ""
        self.log(message: "Lets A Go!")
        
        if(url != "") {
            self.log(message: "Starting Installation")
            if(!fm.fileExists(atPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1")) {
                do {
                    try self.fm.removeItem(at: URL(fileURLWithPath: self.downloadPath))
                    try self.fm.removeItem(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1"))
                    
                    self.log(message: "Cleaned Old Files")
                    
                } catch _ {
                    self.log(message: "No Files To Clean")
                }
            }
            do {
                if(!fm.fileExists(atPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/")) {
                    do{
                        try fm.createDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/", isDirectory: true), withIntermediateDirectories: false, attributes: nil)
                    } catch _ {
                        self.log(message: "Directory Created")
                    }
                }
                self.log(message: "Downloading...")
                
                Downloader.load(url: URL(string: url)!, to: URL(fileURLWithPath: downloadPath)) {
                    self.log(message: "File downloaded!")
                    do {
                        do{
                            try self.fm.unzipItem(at: URL(fileURLWithPath: self.downloadPath), to: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1"))
                        }catch{
                            self.log(message: "Unzipped!")
                            self.log(message: "Moving files...")
                        }
                        if(self.fm.fileExists(atPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/Library")) {
                            
                            self.log(message: "Library Exists! Doing lib method!")
                            
                            var DynamicLibs = [URL(string: "")]
                            
                            let mobileSubstrateDynamicLibs = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/Library/MobileSubstrate/DynamicLibraries"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                            
                            for file in mobileSubstrateDynamicLibs {
                                DynamicLibs.removeFirst()
                                DynamicLibs.append(file.absoluteURL)
                            }
                            
                            for file in DynamicLibs {
                                self.log(message: "Found files in Mobile Substrate:" + (file?.absoluteString)!)
                            }
                            
                            var PreferenceFiles = [URL(string: "")]
                            
                            let preferenceLoaderFiles = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/Library/PreferenceLoader/Preferences"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                            
                            PreferenceFiles.removeFirst()
                            
                            for file in preferenceLoaderFiles {
                                if(file.absoluteString.hasSuffix(".bundle")) {
                                    PreferenceFiles.append(file.absoluteURL)
                                }
                            }
                            
                            for file in preferenceLoaderFiles {
                                self.log(message: "Found files in PreferenceLoader:" + file.absoluteString)
                            }
                            
                            let preferenceBundleFiles = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/Library/PreferenceBundles/"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                            
                            for file in preferenceBundleFiles {
                                DynamicLibs.removeFirst()
                                DynamicLibs.append(file.absoluteURL)
                            }
                            
                            for file in DynamicLibs {
                                self.log(message: "Found files in Mobile Substrate:" + file!.absoluteString)
                            }
                            
                            self.log(message: "Found required files, moving files...")
                            
                            for url in mobileSubstrateDynamicLibs {
                                let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries/" + url.lastPathComponent)
                                
                                self.log(message: "File URL:" + url.absoluteString)
                                self.log(message: "Destination URL:" +  path.absoluteString)
                                
                                try self.fm.moveItem(at: url, to: path)
                            }
                            
                            self.log(message: "Moved mobileSubstrateDynamicLibs...")
                            
                            for url in preferenceLoaderFiles {
                                let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/PreferenceLoader/Preferences/" + url.lastPathComponent)
                                
                                self.log(message: "File URL:" + url.absoluteString)
                                self.log(message: "Destination URL:" + path.absoluteString)
                                
                                try self.fm.moveItem(at: url, to: path)
                            }
                            
                            self.log(message: "Moved preferenceLoaderFiles...")
                            
                            for url in preferenceBundleFiles {
                                let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/PreferenceBundles/" + url.lastPathComponent)
                                
                                self.log(message: "File URL:" + url.absoluteString)
                                self.log(message: "Destination URL:" + path.absoluteString)
                                
                                try self.fm.moveItem(at: url, to: path)
                            }
                            
                            let preferenceBundle = preferenceBundleFiles[0].absoluteURL
                            let tweakDylib = mobileSubstrateDynamicLibs[0].absoluteURL
                            
                            if(tweakDylib != URL(string: "") && preferenceBundle != URL(string: "")) {
                                self.log(message: "Moved all files... INJECTING!")
                                
                                self.injectFiles(tweakDylib: tweakDylib, preferenceBundle: preferenceBundle)
                            } else {
                                self.showInstallError(error: "TweakDylib or PreferenceBundle is nil!")
                                self.downloadButton.isEnabled = true
                            }
                        } else {
                            self.log(message: "Library Doesnt Exist! Doing non-lib method!")
                            
                            if(self.fm.fileExists(atPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/MobileSubstrate")) {
                                self.log(message: "MobileSubstrate Exists! Continuing...")
                                
                                //Install without Library, straight from MobileSubstrate
                                
                                var DynamicLibs = [URL(string: "")]
                                
                                let mobileSubstrateDynamicLibs = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/MobileSubstrate/DynamicLibraries"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                                
                                for file in mobileSubstrateDynamicLibs {
                                    DynamicLibs.removeFirst()
                                    DynamicLibs.append(file.absoluteURL)
                                }
                                
                                for file in DynamicLibs {
                                    self.log(message: "Found files in Mobile Substrate:" + file!.absoluteString)
                                }
                                
                                var PreferenceFiles = [URL(string: "")]
                                
                                let preferenceLoaderFiles = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/PreferenceLoader/Preferences"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                                
                                PreferenceFiles.removeFirst()
                                
                                for file in preferenceLoaderFiles {
                                    if(file.absoluteString.hasSuffix(".bundle")) {
                                        PreferenceFiles.append(file.absoluteURL)
                                    }
                                }
                                
                                for file in preferenceLoaderFiles {
                                    self.log(message: "Found files in PreferenceLoader:" + file.absoluteString)
                                }
                                
                                let preferenceBundleFiles = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/PreferenceBundles/"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                                
                                for file in preferenceBundleFiles {
                                    DynamicLibs.removeFirst()
                                    DynamicLibs.append(file.absoluteURL)
                                }
                                
                                for file in DynamicLibs {
                                    self.log(message: "Found files in Mobile Substrate:" + file!.relativeString)
                                }
                                
                                self.log(message: "Found required files, moving files...")
                                
                                for url in mobileSubstrateDynamicLibs {
                                    let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries/" + url.lastPathComponent)
                                    
                                    self.log(message: "File URL:" + url.absoluteString)
                                    self.log(message: "Destination URL:" + path.absoluteString)
                                    
                                    try self.fm.moveItem(at: url, to: path)
                                }
                                
                                self.log(message: "Moved mobileSubstrateDynamicLibs...")
                                
                                for url in preferenceLoaderFiles {
                                    let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/PreferenceLoader/Preferences/" + url.lastPathComponent)
                                    
                                    self.log(message: "File URL:" + url.absoluteString)
                                    self.log(message: "Destination URL:" + path.absoluteString)
                                    
                                    try self.fm.moveItem(at: url, to: path)
                                }
                                
                                self.log(message: "Moved preferenceLoaderFiles...")
                                
                                for url in preferenceBundleFiles {
                                    let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/PreferenceBundles/" + url.lastPathComponent)
                                    
                                    self.log(message: "File URL:" + url.absoluteString)
                                    self.log(message: "Destination URL:" + path.absoluteString)
                                    
                                    try self.fm.moveItem(at: url, to: path)
                                }
                                
                                let preferenceBundle = preferenceBundleFiles[0].absoluteURL
                                let tweakDylib = mobileSubstrateDynamicLibs[0].absoluteURL
                                
                                if(tweakDylib != URL(string: "") && preferenceBundle != URL(string: "")) {
                                    self.log(message: "Moved all files... INJECTING!")
                                    
                                    self.injectFiles(tweakDylib: tweakDylib, preferenceBundle: preferenceBundle)
                                } else {
                                    self.showInstallError(error: "TweakDylib or PreferenceBundle is nil!")
                                    self.downloadButton.isEnabled = true
                                }
                            } else {
                                self.log(message: "MobileSubstrate or Library doesn't exist... Checking for tweak name.")
                                
                                let fileName = URL(fileURLWithPath: self.downloadPath).lastPathComponent.dropLast(6)
                                
                                if(self.fm.fileExists(atPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/" + fileName)) {
                                    
                                    self.log(message: "TweakName folder exists! Going forward with installation")
                                    
                                    var DynamicLibs = [URL(string: "")]
                                    
                                    let mobileSubstrateDynamicLibs = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/" + fileName + "/Library/MobileSubstrate/DynamicLibraries"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                                    
                                    for file in mobileSubstrateDynamicLibs {
                                        DynamicLibs.removeFirst()
                                        DynamicLibs.append(file.absoluteURL)
                                    }
                                    
                                    for file in DynamicLibs {
                                        self.log(message: "Found files in Mobile Substrate:" + file!.absoluteString)
                                    }
                                    
                                    var PreferenceFiles = [URL(string: "")]
                                    
                                    let preferenceLoaderFiles = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/" + fileName + "Library/PreferenceLoader/Preferences"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                                    
                                    PreferenceFiles.removeFirst()
                                    
                                    for file in preferenceLoaderFiles {
                                        if(file.absoluteString.hasSuffix(".bundle")) {
                                            PreferenceFiles.append(file.absoluteURL)
                                        }
                                    }
                                    
                                    for file in preferenceLoaderFiles {
                                        self.log(message: "Found files in PreferenceLoader:" + file.absoluteString)
                                    }
                                    
                                    let preferenceBundleFiles = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/1/" + fileName + "   Library/PreferenceBundles/"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                                    
                                    for file in preferenceBundleFiles {
                                        DynamicLibs.removeFirst()
                                        DynamicLibs.append(file.absoluteURL)
                                    }
                                    
                                    for file in DynamicLibs {
                                        self.log(message: "Found files in Mobile Substrate:" + file!.absoluteString)
                                    }
                                    
                                    self.log(message: "Found required files, moving files...")
                                    
                                    for url in mobileSubstrateDynamicLibs {
                                        let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries/" + url.lastPathComponent)
                                        
                                        self.log(message: "File URL:" + url.absoluteString)
                                        self.log(message: "Destination URL:" + path.absoluteString)
                                        
                                        try self.fm.moveItem(at: url, to: path)
                                    }
                                    
                                    self.log(message: "Moved mobileSubstrateDynamicLibs...")
                                    
                                    for url in preferenceLoaderFiles {
                                        let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/PreferenceLoader/Preferences/" + url.lastPathComponent)
                                        
                                        self.log(message: "File URL:" + url.absoluteString)
                                        self.log(message: "Destination URL:" + path.absoluteString)
                                        
                                        try self.fm.moveItem(at: url, to: path)
                                    }
                                    
                                    self.log(message: "Moved preferenceLoaderFiles...")
                                    
                                    for url in preferenceBundleFiles {
                                        let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/PreferenceBundles/" + url.lastPathComponent)
                                        
                                        self.log(message: "File URL:" +  url.absoluteString)
                                        self.log(message: "Destination URL:" + path.absoluteString)
                                        
                                        try self.fm.moveItem(at: url, to: path)
                                    }
                                    
                                    let preferenceBundle = preferenceBundleFiles[0].absoluteURL
                                    let tweakDylib = mobileSubstrateDynamicLibs[0].absoluteURL
                                    
                                    if(tweakDylib != URL(string: "") && preferenceBundle != URL(string: "")) {
                                        self.log(message: "Moved all files... INJECTING!")
                                        
                                        self.injectFiles(tweakDylib: tweakDylib, preferenceBundle: preferenceBundle)
                                    } else {
                                        self.showInstallError(error: "TweakDylib or PreferenceBundle is nil!")
                                        self.downloadButton.isEnabled = true
                                    }
                                }
                            }
                        }
                    } catch let error2 {
                        self.log(message: error2.localizedDescription)
                        self.showInstallError(error: error2.localizedDescription)
                        self.downloadButton.isEnabled = false
                    }
                }
            } catch let error {
                self.showInstallError(error: error.localizedDescription)
                self.log(message: error.localizedDescription)
                downloadButton.isEnabled = true
            }
        }
    }
}
