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
import Analytics

protocol messagesDelegate {
    func removeThisChat(chat:MessagesViewController)
}

class MessagesViewController: JSQMessagesViewController {
    
    var signUpButton: UIButton!
    var logInButton: UIButton!
    
    var delegate:messagesDelegate!
    var otherUser:String!
    
    var messages:[JSQMessage]!
    var incomingBubble:JSQMessagesBubbleImage!
    var outgoingBubble:JSQMessagesBubbleImage!
    var botBubble:JSQMessagesBubbleImage!
    
    override func viewDidLayoutSubviews() {
        constrain(view) { view in
            view.edges == view.superview!.edges
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateChat:", name: "updateChat", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadOnboardingMessages:", name: "loadOnboardingMessages", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissKeyBoard:", name: "dismissKeyBoard", object: nil)
        
        self.senderDisplayName = (PFUser.currentUser()?.username!)!
        self.senderId = (PFUser.currentUser()?.objectId!)!
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor( UIColor.jsq_messageBubbleGreenColor() )
        self.outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor( UIColor.jsq_messageBubbleLightGrayColor())
        self.botBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor( UIColor(red: 70/255.0, green: 130/255.0, blue: 180/255.0, alpha: 1.000) )
        // Do any additional setup after loading the view.
        
        // lets me toggle the appearance of the attachments button
        print("\(PFUser.currentUser()?.objectId!) is talking to \(otherUser)")
        
        if PFUser.currentUser()?.objectId != "E0u5zMTSEW" {
            self.inputToolbar!.contentView!.leftBarButtonItem = nil
        }
        
//        showSignUpOptions()
        
        loadMessages()
        
    }
    
    func updateChat(note: NSNotification) {
        print("reloading the page")
        if messages.count > 0 {
            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
        }
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
            groupId = "E0u5zMTSEW\(otherUser)"
        } else {
            groupId = "E0u5zMTSEW\((PFUser.currentUser()?.objectId!)!)"
        }
        
        print("loading this chat: \(groupId)")
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
                print(senderID)
                let text = object.objectForKey("text") as! String
                self.messages.append(JSQMessage(senderId: senderID, displayName: "name", text: text))
                self.finishSendingMessage()
            }
        
            if self.messages.count == 0 {
                print("loading onboarding messages if there haven't been any messages yet")
                self.loadOnboardingMessages()
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
            messageObject["groupId"] = "E0u5zMTSEW\(otherUser)"
        } else {
            messageObject["groupId"] = "E0u5zMTSEW\((PFUser.currentUser()?.objectId!)!)"
        }
        
        messageObject["text"] = text
        messageObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            self.messages.append(message)
            self.finishSendingMessage()
            JSQSystemSoundPlayer.jsq_playMessageSentSound()
            SEGAnalytics.sharedAnalytics().track("message", properties: [text : messageObject.objectForKey("text")!])
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        delegate.removeThisChat(self)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return self.messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let msg = self.messages[indexPath.row]
        print(msg.senderId)
        if(msg.senderId == self.senderId){
            return self.outgoingBubble
        }else{
            return self.botBubble
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
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
    
    func loadOnboardingMessages() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let onboardingMessages:[String] = [
            "Welcome to Luxyy!",
            "I'm Stanley, the developer of this app.",
            "Over time, I hope this app becomes an indespensable tool to help you discover, track, and buy watches",
            "Note: This is an Early Pre-Release Test, so please don't be too mad if there are still some kinks in the product",
            "I highly encourage feedback through either this private chat or directly email me at stanley@getLuxyy.com",
        ]
        
        do {
            
            let findLuxyy = PFUser.query()
            findLuxyy?.whereKey("objectId", equalTo: "E0u5zMTSEW")
            print("going to find luxyy")
            let Luxyy = try findLuxyy!.findObjects()[0]

            for msg in onboardingMessages {
                
                let messageObject = PFObject(className: "Message")
                
                
                messageObject["user"] = Luxyy
                messageObject["groupId"] = "E0u5zMTSEW\((PFUser.currentUser()?.objectId!)!)"
                messageObject["text"] = msg
                
                do {
                    try messageObject.save()
                    self.messages.append(JSQMessage(senderId: "E0u5zMTSEW", senderDisplayName: "Luxyy", date: NSDate(), text: msg))
                    self.finishSendingMessage()
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                } catch {
                    print(error)
                }
            }            
        } catch {
            print(error)
        }
        
        
        appDelegate.unreadMessagesBadge.badgeValue = onboardingMessages.count
        
    }
}
