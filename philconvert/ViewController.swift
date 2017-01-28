//
//  ViewController.swift
//  philconvert
//
//  Created by 横島健一 on 2016/10/02.
//  Copyright © 2016年 info.tmpla. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var textAmount: UITextField!
    @IBOutlet weak var textAmountOther: UITextField!
    
    @IBOutlet weak var lblRateOther: UILabel!
    @IBOutlet weak var lblRatePhil: UILabel!
    @IBOutlet weak var indRatePhil: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var indRateOther: UIActivityIndicatorView!
    @IBOutlet weak var btnUpdateRate: UIButton!
    @IBOutlet weak var lblUpdateRateLabel: UILabel!
    
    private let countries:NSArray = ["jp", "us"]
    private let collectionContries: [UIImage] = [
        #imageLiteral(resourceName: "bg-japan"),#imageLiteral(resourceName: "bg-us"),#imageLiteral(resourceName: "Australia")]
    
//    private var amount:Decimal
//    private var amountOther:Decimal

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        let amountPanGesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePhilAmount(reconizer:)))
        textAmount.addGestureRecognizer(amountPanGesture)
        let amountOtherPanGesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleOtherAmount(reconizer:)))
        textAmountOther.addGestureRecognizer(amountOtherPanGesture)
        let viewTapGescure:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapScreen(reconizer:)))
        self.view.addGestureRecognizer(viewTapGescure)
   
        updateRate()
        updateAmount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func amountDidChange(_ sender: AnyObject) {
        var amount:Double
        let text:UITextField = sender as! UITextField
        if (text.text?.isEmpty)! {
            amount = 0
        } else {
            amount = Double(textAmount.text!)!
        }
        text.text = String(amount)
        print(amount)
    }
    @IBAction func otherAmountDidChange(_ sender: AnyObject) {
        var amount:Double
        let text:UITextField = sender as! UITextField
        if (text.text?.isEmpty)! {
            amount = 0
        } else {
            amount = Double(textAmount.text!)!
        }
        text.text = String(amount)
        print(amount)
    }
    
    @IBAction func textFieldDidChange(_ sender: AnyObject) {
        updateAmount()
    }
    
    func updateAmount() {
        var amount:Double
        if (textAmount.text?.isEmpty)! {
            amount = 0
        } else {
            amount = Double(textAmount.text!)!
        }
        let latestRate:Double = 1 / loadLatestRate("JPY")
        let otherAmount:Double = round(latestRate * amount)
        
        textAmountOther.text = String(describing: otherAmount)
    }


    
    func roundDouble(value: Double) -> Double {
        return Double(round(value*1000)/1000)
    }
    @IBAction func doUpdateRate(_ sender: AnyObject) {
        
        updateRate()
//        let rateJPY:Double = self.loadLatestRate("JPY");
//        let rateJPYFromPhil:Double = self.roundDouble(value: 1 / rateJPY)
//        self.rateFromOther.text = "¥1 = ₱\(rateJPY)"
//        self.rateFromPhil.text = "¥1 = ₱\(rateJPYFromPhil)"
//        self.lblUpdateRateLabel.text = self.loadRateUpdated()
    }

    func loadPhilRate(countoryCode: String) -> Double{
        return 1 / loadLatestRate(countoryCode)
    }
    func updateRate() {
        self.toggleIndicator()
        Alamofire.request("https://api.fixer.io/latest?base=PHP&symbols=JPY,USD").responseJSON { (response) in
            guard let object = response.result.value else {
                return
            }
            
            switch response.result {
            
            case .success:
                let json = JSON(object)
                print(json["base"])
                print(json["date"])
                self.saveRateUpdated(date: json["date"].stringValue)
                let rates = json["rates"]
                let rateJPY:Double = self.roundDouble(value: rates["JPY"].doubleValue)
                
                self.saveLatestRate(country: "JPY", rate: rateJPY)

                break
            case .failure(let error):
                print(error)
                break
                
            }
            
            let rateJPY:Double = self.loadLatestRate("JPY")
            let ratePhil:Double = self.roundDouble(value: 1 / rateJPY)
            self.lblRateOther.text = "¥1 = ₱\(ratePhil)"
            self.lblRatePhil.text = "₱1 = ¥\(rateJPY)"
            self.lblUpdateRateLabel.text = "Last update: \(self.loadRateUpdated())"
//            self.indicator?.stopAnimating()
            self.toggleIndicator()
        }
    }
    
    func tapScreen(reconizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    func toggleIndicator() {
        if self.indRatePhil.isAnimating {
            self.indRatePhil.stopAnimating()
            self.indRateOther.stopAnimating()
        } else {
            self.indRatePhil.startAnimating()
            self.indRateOther.startAnimating()
        }
    }
    let KEY_LATEST_RATE_JPY = "latest_rate_jpy"
    let KEY_RATE_UPDATED = "rate_updated"
    
    func getUserDefault() -> UserDefaults {
        let def = UserDefaults.init()
        var initValues: [String:Any] = Dictionary();
        
        let today:Date = NSDate() as Date
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD"
        initValues[KEY_RATE_UPDATED] = formatter.string(from: today)
        initValues[KEY_LATEST_RATE_JPY] = 0.4500
        
        def.register(defaults: initValues)
        
        return def
    }
    func loadLatestRate(_ country:String) -> Double{
        let def:UserDefaults = UserDefaults.init()
        return def.double(forKey: KEY_LATEST_RATE_JPY)
    }
    
    func loadRateUpdated() -> String {
        return UserDefaults.init().string(forKey: "\(KEY_RATE_UPDATED)")!
    }
    
    func saveRateUpdated(date:String) {
        UserDefaults.init().set(date, forKey: "\(KEY_RATE_UPDATED)")
    }
    func saveLatestRate(country:String, rate:Double) {
        let d = UserDefaults.init()
        
        d.set(rate, forKey: KEY_LATEST_RATE_JPY)
    }
    
    func respondToPanGesture (gesture: UIPanGestureRecognizer) {
        let point = gesture.translation(in: self.view)
        
        print(point)
    }

    // MARK: pan gesture reconizer
    func handlePhilAmount (reconizer: UIPanGestureRecognizer) {
        changeAmount(textField: textAmount, reconizer: reconizer)
        let otherAmount:Double = loadPhilRate(countoryCode: "JPY") * atof(textAmount.text!)
        textAmountOther.text = Int(round(otherAmount)).description
    }
    

    func handleOtherAmount (reconizer: UIPanGestureRecognizer) {
        changeAmount(textField: textAmountOther, reconizer: reconizer)
        let philAmount:Double = loadLatestRate("JPY") * atof(textAmountOther.text)
        textAmount.text = Int(round(philAmount)).description
    }
    
    var change = 1
    var totalChange = 0
    var directionIncrement = true
    func initializeAmountChange() {
        change = 1
        totalChange = 0
    }
    func changeAmount(textField: UITextField, reconizer : UIPanGestureRecognizer) {
        let point = reconizer.translation(in: self.view)
//        let velocity = reconizer.velocity(in: self.view)
        switch reconizer.state {
            case .changed:
                if (directionIncrement && point.y > 0 ||
                    !directionIncrement && point.y < 0) {
                    initializeAmountChange()
                    directionIncrement = !directionIncrement
                }
                var amount: Int = 0
                if let val = Int(textField.text!) {
                    amount = val
                }
//                
//                if (amount % 10000 == 0) {
//                    change = 10000
//                } else if (amount % 1000 == 0) {
//                    change = 1000
//                } else if (amount % 100 == 0){
//                    change = 100
//                } else if (amount % 10 == 0){
//                    change = 10
//                }
                change = calcChangeValue(change: abs(Int(round(point.x))))

//                    if (totalChange > 10000) {
//                        change = 10000
//                    } else if (totalChange > 1000) {
//                        change = 1000
//                    } else if (totalChange > 100) {
//                        change = 100
//                    } else if (totalChange > 10) {
//                        change = 10
//                    }

                
                
//                if (totalChange > 10000) {
//                    change = 10000
//                } else if (totalChange > 1000) {
//                    change = 1000
//                } else if (totalChange > 100) {
//                    change = 100
//                } else if (totalChange > 10) {
//                    change = 10
//                }
                if directionIncrement {
                    amount = amount + change
                    totalChange = totalChange + change
                } else {
                    amount = amount - change
                    totalChange = totalChange - change
                }
                
                if (amount < 0) {
                    amount = 0
                }
                
                print(amount)
//                let digit : Int = calcDigit(number: amount) + 1


//                print(digit)
//                if (velocity.x < -20) {
                    textField.text = amount.description
//                }
        case .ended:
            initializeAmountChange()
        default:
            print(point)
//            print(velocity)
            
        }
        print(point)

    }
    
    
    func calcDigit(number: Int) -> Int {
        if Double(number).isNaN {
         return 0   
        }
        let d = Double(number)
        let l = log10(d)
        let f = floor(l)
        let val = Int(f)
        var digit : Int = 0
        if (val != nil) {
            digit = val
        }
        return digit
    }
    func calcChangeValue(change: Int) -> Int{
        let totals = abs(totalChange)
        if (totals > 10000) {
            return 1000
        } else if (totals > 1000) {
            return 1000
        } else if (totals > 100) {
            return 100
        } else if (totals > 10) {
            return 10
        } else {
            return change
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        let image:UIImageView = cell.image
        image.image = collectionContries[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    // MARK: - 
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize:CGFloat = self.view.frame.size.width
        return  CGSize(width: cellSize, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string)
        return true
    }
}


