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
    var content:[AnyObject]!
    
    init(title: String) {
        self.title = title
        content = [AnyObject]()
    }
    
    func parsePost(rawHTML: String){
        let parsedRSS = ParsedRSS()
        content = parsedRSS.setup(rawHTML)
        print(content)
    }
}