//
//  PlayListCollectionViewCell.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class PlayListCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let cell = UIView(frame: self.frame)
        let label = UILabel(frame: self.frame)
        label.text = "Liked"
        cell.addSubview(label)
        self.addSubview(cell)
        cell.backgroundColor = UIColor.lightGrayColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
