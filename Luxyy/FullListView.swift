//
//  FullListViewController.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Parse

protocol fullListDelegate{
    func dismissFullList()
    func getList() -> [PFObject]?
}

class FullListView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var delegate:fullListDelegate!
    var list: [PFObject]!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    func setUp() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let cellWidth = self.frame.width / 2 - 15
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        list = delegate.getList()
        
        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(PlayListCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        self.addSubview(collectionView)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PlayListCollectionViewCell
        cell.backgroundColor = UIColor.lightGrayColor()

        if indexPath.item == 0 {
            cell.label.text = "Back"
        } else if indexPath.item == 1 {
            cell.label.text = "Filter"
        } else {
            if list != nil {
                let result = list[indexPath.item - 2] as PFObject
                
                let itemID = result.objectForKey("item")!.objectId
                
                let actualItem = PFQuery(className: "Item")
                actualItem.whereKey("objectId", equalTo: itemID!!)
                do {
                    let actualResult = try actualItem.findObjects()
                    let imageFile:PFFile = actualResult[0].objectForKey("image")! as! PFFile
                    let imageData = try imageFile.getData()
                    print("got image data")
                    cell.imageView.image = UIImage(data: imageData)
                } catch {
                    print(error)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("tapped cell \(indexPath.item + 1)")
        if indexPath.item == 0 {
            delegate.dismissFullList()
        }
    }
}