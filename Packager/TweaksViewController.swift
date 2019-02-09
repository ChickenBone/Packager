//
//  TweaksViewController.swift
//  Packager
//
//  Created by Conor Byrne on 09/02/2019.
//  Copyright © 2019 Conor Byrne. All rights reserved.
//

import UIKit

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
    
    @IBAction func startDownload(_ sender: Any) {
        let fm = FileManager.default
        let url = textField.text ?? ""
        let downloadPath = "/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries/packagertemp"
    
        if(url != "") {
            Downloader.load(url: URL(string: url)!, to: URL(string: downloadPath)!) {
                print("File downloaded!")
            }
        }
    }
}

