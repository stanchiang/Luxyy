//
//  BrowseViewController.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Cartography
import ZLSwipeableViewSwift
import Alamofire
import AlamofireImage
import Parse
import PromiseKit
import Analytics

class BrowseViewController: UIViewController, cardDelegate, detailDelegate, expandedDelegate {
    
    var swipeableView: ZLSwipeableView!
    var thecardView: CardView!
    var cardsizeconstraints:ConstraintGroup!
    var cardDefaultCenter:CGPoint!
    
    var detailView:DetailView!
    
    var skipButton: UIButton!
    var likeButton: UIButton!
    var shareButton: UIButton!
    
    var expandedImage: UIImageView!
    var previousY:CGFloat = 0
    var tapToExpand: UIGestureRecognizer!
    var expanded: expandedImageView!
    
    var currentItem: PFObject!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        swipeableView.numberOfActiveView = 4
        swipeableView.nextView = {
            return self.nextCardView()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        shareButton.setNeedsDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SEGAnalytics.sharedAnalytics().identify(PFUser.currentUser()?.objectId!, traits: ["email" : (PFUser.currentUser()?.email!)!])
        
        view.backgroundColor = UIColor.whiteColor()
        view.clipsToBounds = true
        view.userInteractionEnabled = false
        
        swipeableView = ZLSwipeableView()
        view.addSubview(swipeableView)
        
        cardsizeconstraints = constrain(swipeableView) { view1 in
            view1.leading == view1.superview!.leading + 20
            view1.trailing == view1.superview!.trailing - 20
            view1.top == view1.superview!.top + 20
            view1.bottom == view1.superview!.bottom - 200
        }
        
        let edge:CGFloat = 30
        
        //skip button
        skipButton = UIButton()
        let skipImage = UIImage(named: "skip")
        let tintedSkip = skipImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        skipButton.setImage(tintedSkip, forState: UIControlState.Normal)
        skipButton.tintColor = UIColor(red: 255/255.0, green: 93/255.0, blue: 47/255.0, alpha: 1)
        skipButton.imageEdgeInsets = UIEdgeInsets(top: edge, left: edge, bottom: edge, right: edge)
        skipButton.addTarget(self, action: "skipAction:", forControlEvents: .TouchUpInside)
        
        //share button
        shareButton = UIButton()
        let shareImage = UIImage(named: "share")
        let tintedShare = shareImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        shareButton.setImage(tintedShare, forState: UIControlState.Normal)
        shareButton.tintColor = UIColor(red: 70/255.0, green: 130/255.0, blue: 180/255.0, alpha: 1)
        shareButton.imageEdgeInsets = UIEdgeInsets(top: edge, left: edge, bottom: edge, right: edge)
        shareButton.addTarget(self, action: "shareAction:", forControlEvents: .TouchUpInside)
        
        //like button
        likeButton = UIButton()
        let likeImage = UIImage(named: "save")
        let tintedLike = likeImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        likeButton.setImage(tintedLike, forState: UIControlState.Normal)
        likeButton.tintColor = UIColor(red: 43/255.0, green: 227/255.0, blue: 248/255.0, alpha: 1)
        likeButton.imageEdgeInsets = UIEdgeInsets(top: edge, left: edge, bottom: edge, right: edge)
        likeButton.addTarget(self, action: "likeAction:", forControlEvents: .TouchUpInside)

        //constraints
        let buttons:[UIButton] = [skipButton, shareButton, likeButton]
        
        for button in buttons {
            view.addSubview(button)
        }
        
        constrain(buttons[1], swipeableView) { button2, card in
            button2.top == card.bottom + 60
            button2.bottom == button2.superview!.bottom - 60
            button2.width == button2.height
            button2.centerX == button2.superview!.centerX
        }
        
        constrain(buttons[0], buttons[1], buttons[2]) { button1, button2, button3 in
            button1.leading == button1.superview!.leading + 30
            button1.trailing == button2.leading - 20
            button1.height == button1.width
            button1.centerY == button2.centerY
            
            button3.leading == button2.trailing + 20
            button3.trailing == button3.superview!.trailing - 30
            button3.height == button3.width
            button3.centerY == button2.centerY
        }
        
        for button in buttons {
            button.layoutIfNeeded()
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.layer.borderWidth = 10
            button.layer.borderColor = UIColor.lightGrayColor().CGColor
            button.backgroundColor = UIColor.clearColor()
        }


        swipeableView.allowedDirection = Direction.Horizontal
        
        swipeableView.swiping = {view, location, translation in
            //FIXME: get a dynamic value of share button y axis value; currently set to iphone 6s
            if location.y > self.previousY {
//                self.shareButton.layer.borderWidth =  ( 1 - location.y / 420 ) * 5
            }
            self.previousY = location.y
            
            if location.y > 420 {
                self.shareAction(self)
            }
            
            if (self.swipeableView.topView() as! CardView).center.x > self.cardDefaultCenter.x {
//                print("liking")
                let alpha = ( (self.swipeableView.topView() as! CardView).center.x - self.cardDefaultCenter.x ) / ( self.view.frame.width / 3 )
                (self.swipeableView.topView() as! CardView).likeImage.alpha = alpha
                (self.swipeableView.topView() as! CardView).skipImage.alpha = 0
            }
            
            if (self.swipeableView.topView() as! CardView).center.x < self.cardDefaultCenter.x {
//                print("skipping")
                let alpha = ( self.cardDefaultCenter.x - (self.swipeableView.topView() as! CardView).center.x ) / ( self.view.frame.width / 3 )
                
                (self.swipeableView.topView() as! CardView).likeImage.alpha = 0
                (self.swipeableView.topView() as! CardView).skipImage.alpha = alpha
            }
        }
        
        
        swipeableView.didEnd = { view in
            self.shareButton.layer.borderWidth = 5
            (self.swipeableView.topView() as! CardView).likeImage.alpha = 0
            (self.swipeableView.topView() as! CardView).skipImage.alpha = 0
        }
        
        swipeableView.animateView = { (view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
            //override default card offset
        }
        
        swipeableView.didSwipe = { (view: UIView, inDirection: Direction, directionVector: CGVector) in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if inDirection == Direction.Right {
                appDelegate.backgroundThread(0, background: { () -> AnyObject in
                    self.saveDecision(true)
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadCollectionView", object: nil)
                    self.updateCurrentItem()
                    return ""
                    }, completion: nil)
            } else  {
                appDelegate.backgroundThread(0, background: { () -> AnyObject in
                    self.saveDecision(false)
                    NSNotificationCenter.defaultCenter().postNotificationName("reloadCollectionView", object: nil)
                    self.updateCurrentItem()
                    return ""
                    }, completion: nil)
            }
        }
    }
    
    func skipAction(sender: AnyObject){
        SEGAnalytics.sharedAnalytics().track(
            "made a decision",
            properties: [
                "decider" : (PFUser.currentUser()?.objectId!)!,
                "liked": false,
                "objectId" : currentItem.objectId!,
                "itemName":currentItem.objectForKey("itemName")!,
                "itemBrand":currentItem.objectForKey("itemBrand")!,
                "price":currentItem.objectForKey("price")!
            ]
        )
        self.swipeableView.swipeTopView(inDirection: .Left)
    }
    
    func captureScreenShot() -> UIImage {
        let layer = UIApplication.sharedApplication().keyWindow!.layer
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil)
        return screenshot
    }
    
    func shareAction(sender: AnyObject){
        
        SEGAnalytics.sharedAnalytics().track(
            "opened sharing",
            properties: [
                "decider" : (PFUser.currentUser()?.objectId!)!,
                "objectId" : currentItem.objectId!,
                "itemName":currentItem.objectForKey("itemName")!,
                "itemBrand":currentItem.objectForKey("itemBrand")!,
                "price":currentItem.objectForKey("price")!
            ]
        )

        
        let toShare:[AnyObject] = ["take a look at the \(currentItem.objectForKey("itemName")!) by \(currentItem.objectForKey("itemBrand")!). I found it on http://www.getLuxyy.com",captureScreenShot()]
        let activityViewController = UIActivityViewController(activityItems: toShare, applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
//        https://blog.branch.io/how-to-deep-link-on-facebook
    }
    
    func likeAction(sender: AnyObject){
        self.swipeableView.swipeTopView(inDirection: .Right)
        SEGAnalytics.sharedAnalytics().track(
            "made a decision",
            properties: [
                "decider" : (PFUser.currentUser()?.objectId!)!,
                "liked": true,
                "objectId" : currentItem.objectId!,
                "itemName":currentItem.objectForKey("itemName")!,
                "itemBrand":currentItem.objectForKey("itemBrand")!,
                "price":currentItem.objectForKey("price")!
            ]
        )
    }

    func saveDecision(liked: Bool){
        disableAllUserInteractions()
        liked ? print("liked") : print("skipped")
        
        if let previousDecisionLiked = checkForPossibleExistingDecision() {
            if liked != previousDecisionLiked {
                
                let updater = PFQuery(className: "Decision")
                updater.whereKey("user", equalTo: PFUser.currentUser()!)
                updater.whereKey("item", equalTo: currentItem)
                updater.whereKey("liked", equalTo: previousDecisionLiked)
                
                updater.findObjectsInBackgroundWithBlock({ (object, error) -> Void in
                    guard let object = object else {
                        print(error)
                        self.enableAllUserInteractions()
                        return
                    }
                    
                    let item = object[0]
                    item.setObject(liked, forKey: "liked")
                    item.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if success {
                            self.enableAllUserInteractions()
                            print("was \(previousDecisionLiked) now \(liked)")
//                            print((self.swipeableView.topView() as! CardView).itemObject.objectForKey("liked"))
                        }else {
                            self.enableAllUserInteractions()
                            print("error \(error)")
                        }
                    })
                })

            } else{
                enableAllUserInteractions()
                print("same decision")
            }
        } else{
            print("new decision")
            let save = PFObject(className: "Decision")
            save["user"] = PFUser.currentUser()
            save["liked"] = liked
            save["item"] = currentItem
            save.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    self.enableAllUserInteractions()
                    print("saved")
                } else{
                    self.enableAllUserInteractions()
                    print("error: \(error)")
                }
            }
        }
    }
    
    func checkForPossibleExistingDecision() -> Bool? {
        disableAllUserInteractions()
        let query = PFQuery(className: "Decision")
        query.whereKey("item", equalTo: (self.swipeableView.topView() as! CardView).itemObject)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        do {
            let result = try query.findObjects()
            if result.count > 0 {
                if let decision = result[0].objectForKey("liked") as? Bool {
                    enableAllUserInteractions()
                    return decision
                } else {
                    enableAllUserInteractions()
                    return nil
                }
            } else {
                enableAllUserInteractions()
                return nil
            }
        } catch {
            enableAllUserInteractions()
            return nil
        }
    }
    
    func handleExpand(sender: UIGestureRecognizer){
        thecardView.expand(swipeableView.topView()!)
    }
    
    func nextCardView() -> UIView? {
        
        disableAllUserInteractions()
        
        thecardView = CardView(frame: swipeableView.bounds)
        
        thecardView.backgroundColor = UIColor(red: 220.0/255.0, green: 213.0/255.0, blue: 201.0/255.0, alpha: 1)
        
        thecardView.delegate = self
        
        thecardView.updateLabels()
        thecardView.updateImage()
        
        tapToExpand = UITapGestureRecognizer(target: self, action: "handleExpand:")
        thecardView.addGestureRecognizer(self.tapToExpand)
        
        cardDefaultCenter = thecardView.convertPoint(thecardView.center, toCoordinateSpace: self.view)
        enableAllUserInteractions()
        return thecardView
    }
    
    func setImage(myCardView: CardView) {
        
//        disableAllUserInteractions()
        
        let countQuery = PFQuery(className: "Item")
        countQuery.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if (error == nil) {
                let randomNumber = Int(arc4random_uniform(UInt32(count)))
                let query = PFQuery(className: "Item")
                query.skip = randomNumber
                query.limit = 1
                query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
                    guard let object = objects else {
                        print("error \(error)")
                        return
                    }
                    
                    let result = object[0] as PFObject
                    let imageFile:PFFile = result.objectForKey("image")! as! PFFile
                    imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                        guard let data = data else {
                            print("error \(error)")
                            return
                        }
                        myCardView.imageView.image = UIImage(data: data)
                        myCardView.itemObject = result
                        print("\(result.objectId) \(result.objectForKey("itemBrand")) \(result.objectForKey("itemName")) ")
                        if self.currentItem == nil {
                            self.updateCurrentItem()
                        }
                    })
                }
            } else {
                print(error)
            }
        }
    }
    
    func setleftLabelText(myCardView:CardView) {
//        let cardData = CardModel()
//
//        var urlString:String!
//
//        cardData.getContent("http://www.stanleychiang.com/watchProject/randomNum.php", success: { (response) -> Void in
//
//            switch (response){
//            case "0":
//                urlString = "Hello"
//            case "1":
//                urlString = "World"
//            default:
//                urlString = "!"
//            }
//
//            myCardView.leftLabel.text = urlString
//            }) { (error) -> Void in
//                print(error)
//        }
    }
    
    func expandedView(myCardView: CardView) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //overlay a detailVC instance
        self.expandedImage = UIImageView(image: myCardView.imageView.image)
        
        let viewFrame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        detailView = DetailView(frame: viewFrame)
        detailView.delegate = self
        detailView.setup()
        
        self.view.addSubview(detailView)
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
    
    func dismissDetailView(sender: AnyObject) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        detailView.removeFromSuperview()
    }
    
    func addImageHandler(sender: UIGestureRecognizer) {
        let theImageView = sender.view as! UIImageView
        let viewFrame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        expanded = expandedImageView(frame: viewFrame)
        view.addSubview(expanded)
        expanded.expandedDel = self
        expanded.setup(theImageView)
    }
    
    func updateOverlayImage(myCardView: CardView) {
        swipeableView.swiping = { (view: UIView, atLocation: CGPoint, translation: CGPoint) in
            print(atLocation)
        }
    }
    
    func locate() {
        print("locating")
    }
    
    func getParentData() -> [String:AnyObject] {
        
        var parent = [String:AnyObject]()
        let imageArray:[UIImageView] = [expandedImage]
        parent.updateValue(imageArray, forKey: "imageArray")
        parent.updateValue(currentItem.objectForKey("itemName")!, forKey: "name")
        parent.updateValue(currentItem.objectForKey("itemBrand")!, forKey: "brand")
        
        parent.updateValue(currentItem.objectForKey("price")!, forKey: "price")
        parent.updateValue(currentItem.objectForKey("movement")!, forKey: "movement")
        parent.updateValue(currentItem.objectForKey("functions")!, forKey: "functions")
        parent.updateValue(currentItem.objectForKey("band")!, forKey: "band")
        parent.updateValue(currentItem.objectForKey("refNum")!, forKey: "refNum")
        parent.updateValue(currentItem.objectForKey("variations")!, forKey: "variations")
        
        
        return parent
    }
    
    func updateCurrentItem(){
        print("updating")
        if currentItem == nil {
            if let item = (self.swipeableView.activeViews().first as? CardView)?.itemObject {
                currentItem = item
                print("starting with \(currentItem!)")
            } else {
                print("couldn't load")
            }
        } else {
            currentItem = (self.swipeableView.topView() as! CardView).itemObject
            print("updating to \(currentItem!)")
        }
    }
    
    func loadDecision() {
        print("loading")
    }
    
    func disableAllUserInteractions(){
        view.userInteractionEnabled = false
        likeButton.userInteractionEnabled = false
        shareButton.userInteractionEnabled = false
        skipButton.userInteractionEnabled = false
    }
    
    func enableAllUserInteractions(){
        view.userInteractionEnabled = true
        likeButton.userInteractionEnabled = true
        shareButton.userInteractionEnabled = true
        skipButton.userInteractionEnabled = true
    }
}
