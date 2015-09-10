//
//  PreviewViewController.swift
//  nobishiro
//
//  Created by akaimo on 2015/09/09.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

import UIKit
import Haneke
import Himotoki
import Alamofire

class PreviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    @IBOutlet weak var postBtn: UIBarButtonItem!
    @IBOutlet weak var postTableView: UITableView!
    internal var imgArray: [Int]!
    internal var materials: [Material]!
    private var postTitle = ""
    private let maxLength = 20
    private var previousText = ""
    private var lastReplaceRange: NSRange!
    private var lastReplacementString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "タイトル"
        self.postTableView.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
        
        postTableView.registerNib(UINib(nibName: "PostingTableViewCell", bundle: nil), forCellReuseIdentifier: "Posting")
        postTableView.registerNib(UINib(nibName: "TopPostingTableViewCell", bundle: nil), forCellReuseIdentifier: "TopPosting")
        postTableView.registerNib(UINib(nibName: "BottomTableViewCell", bundle: nil), forCellReuseIdentifier: "BottomPosting")
        postTableView.registerNib(UINib(nibName: "PostingTitleCustomCell", bundle: nil), forCellReuseIdentifier: "Title")
        
        let backgroundImg = UIImage(named: "background")
        postTableView.backgroundView = UIImageView(image: backgroundImg)
        
        postBtn.enabled = false

        println(materials)
        println(imgArray)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
    // MARK: - UITableViewDelegate Protocol
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.imgArray.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 75
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                return 177
            } else if indexPath.row == imgArray.count - 1 {
                return 177
            } else {
                return 152
            }
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = postTableView.dequeueReusableCellWithIdentifier("Title") as! PostingTitleCustomCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.titleTextView.delegate = self
            cell.titleTextView.becomeFirstResponder()
            cell.titleBackgroundView.layer.borderColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1).CGColor
            cell.titleBackgroundView.layer.borderWidth = 1
            cell.backgroundColor = UIColor.clearColor()
            
            return cell
            
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = postTableView.dequeueReusableCellWithIdentifier("TopPosting") as! TopPostingTableViewCell
                let material = materials[imgArray[indexPath.row] - 1]
                cell.postingImageView.hnk_setImageFromURL(NSURL(string: material.url)!)
                
                cell.deleteBtn.hidden = true
                cell.postingImageView.tag = indexPath.row
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.backgroundColor = UIColor.clearColor()
                
                return cell
            } else if indexPath.row == imgArray.count - 1 {
                let cell = postTableView.dequeueReusableCellWithIdentifier("BottomPosting") as! BottomTableViewCell
                let material = materials[imgArray[indexPath.row] - 1]
                cell.postingImageView.hnk_setImageFromURL(NSURL(string: material.url)!)
                
                cell.deleteBtn.hidden = true
                cell.postingImageView.tag = indexPath.row
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.backgroundColor = UIColor.clearColor()
                
                return cell
            } else {
                let cell = postTableView.dequeueReusableCellWithIdentifier("Posting") as! PostingTableViewCell
                let material = materials[imgArray[indexPath.row] - 1]
                cell.postingImageView.hnk_setImageFromURL(NSURL(string: material.url)!)
                
                cell.deleteBtn.hidden = true
                cell.postingImageView.tag = indexPath.row
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.backgroundColor = UIColor.clearColor()
                
                return cell
            }
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        titleCheck()
    }
    
    
    
    // MARK: - UITextFieldDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "タイトルを入力してね！" {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        self.postTitle = textView.text
        titleCheck()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.postTitle = textView.text
        if textView.text == "" {
            textView.text = "タイトルを入力してね！"
            textView.textColor = UIColor.lightGrayColor()
        }
        titleCheck()
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.markedTextRange != nil {
            return
        }
        
        if count(textView.text) > maxLength {
            var offset = maxLength - count(textView.text)
            var replacementString = (lastReplacementString as NSString).substringToIndex(count(lastReplacementString) + offset)
            var text = (previousText as NSString).stringByReplacingCharactersInRange(lastReplaceRange, withString: replacementString)
            var position = textView.positionFromPosition(textView.selectedTextRange!.start, offset: offset)
            var selectedTextRange = textView.textRangeFromPosition(position, toPosition: position)
            
            textView.text = text
            textView.selectedTextRange = selectedTextRange
        }
        
        self.postTitle = textView.text
        titleCheck()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.previousText = textView.text
        self.lastReplaceRange = range
        self.lastReplacementString = text
        
        return true
    }
    
    
    // MARK: -
    func titleCheck() {
        let str = postTitle.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let sstr = str.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        if postTitle.isEmpty || sstr.isEmpty {
            postBtn.enabled = false
        } else {
            postBtn.enabled = true
        }
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

    @IBAction func tapPostBtn(sender: AnyObject) {
        self.view.endEditing(true)
        
        if postTitle == "" {
            println("タイトルが入力されていない")
            return
        }
        
        var userID: AnyObject!
        let ud = NSUserDefaults.standardUserDefaults()
        userID = ud.objectForKey("userID")
        
        if userID == nil {
            println("--- uiseID = nil ---")
            return
        }
    
        let parameters: [String: AnyObject] = [
            "title": postTitle,
            "user_id": userID,
            "materials": self.imgArray
        ]
        Alamofire.request(.POST, "http://yuji.website:3001/api/work", parameters: parameters, encoding: .JSON).responseJSON{ request, response, JSON, error in
            println(request)
            println(response)
            println(JSON)
            println(error)
        }

        self.dismissViewControllerAnimated(true, completion: nil)

        let notification = NSNotification(name: "ShowNew", object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
}
