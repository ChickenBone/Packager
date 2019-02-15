//
//  InstallUtils.swift
//  Packager
//
//  Created by Conor Byrne on 15/02/2019.
//  Copyright © 2019 Conor Byrne. All rights reserved.
//

import Foundation

class InstallUtils {
    
    //Respring the device
    public func respring() {
        let task = NSTask()
        task!.setLaunchPath("/var/containers/Bundle/iosbinpack64/usr/bin/killall")
        task!.setArguments(["-9", "SpringBoard"])
        task!.launch()
    }
    
    //Inject a tweak dylib
    public func inject(path: String) {
        let task = NSTask()
        task!.setLaunchPath("/var/containers/Bundle/iosbinpack64/usr/bin/inject")
        task!.setArguments([path])
        task!.launch()
    }
    
    //chmod 777 a file
    public func chmod(path: String) {
        let task = NSTask()
        task!.setLaunchPath("/var/containers/Bundle/iosbinpack64/usr/bin/chmod")
        task!.setArguments([path])
        task!.launch()
    }
    
    //Run a command
    public func run(command: String, arguments: [String]) {
        let task = NSTask()
        task!.setLaunchPath("/var/containers/Bundle/iosbinpack64/usr/bin/" + command)
        task!.setArguments(arguments)
        task!.launch()
    }
}
