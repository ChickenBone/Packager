//
//  HomeViewController.swift
//  Packager
//
//  Created by Conor Byrne on 09/02/2019.
//  Copyright © 2019 Conor Byrne. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    
    var files = [""]
    
    func isJailbroken() -> Bool {
        return FileManager.default.isWritableFile(atPath: "/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Create a FileManager instance
        let fileManager = FileManager.default
            
        // Get contents in the tweak directory
        do {
            let collectedFiles = try fileManager.contentsOfDirectory(atPath: "/var/containers/Bundle/tweaksupport/Library/MobileSubstrate/DynamicLibraries")
                
            var dylibFiles = [""]

            for file in collectedFiles {
                if file.hasSuffix(".dylib") {
                    dylibFiles.append(String(file.dropLast(6)))
                }
            }
            
            // Remove the first entry because it is always ""
            dylibFiles.removeFirst()
                
            self.files = dylibFiles
            
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1.0)
        cell.textLabel?.textColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        cell.textLabel?.text = files[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(files[indexPath.row])
    }
}
