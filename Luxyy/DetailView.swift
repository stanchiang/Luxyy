//
//  DetailView.swift
//  WatchProject
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2015 Stanley Chiang. All rights reserved.
//

import UIKit
import Cartography

protocol detailDelegate {
    func dismissDetailView(sender: AnyObject)
    func addDismissHandler(sender: AnyObject)
    func addImageHandler(sender: UIGestureRecognizer)
    func getParentData() -> [String:AnyObject]
    func skipAction(sender: UIButton)
    func shareAction(sender: AnyObject)
    func likeAction(sender: UIButton)
    func locate()
}

class DetailView: UIView, UIScrollViewDelegate {

    var detailDel: detailDelegate!
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
    
    override func layoutSubviews() {
        scrollBaseView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
        
        // 4
        let pagesScrollViewSize = scrollView.frame.size
        
        if pagesScrollViewSize.width > 0 && pagesScrollViewSize.height > 0{
            scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * CGFloat(pageImages.count), pagesScrollViewSize.height)
            loadVisiblePages()
        }
        
        let height = stackView.frame.size.height + scrollView.frame.size.height + 50
        
        scrollBaseView.contentSize = CGSizeMake(scrollBaseView.frame.size.width, height)
        
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
        
        addToStack()
        addDismissButton()
        addActionButtons()
    }
    
    func addToStack(){
        let nameLabel = UILabel()
        nameLabel.text = watchName
        
        let brandLabel = UILabel()
        brandLabel.text = watchBrand
        
        let infoArray:[UILabel] = [nameLabel, brandLabel]
        for label in infoArray {
            stackView.addArrangedSubview(label)
        }
        
        let locateButton = UIButton()
        locateButton.backgroundColor = UIColor.greenColor()
        locateButton.setTitle("Locate this Item", forState: UIControlState.Normal)
        locateButton.addTarget(self, action: "locate:", forControlEvents: .TouchUpInside)
        stackView.addArrangedSubview(locateButton)
        
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
        parentData = detailDel.getParentData()
        pageImages = parentData["imageArray"] as! [UIImageView]
        pageCount = pageImages.count
        watchName = parentData["name"] as! String
        watchBrand = parentData["brand"] as! String
    }

    func addDismissButton() {
        dismiss = UIButton()
        dismiss.backgroundColor = UIColor.blueColor()
        dismiss.alpha = 0.5
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
        detailDel.addImageHandler(sender)
    }
    
    func addDismissHandler() {
        detailDel.addDismissHandler(dismiss)
    }
    
    func addActionButtons() {
        let skip = UIButton()
        skip.backgroundColor = UIColor.redColor()
        skip.addTarget(self, action: "itemSkipAction:", forControlEvents: .TouchUpInside)

        let share = ShareButton()
        share.backgroundColor = UIColor.whiteColor()
        share.addTarget(self, action: "itemShareAction:", forControlEvents: .TouchUpInside)
        
        let save = UIButton()
        save.backgroundColor = UIColor.greenColor()
        save.addTarget(self, action: "itemSaveAction:", forControlEvents: .TouchUpInside)
        
        let actionArray = [skip, share, save]
        
        for action in actionArray {
            addSubview(action)
            
            constrain(action) { view in
                view.height == 50
                view.width == 50
                view.bottom == view.superview!.bottom - 10
            }
        }
        
        constrain(skip) { view in
            view.leading == view.superview!.leading + 10
        }

        constrain(skip, share, save) { obj1, obj2, obj3 in
            distribute(by: 10, horizontally: obj1, obj2, obj3)
        }

        
    }
    
    func itemSkipAction(sender: UIButton) {
        self.removeFromSuperview()
        detailDel.skipAction(sender)
    }
    
    func itemSaveAction(sender: UIButton) {
        self.removeFromSuperview()
        detailDel.likeAction(sender)
    }
    
    func itemShareAction(sender: UIButton) {
        self.removeFromSuperview()
        detailDel.shareAction(sender)
    }
    
    func locate(sender: UIButton) {
        detailDel.locate()
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //FIXME: get a dynamic value of when to collapse scroll view; currently hard coded to some distance below where we set the original card down from top

        if scrollView.contentOffset.y < -140 {
            detailDel.dismissDetailView(self)
        }
    }

}