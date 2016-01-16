//
//  ShareButton.swift
//  WatchProject
//
//  Created by Stanley Chiang on 12/27/15.
//  Copyright © 2015 Stanley Chiang. All rights reserved.
//

import UIKit

class ShareButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 0.5 * layer.bounds.size.width
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 0.5 * layer.bounds.size.width
    }
    
    override func drawRect(rect: CGRect) {
        
        //// PaintCode Trial Version
        //// www.paintcodeapp.com
        
        //// Color Declarations
        let fillColor = UIColor.blueColor()
        
        //// Subframes
        let subframe: CGRect = CGRectMake(rect.minX + 18, rect.minY + 14.7, rect.width - 35, rect.height - 28.7)
        
        //// shareIcon Drawing
        let shareIcon = UIBezierPath()
        shareIcon.moveToPoint(CGPointMake(subframe.minX + 0.46725 * subframe.width, subframe.minY + 0.09284 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.31384 * subframe.width, subframe.minY + 0.20184 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.26443 * subframe.width, subframe.minY + 0.16674 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.44877 * subframe.width, subframe.minY + 0.03576 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.44784 * subframe.width, subframe.minY + 0.03510 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.49724 * subframe.width, subframe.minY + 0.00000 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.49817 * subframe.width, subframe.minY + 0.00066 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.49910 * subframe.width, subframe.minY + 0.00000 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.54851 * subframe.width, subframe.minY + 0.03510 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.54758 * subframe.width, subframe.minY + 0.03576 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.73191 * subframe.width, subframe.minY + 0.16674 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.68251 * subframe.width, subframe.minY + 0.20184 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.53275 * subframe.width, subframe.minY + 0.09544 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.53275 * subframe.width, subframe.minY + 0.62457 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.46725 * subframe.width, subframe.minY + 0.62457 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.46725 * subframe.width, subframe.minY + 0.09284 * subframe.height))
        shareIcon.closePath()
        shareIcon.moveToPoint(CGPointMake(subframe.minX + 0.37118 * subframe.width, subframe.minY + 0.29258 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.00000 * subframe.width, subframe.minY + 0.29258 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.00000 * subframe.width, subframe.minY + 1.00000 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 1.00000 * subframe.width, subframe.minY + 1.00000 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 1.00000 * subframe.width, subframe.minY + 0.29258 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.62445 * subframe.width, subframe.minY + 0.29258 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.62445 * subframe.width, subframe.minY + 0.33913 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.93450 * subframe.width, subframe.minY + 0.33913 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.93450 * subframe.width, subframe.minY + 0.95346 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.06550 * subframe.width, subframe.minY + 0.95346 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.06550 * subframe.width, subframe.minY + 0.33913 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.37118 * subframe.width, subframe.minY + 0.33913 * subframe.height))
        shareIcon.addLineToPoint(CGPointMake(subframe.minX + 0.37118 * subframe.width, subframe.minY + 0.29258 * subframe.height))
        shareIcon.closePath()
        shareIcon.miterLimit = 4;
        
        shareIcon.usesEvenOddFillRule = true;
        
        fillColor.setFill()
        shareIcon.fill()
    }

}
