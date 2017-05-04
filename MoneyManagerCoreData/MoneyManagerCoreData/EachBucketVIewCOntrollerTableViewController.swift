//
//  EachBucketVIewCOntrollerTableViewController.swift
//  MoneyManagerCoreData
//
//  Created by Sakib Rabbany on 2017-04-15.
//  Copyright © 2017 Sakib Rabbany. All rights reserved.
//

import UIKit

class EachBucketVIewCOntrollerTableViewController: UITableViewController {

    var name:String = ""
    var entryArray = [Entries]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell = self.tableView.dequeueReusableCell(withIdentifier: "Entry", for: indexPath) as UITableViewCell
        
        let date:NSDate = entryArray[indexPath.row].timeStamp!
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let timeStampString:String = formatter.string(from: date as Date)
        
        
        Cell.textLabel?.text = String(entryArray[indexPath.row].amount) + "           " + timeStampString
        
        return Cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entryArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return name
    }
    
    
}
