//
//  PostingViewController.swift
//  nobishiro
//
//  Created by akaimo on 2015/09/03.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

import UIKit
import Haneke
import Himotoki
import Alamofire

class PostingViewController: UIViewController {
    @IBOutlet weak var postingTableView: UITableView!
    @IBOutlet weak var postingCollectionView: UICollectionView!
    
    private var imgCount: Int = 0
    private var imgArray: [Int?] = [nil, nil, nil, nil]
    private var materials: [Material] = [] {
        didSet {
            postingCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = false

        postingTableView.registerNib(UINib(nibName: "PostingTableViewCell", bundle: nil), forCellReuseIdentifier: "Posting")
        postingTableView.registerNib(UINib(nibName: "PostingTitleCustomCell", bundle: nil), forCellReuseIdentifier: "Title")
        postingTableView.allowsSelection = false
        
        loadMaterials()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewDelegate Protocol
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 70
        default:
            return 160
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = postingTableView.dequeueReusableCellWithIdentifier("Title") as! PostingTitleCustomCell
            
            return cell
            
        default:
            let cell = postingTableView.dequeueReusableCellWithIdentifier("Posting") as! PostingTableViewCell
            if let count = imgArray[indexPath.row - 1] {
                let material = materials[imgArray[indexPath.row - 1]!]
                cell.postingImageView.hnk_setImageFromURL(NSURL(string: material.url)!)
            } else {
                cell.postingImageView.image = UIImage(named: "Image")
            }
            cell.postingImageView.tag = indexPath.row
            
            let gesture = UITapGestureRecognizer(target:self, action: "didClickImageView:")
            cell.postingImageView.addGestureRecognizer(gesture)
            
            return cell
        }
    }
    
    // MARK: -
    func didClickImageView(recognizer: UIGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            // TODO: キーボード的なのを表示
            println(imageView.tag)
        }
    }
    
    func loadMaterials() {
        let cache = Cache<JSON>(name: "materials")
        let URL = NSURL(string: "http://yuji.website:3001/api/material")!
        
        cache.fetch(URL: URL).onSuccess{ JSON in
            if let json = JSON.dictionary, materialData: MaterialsData = decode(json) {
                self.materials = materialData.data
                println("data:\(materialData.data)")
                println("error:\(materialData.error)")
            } else {
                println("can't decode")
            }
        }.onFailure{Failer in
            println(Failer)
        }
    }
    
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let material = materials[indexPath.row]
        
        let cell:PostingCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PostingCollectionViewCell
        cell.stampImageView.hnk_setImageFromURL(NSURL(string: material.url)!)
        cell.backgroundColor = UIColor.blackColor()
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return materials.count;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println(indexPath.row)
        println(imgCount)
        imgArray[imgCount] = indexPath.row
        self.postingTableView.reloadData()
        
        if imgCount == 3 {
            imgCount = 0
        } else {
            imgCount += 1
        }
    }
    
    @IBAction func tapPostingBtn(sender: AnyObject) {
        let parameters: [String: AnyObject] = [
            "title": "hogehogehoge",
            "materials": [3, 2, 1]
        ]
        Alamofire.request(.POST, "http://yuji.website:3001/api/work", parameters: parameters, encoding: .JSON).responseJSON{ request, response, JSON, error in
            println(request)
            println(response)
            println(JSON)
            println(error)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        //self.navigationController?.popViewControllerAnimated(true)
    }

}
