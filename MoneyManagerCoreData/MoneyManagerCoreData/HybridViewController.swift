//
//  HybridViewController.swift
//  MoneyManagerCoreData
//
//  Created by Sakib Rabbany on 2017-04-16.
//  Copyright © 2017 Sakib Rabbany. All rights reserved.
//

import UIKit

class HybridViewController: UIViewController, UITableViewDataSource {
    
//    var buckets:[Bucket] = [Bucket]()
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return buckets.count
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return buckets[section].entries.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
//        cell.textLabel?.text = String(buckets[indexPath.section].entries[indexPath.row])
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return buckets[section].category + "  " + "\(buckets[section].subTotal)" + "  " + "(\(buckets[section].percentage)%)"
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Do any additional setup after loading the view.
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)      // first responder
//    }

    
    var buckets:[Bucket] = [Bucket]()
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buckets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = buckets[indexPath.row].category
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)      // first responder
    }

    
    
    
    
    
}
