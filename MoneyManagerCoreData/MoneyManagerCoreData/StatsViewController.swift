//
//  StatsViewController.swift
//  MoneyManagerCoreData
//
//  Created by Sakib Rabbany on 2017-04-10.
//  Copyright © 2017 Sakib Rabbany. All rights reserved.
//

import UIKit
import Charts

extension NSDate {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func isGreaterThanOrEqualTo(dateToCompare: NSDate) -> Bool {
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        return isGreater || isEqualTo
    }
    
    func isLessThanOrEqualTo(dateToCompare: NSDate) -> Bool {
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        return isEqualTo || isLess
    }
    
    func isInBetween(fromDate: NSDate, toDate: NSDate) -> Bool {
        return self.isGreaterThanOrEqualTo(dateToCompare: fromDate) && self.isLessThanOrEqualTo(dateToCompare: toDate)
    }
}





class StatsViewController: UIViewController, UITextFieldDelegate {
  
    var entries:[Entries] = [Entries]()
    var buckets:[Bucket] = [Bucket]()
    var values: [PieChartDataEntry] = [PieChartDataEntry]()
    var colors:[UIColor] = [UIColor]()
    var total:Double = 0

    

    @IBOutlet weak var pieView: PieChartView!
    
    
    @IBOutlet weak var fromDate: UITextField!
    @IBOutlet weak var toDate: UITextField!
    
    
    
    @IBOutlet weak var amountSpent: UILabel!
    @IBOutlet weak var amountPerDay: UILabel!
    @IBOutlet weak var favCat: UILabel!
    
    
    let fromDatePicker = UIDatePicker()
    let toDatePicker = UIDatePicker()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setPieChart(buckets: buckets)
        printBuckets()
        setupFromPicker()
        
        setupToPicker()
        
        
        for bucket in buckets {
            total += bucket.subTotal
        }
        
        let numDays:Int = diffetenceBetweenDates(firstDate: fromDatePicker.date, secondDate: toDatePicker.date)
        
        getStats(buckets: buckets, days: numDays)
            
        printEntries()
        print("Bucke")
        printBuckets()
        print(fromDatePicker.date)
        print(toDatePicker.date)
        
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    func getStats(buckets: [Bucket], days: Int) {
        var total:Double = 0
        
        for index in 0..<buckets.count {
            total += buckets[index].subTotal
        }
        
        var popCat:String = buckets[0].category
        var count:Int = buckets[0].entries.count
        
        for index in 1..<buckets.count {
            if buckets[index].entries.count > count {
                popCat = buckets[index].category
                count = buckets[index].entries.count
            }
        }
        
        let average:Double = total/Double(days)
        
        
        let y = Double(round(100*average)/100)
        
        
        amountSpent.text = String(total)
        amountPerDay.text = String(y)
        if total == 0 {
            favCat.text = "None"
        } else {
            favCat.text = popCat
        }
        
        
    }
    
    
    func setupToPicker() {
        toDatePicker.datePickerMode = UIDatePickerMode.date
        toDatePicker.maximumDate = entries.last?.timeStamp as Date?
        
        toDate.inputView = toDatePicker
        toDate.delegate = self
        toDatePicker.addTarget(self, action: #selector(toPickerChanged(sender:)), for: .valueChanged)
        toDatePicker.setDate((entries.last?.timeStamp)! as Date, animated: false)
        print("setup: \(toDatePicker.date)")
        toPickerChanged(sender: toDatePicker)

    }
    
    
    func setupFromPicker() {
        fromDatePicker.datePickerMode = UIDatePickerMode.date
        fromDatePicker.minimumDate = entries.first?.timeStamp as Date?
        
        fromDate.inputView = fromDatePicker
        fromDate.delegate = self
        fromDatePicker.addTarget(self, action: #selector(fromPickerChanged(sender:)), for: .valueChanged)
        fromDatePicker.setDate((entries.first?.timeStamp)! as Date, animated: false)
        fromPickerChanged(sender: fromDatePicker)
    }
    
    
    func toPickerChanged(sender: UIDatePicker) {
        print("topickerchangedrunnign")
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        toDate.text = formatter.string(from: sender.date)
        fromDatePicker.maximumDate = sender.date
        
        if ((fromDate.text?.isEmpty)! || (toDate.text?.isEmpty)!) {
            return
        } else {
            var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
            let calendar = NSCalendar.current
            
            var toPickerDate:Date = toDatePicker.date
            toPickerDate = calendar.startOfDay(for: toPickerDate)
            print("toPicker: \(toPickerDate)")
            
            var component1 = DateComponents()
            
            component1.hour = 23
            component1.minute = 59
            component1.second = 59
            
            var component2 = DateComponents()
            component2.second = secondsFromGMT
            
            
            
            toPickerDate = calendar.date(byAdding: component1, to: toPickerDate)!
            toPickerDate = calendar.date(byAdding: component2, to: toPickerDate)!
            print("frompicker: \(toPickerDate)")
            
            var fromPickerDate:Date = fromDatePicker.date
            fromPickerDate = calendar.startOfDay(for: fromPickerDate)
            fromPickerDate = calendar.date(byAdding: component2, to: fromPickerDate)!
            
            
            print("fromPicker: \(fromPickerDate)")
            print("toPicker: \(toPickerDate)")
            getNewChart(fromDate: fromPickerDate as NSDate, toDate: toPickerDate as NSDate)
            
        }
    }
    
    
    
    
    
    func fromPickerChanged(sender: UIDatePicker) {
        print("frompcikerchangedrunning")
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        fromDate.text = formatter.string(from: sender.date)
        toDatePicker.minimumDate = sender.date
        
        if ((fromDate.text?.isEmpty)! || (toDate.text?.isEmpty)!) {
            return
        } else {
            var secondsFromGMT: Int { return TimeZone.current.secondsFromGMT() }
            let calendar = NSCalendar.current
            
            var toPickerDate:Date = toDatePicker.date
            toPickerDate = calendar.startOfDay(for: toPickerDate)
            print("toPicker: \(toPickerDate)")
            
            var component1 = DateComponents()
            
            component1.hour = 23
            component1.minute = 59
            component1.second = 59
            
            var component2 = DateComponents()
            component2.second = secondsFromGMT
            
            
            toPickerDate = calendar.date(byAdding: component1, to: toPickerDate)!
            toPickerDate = calendar.date(byAdding: component2, to: toPickerDate)!
            
            var fromPickerDate:Date = fromDatePicker.date
            fromPickerDate = calendar.startOfDay(for: fromPickerDate)
            fromPickerDate = calendar.date(byAdding: component2, to: fromPickerDate)!

            
            

            
            print("fromPicker: \(fromPickerDate)")
            print("toPicker: \(toPickerDate)")
            getNewChart(fromDate: fromPickerDate as NSDate, toDate: toPickerDate as NSDate)
            
            print(diffetenceBetweenDates(firstDate: fromPickerDate, secondDate: toPickerDate))
            
        }

    }
    
    
    
    
    
    func diffetenceBetweenDates(firstDate: Date, secondDate: Date) -> Int {
        let calendar = NSCalendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: firstDate)
        let date2 = calendar.startOfDay(for: secondDate)
        
        
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day! + 1
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func printEntries() {
        for entry in entries {
            print(entry.category!)
            print(entry.amount)
            print(entry.timeStamp!)
        }
    }
    
    
    func printBuckets() {
        for bucket in buckets {
            print(bucket.category)
            for entry in bucket.entries {
                print(entry.amount)
            }
        }
    }
    
    
    
    func getNewChart(fromDate: NSDate, toDate: NSDate) {
        makeNewBucket(fromDate: fromDate, toDate: toDate)
        values.removeAll()
        colors.removeAll()
        setPieChart(buckets: buckets)
        let numDays:Int = diffetenceBetweenDates(firstDate: fromDatePicker.date, secondDate: toDatePicker.date)
        
        getStats(buckets: buckets, days: numDays)
        
        print(numDays)
    }
    
    
    
    
    
    
    func makeNewBucket(fromDate: NSDate, toDate: NSDate) {
        total = 0
        for index in 0..<buckets.count {
            buckets[index].entries.removeAll()
            buckets[index].percentage = 0
            buckets[index].subTotal = 0
        }
        
        
        for index in 0..<entries.count {
            if (entries[index].timeStamp?.isInBetween(fromDate: fromDate, toDate:  toDate))! {
                insertIntoBucket(entry: entries[index])
            }
        }
        printBuckets()
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

    
    
    
    
    func setPieChart(buckets: [Bucket]) {
        
        for index in 0..<buckets.count {
            let pct = buckets[index].percentage
            if (pct == 0) {
                continue
                
            }
            let cat = buckets[index].category
            let pieData = PieChartDataEntry(value: Double(pct), label: cat)
            values.append(pieData)
            
            let randColour = getRandomColor()
            colors.append(randColour)
        }
        
        let dataSet: PieChartDataSet = PieChartDataSet(values: values, label: "buckets")
        
        dataSet.drawIconsEnabled = false;
        dataSet.sliceSpace = 2;
        dataSet.iconsOffset = CGPoint(x: 0, y: 40)
        dataSet.colors = colors
        
        
        let data = PieChartData(dataSet: dataSet)
        
        pieView.data = data 
        
        
    }
    
    
    
    
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)      // first responder
    }
    
    
}


