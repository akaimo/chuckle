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
        postingTableView.registerNib(UINib(nibName: "PostingTitleCustomCell", bundle: nil), forCellReuseIdentifier: "Title")
        
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
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.titleTextField.delegate = self
            
            return cell
            
        default:
            let cell = postingTableView.dequeueReusableCellWithIdentifier("Posting") as! PostingTableViewCell
            if let count = imgArray[indexPath.row - 1] {
                let material = materials[imgArray[indexPath.row - 1]!]
                cell.postingImageView.hnk_setImageFromURL(NSURL(string: material.url)!)
                cell.deleteBtn.tag = indexPath.row - 1
                cell.deleteBtn.addTarget(self, action: "tapDelete:", forControlEvents:.TouchUpInside)
                cell.deleteBtn.hidden = false
            } else {
                switch indexPath.row - 1 {
                case 0, 1:
                    cell.postingImageView.image = UIImage(named: "Image")
                case 2, 3:
                    cell.postingImageView.image = UIImage(named: "Image2")
                default:
                    cell.postingImageView.image = UIImage(named: "Image2")
                }
                cell.deleteBtn.hidden = true
            }
            
            if focusNum != nil && focusNum! == (indexPath.row - 1) {
                cell.postingImageView.layer.borderColor = UIColor(red: 247/255, green: 152/255, blue: 0/255, alpha: 1).CGColor
                cell.postingImageView.layer.borderWidth = 2
            } else {
                cell.postingImageView.layer.borderWidth = 0
            }
            
            cell.postingImageView.tag = indexPath.row - 1
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            let gesture = UITapGestureRecognizer(target:self, action: "didClickImageView:")
            cell.postingImageView.addGestureRecognizer(gesture)
            
            return cell
        }
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
            self.postingTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: imgCount + 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
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
    
    // 実機チェック
    func platformName() -> String {
        var size: size_t = 0;
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = UnsafeMutablePointer<CChar>(malloc(size))
        sysctlbyname("hw.machine", machine, &size, nil, 0)
        var platformName = NSString(CString: machine, encoding: NSUTF8StringEncoding)
        free(machine)
        
        return platformName! as String
    }
    
    func postCheck() {
        if imgArray[0] != nil && imgArray[1] != nil && titleCheck() {
           postBtn.enabled = true
        } else {
            postBtn.enabled = false
        }
    }
    
    func titleCheck() -> Bool {
        if postTitle == "" {
            return false
        }
        
        return true
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
    
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.postTitle = textField.text
        postCheck()
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        self.postTitle = textField.text
        postCheck()
        return true
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
        
        // TODO: カラ、空白オンリーは弾く
        if postTitle == "" {
            println("タイトルが入力されていない")
            return
        }
        
        var userID: AnyObject!
        var platform = platformName()
        if platform == "x86_64" {
            // simulator
            userID = 1
        } else {
            // 実機処理
            let ud = NSUserDefaults.standardUserDefaults()
            userID = ud.objectForKey("userID")
        }
        
        println("userID:\(userID)")
        println("title:\(postTitle)")
        
        let parameters: [String: AnyObject] = [
            "title": postTitle,
            "user_id": userID,
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
