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

class PostingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIApplicationDelegate {
    @IBOutlet weak var postBtn: UIBarButtonItem!
    @IBOutlet weak var postingTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var postingTableView: UITableView!
    var postingCollectionView: PostCollectionView!
    
    private var imgCount: Int = 0
    private var imgArray: [Int?] = [nil, nil, nil, nil]
    private var focusNum: Int? = nil
    private var postTitle: String = ""
    private var animat = false
    private var collectionOriginY: CGFloat = 0.0
    private var materials: [Material] = [] {
        didSet {
            postingCollectionView.postCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = false

        postingTableView.registerNib(UINib(nibName: "PostingTableViewCell", bundle: nil), forCellReuseIdentifier: "Posting")
        
        postingCollectionView = PostCollectionView.instance()
        postingCollectionView.postCollectionView.dataSource = self
        postingCollectionView.postCollectionView.delegate = self
        postingCollectionView.postCollectionView.registerNib(UINib(nibName: "PostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Stamp")
        postingCollectionView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 230)
        self.view.addSubview(postingCollectionView)
        
        postBtn.enabled = false
        
        collectionOriginY = self.postingCollectionView.frame.origin.y
        
        loadMaterials()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - UITableViewDelegate Protocol
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = postingTableView.dequeueReusableCellWithIdentifier("Posting") as! PostingTableViewCell
        if let count = imgArray[indexPath.row] {
            let material = materials[imgArray[indexPath.row]!]
            cell.postingImageView.hnk_setImageFromURL(NSURL(string: material.url)!)
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: "tapDelete:", forControlEvents:.TouchUpInside)
            cell.deleteBtn.hidden = false
        } else {
            switch indexPath.row {
            case 0, 1:
                cell.postingImageView.image = UIImage(named: "Image")
            case 2, 3:
                cell.postingImageView.image = UIImage(named: "Image2")
            default:
                cell.postingImageView.image = UIImage(named: "Image2")
            }
            cell.deleteBtn.hidden = true
        }
        
        if focusNum != nil && focusNum! == indexPath.row {
            cell.postingImageView.layer.borderColor = UIColor(red: 247/255, green: 152/255, blue: 0/255, alpha: 1).CGColor
            cell.postingImageView.layer.borderWidth = 2
        } else {
            cell.postingImageView.layer.borderWidth = 0
        }
        
        cell.postingImageView.tag = indexPath.row
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        let gesture = UITapGestureRecognizer(target:self, action: "didClickImageView:")
        cell.postingImageView.addGestureRecognizer(gesture)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        closeCollection()
        postCheck()
        focusNum = nil
        self.postingTableView.reloadData()
    }
    
    
    
    // MARK: -
    // 画像がタップされたとき
    func didClickImageView(recognizer: UIGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            imgCount = imageView.tag
            
            if !animat {
                openCollection()
            }
            
            focusNum = imgCount
            self.postingTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: imgCount, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            self.postingTableView.reloadData()
        }
    }
    
    // stampを読み込む
    func loadMaterials() {
        let cache = Cache<JSON>(name: "materials")
        let URL = NSURL(string: "http://yuji.website:3001/api/material")!
        
        cache.fetch(URL: URL).onSuccess{ JSON in
            if let json = JSON.dictionary, materialData: MaterialsData = decode(json) {
                self.materials = materialData.data
//                println("data:\(materialData.data)")
                println("error:\(materialData.error)")
            } else {
                println("can't decode")
            }
        }.onFailure{Failer in
            println(Failer)
        }
    }

    // collectionViewを出す
    func openCollection() {
        self.postingTableViewHeight.constant = 230
        self.postingCollectionView.frame.origin.y = self.collectionOriginY
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.postingCollectionView.frame.origin.y -= self.postingCollectionView.frame.height
            self.postingTableView.layoutIfNeeded()
        })
        animat = true
    }
    
    // collectionViewを隠す
    func closeCollection() {
        self.postingTableViewHeight.constant = 0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.postingCollectionView.frame.origin.y += self.postingCollectionView.frame.height
            self.postingTableView.layoutIfNeeded()
        })
        animat = false
    }
    
    func postCheck() {
        if imgArray[0] != nil && imgArray[1] != nil {
           postBtn.enabled = true
        } else {
            postBtn.enabled = false
        }
    }
    
    // 画像の削除ボタンをタップ
    func tapDelete(sender: AnyObject) {
        imgArray[sender.tag] = nil
        self.postingTableView.reloadData()
        postCheck()
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
            // 4つ目を選択したとき
            imgCount = 0
            focusNum = nil
            closeCollection()
            self.postingTableView.reloadData()
        } else {
            // 1~3つ目を選択したとき
            imgCount += 1
            focusNum = imgCount
            self.postingTableView.reloadData()
            self.postingTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: imgCount, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
        
        postCheck()
    }
    
    
    // MARK: -
    @IBAction func tapPostingBtn(sender: AnyObject) {
        if imgArray[0] == nil || imgArray[1] == nil {
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
        
        let previewVC: PreviewViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PreviewVC") as! PreviewViewController
        previewVC.imgArray = postMaterial
        previewVC.materials = self.materials
        self.navigationController?.pushViewController(previewVC, animated: true)
    }

    @IBAction func backBtnTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
