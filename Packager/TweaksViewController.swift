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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func moveFiles(msDL: [URL?], pLF: [URL?], pBF: [URL?] ){
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
            self.showInstallError(error: "Could Not Move Dynamic Library Files")
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
        var PreferenceFiles = [URL(string: "")]
            do{
        let preferenceLoaderFiles = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/"+type+"/PreferenceLoader/Preferences/"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
        
        PreferenceFiles.removeFirst()
        
        for file in preferenceLoaderFiles {
                PreferenceFiles.append(file.absoluteURL)
        }
        
        for file in preferenceLoaderFiles {
            self.log(message: "[i] Found files in PreferenceLoader: \n [i] " + file.absoluteString)
        }
            }catch{
                self.log(message: "[i] No files in PreferanceFiles")
                return PreferenceFiles
        }
        return PreferenceFiles
    }
    func getPrefBun(type: String)->[URL?]{
        var PrefBundles = [URL(string: "")]
        do{
            let preferenceBundleFiles = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/"+type+"/PreferenceBundles/"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            PrefBundles.removeFirst()
        for file in preferenceBundleFiles {
            PrefBundles.append(file.absoluteURL)
        }
        }catch{
            self.log(message: "[i] No files in PreferanceBundles")
            return PrefBundles
        }
        return PrefBundles
    }
    func getDynLibs(type: String)->[URL?]{
        // A theft and adaptation to a seperate function, currently only gets one file and IDK why
        var DynamicLibs = [URL(string: "")]
        do{
        let mobileSubstrateDynamicLibs = try self.fm.contentsOfDirectory(at: URL(fileURLWithPath: "/var/containers/Bundle/tweaksupport/Library/packagertemp/"+type+"/MobileSubstrate/DynamicLibraries/"), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            DynamicLibs.removeFirst()
            
        for file in mobileSubstrateDynamicLibs {
            DynamicLibs.append(file.absoluteURL)
        }
        for file in DynamicLibs {
            self.log(message: "[i] Found files in Mobile Substrate: \n [i] " + (file?.absoluteString)!)
        }
            
        }catch{
            self.log(message: "[i] No files in DynamicLibs")
            self.showInstallError(error: "No Dynamic Libs Found!")
            return DynamicLibs
        }
        
        return DynamicLibs
    }
    func injectFiles(tweakDylib: URL, preferenceBundle: URL) {
        let installUtils = InstallUtils.init()
        self.log(message: "[i] Injecting TweakDylib...")
        installUtils.inject(path: tweakDylib.absoluteString)
        self.log(message: "[i] Injected TweakDylib!")
        self.log(message: "[i] Injecting PreferenceBundle...")
        installUtils.inject(path: preferenceBundle.absoluteString)
        self.log(message: "[i] Injected PreferenceBundle!")
        self.log(message: "[i] Giving permissions to PreferenceBundle!")
        installUtils.chmod(path: preferenceBundle.absoluteString)
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
        
            }
        } else {
            self.log(message: "[!] Tweak URL is Invalid!")
            self.showInstallError(error: "The URL you entered is invalid")
        }
    }
    func getMethod(url: URL){
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
    func installTweak(tweakname: String, method: String) {
        if(method == "libraryFirst") {
            let type = "Library"
            let dLF = self.getDynLibs(type: type)
            let pLF = self.getPrefLoader(type: type)
            let pBF = self.getPrefBun(type: type)
            self.log(message: "[i] Found required files, moving files...")
            self.moveFiles(msDL: dLF, pLF: pLF, pBF: pBF)
            self.log(message: "Files Moved!")
            self.injectFiles(tweakDylib: dLF[0]!, preferenceBundle: pBF[0]!)
        } else if(method == "tweakNameFirst") {
            let type = tweakname+"/Library"
            let dLF = self.getDynLibs(type: type)
            let pLF = self.getPrefLoader(type: type)
            let pBF = self.getPrefBun(type: type)
            self.log(message: "[i] Found required files, moving files...")
            self.moveFiles(msDL: dLF, pLF: pLF, pBF: pBF)
            self.log(message: "Files Moved!")
            self.injectFiles(tweakDylib: dLF[0]!, preferenceBundle: pBF[0]!)
        } else if(method == "varFirst") {
            let type = "var/Library"
            let dLF = self.getDynLibs(type: type)
            let pLF = self.getPrefLoader(type: type)
            let pBF = self.getPrefBun(type: type)
            self.log(message: "[i] Found required files, moving files...")
            self.moveFiles(msDL: dLF, pLF: pLF, pBF: pBF)
            self.log(message: "Files Moved!")
            self.injectFiles(tweakDylib: dLF[0]!, preferenceBundle: pBF[0]!)
        } else {
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
            InstallUtils.init().respring()
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

