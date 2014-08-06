//
//  PhotoViewController.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/5/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit
import Photos

class PhotoViewController: UIViewController, UICollectionViewDataSource, ConfirmPhotoDelegate {

	@IBOutlet weak var photoCollectionView: UICollectionView!
	var fetchResultAssets : PHFetchResult!
	var photoManager : PHCachingImageManager!
	var assetPhotoSize : CGSize!
	var delegate : ConfirmPhotoDelegate?
	
	
	
//MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
		self.photoManager = PHCachingImageManager()
		
		
    }
	
	override func viewWillAppear(animated: Bool) {
		var scale = UIScreen.mainScreen().scale
		var flowLayout = self.photoCollectionView.collectionViewLayout as UICollectionViewFlowLayout
		var itemSize = flowLayout.itemSize
		assetPhotoSize = CGSize(width: itemSize.width, height: itemSize.height)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
//MARK: Segue
	override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
		if segue.identifier == "PickPhoto" {
			
			var cell = sender as PhotoCell
			var destination = segue.destinationViewController as ConfirmPhotoController
			var indexPath = self.photoCollectionView.indexPathForCell(cell)
			destination.asset = self.fetchResultAssets[indexPath.item] as PHAsset
			destination.delegate = self
			
		}
	}
	
//MARK: UICollectionViewDataSource
	func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoLibraryCell", forIndexPath: indexPath) as PhotoCell
		//cell.backgroundColor = UIColor.blueColor()
		
		var incrementTag = cell.tag + 1
		cell.tag = incrementTag
		
		var asset = self.fetchResultAssets[indexPath.item] as PHAsset
		self.photoManager.requestImageForAsset(asset, targetSize: assetPhotoSize, contentMode: PHImageContentMode.AspectFit, options: nil) {
			(result : UIImage!, [NSObject : AnyObject]!) -> Void in
			
			if cell.tag == incrementTag {
				cell.photoImageView.image = result
			}
		}
		
		return cell
	}
	func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
		return self.fetchResultAssets.count
	}
	
//MARK: ConfirmPhotoDelegate
	func photoConfirmed(asset: PHAsset) {
		self.delegate!.photoConfirmed(asset)
	}
}
