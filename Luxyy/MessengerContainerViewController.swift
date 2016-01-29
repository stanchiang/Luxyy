//
//  MessengerContainerViewController.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Parse

class MessengerContainerViewController: UIViewController, conversationDelegate, messagesDelegate {

    var convoList:ConversationListViewController!
    var messenger:MessagesViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PFUser.currentUser()?.objectId == "E0u5zMTSEW" ? showConvoList() : showMessenger("")
    }

    func showConvoList(){
        convoList = ConversationListViewController()
        convoList.delegate = self
        addVC(convoList)
    }
    
    func showMessenger(userId:String){
        messenger = MessagesViewController()
        messenger.delegate = self
        messenger.otherUser = userId
        addVC(messenger)
    }
    
    func addVC(vc:UIViewController){
        self.addChildViewController(vc)
        self.view.addSubview(vc.view)
        vc.didMoveToParentViewController(self)
    }
    
    func removeThisChat(chat:MessagesViewController){
        self.willMoveToParentViewController(convoList)
        chat.view.removeFromSuperview()
    }
    
    func switchToThisChat(userId: String) {
        print(userId)
        showMessenger(userId)
    }
    
}