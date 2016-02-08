//
//  ParsedRSSView.swift
//  Luxyy
//
//  Created by Stanley Chiang on 2/7/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Kanna
import MWFeedParser

class ParsedRSS: NSObject, MWFeedParserDelegate {

    var images = [UIImageView]()
    
    func setup(htmlString:String) -> [AnyObject] {
//        let htmlFile = NSBundle.mainBundle().pathForResource("compacthodinkeersstest", ofType: "html")
//        let htmlTESTString = try? String(contentsOfFile: htmlFile!, encoding: NSUTF8StringEncoding)
//        return restructureText(htmlTESTString!)
        return restructureText(htmlString)
    }

    func getImages() -> [UIImageView] {
        return images
    }
    
    func addHyperLink(html:String, noTags:String) -> NSMutableAttributedString {
        let didEmbedHyperlinks:NSMutableAttributedString = NSMutableAttributedString(string: noTags)
        if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
            for link in doc.css("a") {
                let linkText = link.text!
                let linkURL = link["href"]!
                
                let rangeOfLinkText = noTags.rangeOfString(linkText)!
                
                let startIndexString = String(rangeOfLinkText.startIndex)
                let startIndexInt = Int(startIndexString)!
                didEmbedHyperlinks.addAttribute(NSLinkAttributeName, value: linkURL, range: NSMakeRange(startIndexInt, linkText.characters.count))
            }
        }
        return didEmbedHyperlinks
    }
    
    func extractImageLinksAndPositionsFrom(html:String, noTags:String) -> [(String, Range<String.Index>)] {
        var imagesLinkAndPosition = [(String, Range<String.Index>)]()
        if let doc = Kanna.HTML(html: html, encoding: NSUTF8StringEncoding) {
            for node in doc.css("div.embed-img"){
                if let imageId = node.css("p").innerHTML {
                    for link in node.css("img") {
                        if let url = link["src"], _ = link["src"]?.rangeOfString("hodinkee"){
                            if let range = noTags.rangeOfString(imageId) {
                                imagesLinkAndPosition.append((url, range))
                            }
                        }
                    }
                }
            }
        }
        return imagesLinkAndPosition
    }
    
    func stripTagsFrom(html: String) -> String? {
        let encodedString:String = html
        let encodedData:NSData = encodedString.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions: [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        do {
            let tagsStripped = try NSMutableAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
            return tagsStripped.string
        } catch {
            print(error)
            return nil
        }
    }
    
    func restructureText(html: String) -> [AnyObject]{
        var stack = [AnyObject]()
        if let noTags:String = stripTagsFrom(html) {
            let didExtractImageLinksAndPositions:[(String, Range<String.Index>)] = extractImageLinksAndPositionsFrom(html, noTags: noTags)
            let didEmbedHyperlinks:NSMutableAttributedString = addHyperLink(html, noTags: noTags)
            print(didEmbedHyperlinks)
            /*
            we will consider the base case to be alternating between 1 textview and then 1 image view and assume that they alternate --done--
            edge case #1: starting with an image --done--
            edge case #2: ending on text --done--
            */
            
            var prevLocation:Int = 0
            var length: Int!
            
            for (link, range) in didExtractImageLinksAndPositions {
                if let startOfImageLoc = convertIndexToInt(range.startIndex), let endOfImageLoc = convertIndexToInt(range.endIndex) {
                    
                    length = startOfImageLoc - prevLocation
                    
                    if startOfImageLoc != 0{
                        let label:UILabel = UILabel()
                        let substring = didEmbedHyperlinks.attributedSubstringFromRange(NSMakeRange(prevLocation, length))
                        label.numberOfLines = 0
                        label.attributedText = substring
                        stack.append(label)
                        prevLocation = endOfImageLoc
                    }
                    
                    let imageLink:UIImageView = UIImageView()
                    imageLink.contentMode = .Center
                    let imgURL: NSURL = NSURL(string: link)!
                    
                    // Download an NSData representation of the image at the URL
                    let request: NSURLRequest = NSURLRequest(URL: imgURL)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                        if error == nil {
                            imageLink.image = UIImage(data: data!)
                            self.images.append(imageLink)
                        }
                        else {
                            print("Error: \(error!.localizedDescription)")
                        }
                    })
                    stack.append(imageLink)
                    
                    if didExtractImageLinksAndPositions.last!.0 == link {
                        let finalLength = noTags.characters.count - prevLocation
                        let label:UILabel = UILabel()
                        let substring = didEmbedHyperlinks.attributedSubstringFromRange(NSMakeRange(prevLocation, finalLength))
                        label.numberOfLines = 0
                        label.attributedText = substring
                        stack.append(label)
                    }
                }
            }
        }
        return stack
    }
    
    func convertIndexToInt(index:String.Index) -> Int? {
        let string = String(index)
        if let int = Int(string) {
            return int
        }else {
            return nil
        }
    }
}
