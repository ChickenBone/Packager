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
        proceedButton.alpha = 0.0
        ButtonRoundedCorners.animate(withDuration: 1.5, delay: 0.2, options: .curveEaseOut, animations: {
            self.proceedButton.alpha = 1.0
        })
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
            sandboxStatus.textColor = .white
            sandboxStatus.alpha = 1
        } else {
            proceedButton.isHidden = true
            refreshButton.isHidden = false
            quitButton.isHidden = false
            sandboxStatus.textColor = .red
            sandboxStatus.alpha = 1
        }
    }
}
