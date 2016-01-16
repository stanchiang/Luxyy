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

protocol cardDelegate {
    func setleftLabelText(myCardView:CardView)
    func setImage(myCardView:CardView)
    
    func expandedView(myCardView:CardView)
}

class CardView: UIView {
    
    var delegate: cardDelegate!
    
    var imageView:UIImageView!
    
    var leftLabel:UILabel!
    var rightLabel:UILabel!
    
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
        
        // Shadow
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSizeMake(0, 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        // Corner Radius
        layer.cornerRadius = 10.0;
        
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