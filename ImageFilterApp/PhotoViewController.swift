//
//  PhotoViewController.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/5/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UICollectionViewDataSource {

	@IBOutlet weak var photoCollectionView: UICollectionView!
	
//MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
//MARK: UICollectionViewDataSource
	func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoLibraryCell", forIndexPath: indexPath) as UICollectionViewCell
		cell.backgroundColor = UIColor.blueColor()
		
		return cell
	}
	func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
		return 20
	}
}
