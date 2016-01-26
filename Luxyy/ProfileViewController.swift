//
//  ProfileViewController.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, fullListDelegate {

    var collectionView: UICollectionView!
    var fullList:FullListView!
    var object:[PFObject]!
    var objectLiked:[PFObject]!
    var objectPassed:[PFObject]!
    var liked: Bool!
    
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
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PlayListCollectionViewCell
        if indexPath.item == 0 {
            appDelegate.backgroundThread(0, background: { () -> AnyObject in
                
                let item = PFQuery(className: "Decision")
                item.whereKey("user", equalTo: PFUser.currentUser()!)
                item.whereKey("liked", equalTo: true)
                
                item.findObjectsInBackgroundWithBlock({ (returnedObject, error) -> Void in
                    self.object = returnedObject
                    if self.object.count > 0 {
                        self.objectLiked = self.object
                        cell.centerLabel.text = "\(self.objectLiked.count)"
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
        } else {
            appDelegate.backgroundThread(0, background: { () -> AnyObject in
                
                let item = PFQuery(className: "Decision")
                item.whereKey("user", equalTo: PFUser.currentUser()!)
                item.whereKey("liked", equalTo: false)
                
                item.findObjectsInBackgroundWithBlock({ (returnedObject, error) -> Void in
                    self.object = returnedObject
                    if self.object.count > 0 {
                        self.objectPassed = self.object
                        cell.centerLabel.text = "\(self.objectPassed.count)"
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
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("tapped cell \(indexPath.item + 1)")
        
        fullList = FullListView(frame: self.view.frame)
        fullList.delegate = self
        if (indexPath.item == 0) {
            fullList.setUp("liked")
        } else if (indexPath.item == 1) {
            fullList.setUp("passed")
        }
        self.view.addSubview(fullList)
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
