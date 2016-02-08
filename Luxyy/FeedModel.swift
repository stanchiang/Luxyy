//
//  FeedModel.swift
//  Luxyy
//
//  Created by Stanley Chiang on 2/7/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import MWFeedParser

protocol feedDelegate {
    func transferBlogPost(post: BlogPostModel)
}

class FeedModel: NSObject, MWFeedParserDelegate {
    var rssLink: String!
    var blogPosts:[BlogPostModel]!
    var delegate: feedDelegate!
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
        let blogPost = BlogPostModel(title: item.title)
        print(item.summary)
        if let htmlString = try? String(contentsOfFile: item.summary, encoding: NSUTF8StringEncoding) {
            blogPost.parsePost(htmlString)
        }
        
        blogPosts.append(blogPost)
        delegate.transferBlogPost(blogPosts.first!)
        parser.stopParsing()
    }
}
