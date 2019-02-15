//
//  TweaksViewController.swift
//  Packager
//
//  Created by Conor Byrne on 09/02/2019.
//  Copyright © 2019 Conor Byrne. All rights reserved.
//

import UIKit;
import Foundation;
import QuartzCore;
import ZIPFoundation;
import Digger;

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
//BEGINING OF WHAT I DID, you can delete from here to the end
    func moveFiles(msDL: [URL?], pLF: [URL?], pBF: [URL?] ){
        //Just a direct theft of what you made conor from the old moving files and it works lmao
        for url in msDL {
            let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries/" + url!.lastPathComponent)
            
            self.log(message: "File URL:" + url!.absoluteString)
            self.log(message: "Destination URL:" +  path.absoluteString)
            do{
            try self.fm.moveItem(at: url!, to: path)
        }catch{
            self.log(message: "Error in moveing files")
        }
        }
        
        self.log(message: "Moved mobileSubstrateDynamicLibs...")
        
        for url in pLF {
            let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/PreferenceLoader/Preferences/" + url!.lastPathComponent)
            
            self.log(message: "File URL:" + url!.absoluteString)
            self.log(message: "Destination URL:" + path.absoluteString)
            do{
            try self.fm.moveItem(at: url!, to: path)
        }catch{
            self.log(message: "Error in moveing files")
        }
        }
        
        self.log(message: "Moved preferenceLoaderFiles...")
        
        for url in pBF {
            let path = URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/PreferenceBundles/" + url!.lastPathComponent)
            
            self.log(message: "File URL:" + url!.absoluteString)
            self.log(message: "Destination URL:" + path.absoluteString)
            do{
            try self.fm.moveItem(at: url!, to: path)
            }catch{
                self.log(message: "Error in moveing files")
            }
        }
    }
    func getPrefLoader(type: String)->[URL?]{
        // A theft and adaptation to a seperate function, currently only gets one file and IDK why
        var PreferenceFiles = [URL(string: "")]
            do{
        let preferenceLoaderFiles = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/"+type+"/PreferenceLoader/Preferences/"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
        
        PreferenceFiles.removeFirst()
        
        for file in preferenceLoaderFiles {
            if(file.absoluteString.hasSuffix(".bundle")) {
                PreferenceFiles.append(file.absoluteURL)
            }
        }
        
        for file in preferenceLoaderFiles {
            self.log(message: "[i] Found files in PreferenceLoader: \n [i] " + file.absoluteString)
        }
            }catch{
                return PreferenceFiles
                
                
        }
        return PreferenceFiles
    }
    func getPrefBun(type: String)->[URL?]{
        // A theft and adaptation to a seperate function, Works beautifully

        var PrefBundles = [URL(string: "")]

        do{
        let preferenceBundleFiles = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/"+type+"/PreferenceBundles/"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
        
        for file in preferenceBundleFiles {
            PrefBundles.removeFirst()
            PrefBundles.append(file.absoluteURL)
        }
        
        for file in PrefBundles {
            self.log(message: "[i] Found files in PreferanceBundles: \n [i] " + file!.absoluteString)
        }
        }catch{
            return PrefBundles

        }
        return PrefBundles

    }
    func getDynLibs(type: String)->[URL?]{
        // A theft and adaptation to a seperate function, currently only gets one file and IDK why

        var DynamicLibs = [URL(string: "")]
        do{
        let mobileSubstrateDynamicLibs = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/"+type+"/MobileSubstrate/DynamicLibraries/"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
        for file in mobileSubstrateDynamicLibs {
            DynamicLibs.removeFirst()
            DynamicLibs.append(file.absoluteURL)
        }
        
        for file in DynamicLibs {
            self.log(message: "[i] Found files in Mobile Substrate: \n [i] " + (file?.absoluteString)!)
        }
        }catch{
            return DynamicLibs
            
            
        }
        return DynamicLibs

    }
// END OF WHAT I DID, delete to here ( if you want to go back )
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
        // We need to remove this just in case there is more than one DYNLIB or PREFBUNDLE so we can run this in a for loop
        self.cleanUp()
        // Same here we can call this seperatly
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
                                // Fixes the problem you told me to fix
                                let tempfile = url.absoluteString.replacingOccurrences(of: "file://", with: "")

                                self.log(message: "[d] Does File Downloaded URL Exist = " + String(self.fm.fileExists(atPath: tempfile)))

                                try self.fm.copyItem(at: URL(fileURLWithPath: tempfile), to: URL(fileURLWithPath: downloadPath))
                                try self.fm.unzipItem(at: URL(fileURLWithPath: downloadPath), to: URL(fileURLWithPath: downloadDirectory))
                                self.getMethod(url: URL(fileURLWithPath: downloadPath)) // Gets method and installs Tweak one big spicy function
                            } catch let error{
                                self.log(message: error.localizedDescription)
                                self.showInstallError(error: error.localizedDescription)
                                self.downloadButton.isEnabled = true
                                self.progressBar.progress = 0
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
//BEGINING OF WHAT I DID  ( Please keep it, it'll make the API and non-user provided URL installation MUCH easier )
    func getMethod(url: URL){
        // This func allows for easy installation once we impliment the API we can just do getMethod( local file name ) then it will install
        // All we need todo is make a method that downloads and unzips the files then we can truly just do justInstall( webURL ) and wow that would be cool
        // Honestly This works the best it can and it is the most efficiant it can be so I would stick with it
        let filename = url.lastPathComponent.replacingOccurrences(of: ".zip", with: "")
        let path = "/var/containers/Bundle/tweaksupport/Library/packagertemp/"
        do{
        if(self.fm.fileExists(atPath: path)){
            if(self.fm.fileExists(atPath: path+"Library/")){
                self.log(message: "[i] Library method found begining install")
                  self.installTweak(tweakname: filename, method: "libraryFirst")
            }
            else if(self.fm.fileExists(atPath: path+filename+"/Library/") || self.fm.fileExists(atPath: path+filename+"/LIB/")){
                self.log(message: "[i] Tweak Name method found begining install")
              self.installTweak(tweakname: filename, method: "tweakNameFirst")
            }
            else if(self.fm.fileExists(atPath: path+"/var/Library/") || self.fm.fileExists(atPath: "/var/LIB/")){
                self.log(message: "[i] Var method found begining install")
                self.installTweak(tweakname: filename, method: "varFirst")
            }else{
                self.log(message: "[!] Tweak is not formatted correctly!")
                self.showInstallError(error: "The tweak you provided is not supported by Packager.")
                self.downloadButton.isEnabled = true
            }
        }
    }
}
// END OF WHAT I DID
    func installTweak(tweakname: String, method: String) {
        if(method == "libraryFirst") {
//BEGINING OF WHAT I DID
            // Gets Dynamic Library Files using the /var/containers/Bundle/tweaksupport/Library/packagertemp/"+TYPE+"/MobileSubstrate/DynamicLibraries/ where TYPE is Library
            let type = "Library"
            let dLF = self.getDynLibs(type: type)
            // Same thing here
            let pLF = self.getPrefLoader(type: type)
            // WOW
            let pBF = self.getPrefBun(type: type)
            // Message
            self.log(message: "[i] Found required files, moving files...")
            // Moves the files gathered
            self.moveFiles(msDL: dLF, pLF: pLF, pBF: pBF)
            // Self explanitory
            self.log(message: "Files Moved!")
            // Holy shit it works
            self.showInstallError(error: "Files MOVED!!!!")
// END OF WHAT I DID
            //Method Name
            // zipfile.zip/Library/...
        } else if(method == "tweakNameFirst") {
//BEGINING OF WHAT I DID
            // WOW LOOK its adaptable
            let type = tweakname+"/Library"
            let dLF = self.getDynLibs(type: type)
            let pLF = self.getPrefLoader(type: type)
            let pBF = self.getPrefBun(type: type)
            self.log(message: "[i] Found required files, moving files...")
            self.moveFiles(msDL: dLF, pLF: pLF, pBF: pBF)
            self.log(message: "Files Moved!")
            self.showInstallError(error: "Files MOVED!!!!")
// END OF WHAT I DID
            // Zip File Format:
            // zipfile.zip/TweakName/Library/...
            // Also check for:
            // Zip File Format:
            // zipfile.zip/TweakName/var/LIB/...
        } else if(method == "varFirst") {

//BEGINING OF WHAT I DID
            // WOW LOOK its adaptable
            let type = "var/Library"
            let dLF = self.getDynLibs(type: type)
            let pLF = self.getPrefLoader(type: type)
            let pBF = self.getPrefBun(type: type)
            self.log(message: "[i] Found required files, moving files...")
            self.moveFiles(msDL: dLF, pLF: pLF, pBF: pBF)
            self.log(message: "Files Moved!")
            self.showInstallError(error: "Files MOVED!!!!")
// END OF WHAT I DID
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
