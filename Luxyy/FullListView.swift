//
//  FullListViewController.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Parse
import Cartography

protocol fullListDelegate{
    func dismissFullList()
    func getList(name:String) -> [PFObject]?
}

class FullListView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, detailDelegate, expandedDelegate {
    
    var collectionView: UICollectionView!
    var delegate:fullListDelegate!
    var list: [PFObject]!
    var detailView: DetailView!
    var expandedImage:UIImageView!

    var itemName:String!
    var itemBrand:String!
    var price:Double!
    var movement:String!
    var functions:String!
    var band:String!
    var refNum:String!
    var variations:String!
    
    var selectedObject:PFObject!
    var listName:String!
    var expanded: expandedImageView!
    
    var goBack:UIGestureRecognizer!
    
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
        
        let toolBar = UIView(frame: CGRectMake(0, 0, self.frame.width, cellWidth / 3))
        self.addSubview(toolBar)
        
        let backButton = UIButton()
        backButton.frame = CGRectMake(0, 0, toolBar.frame.width / 4, toolBar.frame.height)
        backButton.backgroundColor = UIColor.whiteColor()
        backButton.setTitle("Back", forState: UIControlState.Normal)
        backButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        toolBar.addSubview(backButton)

        let searchButton = UIButton()
        searchButton.frame = CGRectMake(toolBar.frame.width / 4, 0, toolBar.frame.width / 2, toolBar.frame.height)
        searchButton.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        searchButton.setTitle("Search", forState: UIControlState.Normal)
        toolBar.addSubview(searchButton)

        let filterButton = UIButton()
        filterButton.frame = CGRectMake(toolBar.frame.width * 3 / 4, 0, toolBar.frame.width / 4, toolBar.frame.height)
        filterButton.layer.backgroundColor = UIColor.darkGrayColor().CGColor
        filterButton.setTitle("Filter", forState: UIControlState.Normal)
        toolBar.addSubview(filterButton)
        
        goBack = UITapGestureRecognizer(target: self, action: "backButtonAction:")
        backButton.addGestureRecognizer(self.goBack)
        
        
        list = delegate.getList(name)
        listName = name
        
        collectionView = UICollectionView(frame: CGRectMake(0, cellWidth / 3, self.frame.width, self.frame.height - cellWidth / 3), collectionViewLayout: layout)
//        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(PlayListCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        self.addSubview(collectionView)
        
//        constrain(toolBar, collectionView) { t, c in
//            t.width == t.superview!.width
//            t.height == 50
//            t.leading == t.superview!.leading
//            t.trailing == t.superview!.trailing
//            c.top == t.bottom
//            c.leading == c.superview!.leading
//            c.trailing == c.superview!.trailing
//            c.bottom == c.superview!.bottom
//        }
//        collectionView.setNeedsDisplay()
//        collectionView.setNeedsUpdateConstraints()
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
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PlayListCollectionViewCell
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.backgroundThread(0, background: { () -> AnyObject in
            if self.list.count > 0 {
                let result = self.list[indexPath.item] as PFObject
                
                let itemID = result.objectForKey("item")!.objectId
                
                let actualItem = PFQuery(className: "Item")
                actualItem.whereKey("objectId", equalTo: itemID!!)

                actualItem.findObjectsInBackgroundWithBlock({ (actualResult, error) -> Void in
                    if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PlayListCollectionViewCell {
                        let imageFile:PFFile = actualResult![0].objectForKey("image")! as! PFFile
                        imageFile.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                            cell.imageView.image = UIImage(data: imageData!)
                        })
                        if cell.object == nil {
                            cell.object = actualResult![0]
                        }
                    }
                })
            }else {
                cell.backgroundColor = UIColor.orangeColor()
            }
            return cell
        }, completion: nil)
        if cell.imageView.image == nil {
            cell.backgroundColor = UIColor.lightGrayColor()
        }
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("tapped cell \(indexPath.item + 1)")
//        if indexPath.item == 0 {
//            delegate.dismissFullList()
//        } else if indexPath.item == 1 {
//            if PFUser.currentUser()?.objectId != "E0u5zMTSEW" {
//                PFUser.logOut()
//                do {
//                    try PFUser.logInWithUsername("stanley@getluxyy.com", password: "aVD336af")
//                    let cancelButtonTitle = NSLocalizedString("OK", comment: "")
//                    UIAlertView(title: "logged in as stanley@getLuxyy.com", message: nil, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
//                } catch {
//                    print(error)
//                }
//            } else {
//                PFUser.logOut()
//                do {
//                    try PFUser.logInWithUsername("stanchiang23@gmail.com", password: "aVD336af")
//                    let cancelButtonTitle = NSLocalizedString("OK", comment: "")
//                    UIAlertView(title: "logged in as stanchiang23@gmail.com", message: nil, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
//                } catch {
//                    print(error)
//                }
//            }
//        }else{
            let selected: PlayListCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as! PlayListCollectionViewCell
            print("\(selected.object.objectId) \(selected.object.objectForKey("itemBrand")) \(selected.object.objectForKey("itemName")) ")
            let viewFrame = CGRectMake(0, 0, self.frame.width, self.frame.height)
            
            expandedImage = selected.imageView
            itemBrand = selected.object.objectForKey("itemBrand") as! String
            itemName = selected.object.objectForKey("itemName") as! String
            price = selected.object.objectForKey("price") as! Double
            movement = selected.object.objectForKey("movement") as! String
            functions = selected.object.objectForKey("functions") as! String
            band = selected.object.objectForKey("band") as! String
            refNum = selected.object.objectForKey("refNum") as! String
            variations = selected.object.objectForKey("variations") as! String
            
            selectedObject = selected.object
            
            detailView = DetailView(frame: viewFrame)
            detailView.delegate = self
            detailView.setup()
            self.addSubview(detailView)
//        }
    }
    
    func dismissDetailView(sender: AnyObject) {
        detailView.removeFromSuperview()
    }
    
    func addDismissHandler(sender: AnyObject) {
        let button:UIButton = sender as! UIButton
        button.addTarget(self, action: "dismissDetailView:", forControlEvents: .TouchUpInside)
    }
    
    func addDismissExpandedHandler(sender: AnyObject){
        let button:UIButton = sender as! UIButton
        button.addTarget(self, action: "dismissDetailExpandedView:", forControlEvents: .TouchUpInside)
        
    }
    
    func dismissDetailExpandedView(sender: AnyObject) {
        expanded.removeFromSuperview()
    }
    
    func addImageHandler(sender: UIGestureRecognizer){
        let theImageView = sender.view as! UIImageView
        let viewFrame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        expanded = expandedImageView(frame: viewFrame)
        addSubview(expanded)
        expanded.expandedDel = self
        expanded.setup(theImageView)
    }
    
    func getParentData() -> [String:AnyObject] {
        
        var parent = [String:AnyObject]()
        let imageArray:[UIImageView] = [expandedImage]
        parent.updateValue(imageArray, forKey: "imageArray")
        parent.updateValue(itemName, forKey: "name")
        parent.updateValue(itemBrand, forKey: "brand")
        parent.updateValue(price, forKey: "price")
        parent.updateValue(movement, forKey: "movement")
        parent.updateValue(functions, forKey: "functions")
        parent.updateValue(band, forKey: "band")
        parent.updateValue(refNum, forKey: "refNum")
        parent.updateValue(variations, forKey: "variations")
        
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

    func backButtonAction(sender: AnyObject){
        delegate.dismissFullList()
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
                    return decision
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func loadDecision() {
        print("loading")
    }
}