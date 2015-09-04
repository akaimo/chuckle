//
//  PostingViewController.swift
//  nobishiro
//
//  Created by akaimo on 2015/09/03.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

import UIKit

class PostingViewController: UIViewController {
    @IBOutlet weak var postingTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        postingTableView.registerNib(UINib(nibName: "PostingTableViewCell", bundle: nil), forCellReuseIdentifier: "Posting")
        postingTableView.allowsSelection = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: PostingTableViewCell
        cell = postingTableView.dequeueReusableCellWithIdentifier("Posting") as! PostingTableViewCell
        cell.postingImageView.image = UIImage(named: "Image")
        cell.postingImageView.tag = indexPath.row
        
        let gesture = UITapGestureRecognizer(target:self, action: "didClickImageView:")
        cell.postingImageView.addGestureRecognizer(gesture)
        
        return cell
    }
    
    
    func didClickImageView(recognizer: UIGestureRecognizer) {
        if let imageView = recognizer.view as? UIImageView {
            // TODO: キーボード的なのを表示
            println(imageView.tag)
        }
    }

}
