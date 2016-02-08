//
//  BlogModel.swift
//  Luxyy
//
//  Created by Stanley Chiang on 2/7/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

protocol postDelegate {
    func sendPostContentToView(content:[AnyObject])
}

class PostModel: NSObject {

    var url:String!
    var content:[AnyObject]!
    var delegate: postDelegate!
    
    init(url: String) {
        self.url = url
        content = [AnyObject]()
    }
    
    func getHTMLFromURL(){
        
        let nsURL = NSURL(string: url)!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(nsURL) { (data, response, error) in
            if let htmlData = data{
                if let html = String(data: htmlData, encoding: NSUTF8StringEncoding){
                    self.parsePost(html)
                }
            }
        }
        
        task.resume()
    }
    
    func parsePost(rawHTML: String){
        let parsedRSS = ParseHTMLHelper()
        content = parsedRSS.setup(rawHTML)
        delegate.sendPostContentToView(content)
    }
}