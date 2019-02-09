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
        if(!isJailbroken()) {
            let alert = UIAlertController(title: "Packager Error", message: "You are not jailbroken! or Packager is sandboxed, please unsandbox from iSuperSU.", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "Check Again", style: UIAlertAction.Style.default) {
                UIAlertAction in
                self.viewDidAppear(animated)
            }
            let cancelAction = UIAlertAction(title: "Close App", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                exit(0)
            }
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        } else {
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
                
                dylibFiles.removeFirst()
                
                self.files = dylibFiles
                
                print(files)
                
                self.tableView.reloadData()
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
            
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
        cell.textLabel?.text = files[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(files[indexPath.row])
    }
}
