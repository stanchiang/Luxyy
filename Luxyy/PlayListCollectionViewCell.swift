//
//  PlayListCollectionViewCell.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Parse
import Cartography

class PlayListCollectionViewCell: UICollectionViewCell {
    
    var bottomlabel:UILabel!
    var centerLabel:UILabel!
    var imageView:UIImageView!
    var overlayView:UIView!
    var object: PFObject!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView()
        contentView.addSubview(imageView)

        overlayView = UIView()
        contentView.addSubview(overlayView)
        
        bottomlabel = UILabel()
        bottomlabel.textAlignment = .Center
        contentView.addSubview(bottomlabel)
        
        centerLabel = UILabel()
        centerLabel.textAlignment = .Center
        contentView.addSubview(centerLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bottomlabel.frame = self.bounds
        self.centerLabel.frame = self.bounds
        self.imageView.frame = self.bounds
        self.overlayView.frame = self.bounds
        
        constrain(bottomlabel) { label in
            label.centerX == label.superview!.centerX
            label.bottom == label.superview!.bottom
            label.height == 30
        }
        
        constrain(centerLabel, bottomlabel) { c, b in
            c.centerX == b.centerX
            c.centerY == c.superview!.centerY
            c.bottom == b.top
            c.width == c.height
        }
    }

    override func prepareForReuse() {
        print("prepareForReuse")
        super.prepareForReuse()
        imageView.image = nil
        bottomlabel.text = nil
        object = nil
    }
}
