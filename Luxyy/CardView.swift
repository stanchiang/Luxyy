//
//  CardView.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Cartography
import Alamofire
import Parse

protocol cardDelegate {
    func setleftLabelText(myCardView:CardView)
    func setImage(myCardView:CardView)
    func expandedView(myCardView:CardView)
}

class CardView: UIView {
    
    var delegate: cardDelegate!
    
    var imageView:UIImageView!
    
    var likeImage:UIImageView!
    var skipImage:UIImageView!
    
    var leftLabel:UILabel!
    var rightLabel:UILabel!
    
    var itemObject: PFObject!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
        //main image
        imageView = UIImageView()
        imageView.tag = 4
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(imageView)
        
        imageView.frame = self.frame

        let inset:CGFloat = 10
        
        //like image
        likeImage = UIImageView(frame: CGRectMake(inset, inset, imageView.frame.width/4, imageView.frame.height/4))
        likeImage.image = UIImage(named: "save")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        likeImage.tintColor = UIColor(red: 43/255.0, green: 227/255.0, blue: 248/255.0, alpha: 1)
        likeImage.alpha = 0
        imageView.addSubview(likeImage)
        
        //skip image
        skipImage = UIImageView(frame: CGRectMake(3*imageView.frame.width/4 - inset, inset, imageView.frame.width/4, imageView.frame.height/4))
        skipImage.image = UIImage(named: "skip")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        skipImage.tintColor = UIColor(red: 255/255.0, green: 93/255.0, blue: 47/255.0, alpha: 1)
        skipImage.alpha = 0
        imageView.addSubview(skipImage)
        
        setNeedsDisplay()
        setNeedsLayout()
        setNeedsUpdateConstraints()
        
        //left label
        leftLabel = UILabel()
        leftLabel.textAlignment = .Left
        self.addSubview(leftLabel)
        
        constrain(leftLabel, imageView) { obj1, obj2 in
            obj1.left == obj2.left
            obj1.width == obj2.width * 0.5
            obj1.top == obj2.bottom - 50
            obj1.bottom == obj2.bottom
        }
        
        //right label
        rightLabel = UILabel()
        rightLabel.textAlignment = .Right
        self.addSubview(rightLabel)
        
        constrain(leftLabel, rightLabel) { obj1, obj2 in
            obj1.width == obj2.width
            obj1.top == obj2.top
            obj1.bottom == obj2.bottom
            distribute(by: 0, horizontally: obj1, obj2)
        }
        
        // Corner Radius
        layer.cornerRadius = 5.0;
        
    }
    
    func updateLabels(){
        delegate?.setleftLabelText(self)
    }
    
    func updateImage(){
        delegate?.setImage(self)
    }
    
    func expand(sender: AnyObject){
        delegate?.expandedView(sender as! CardView)
    }
    
}
