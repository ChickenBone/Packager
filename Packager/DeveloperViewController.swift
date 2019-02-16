//
//  DeveloperViewController.swift
//  Packager
//
//  Created by Wyatt W on 2/15/19.
//  Copyright © 2019 Conor Byrne. All rights reserved.
//
import UIKit
import Foundation
import Alamofire

class DeveloperViewController: UITableViewController {
    @IBOutlet weak var textLabel: UILabel!
    var responseArray: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AF.request("https://dev.mintdev.co:8443/download/developers/developers.json").responseJSON { response in
            if let json = response.result.value {
                print(json)
                self.responseArray = json as! NSArray
            }
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let Developers = responseArray[(indexPath as NSIndexPath).row]
        let DevName = (Developers as AnyObject)["Name"] as? String
        cell.textLabel?.text = DevName
        return cell
}

}
