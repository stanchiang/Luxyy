//
//  expandedImageView.swift
//  WatchProject
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Cartography

protocol expandedDelegate {
    func addDismissExpandedHandler(sender: AnyObject)
}

class expandedImageView: UIView, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var expandedDel: expandedDelegate!
    var dismiss: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(expand: UIImageView) {
        
        // prep
        scrollView = UIScrollView(frame: self.frame)
        scrollView.backgroundColor = UIColor.lightGrayColor()
        scrollView.delegate = self
        self.addSubview(scrollView)
        
        // 1
        let image = expand.image!
        imageView = UIImageView(image: image)
        imageView.frame = CGRect(origin: CGPointMake(0.0, 0.0), size:image.size)
        
        // 2
        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size
        
        // 3
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        // 4
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        
        // 5
        scrollView.maximumZoomScale = 10.0
        scrollView.zoomScale = scaleWidth
        
        // 6
        centerScrollViewContents()
        
        addDismissButton()
        
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
    
    func addDismissHandler() {
        expandedDel.addDismissExpandedHandler(dismiss)
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
        
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
//        // 1
//        let pointInView = recognizer.locationInView(imageView)
//        
//        // 2
//        var newZoomScale = scrollView.zoomScale * 1.5
//        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
//        
//        // 3
//        let scrollViewSize = scrollView.bounds.size
//        let w = scrollViewSize.width / newZoomScale
//        let h = scrollViewSize.height / newZoomScale
//        let x = pointInView.x - (w / 2.0)
//        let y = pointInView.y - (h / 2.0)
//        
//        let rectToZoomTo = CGRectMake(x, y, w, h);
//        
//        // 4
//        scrollView.zoomToRect(rectToZoomTo, animated: true)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
}

