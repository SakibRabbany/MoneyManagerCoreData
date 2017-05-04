//
//  BucketsViewController.swift
//  MoneyManagerCoreData
//
//  Created by Sakib Rabbany on 2017-04-10.
//  Copyright © 2017 Sakib Rabbany. All rights reserved.
//

import UIKit

class BucketsViewController: UITableViewController {
    
    
    var buckets:[Bucket] = [Bucket]()
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buckets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell = self.tableView.dequeueReusableCell(withIdentifier: "Category", for: indexPath) as UITableViewCell
        
        let ptage = buckets[indexPath.row].percentage
        
        let y = Double(round(100*ptage)/100)
        Cell.textLabel?.text = buckets[indexPath.row].category + " " + "(" + String(y) + "%" + ")"
        
        return Cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Categories"
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var indexPath : IndexPath = self.tableView.indexPathForSelectedRow!
        
        let destViewContrl = segue.destination as! EachBucketVIewCOntrollerTableViewController
        
        destViewContrl.entryArray = buckets[indexPath.row].entries
        destViewContrl.name = buckets[indexPath.row].category
        
        
    }

        
}
