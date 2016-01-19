//
//  PlayListCollectionViewCell.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class PlayListCollectionViewCell: UICollectionViewCell {
    
    var label:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = UILabel()
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.frame = self.bounds
    }

}
