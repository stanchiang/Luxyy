//
//  BlogModel.swift
//  Luxyy
//
//  Created by Stanley Chiang on 2/7/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class BlogPostModel: NSObject {

    var title:String!
    var rawHtml:String!
    var content:[AnyObject]!
    
    init(title: String, rawHtml:String) {
        self.title = title
        self.rawHtml = rawHtml
    }
    
    func parsePost(){
        let parsedRSS = ParsedRSS()
        
        //need to make
        content = parsedRSS.setup()
        
    }
}