//
//  WelcomeScreen.swift
//  Packager
//
//  Created by Gijsbert te Paske on 11/02/2019.
//  Copyright © 2019 Conor Byrne. All rights reserved.
//

import UIKit

class WelcomeScreen: UIViewController {
    @IBOutlet weak var quitButton: ButtonRoundedCorners!
    @IBOutlet weak var refreshButton: ButtonRoundedCorners!
    @IBOutlet weak var proceedButton: ButtonRoundedCorners!
    @IBOutlet weak var sandboxStatus: UILabel!
    
    func isJailbroken() -> Bool {
        return FileManager.default.isWritableFile(atPath: "/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries")
    }
    
    @IBAction func quitButtonPress(_ sender: Any) {
        exit(0)
    }
    @IBAction func refreshButtonPress(_ sender: Any) {
        self.viewDidAppear(true)
        self.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isJailbroken() {
            quitButton.isHidden = true
            refreshButton.isHidden = true
            proceedButton.isHidden = false
            sandboxStatus.text = "You're unsandboxed! Hit proceed."
        } else {
            proceedButton.isHidden = true
            refreshButton.isHidden = false
            quitButton.isHidden = false
        }
    }
}
