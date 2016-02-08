//
//  ConversationListViewController.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/27/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Parse

protocol conversationDelegate {
    func switchToThisChat(userId: String)
}

class ConversationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var delegate: conversationDelegate!
    var tableView: UITableView!
    var convoList = [String]()
    var IDList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //need to get a list of all conversations, put the user ids into an array, use that as the table's datasource and then pass that id when tapped
        
        let conversations = PFUser.query()
        conversations!.whereKey("objectId", notEqualTo: "E0u5zMTSEW")
        conversations!.findObjectsInBackgroundWithBlock { (object, error) -> Void in
            if object != nil && object?.count > 0 {
                for user in object! {
//                    print("we have a userid: \(user.objectId!)")
                    self.convoList.append(user.objectForKey("username") as! String)
                    self.IDList.append(user.objectId!)
                }
                
                self.tableView = UITableView(frame: self.view.bounds)
                self.tableView.dataSource = self
                self.tableView.delegate = self
                self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
                self.tableView.tableFooterView = UIView(frame: CGRect.zero)
                self.view.addSubview(self.tableView)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return convoList.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        let label = UILabel(frame: cell.bounds)
        label.text = "\(convoList[indexPath.item])"
        label.textAlignment = .Center
        cell.addSubview(label)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.item)
        delegate.switchToThisChat(IDList[indexPath.item])
    }
}
