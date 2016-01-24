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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PlayListCollectionViewCell
        
        if indexPath.item == 0 {
            liked = true
            
        } else {
            liked = false
        }
        

        let item = PFQuery(className: "Decision")
        item.whereKey("user", equalTo: PFUser.currentUser()!)
        item.whereKey("liked", equalTo: liked)
        
        do {
            object = try item.findObjects()
            if object.count > 0 {
                if indexPath.item == 0 {
                    objectLiked = object
                    cell.label.text = "\(object.count) Liked"
                } else {
                    objectPassed = object
                    cell.label.text = "\(object.count) Passed"
                }
                
                let result = object[object.count - 1] as PFObject
                
                let itemID = result.objectForKey("item")!.objectId
                
                let actualItem = PFQuery(className: "Item")
                actualItem.whereKey("objectId", equalTo: itemID!!)
                do {
                    let actualResult = try actualItem.findObjects()
                    let imageFile:PFFile = actualResult[0].objectForKey("image")! as! PFFile
                    let imageData = try imageFile.getData()
                    print("got image data")
                    cell.imageView.image = UIImage(data: imageData)
                } catch {
                    print(error)
                }
            } else {
                cell.backgroundColor = UIColor.orangeColor()
            }
            
        }catch {
            print(error)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("tapped cell \(indexPath.item + 1)")
        
        fullList = FullListView(frame: self.view.frame)
        fullList.delegate = self
        if (indexPath.item == 0) {
            fullList.setUp("liked")
        } else {
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
