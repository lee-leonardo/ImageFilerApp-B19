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
	
}

class PhotosAssetController {
	var photoAsset : PHAsset?
	var delegate : PhotoAssetDelegate?
	
	init(){}
	
	
}
