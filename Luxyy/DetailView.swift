//
//  DetailView.swift
//  WatchProject
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2015 Stanley Chiang. All rights reserved.
//

import UIKit
import Cartography
import Parse

protocol detailDelegate {
    func dismissDetailView(sender: AnyObject)
    func addDismissHandler(sender: AnyObject)
    func addImageHandler(sender: UIGestureRecognizer)
    func getParentData() -> [String:AnyObject]
    func skipAction(sender: AnyObject)
    func shareAction(sender: AnyObject)
    func likeAction(sender: AnyObject)
    func locate()
    func checkForPossibleExistingDecision() -> Bool?
    func loadDecision()
}

class DetailView: UIView, UIScrollViewDelegate {

    var delegate: detailDelegate!
    var parentData = [String:AnyObject]()
    var parentImageView: UIImageView!
    
    
    var stackContainerView: UIStackView!
    var expandedImage: UIImageView!
    var contentviewconstraints: ConstraintGroup!
    var nestedStack: UIStackView!
    var contentStack: UIStackView!
    var spacerView:UIView!
    var infoView: UIView!
    var dismiss: UIButton!
    
    var scrollBaseView: UIScrollView!
    var stackView: UIStackView!
    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    
    var pageImages: [UIImageView] = []
    var pageViews: [UIImageView?] = []
    var pageCount: Int!
    
    var watchName: String!
    var watchBrand: String!
    var watchprice:Double!
    var watchmovement:String!
    var watchfunctions:String!
    var watchband:String!
    var watchrefNum:String!
    var watchvariations:String!
    
    
    var skip:UIButton!
    var save:UIButton!
    
    override func layoutSubviews() {
        scrollBaseView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
        
        // 4
        let pagesScrollViewSize = scrollView.frame.size
        
        if pagesScrollViewSize.width > 0 && pagesScrollViewSize.height > 0{
            scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * CGFloat(pageImages.count), pagesScrollViewSize.height)
            loadVisiblePages()
        }
        
        let height = stackView.frame.size.height + scrollView.frame.size.height
        
        scrollBaseView.contentSize = CGSizeMake(scrollBaseView.frame.size.width, height)
        scrollBaseView.contentInset.bottom = 75
    }
    
    func setup(){

        processModel()
        
        self.backgroundColor = UIColor.whiteColor()
        scrollBaseView = UIScrollView(frame: self.frame)
        scrollBaseView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollBaseView)
        scrollBaseView.delegate = self
        
        constrain(scrollBaseView){ view in
            view.edges == view.superview!.edges
        }
        
        setupSlideShow()
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Vertical
        scrollBaseView.addSubview(stackView)
        
        constrain(stackView, scrollView) { view1, view2 in
            view1.top == view2.bottom
            view1.leading == view2.leading
            view1.trailing == view2.trailing
            view1.bottom == (view1.superview?.bottom)!
        }
        
        addItemDetails()
//        addLocationButton()
//        addBlogPosts()
        
        addDismissButton()
        addActionButtons()
        
        if let previousDecisionLiked = delegate.checkForPossibleExistingDecision() {
            if previousDecisionLiked {
                save.layer.backgroundColor = UIColor.greenColor().CGColor
            }else{
                skip.layer.backgroundColor = UIColor.redColor().CGColor
            }
        }else{
            print("still fresh")
        }
        
        delegate.loadDecision()
    }
    
    func addItemDetails() {
        let nameLabel = UILabel()
        nameLabel.text = watchName
        let brandLabel = UILabel()
        brandLabel.text = watchBrand
        let priceLabel = UILabel()
        priceLabel.text = "$\(NSString(format: "%.02f", watchprice))"
        
        let additionalInfoLabel = UILabel()
        additionalInfoLabel.text = "Additional Information"
        
        let primaryInfo = [nameLabel, brandLabel, priceLabel, additionalInfoLabel]
        
        for label in primaryInfo {
            
            if label == primaryInfo[0] || label == primaryInfo[3] {
                let gapView = UIView()
                stackView.addArrangedSubview(gapView)
                constrain(gapView) { view in
                    view.height == 30
                }
            }
            stackView.addArrangedSubview(label)
        }
        
        let movementLabel = UILabel()
        let movementHeader = "Movement:"
        movementLabel.text = watchmovement
        
        let functionLabel = UILabel()
        let functionHeader = "Functions:"
        functionLabel.text = watchfunctions
        
        let bandLabel = UILabel()
        let bandHeader = "Band:"
        bandLabel.text = watchband
        
        let variationsLabel = UILabel()
        let variationHeader = "Variations:"
        variationsLabel.text = watchvariations
        
        let refNumLabel = UILabel()
        let refNumHeader = "Reference Number:"
        refNumLabel.text = watchrefNum
  
        let infoArray:[String:UILabel] = ["1":nameLabel, "2":brandLabel, "3":priceLabel, "4":additionalInfoLabel, movementHeader:movementLabel, functionHeader:functionLabel, bandHeader:bandLabel, variationHeader:variationsLabel, refNumHeader:refNumLabel]
        
        for (header, label) in infoArray {
            label.numberOfLines = 0

            if header == "1" || header == "2" || header == "3" || header == "4" {
                label.font = UIFont(name: "Avenir", size: 20)
                if header == "4" {
                    label.font = UIFont.boldSystemFontOfSize(20.0)
                }
            } else {
                let fullString = "\(header) \(label.text!)"
                print(fullString)
                let start = fullString.characters.count - label.text!.characters.count
                var myMutableString = NSMutableAttributedString()
                myMutableString = NSMutableAttributedString(string: fullString, attributes: [NSFontAttributeName:UIFont(name: "Avenir", size: 20)!])
                myMutableString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(15), range: NSMakeRange(start, label.text!.characters.count))
                label.attributedText = myMutableString
                stackView.addArrangedSubview(label)
            }
            
            
            constrain(label) { label in
                label.leading == label.superview!.leading + 30
                label.trailing == label.superview!.trailing - 30
            }
        }
    }
    
    func addLocationButton(){
        let locateButton = UIButton()
        locateButton.backgroundColor = UIColor.greenColor()
        locateButton.setTitle("Locate this Item", forState: UIControlState.Normal)
        locateButton.addTarget(self, action: "locate:", forControlEvents: .TouchUpInside)
        stackView.addArrangedSubview(locateButton)
    }
    
    func addBlogPosts(){
        
        let blogStart = UILabel()
        blogStart.text = "What the Experts Say"
        stackView.addArrangedSubview(blogStart)
        
        for i in 1 ..< 25 {
            let post = UIButton(type: UIButtonType.System)
            post.backgroundColor = UIColor.orangeColor()
            post.layer.borderColor = UIColor.blackColor().CGColor
            post.layer.borderWidth = 1
            post.setTitle("blog post \(i)", forState: .Normal)
            self.stackView.addArrangedSubview(post)
            
        }
    }
    
    
    
    func setupSlideShow() {
        //1
        self.scrollView = UIScrollView()
        scrollView.pagingEnabled = true
        scrollView.bounces = true
        scrollView.bouncesZoom = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.delaysContentTouches = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollBaseView.addSubview(scrollView)
        
        constrain(scrollView, scrollBaseView) { view1, view2 in
            view1.top == view2.top
            view1.leading == view2.leading
            view1.trailing == view2.trailing
            view1.height == view2.height * 2 / 3
        }
        
        self.scrollView.delegate = self
        
        //pagecontrol
        configurePageControl()
        
        // 3
        for _ in 0..<pageControl.numberOfPages {
            pageViews.append(nil)
        }
        
        if pageCount < 2 {
            pageControl.hidden = true
        }
        
    }
    
    func configurePageControl(){
        pageControl = UIPageControl()
        scrollBaseView.addSubview(pageControl)
        

        constrain(pageControl, scrollView) { view1, view2 in
            view1.leading == view1.superview!.leading
            view1.trailing == view1.superview!.trailing
            view1.centerX == view1.superview!.centerX
            view1.top == view2.bottom - 30
        }
        
        pageControl.setNeedsUpdateConstraints()
        
        self.pageControl.numberOfPages = pageCount
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.redColor()
        self.pageControl.pageIndicatorTintColor = UIColor.redColor()
        self.pageControl.currentPageIndicatorTintColor = UIColor.lightGrayColor()
        
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        
        loadVisiblePages()
    }
    
    
    //MARK: All New Functions
    
    func loadPage(page: Int) {
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // 1
        if let _ = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            // 2
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            // 3
            let newPageView = UIImageView(image: pageImages[page].image)
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            
            // 4
            pageViews[page] = newPageView
        
            pageViews[page]!.userInteractionEnabled = true
            let imageExpand = UITapGestureRecognizer(target: self, action: Selector("addExpandHandler:"))
            pageViews[page]!.addGestureRecognizer(imageExpand)
            
        }
    }
    
    func purgePage(page: Int) {
        
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
        
    }
    
    func loadVisiblePages() {
        
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for var index = firstPage; index <= lastPage; ++index {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }

    
    func processModel(){
        parentData = delegate.getParentData()
        pageImages = parentData["imageArray"] as! [UIImageView]
        pageCount = pageImages.count
        watchName = parentData["name"] as! String
        watchBrand = parentData["brand"] as! String
        watchprice = parentData["price"] as! Double
        watchmovement = parentData["movement"] as! String
        watchfunctions = parentData["functions"] as! String
        watchband = parentData["band"] as! String
        watchrefNum = parentData["refNum"] as! String
        watchvariations = parentData["variations"] as! String
    }

    func addDismissButton() {
        dismiss = UIButton()
        dismiss.setImage(UIImage(named: "dismiss"), forState: .Normal)
        addSubview(dismiss)
        
        constrain(dismiss) { view in
            view.height == 50
            view.width == 50
            view.leading == view.superview!.leading + 20
            view.top == view.superview!.top + 20
        }
        addDismissHandler()
    }
    
    func addExpandHandler(sender: UIGestureRecognizer) {
        delegate.addImageHandler(sender)
    }
    
    func addDismissHandler() {
        delegate.addDismissHandler(dismiss)
    }
    
    func addActionButtons() {

        let edge:CGFloat = 15
        
        skip = UIButton()
        let skipImage = UIImage(named: "skip")
        let tintedSkip = skipImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        skip.setImage(tintedSkip, forState: UIControlState.Normal)
        skip.tintColor = UIColor(red: 255/255.0, green: 93/255.0, blue: 47/255.0, alpha: 1)
        skip.imageEdgeInsets = UIEdgeInsets(top: edge, left: edge, bottom: edge, right: edge)
        skip.addTarget(self, action: "itemSkipAction:", forControlEvents: .TouchUpInside)

        let share = UIButton()
        let shareImage = UIImage(named: "share")
        let tintedShare = shareImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        share.setImage(tintedShare, forState: UIControlState.Normal)
        share.tintColor = UIColor(red: 70/255.0, green: 130/255.0, blue: 180/255.0, alpha: 1)
        share.imageEdgeInsets = UIEdgeInsets(top: edge, left: edge, bottom: edge, right: edge)
        share.addTarget(self, action: "itemShareAction:", forControlEvents: .TouchUpInside)
        
        save = UIButton()
        let saveImage = UIImage(named: "save")
        let tintedSave = saveImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        save.setImage(tintedSave, forState: UIControlState.Normal)
        save.tintColor = UIColor(red: 43/255.0, green: 227/255.0, blue: 248/255.0, alpha: 1)
        save.imageEdgeInsets = UIEdgeInsets(top: edge, left: edge, bottom: edge, right: edge)
        save.addTarget(self, action: "itemSaveAction:", forControlEvents: .TouchUpInside)
        
        let actionArray = [skip, share, save]
        
        for action in actionArray {
            addSubview(action)

            constrain(action) { view in
                view.height == 50
                view.width == 50
                view.bottom == view.superview!.bottom - 10
            }
            
            action.layoutIfNeeded()
            action.layer.cornerRadius = 0.5 * action.bounds.size.width
            action.layer.borderWidth = 5
            action.layer.borderColor = UIColor.lightGrayColor().CGColor

        }
        
        constrain(actionArray[1]){ obj1 in
            obj1.centerX == obj1.superview!.centerX
        }

        constrain(skip, share, save) { obj1, obj2, obj3 in
            distribute(by: 30, horizontally: obj1, obj2, obj3)
        }

    }
    
    func itemSkipAction(sender: UIButton) {
        self.removeFromSuperview()
        delegate.skipAction(sender)
    }
    
    func itemSaveAction(sender: UIButton) {
        self.removeFromSuperview()
        delegate.likeAction(sender)
    }
    
    func itemShareAction(sender: UIButton) {
        self.removeFromSuperview()
        delegate.shareAction(sender)
    }
    
    func locate(sender: UIButton) {
        delegate.locate()
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //FIXME: get a dynamic value of when to collapse scroll view; currently hard coded to some distance below where we set the original card down from top

        if scrollView.contentOffset.y < -140 {
            delegate.dismissDetailView(self)
        }
    }

}
