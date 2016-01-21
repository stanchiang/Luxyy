//
//  uploadFilesViewController.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/20/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Parse

class uploadFilesViewController: UIViewController {

    var itemDataSource : NSArray!
    var itemArray: [String] = []
    var dic: NSArray!
    var broken: NSArray!
    var moneyDouble: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = NSBundle.mainBundle().pathForResource("fullList", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                
                do {
                    let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    itemDataSource = jsonResult["item"] as! NSArray
                    
                    for dic in itemDataSource {
//                        print("=====================")
                        
                        guard
                            let name = dic["name"] as? String,
                            let image = dic["image"] as? String,
                            let refNum = dic["Reference number"] as? String,
                            let movement = dic["Movement"] as? String,
                            let functions = dic["Functions"] as? String,
                            let itemCase = dic["Case"] as? String,
                            let band = dic["Band"] as? String,
                            let price = dic["Price"] as? String,
                            let variations = dic["Variations"] as? String,
                            let brand = dic["brand"] as? String
                            
                            else {
                                print("incomplete object for \(dic["image"]!), skipping for now")
                                continue
                        }
                        
                        let item = PFObject(className: "Item")
                        item.setObject(price, forKey: "price")
                        
                        for (k, v) in dic as! Dictionary<String, AnyObject> {
                            if k == "Price" {
                                let formatter = NSNumberFormatter()
                                formatter.locale = NSLocale(localeIdentifier: "en_US")
                                formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
                                
                                moneyDouble = formatter.numberFromString(v as! String)?.doubleValue
                                
                                if moneyDouble != nil {
                                    item.removeObjectForKey("price")
                                    item.setObject(moneyDouble, forKey: "price")
                                } else {
                                    continue
                                }
                            }
                        }
                        
//                        item.setObject(name.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet()), forKey: "itemName")
//                        let imageAsset = UIImage(named: image)!
//                        let jpeg = UIImageJPEGRepresentation(imageAsset, 1.0)!
//                        let file = PFFile(data: jpeg)!
//                        item.setObject( file , forKey: "image")
//                        item.setObject(refNum.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet()), forKey: "refNum")
//                        item.setObject(movement.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet()), forKey: "movement")
//                        item.setObject(functions.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet()), forKey: "functions")
//                        item.setObject(itemCase.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet()), forKey: "case")
//                        item.setObject(band.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet()), forKey: "band")
//                        item.setObject(variations.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet()), forKey: "variations")
//                        item.setObject(brand.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet()), forKey: "itemBrand")
//                        item.saveInBackgroundWithBlock({ (success, error) -> Void in
//                            if success {
//                                print("saved \(image)")
//                            }else {
//                                print(error)
//                            }
//                        })
//                        print(item)
//                        break;
                    }
                }catch {
                    print("error with jsonserialization")
                }
            }catch {
                print("error with json")
            }
        }
    }
}
