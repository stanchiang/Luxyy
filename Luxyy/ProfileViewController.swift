//
//  ProfileViewController.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Parse
import Cartography

class ProfileViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, fullListDelegate {

    var collectionView: UICollectionView!
    var fullList:FullListView!
    var object:[PFObject]!
    var objectLiked:[PFObject]!
    var objectPassed:[PFObject]!
    var liked: Bool!

    var likedCount:Int = 0
    var passedCount:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadCollectionView:", name: "reloadCollectionView", object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let cellWidth = self.view.frame.width / 2 - 15
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(PlayListCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView)
    }
    
    func reloadCollectionView(note: NSNotification){
        print("reloading profile page collection")
        collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PlayListCollectionViewCell
        
        if indexPath.item == 0 {
            cell.imageView.image = UIImage(named: "save")
            appDelegate.backgroundThread(0, background: { () -> AnyObject in
                
                let item = PFQuery(className: "Decision")
                item.whereKey("user", equalTo: PFUser.currentUser()!)
                item.whereKey("liked", equalTo: true)
                
                item.findObjectsInBackgroundWithBlock({ (returnedObject, error) -> Void in
                    self.object = returnedObject
                    if self.object.count > 0 {
                        self.objectLiked = self.object
                        self.likedCount = self.objectLiked.count
                        cell.centerLabel.text = "\(self.likedCount)"
                        cell.centerLabel.font = UIFont(name: "yuanti-SC", size: 40)
                        cell.centerLabel.textColor = UIColor.whiteColor()
                        
                        cell.bottomlabel.text = "LIKED"
                        cell.bottomlabel.font = UIFont(name: "yuanti-SC", size: 20)
                        cell.bottomlabel.textColor = UIColor.whiteColor()
                        let result = self.object[self.object.count - 1] as PFObject
                        let itemID = (result.objectForKey("item")!.objectId)!
                        let actualItem = PFQuery(className: "Item")
                        actualItem.whereKey("objectId", equalTo: itemID!)
                        
                        actualItem.findObjectsInBackgroundWithBlock({ (actualResult, error) -> Void in
                            let imageFile:PFFile = actualResult![0].objectForKey("image")! as! PFFile
                            imageFile.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                                cell.imageView.image = UIImage(data: imageData!)
                                cell.overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                            })
                        })
                    }
                })
                
                return cell
                
                }, completion: nil)
        } else if indexPath.item == 1 {
            cell.imageView.image = UIImage(named: "skip")
            appDelegate.backgroundThread(0, background: { () -> AnyObject in
                
                let item = PFQuery(className: "Decision")
                item.whereKey("user", equalTo: PFUser.currentUser()!)
                item.whereKey("liked", equalTo: false)
                
                item.findObjectsInBackgroundWithBlock({ (returnedObject, error) -> Void in
                    self.object = returnedObject
                    if self.object.count > 0 {
                        self.objectPassed = self.object
                        self.passedCount = self.objectPassed.count
                        cell.centerLabel.text = "\(self.passedCount)"
                        cell.centerLabel.font = UIFont(name: "yuanti-SC", size: 40)
                        cell.centerLabel.textColor = UIColor.whiteColor()

                        cell.bottomlabel.text = "PASSED"
                        cell.bottomlabel.font = UIFont(name: "yuanti-SC", size: 20)
                        cell.bottomlabel.textColor = UIColor.whiteColor()
                        let result = self.object[self.object.count - 1] as PFObject
                        let itemID = (result.objectForKey("item")!.objectId)!
                        let actualItem = PFQuery(className: "Item")
                        actualItem.whereKey("objectId", equalTo: itemID!)
                        
                        actualItem.findObjectsInBackgroundWithBlock({ (actualResult, error) -> Void in
                            let imageFile:PFFile = actualResult![0].objectForKey("image")! as! PFFile
                            imageFile.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                                cell.imageView.image = UIImage(data: imageData!)
                                cell.overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                            })
                        })
                    }
                })
                
                return cell
                
                }, completion: nil)
        }
        
        cell.backgroundColor = UIColor.lightGrayColor()
        
        if indexPath.item == 2 {
            cell.imageView.image = UIImage(named: "defaultProfilePic")
            cell.backgroundColor = UIColor(red: 70/255.0, green: 130/255.0, blue: 180/255.0, alpha: 1.000)
            cell.centerLabel.text = ""
            cell.bottomlabel.text = "LOG OUT"
            cell.bottomlabel.font = UIFont(name: "yuanti-SC", size: 20)
            cell.bottomlabel.textColor = UIColor.blackColor()
            cell.overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
            print("cell.bottomlabel.frame:\(cell.bottomlabel.frame)")
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("tapped cell \(indexPath.item + 1)")
        let currentWindow = UIApplication.sharedApplication().keyWindow
        
        if (indexPath.item == 0) {
            if likedCount > 0 {
                fullList = FullListView(frame: currentWindow!.frame)
                fullList.delegate = self
                fullList.setUp("liked")
                currentWindow!.addSubview(fullList)
            } else {
                let cancelButtonTitle = NSLocalizedString("OK", comment: "")
                UIAlertView(title: "Please Swipe Right On A Watch First", message: nil, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
            }
        }
            
        if (indexPath.item == 1) {
            if passedCount > 0 {
                fullList = FullListView(frame: currentWindow!.frame)
                fullList.delegate = self
                fullList.setUp("passed")
                self.view.addSubview(fullList)
                
                currentWindow!.addSubview(fullList)
            } else {
                let cancelButtonTitle = NSLocalizedString("OK", comment: "")
                UIAlertView(title: "Please Swipe Left On A Watch First", message: nil, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
            }
        }
        
        if indexPath.item == 2 {
            print("logout")
            PFUser.logOut()
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.finishLoggingOut()
            print("take user to login page")
        }
    }
    
    func dismissFullList() {
        fullList.removeFromSuperview()
    }
    
    func getList(name: String) -> [PFObject]? {
        if name == "liked" {
            return objectLiked
        }else {
            return objectPassed
        }
    }
}
