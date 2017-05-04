//
//  ViewController.swift
//  MoneyManagerCoreData
//
//  Created by Sakib Rabbany on 2017-03-31.
//  Copyright © 2017 Sakib Rabbany. All rights reserved.
//

import UIKit
import CoreData
import Foundation



class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var selectedCategory: UITextField!
    @IBOutlet weak var amountEntered: UITextField!
    
    
    

    
    var entries: [Entries] = []
    var categories: [Categories] = []
    var buckets: [Bucket] = []
    var total: Double = 0
    
    var picker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getEntriesFromCore()
        getCategoriesFromCore()
        initBuckets()
        //calculatePercentage()
        
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
       
        
        
        
        let toolBar = initToolbar()
        
        
        selectedCategory.inputAccessoryView = toolBar
        selectedCategory.inputView = picker
        
        print("view did load")
    }
    
    func initToolbar() -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.cancelPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let addNewButton = UIBarButtonItem(title: "Add New", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.addNewPicker))
        let deleteButton = UIBarButtonItem(title: "Delete", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ViewController.deletePicker))
        
        toolBar.setItems([deleteButton, spaceButton, addNewButton, spaceButton, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }
    
    func deletePicker() {
        if (selectedCategory.text?.isEmpty)! {
            displayError(message: "Please select a category")
            return
        }
        
        let deleteAlert = UIAlertController(title: "Warning!", message: "Deleting the category will remove all its associated expenses!!", preferredStyle: UIAlertControllerStyle.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let category = self.selectedCategory.text!
            print(category)
            print(self.buckets.count)
            
            self.removeCategoryFromCore(category: category)
            print(self.buckets.count)
            
            self.removeCategoryEntryFromCore(category: category)
            print(self.buckets.count)
            
            self.removeCategoryFromBucket(category: category)
            print(self.buckets.count)
            if (self.total != 0) {
                self.calculatePercentage()
            }
            self.selectedCategory.text = ""
            self.picker.reloadAllComponents()
            self.picker.selectRow(0, inComponent: 0, animated: true)
            self.pickerView(self.picker, didSelectRow: 0, inComponent: 0)
            self.displaySuccess(message: "The category has been removed!!")
            
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        present(deleteAlert, animated: true, completion: nil)
        

    }
    
    func addNewPicker() {
        
        let addCategoryAlert = UIAlertController(title: "Add Category!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        addCategoryAlert.addTextField { (textField: UITextField) -> Void in
            textField.placeholder = "Enter Category"
        }
        
        
        addCategoryAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let newCategory = addCategoryAlert.textFields?[0]
            if (newCategory?.text?.isEmpty)! {
                self.displayError(message: "Please enter a category")
                return
            }
            
            let catStr = newCategory?.text!
            let trimmedCatStr = catStr?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            

            if (self.addNewCategory(category: trimmedCatStr!)) {
                self.displaySuccess(message: "The new category has been added!!")

            }

            
        }))
        
        addCategoryAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        present(addCategoryAlert, animated: true, completion: nil)
        
        }
    
    func cancelPicker() {
        selectedCategory.text = ""
        selectedCategory.resignFirstResponder()
        picker.selectRow(0, inComponent: 0, animated: false)
    }
    
    func displayError(message: String) {
        // create the alert
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func displaySuccess(message: String) {
        // create the alert
        let alert = UIAlertController(title: "Great!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    func initBuckets() {
        for category in categories {
            let bucket = Bucket(category: category.name!, entries: [Entries](), percentage: 0, subTotal: 0)
            buckets.append(bucket)
        }
        
        for index in 0..<entries.count {
            insertIntoBucket(entry: entries[index])
        }
    }
    
    
    func insertIntoBucket(entry: Entries) {
        total += entry.amount
        for index in 0..<buckets.count {
            if (buckets[index].category == entry.category) {
                  //buckets[index].insert(amount: amount, total: total)
                buckets[index].entries.insert(entry, at: 0)
                buckets[index].subTotal += entry.amount
                buckets[index].percentage = (buckets[index].subTotal / total) * 100
            } else {
                buckets[index].percentage = (buckets[index].subTotal / total) * 100
            }
        }
    }
    
    
    
    func sortEntries() {
        entries.sort{
             $0.timeStamp!.compare($1.timeStamp! as Date) == ComparisonResult.orderedAscending
        }
    }
    
    
    func getEntriesFromCore() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<Entries>(entityName: "Entries")
        
        //3
        do {
            entries = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        sortEntries()
    }

    func getCategoriesFromCore() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<Categories>(entityName: "Categories")
        
        //3
        do {
            categories = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    func deleteAllCategories() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Categories")
        
        //3
        do {
            let result:[NSManagedObject] = try context.fetch(fetchRequest)
            print(result.count)
            for entry in result {
                context.delete(entry)
            }
            try context.save()
            print(result.count)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

    }
    
    
    func initCategory() {
        deleteAllCategories()
        let cats: [String] = [
            "Food",
            "Entertainment",
            "Grocery",
            "Clothing",
            "Bills",
            "Miscellaneous"
        ]
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Categories", in: context)!
        
        
        for category in cats {
            let newCat = Categories(entity: entity, insertInto: context)
            
            newCat.name = category
            
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    
    
    @IBAction func printEntry(_ sender: UIButton) {
        print(entries)
    }
    
    func addNewCategory(category: String) -> Bool {
        for items in categories {
            if (items.name == category) {
                //print("category already exists")
                displayError(message: "The category already exists!")
                return false
            }
        }
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Categories", in: context)!
        let newCat = Categories(entity: entity, insertInto: context)
        
        newCat.name = category
        
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        categories.append(newCat)
        
        let newBucket = Bucket(category: category, entries: [Entries]() , percentage: 0, subTotal: 0)
        buckets.append(newBucket)
        picker.reloadAllComponents()
        return true
    }
    
    
    @IBAction func storeCategory(_ sender: UIButton) {
        if (selectedCategory.text?.isEmpty)! {
            //print("error")
            displayError(message: "Please add a category.")
            return
        }
        let catStr = selectedCategory.text!
        let trimmedCatStr = catStr.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        for items in categories {
            if (items.name == trimmedCatStr) {
                //print("category already exists")
                displayError(message: "The category already exists!")
                return
            }
        }
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Categories", in: context)!
        let newCat = Categories(entity: entity, insertInto: context)
        
        newCat.name = trimmedCatStr
        
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        categories.append(newCat)
        
        let newBucket = Bucket(category: trimmedCatStr, entries: [Entries]() , percentage: 0, subTotal: 0)
        buckets.append(newBucket)
        picker.reloadAllComponents()
    }

    
    
    @IBAction func showCategory(_ sender: UIButton) {
        print(categories.count)
        for items in categories {
            print(items.name!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)      // first responder
    }
    
    
    @IBAction func storeData(_ sender: UIButton) {
        var amount:Double
        
        if (amountEntered.text?.isEmpty)! || (selectedCategory.text?.isEmpty)! {
            //print("error")
            displayError(message: "Please select a category and enter a number.")
            return
        }
        if let amt = Double(amountEntered.text!) {
            amount = amt
        } else {
            //print ("error")
            displayError(message: "Please enter a number.")
            return
        }
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Entries", in: context)!
        let newEntry = Entries(entity: entity, insertInto: context)
        let cat:String = selectedCategory.text!
        
        var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }

        
        let calendar = NSCalendar.current
        var component = DateComponents()
        component.second = secondsFromGMT
        
        var currentDate:Date = Date()
        

        currentDate = calendar.date(byAdding: component, to: currentDate)!
        
        print(currentDate)
        
        
        newEntry.amount = amount
        newEntry.category = cat
        newEntry.timeStamp = currentDate as NSDate
        
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        /////////
        
        entries.append(newEntry)
        
        insertIntoBucket(entry: newEntry)
        //selectedCategory.text = ""
        amountEntered.text = ""
        amountEntered.endEditing(true)
        displaySuccess(message: "The expense is recoreded!!")
    }

    
    func removeAllEntries() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entries")
        
        //3
        do {
            let results:[NSManagedObject] = try context.fetch(fetchRequest)
            print(results.count)
            for result in results {
                context.delete(result)
            }
            try context.save()
            print(results.count)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    @IBAction func factoryReset(_ sender: UIButton) {
        
        let factoryAlert = UIAlertController(title: "Warning!", message: "All data will be lost!!", preferredStyle: UIAlertControllerStyle.alert)
        
        factoryAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.initCategory()
            self.removeAllEntries()
            self.categories.removeAll()
            self.entries.removeAll()
            self.buckets.removeAll()
            self.getCategoriesFromCore()
            self.initBuckets()
            self.total = 0
        }))
        
        factoryAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        present(factoryAlert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func printBuckets(_ sender: UIButton) {
//        print("The total is: \(total)")
//        for bucket in buckets {
//            print(bucket.category)
//            print(bucket.subTotal)
//            print(bucket.percentage)
//            print(bucket.entries)
//        }
    }
    
    func removeCategoryFromCore(category: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<Categories>(entityName: "Categories")
        
        //3
        do {
            let result:[Categories] = try context.fetch(fetchRequest)
            print(result.count)
            for entry in result {
                if (entry.name! == category) {
                    context.delete(entry)
                }
            }
            try context.save()
            print(result.count)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func removeCategoryEntryFromCore(category: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<Entries>(entityName: "Entries")
        
        //3
        do {
            let result:[Entries] = try context.fetch(fetchRequest)
            print(result.count)
            for entry in result {
                if (entry.category! == category) {
                    context.delete(entry)
                }
            }
            try context.save()
            print(result.count)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func removeCategoryFromBucket(category: String) {
        for index in 0..<buckets.count {
            if (buckets[index].category == category){
                total -= buckets[index].subTotal
                buckets.remove(at: index)
                categories.remove(at: index)
                return
            }
        }
    }
    
    func calculatePercentage() {
        for index in 0..<buckets.count {
            buckets[index].percentage = (buckets[index].subTotal / total) * 100
        }
    }
    
    @IBAction func deleteSingleCategory(_ sender: UIButton) {
        if (selectedCategory.text?.isEmpty)! {
            displayError(message: "Please select a category")
            return
        }
        
        let deleteAlert = UIAlertController(title: "Warning!", message: "Deleting the category will remove all its associated expenses!!", preferredStyle: UIAlertControllerStyle.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            let category = self.selectedCategory.text!
            print(category)
            print(self.buckets.count)
            
            self.removeCategoryFromCore(category: category)
            print(self.buckets.count)

            self.removeCategoryEntryFromCore(category: category)
            print(self.buckets.count)

            self.removeCategoryFromBucket(category: category)
            print(self.buckets.count)

            self.calculatePercentage()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            return
        }))
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name!
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //picked = row
        if(categories.count > 0) {
            selectedCategory.text = categories[row].name!
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "") {
            let destViewContrl = segue.destination as! BucketsViewController
            
            destViewContrl.buckets = buckets
        } else if (segue.identifier == "toStats") {
            let destViewContrl = segue.destination as! StatsViewController
            
            destViewContrl.entries = entries
            destViewContrl.buckets = buckets
        } 
        
    }
    
    

    
    
}

