//
//  SettingsViewController.swift
//  Packager
//
//  Created by Conor Byrne on 15/02/2019.
//  Copyright © 2019 Conor Byrne. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    private let fm = FileManager.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func respringPressed(_ sender: Any) {
        InstallUtils.init().respring()
    }
    
    @IBAction func injectAllDylibs(_ sender: Any) {
        InstallUtils.init().run(command: "inject", arguments: ["/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries/*.dylib"])
        InstallUtils.init().run(command: "inject", arguments: ["/var/containers/Bundle/tweaksupport/Library/PreferenceBundles/*.bundle"])
        showActionCompleted()
    }
    
    func showActionError() {
        let alert2 = UIAlertController(title: "Packager Error", message: "There was an issue performing your action.", preferredStyle: UIAlertController.Style.alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            alert2.dismiss(animated: true, completion: nil)
        }
        
        alert2.addAction(action)
        
        self.present(alert2, animated: true, completion: nil)
    }
    
    func showActionCompleted() {
        let alert2 = UIAlertController(title: "Packager", message: "Action completed! Respring to complete changes.", preferredStyle: UIAlertController.Style.alert)
        
        let action = UIAlertAction(title: "Respring", style: UIAlertAction.Style.default) {
            UIAlertAction in
            InstallUtils.init().respring()
        }
        
        let action2 = UIAlertAction(title: "Don't Respring Yet", style: UIAlertAction.Style.default) {
            UIAlertAction in
            alert2.dismiss(animated: true, completion: nil)
        }
        
        alert2.addAction(action)
        alert2.addAction(action2)
        
        self.present(alert2, animated: true, completion: nil)
    }
}
