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
    
    var detailView:DetailView!
    
    var skipButton: UIButton!
    var likeButton: UIButton!
    var shareButton: ShareButton!
    
    var expandedImage: UIImageView!
    var previousY:CGFloat = 0
    var tapToExpand: UIGestureRecognizer!
    var expanded: expandedImageView!
    
    var currentObjectId:String!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        swipeableView.numberOfActiveView = 2
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
            view1.bottom == view1.superview!.bottom - 150
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
            constrain(button, swipeableView) { obj1, obj2 in
//                distribute(by: 50 , vertically: obj2, obj1)
                obj1.width == 50
                obj1.height == 50
                obj1.bottom == obj1.superview!.bottom - 10
            }
            
            button.layoutIfNeeded()
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.layer.borderWidth = 5
            button.backgroundColor = UIColor.clearColor()
        }
        
        constrain(buttons[1]){ obj1 in
            obj1.centerX == obj1.superview!.centerX
        }
        
        constrain(skipButton, shareButton, likeButton) { obj1, obj2, obj3 in
            distribute(by: 30, horizontally: obj1, obj2, obj3)
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
        }
        
        swipeableView.didEnd = { view in
            self.shareButton.layer.borderWidth = 5
        }
        
        swipeableView.animateView = { (view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
            //override default card offset
        }
        
        swipeableView.didSwipe = { (view: UIView, inDirection: Direction, directionVector: CGVector) in
            if inDirection == Direction.Right {
                print("swiped Right on \(self.currentObjectId)")
            } else  {
                print("swiped Left on \(self.currentObjectId)")
            }
        }
    }
    
    func skipAction(sender: UIButton){
        self.swipeableView.swipeTopView(inDirection: .Left)
        print("tapped Skip on \(self.currentObjectId)")
    }
    
    func shareAction(sender: AnyObject){
        let toShare = ["hey"]
        let activityViewController = UIActivityViewController(activityItems: toShare, applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
        print("engaged Share on \(self.currentObjectId)")
    }
    
    func likeAction(sender: UIButton){
        self.swipeableView.swipeTopView(inDirection: .Right)
        print("tapped Like on \(self.currentObjectId)")
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
        
        
        return thecardView
    }
    
    func setImage(myCardView: CardView) {
        //needs a way to get a random image
        
        let item = PFQuery(className: "Item")
        item.whereKey("objectId", equalTo: "NUwM3Kowcc")
        item.findObjectsInBackgroundWithBlock { (object, error) -> Void in
            guard let object = object else {
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
                self.currentObjectId = result.objectId!
            })
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
        detailView.detailDel = self
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
    
    func locate() {
        print("locating")
    }
    
    func getParentData() -> [String:AnyObject] {
        
        var parent = [String:AnyObject]()
        let imageArray:[UIImageView] = [expandedImage, expandedImage, expandedImage]
        parent.updateValue(imageArray, forKey: "imageArray")
        parent.updateValue("Lange1", forKey: "name")
        parent.updateValue("A. Lange & Söhne", forKey: "brand")
        
        return parent
    }
    
}
