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
    var selectedIndexPath:NSIndexPath!
    
    var listName:String!
    var expanded: expandedImageView!
    
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
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let navHeight = appDelegate.controller.NAV_HEIGHT
        
        let navBar = UINavigationBar(frame: CGRectMake(0, 0, self.frame.width, navHeight))
        self.addSubview(navBar)
        navBar.barTintColor = UIColor.whiteColor()
        
        //NOTE: there appears to be a bottom border even though we didn't create one because we pushed this view's collection view down one pixel so users are still seeing the bottom border from the underlying view
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "doneAction:")
        
        let rightButtonPadding = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        rightButtonPadding.width = 10
        
        let items = UINavigationItem()
        items.title = name.uppercaseString
        items.rightBarButtonItems = [rightButtonPadding,rightButton]
        items.hidesBackButton = true

        navBar.pushNavigationItem(items, animated: false)
        //navline color
        //right button padding
        
        list = delegate.getList(name)
        listName = name
        
        collectionView = UICollectionView(frame: CGRectMake(0, navHeight+1, self.frame.width, self.frame.height - cellWidth / 3), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(PlayListCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        self.addSubview(collectionView)

    }

    func reloadCollectionView(note: NSNotification){
        print("reloading full list collection")
        list = delegate.getList(listName)
        collectionView.reloadData()
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
        let selected: PlayListCollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath) as! PlayListCollectionViewCell
        if selected.object != nil {
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
            selectedIndexPath = indexPath
            
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
    
    func addDismissExpandedHandler(sender: AnyObject){
        let button:UIButton = sender as! UIButton
        button.addTarget(self, action: "dismissDetailExpandedView:", forControlEvents: .TouchUpInside)
        print("addDismissExpandedHandler")
    }
    
    func dismissDetailExpandedView(sender: AnyObject) {
        expanded.removeFromSuperview()
        print("dismissDetailExpandedView")
    }
    
    func addImageHandler(sender: UIGestureRecognizer){
        let theImageView = sender.view as! UIImageView
        let viewFrame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        expanded = expandedImageView(frame: viewFrame)
        if expanded.imageView != nil {
            addSubview(expanded)
            expanded.expandedDel = self
            expanded.setup(theImageView)
        }
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

    func doneAction(sender: AnyObject){
        delegate.dismissFullList()
    }
    
    func filterAction(sender: AnyObject){
        print("filter")
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
                            self.removeItem()
                        }else {
                            print("error \(error)")
                        }
                    })
                })
                
            } else{
                print("same decision")
            }
        }
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
    
    func removeItem(){
        list.removeAtIndex(selectedIndexPath.item)
        collectionView.deleteItemsAtIndexPaths([selectedIndexPath])
        NSNotificationCenter.defaultCenter().postNotificationName("reloadCollectionView", object: nil)
    }
    
    func loadDecision() {
        print("loading")
    }
}