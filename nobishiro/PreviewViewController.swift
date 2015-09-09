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

class PreviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var postBtn: UIBarButtonItem!
    @IBOutlet weak var postTableView: UITableView!
    internal var imgArray: [Int]!
    internal var materials: [Material]!
    private var postTitle = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.registerNib(UINib(nibName: "PostingTableViewCell", bundle: nil), forCellReuseIdentifier: "Posting")
        postTableView.registerNib(UINib(nibName: "PostingTitleCustomCell", bundle: nil), forCellReuseIdentifier: "Title")
        
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
            return 70
        } else if indexPath.section == 1 {
            return 160
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = postTableView.dequeueReusableCellWithIdentifier("Title") as! PostingTitleCustomCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.titleTextField.delegate = self
            
            return cell
            
        } else if indexPath.section == 1 {
            let cell = postTableView.dequeueReusableCellWithIdentifier("Posting") as! PostingTableViewCell
            let material = materials[imgArray[indexPath.row]]
            cell.postingImageView.hnk_setImageFromURL(NSURL(string: material.url)!)
            
            cell.deleteBtn.hidden = true
            cell.postingImageView.tag = indexPath.row
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        titleCheck()
    }
    
    
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.postTitle = textField.text
        titleCheck()
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        self.postTitle = textField.text
        titleCheck()
        return true
    }
    
    
    
    func titleCheck() {
        if postTitle == "" {
            postBtn.enabled = false
        } else {
            postBtn.enabled = true
        }
    }

    @IBAction func tapPostBtn(sender: AnyObject) {
        println(self.postTitle)
    }
}
