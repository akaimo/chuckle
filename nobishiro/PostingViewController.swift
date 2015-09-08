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

class PostingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var postingTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var postingTableView: UITableView!
    var postingCollectionView: PostCollectionView!
    
    private var imgCount: Int = 0
    private var imgArray: [Int?] = [nil, nil, nil, nil]
    private var postTitle: String = ""
    private var animat = false
    private var materials: [Material] = [] {
        didSet {
            postingCollectionView.postCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = false

        postingTableView.registerNib(UINib(nibName: "PostingTableViewCell", bundle: nil), forCellReuseIdentifier: "Posting")
        postingTableView.registerNib(UINib(nibName: "PostingTitleCustomCell", bundle: nil), forCellReuseIdentifier: "Title")
        postingTableView.allowsSelection = false
        
        postingCollectionView = PostCollectionView.instance()
        postingCollectionView.postCollectionView.dataSource = self
        postingCollectionView.postCollectionView.delegate = self
        postingCollectionView.postCollectionView.registerNib(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Stamp")
        postingCollectionView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 250)
        self.view.addSubview(postingCollectionView)
        
        
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
            cell.postingImageView.tag = indexPath.row - 1
            
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
            imgCount = imageView.tag
            
            collectionAnimation()
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
    
    func collectionAnimation() {
        if !animat {
            self.postingTableViewHeight.constant = 250
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.postingCollectionView.frame.origin.y -= self.postingCollectionView.frame.height
                self.postingTableView.layoutIfNeeded()
            })
            animat = true
        } else {
            self.postingTableViewHeight.constant = 0
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.postingCollectionView.frame.origin.y += self.postingCollectionView.frame.height
                self.postingTableView.layoutIfNeeded()
            })
            animat = false
        }
    }
    
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let material = materials[indexPath.row]
        
        let cell:PostCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Stamp", forIndexPath: indexPath) as! PostCollectionViewCell
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
        imgArray[imgCount] = indexPath.row
        self.postingTableView.reloadData()
        
        if imgCount == 3 {
            imgCount = 0
        } else {
            imgCount += 1
        }
    }
    
    
    @IBAction func tapPostingBtn(sender: AnyObject) {
        if imgArray[0] == nil || imgArray[1] == nil {
            // TODO: ポップアップ
            println("画像が選択されていない")
            return
        }
        
        var postMaterial: [Int] = []
        for num in imgArray {
            if let materialID = num {
                postMaterial.append(materialID + 1)
            }
        }
        println(postMaterial)
        
        var cell: PostingTitleCustomCell = self.postingTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! PostingTitleCustomCell
        postTitle = cell.titleTextField.text
        println("title:\(postTitle)")
        
        // カラ、空白オンリーは弾く
        if postTitle == "" {
            // TODO: ポップアップ
            println("タイトルが入力されていない")
            return
        }
        
        let parameters: [String: AnyObject] = [
            "title": postTitle,
            "materials": postMaterial
        ]
        Alamofire.request(.POST, "http://yuji.website:3001/api/work", parameters: parameters, encoding: .JSON).responseJSON{ request, response, JSON, error in
            println(request)
            println(response)
            println(JSON)
            println(error)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func backBtnTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
