//
//  HomeViewController.swift
//  Packager
//
//  Created by Conor Byrne on 09/02/2019.
//  Copyright © 2019 Conor Byrne. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    
    func isJailbroken() -> Bool {
        return FileManager.default.isWritableFile(atPath: "/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!isJailbroken()) {
            let alert = UIAlertController(title: "Packager Error", message: "You're not Jailbroken / The app is running in Sandbox Mode!", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "Check Again", style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.viewDidAppear(animated)
            }
            let cancelAction = UIAlertAction(title: "Close App", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                exit(0)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            super.viewDidAppear(animated)
        }
    }
}
