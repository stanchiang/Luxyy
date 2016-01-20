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
        
        //like image
        likeImage = UIImageView(frame: imageView.frame)
        likeImage.image = UIImage(named: "heart")
        likeImage.alpha = 0
        imageView.addSubview(likeImage)
        
        //skip image
        skipImage = UIImageView(frame: imageView.frame)
        skipImage.image = UIImage(named: "conf")
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
