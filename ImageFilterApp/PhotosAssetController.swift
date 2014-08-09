//
//  PhotosAssetController.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/7/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit
import Photos

protocol PhotoAssetDelegate {
	func setAsset(asset: PHAsset)
}

protocol PhotoAssetDataSource {
	func setAsset(asset: PHAsset)
}

class PhotosAssetController {
	var delegate : PhotoAssetDelegate?
	var selectedAsset : PHAsset?
//	var fetchResults : PHFetchResult?
	
	init(){}
	

	
//MARK: PHPhotoLibraryChangeObserver
	func photoLibraryDidChange(changeInstance: PHChange!) {
		NSOperationQueue.mainQueue().addOperationWithBlock {
			() -> Void in
			if self.selectedAsset != nil {
				var changeDetails = changeInstance.changeDetailsForObject(self.selectedAsset)
				if changeDetails != nil {
					self.selectedAsset = changeDetails.objectAfterChanges as? PHAsset
					if changeDetails.assetContentChanged {
//						self.photoConfirmed(self.selectedAsset)
					}
				}
			}
		}
	}
}