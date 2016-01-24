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

class BrowseViewController: UIViewController, cardDelegate, detailDelegate, expandedDelegate {
    
    var swipeableView: ZLSwipeableView!
    var thecardView: CardView!
    var cardsizeconstraints:ConstraintGroup!
    var cardDefaultCenter:CGPoint!
    
    var detailView:DetailView!
    
    var skipButton: UIButton!
    var likeButton: UIButton!
    var shareButton: ShareButton!
    
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
        
        view.backgroundColor = UIColor.whiteColor()
        view.clipsToBounds = true
        
        swipeableView = ZLSwipeableView()
        view.addSubview(swipeableView)
        
        cardsizeconstraints = constrain(swipeableView) { view1 in
            view1.leading == view1.superview!.leading + 20
            view1.trailing == view1.superview!.trailing - 20
            view1.top == view1.superview!.top + 20
            view1.bottom == view1.superview!.bottom - 200
        }
        
        //skip button
        skipButton = UIButton()
        skipButton.addTarget(self, action: "skipAction:", forControlEvents: .TouchUpInside)
        
        //share button
        shareButton = ShareButton(frame: skipButton.frame)
        shareButton.layer.borderColor = UIColor.blueColor().CGColor
        shareButton.addTarget(self, action: "shareAction:", forControlEvents: .TouchUpInside)
        
        //like button
        likeButton = UIButton()
        likeButton.addTarget(self, action: "likeAction:", forControlEvents: .TouchUpInside)
        
        //constraints
        let buttons:[UIButton] = [skipButton, shareButton, likeButton]
        for button in buttons {
            view.addSubview(button)
            if button == buttons[1] {
                continue
            }
            constrain(button, swipeableView) { obj1, obj2 in
                obj1.top == obj2.bottom + 50
                obj1.width == obj1.height
                obj1.bottom == obj1.superview!.bottom - 50
            }
            
        }
        
        constrain(buttons.first!){ obj1 in
            obj1.leading == obj1.superview!.leading + 30
        }
        
        
        constrain(buttons[0], buttons[1], buttons[2]){ obj0, obj1, obj2 in
            obj1.centerY == obj0.centerY
            obj1.leading == obj0.trailing + 15
            obj1.trailing == obj2.leading - 15
            obj1.height == obj1.width
        }

        constrain(buttons.last!){ obj1 in
            obj1.trailing == obj1.superview!.trailing - 30
        }
        
        for button in buttons {
            button.layoutIfNeeded()
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.layer.borderWidth = 5
            button.backgroundColor = UIColor.clearColor()
        }
        
        swipeableView.allowedDirection = Direction.Horizontal
        
        swipeableView.swiping = {view, location, translation in
            //FIXME: get a dynamic value of share button y axis value; currently set to iphone 6s
            if location.y > self.previousY {
                self.shareButton.layer.borderWidth =  ( 1 - location.y / 420 ) * 5
            }
            self.previousY = location.y
            
            if location.y > 420 {
                self.shareAction(self)
            }
            
//            print("evaluating")
            if (self.swipeableView.topView() as! CardView).center.x > self.cardDefaultCenter.x {
//                print("liking")
                (self.swipeableView.topView() as! CardView).likeImage.alpha = 1
                (self.swipeableView.topView() as! CardView).skipImage.alpha = 0
            }
            
            if (self.swipeableView.topView() as! CardView).center.x < self.cardDefaultCenter.y {
//                print("skipping")
                (self.swipeableView.topView() as! CardView).likeImage.alpha = 0
                (self.swipeableView.topView() as! CardView).skipImage.alpha = 1
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
            if inDirection == Direction.Right {
                self.saveDecision(true)
            } else  {
                self.saveDecision(false)
            }
            self.updateCurrentItem()
        }
    }
    
    func skipAction(sender: AnyObject){
        self.swipeableView.swipeTopView(inDirection: .Left)
    }
    
    func shareAction(sender: AnyObject){
        let toShare = ["hey"]
        let activityViewController = UIActivityViewController(activityItems: toShare, applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
    }
    
    func likeAction(sender: AnyObject){
        self.swipeableView.swipeTopView(inDirection: .Right)
    }
    
    func saveDecision(liked: Bool){

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
            save["item"] = currentItem
            save.saveInBackgroundWithBlock { (success, error) -> Void in
                if success {
                    print("saved")
                } else{
                    print("error: \(error)")
                }
            }
        }
    }
    
    func handleExpand(sender: UIGestureRecognizer){
        thecardView.expand(swipeableView.topView()!)
    }
    
    func nextCardView() -> UIView? {
        
        thecardView = CardView(frame: swipeableView.bounds)
        
        thecardView.backgroundColor = UIColor(red: 220.0/255.0, green: 213.0/255.0, blue: 201.0/255.0, alpha: 1)
        
        thecardView.delegate = self
        
        thecardView.updateLabels()
        thecardView.updateImage()
        
        tapToExpand = UITapGestureRecognizer(target: self, action: "handleExpand:")
        thecardView.addGestureRecognizer(self.tapToExpand)
        
        cardDefaultCenter = thecardView.convertPoint(thecardView.center, toCoordinateSpace: self.view)
        
        return thecardView
    }
    
    func setImage(myCardView: CardView) {
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
//        detailView.skip.backgroundColor = UIColor.clearColor()
//        detailView.save.backgroundColor = UIColor.clearColor()
//        detailView.
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
//        print(currentItem.objectId)
        parent.updateValue(currentItem.objectForKey("itemName")!, forKey: "name")
        parent.updateValue(currentItem.objectForKey("itemBrand")!, forKey: "brand")
        
        return parent
    }
    
    func updateCurrentItem(){
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
    
    func checkForPossibleExistingDecision() -> Bool? {
        
        let query = PFQuery(className: "Decision")
        query.whereKey("item", equalTo: (self.swipeableView.topView() as! CardView).itemObject)
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
