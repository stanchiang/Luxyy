//
//  PlayListCollectionViewCell.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Parse

class PlayListCollectionViewCell: UICollectionViewCell {
    
    var label:UILabel!
    var imageView:UIImageView!
    var object: PFObject!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView = UIImageView()
        contentView.addSubview(imageView)

        label = UILabel()
        contentView.addSubview(label)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.frame = self.bounds
        self.imageView.frame = self.bounds
    }

    override func prepareForReuse() {
        print("prepareForReuse")
        super.prepareForReuse()
        imageView.image = nil
        label.text = nil
        object = nil
    }
}
