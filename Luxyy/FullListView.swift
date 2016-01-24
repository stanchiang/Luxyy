//
//  FullListViewController.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Parse

protocol fullListDelegate{
    func dismissFullList()
    func getList(name:String) -> [PFObject]?
}

class FullListView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, detailDelegate {
    
    var collectionView: UICollectionView!
    var delegate:fullListDelegate!
    var list: [PFObject]!
    var detailView: DetailView!
    var expandedImage:UIImageView!
    var itemName:String!
    var itemBrand:String!
    var selectedObject:PFObject!
    var listName:String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    func setUp(name:String) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadCollectionView:", name: "reloadCollectionView", object: nil)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let cellWidth = self.frame.width / 2 - 15
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        list = delegate.getList(name)
        listName = name
        
        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(PlayListCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        self.addSubview(collectionView)
    }
    
    func reloadCollectionView(note: NSNotification){
        print("reloading full list collection")
        print("before count \(list.count)")
        list = delegate.getList(listName)
        collectionView.reloadData()
        print("after count \(list.count)")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if list.count == 0 {
            return 15
        } else {
            return list.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PlayListCollectionViewCell

        print(indexPath.item)
        if indexPath.item == 0 {
            cell.label.text = "Back"
            cell.backgroundColor = UIColor.lightGrayColor()
        } else if indexPath.item == 1 {
            cell.label.text = "Filter"
            cell.backgroundColor = UIColor.lightGrayColor()
        } else {
            if list.count > 0 {
                let result = list[indexPath.item - 2] as PFObject
                
                let itemID = result.objectForKey("item")!.objectId
                
                let actualItem = PFQuery(className: "Item")
                actualItem.whereKey("objectId", equalTo: itemID!!)
                do {
                    let actualResult = try actualItem.findObjects()
                    let imageFile:PFFile = actualResult[0].objectForKey("image")! as! PFFile
                    let imageData = try imageFile.getData()
                    print("got image data")
                    cell.imageView.image = UIImage(data: imageData)
                    cell.object = actualResult[0]
                } catch {
                    print(error)
                }
            }else {
                cell.backgroundColor = UIColor.orangeColor()
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("tapped cell \(indexPath.item + 1)")
        if indexPath.item == 0 {
            delegate.dismissFullList()
        } else{
            let selected: PlayListCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as! PlayListCollectionViewCell
            print("\(selected.object.objectId) \(selected.object.objectForKey("itemBrand")) \(selected.object.objectForKey("itemName")) ")
            let viewFrame = CGRectMake(0, 0, self.frame.width, self.frame.height)
            
            expandedImage = selected.imageView
            itemBrand = selected.object.objectForKey("itemBrand") as! String
            itemName = selected.object.objectForKey("itemName") as! String
            
            selectedObject = selected.object
            
            detailView = DetailView(frame: viewFrame)
            detailView.delegate = self
            detailView.setup()
            self.addSubview(detailView)
        }
    }
    
    
    func dismissDetailView(sender: AnyObject) {
        detailView.removeFromSuperview()
    }
    func addDismissHandler(sender: AnyObject) {
        let button:UIButton = sender as! UIButton
        button.addTarget(self, action: "dismissDetailView:", forControlEvents: .TouchUpInside)
    }
    func addImageHandler(sender: UIGestureRecognizer){
        
    }
    func getParentData() -> [String:AnyObject] {
        
        var parent = [String:AnyObject]()
        let imageArray:[UIImageView] = [expandedImage]
        parent.updateValue(imageArray, forKey: "imageArray")
        parent.updateValue(itemName, forKey: "name")
        parent.updateValue(itemBrand, forKey: "brand")
        
        return parent
    }
    func skipAction(sender: AnyObject){
        print("skipAction")
        saveDecision(false)
    }
    func shareAction(sender: AnyObject){
        print("shareAction")
//        let toShare = ["hey"]
//        let activityViewController = UIActivityViewController(activityItems: toShare, applicationActivities: nil)
//        presentViewController(activityViewController, animated: true, completion: {})
    }
    func likeAction(sender: AnyObject){
        print("likeAction")
        saveDecision(true)
    }
    func locate(){
        print("locating source from the collection view")
    }

    func saveDecision(liked: Bool){
        
        liked ? print("liked") : print("skipped")
        
        if let previousDecisionLiked = checkForPossibleExistingDecision() {
            if liked != previousDecisionLiked {
                
                let updater = PFQuery(className: "Decision")
                updater.whereKey("user", equalTo: PFUser.currentUser()!)
                updater.whereKey("item", equalTo: selectedObject)
                updater.whereKey("liked", equalTo: previousDecisionLiked)
                
                updater.findObjectsInBackgroundWithBlock({ (object, error) -> Void in
                    guard let object = object else {
                        print(error)
                        return
                    }
                    
                    let item = object[0]
                    item.setObject(liked, forKey: "liked")
                    item.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            print("was \(previousDecisionLiked) now \(liked)")
                            //                            print((self.swipeableView.topView() as! CardView).itemObject.objectForKey("liked"))
                        }else {
                            print("error \(error)")
                        }
                    })
                })
                
            } else{
                print("same decision")
            }
        } else{
            print("new decision")
            let save = PFObject(className: "Decision")
            save["user"] = PFUser.currentUser()
            save["liked"] = liked
            save["item"] = selectedObject
            save.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    print("saved")
                } else{
                    print("error: \(error)")
                }
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName("reloadCollectionView", object: nil)
    }
    
    func checkForPossibleExistingDecision() -> Bool? {

        let query = PFQuery(className: "Decision")
        query.whereKey("item", equalTo: selectedObject)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        do {
            let result = try query.findObjects()
            if result.count > 0 {
                if let decision = result[0].objectForKey("liked") as? Bool {
                    //                    print(result)
                    //                    print(result[0])
                    //                    print(result[0].objectForKey("objectId"))
                    return decision
                } else {
                    //                    print("nil 1")
                    return nil
                }
            } else {
                //                print("nil 2")
                return nil
            }
        } catch {
            //            print("nil 3")
            return nil
        }
    }
    
    func loadDecision() {
        print("loading")
    }
}