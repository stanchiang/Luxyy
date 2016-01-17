//
//  MessagesViewController.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Cartography

class MessagesViewController: JSQMessagesViewController {
    
    var messages:[JSQMessage] = []
    var incomingBubble:JSQMessagesBubbleImage!
    var outgoingBubble:JSQMessagesBubbleImage!
    
    //    func senderDisplayName() -> String! {
    //        return "Michael Schinis"
    //    }
    //    func senderId() -> String! {
    //        return "9339"
    //    }
    
    override func viewDidLayoutSubviews() {
        constrain(view) { view in
            view.edges == view.superview!.edges
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.senderDisplayName = "stan" // self.senderDisplayName()
        self.senderId = "9339" //self.senderId()
        self.title = "Recipient name"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor( UIColor.jsq_messageBubbleGreenColor() )
        self.outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor( UIColor.jsq_messageBubbleLightGrayColor())
        // Do any additional setup after loading the view.
        
        // lets me toggle the appearance of the attachments button
        //        self.inputToolbar!.contentView!.leftBarButtonItem = nil
        
        // hides bar at the bottom
        //        self.inputToolbar!.hidden = true
        
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        
        //        // AFNetworking example
        //        var manager = AFHTTPRequestOperationManager()
        //        manager.GET(("[URL to send]" as NSString), parameters: ["from":"SpiKe", "to":"[phone number]", "message": text], success: {
        //            (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
        self.messages.append(message)
        self.finishSendingMessage()
        //            println(responseObject)
        //            }, failure: {
        //                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        //
        //        })
        print(message.senderId)
        print(message.senderDisplayName)
        print(message.text);
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        let message = JSQMessage(senderId: "1234", senderDisplayName: "app", date: NSDate(), text: "who goes there?")
        self.messages.append(message)
        self.finishSendingMessage()
        print(message.senderId)
        print(message.senderDisplayName)
        print(message.text);
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return self.messages[indexPath.row]
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let msg = self.messages[indexPath.row]
        if(msg.senderId == self.senderId){
            return self.outgoingBubble
        }else{
            return self.incomingBubble
        }
    }
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message: JSQMessage = self.messages[indexPath.item]
        let initials: String!
        
        if(message.senderId == self.senderId){
            initials = "SC"
        } else {
            initials = "LX"
        }
        return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.grayColor(), font: UIFont.systemFontOfSize(20, weight: 5), diameter: 50) // nil
    }
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let msg = self.messages[indexPath.row]
        if(msg.senderId == self.senderId){
            cell.textView!.textColor = UIColor.blackColor()
        }else{
            cell.textView!.textColor = UIColor.whiteColor()
        }
        return cell
    }
    
}
