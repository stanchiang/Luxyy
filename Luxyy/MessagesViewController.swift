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
import Parse

class MessagesViewController: JSQMessagesViewController {
    
    var signUpButton: UIButton!
    var logInButton: UIButton!
    
    var messages:[JSQMessage]!
    var incomingBubble:JSQMessagesBubbleImage!
    var outgoingBubble:JSQMessagesBubbleImage!
    
    override func viewDidLayoutSubviews() {
        constrain(view) { view in
            view.edges == view.superview!.edges
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateChat:", name: "updateChat", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissKeyBoard:", name: "dismissKeyBoard", object: nil)
        
        self.senderDisplayName = (PFUser.currentUser()?.username!)!
        self.senderId = (PFUser.currentUser()?.objectId!)!
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor( UIColor.jsq_messageBubbleGreenColor() )
        self.outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor( UIColor.jsq_messageBubbleLightGrayColor())
        // Do any additional setup after loading the view.
        
        // lets me toggle the appearance of the attachments button
        //        self.inputToolbar!.contentView!.leftBarButtonItem = nil
        
        // hides bar at the bottom
        
        
//        showSignUpOptions()
        
        loadMessages()
        
    }
    
    func updateChat(note: NSNotification) {
        print("reloading the page")
        loadMessages()
    }
    
    func dismissKeyBoard(note: NSNotification) {
        self.inputToolbar?.contentView?.textView?.resignFirstResponder()
    }
    
    func loadMessages() {
        
        messages = []
        
        let query = PFQuery(className: "Message")
        let groupId: String!
        
        if (PFUser.currentUser()?.objectId!)! == "E0u5zMTSEW" {
            groupId = "E0u5zMTSEWjHCAZoBM2M"
        } else {
            groupId = "E0u5zMTSEW\((PFUser.currentUser()?.objectId!)!)"
        }
        
        print(groupId)
        query.whereKey("groupId", equalTo: groupId)
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            guard let objects = objects else{
                print("error: \(error)")
                return
            }
            
            print(objects.count)
            
            for object in objects {
                let senderID = (object.objectForKey("user")?.objectId)!
                let text = object.objectForKey("text") as! String
                self.messages.append(JSQMessage(senderId: senderID, displayName: "name", text: text))
                self.finishSendingMessage()
            }
        }
    }
    
    func showSignUpOptions() {
        
        signUpButton = UIButton()
        signUpButton.backgroundColor = UIColor.blueColor()
        signUpButton.setTitle("Sign Up", forState: UIControlState.Normal)
        signUpButton.addTarget(self, action: "signUp:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(signUpButton)
        
        constrain(signUpButton) { button in
            button.bottom == button.superview!.bottom
            button.height == (inputToolbar?.frame.height)!
            button.leading == button.superview!.leading
            button.width == button.superview!.width / 2
        }
        
        logInButton = UIButton()
        logInButton.backgroundColor = UIColor.greenColor()
        logInButton.setTitle("Log In", forState: UIControlState.Normal)
        logInButton.addTarget(self, action: "logIn:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(logInButton)
        
        constrain(logInButton, signUpButton) { button, button2 in
            button.bottom == button.superview!.bottom
            button.height == (inputToolbar?.frame.height)!
            button.leading == button2.trailing
            button.width == button.superview!.width / 2
        }
    }
    
    func signUp(sender: UIButton){
        print("sign up")
    }
    
    func logIn(sender: UIButton){
        print("logging in")
        
        signUpButton.hidden = true
        logInButton.hidden = true
        
        inputToolbar?.hidden = false
        
        let message = JSQMessage(senderId: "senderID", senderDisplayName: "Luxyy", date: NSDate(), text: "What's your email?")
        self.messages.append(message)
        self.finishSendingMessage()
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {

        guard let currentUser = PFUser.currentUser() else {
            print("no current user")
            return
        }

        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)

        let messageObject = PFObject(className: "Message")
        messageObject["user"] = currentUser

        if (PFUser.currentUser()?.objectId!)! == "E0u5zMTSEW" {
            messageObject["groupId"] = "E0u5zMTSEWjHCAZoBM2M"
        } else {
            messageObject["groupId"] = "E0u5zMTSEW\((PFUser.currentUser()?.objectId!)!)"
        }
        
        messageObject["text"] = text
        messageObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            self.messages.append(message)
            self.finishSendingMessage()
            
//            let findLuxyy = PFQuery(className: "User")
//            let luxyyUser:PFUser!
//            
//            findLuxyy.whereKey("objectId", equalTo: "E0u5zMTSEW")
//            do{
//                luxyyUser = try findLuxyy.findObjects().first as! PFUser
//                
//                let data = ["alert":"hello there","sound":"chime.aiff", "content":"hello there!"]
//                let pushQuery = PFInstallation.query()
//                pushQuery?.whereKey("user", equalTo: luxyyUser)
//                
//                let push = PFPush()
//                push.setQuery(pushQuery)
//                push.setData(data)
//                push.sendPushInBackground()
//            } catch {
//                print(error)
//            }
//            
            
            
        }
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
//        let message: JSQMessage = self.messages[indexPath.item]
//        let initials: String!
//        
//        if(message.senderId == self.senderId){
//            initials = "SC"
//        } else {
//            initials = "LX"
//        }
//        return JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: UIColor.lightGrayColor(), textColor: UIColor.grayColor(), font: UIFont.systemFontOfSize(20, weight: 5), diameter: 50)
        return nil
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
