//
//  FeedModel.swift
//  Luxyy
//
//  Created by Stanley Chiang on 2/7/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import MWFeedParser
class FeedModel: NSObject, MWFeedParserDelegate {
    var rssLink: String!
    var blogPosts:[BlogPostModel]?
    
    override init(){
        super.init()
        blogPosts = [BlogPostModel]()
    }
    
    func request(rssLink:String) {
        let URL = NSURL(string: rssLink)
        let feedParser = MWFeedParser(feedURL: URL);
        feedParser.delegate = self
        feedParser.parse()
    }
    
    func loadArticles(){
        
    }
    
    func feedParserDidStart(parser: MWFeedParser!) {
        print("starting to parse")
    }
    
    func feedParserDidFinish(parser: MWFeedParser!) {
        print("finished parsing")
    }
    
    func feedParser(parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        let blogPost = BlogPostModel(title: item.title, rawHtml: item.summary)

//        let htmlFile = NSBundle.mainBundle().pathForResource("compacthodinkeersstest", ofType: "html")
        
        if let htmlString = try? String(contentsOfFile: blogPost.rawHtml, encoding: NSUTF8StringEncoding) {
            blogPost.rawHtml = htmlString
        }
        
        print(blogPost.title)
        print(blogPost.rawHtml)
        blogPosts?.append(blogPost)
        parser.stopParsing()
    }
}
