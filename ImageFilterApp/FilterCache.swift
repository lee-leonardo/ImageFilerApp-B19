//
//  FilterCache.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/8/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit
import Photos

class FilterCache {
	var name : String
	var filterKeys = ["Sepia":"CISepiaTone", "Gaussian":"CIGaussianBlur", "Vibrant":"CIVibrance", "Posterize":"CIColorPosterize", "Noir":"CIPhotoEffectNoir"]
	var filter : CIFilter?
	
	init(name: String) {
		self.name = name
		if filterKeys[name] != nil {
			self.filter = CIFilter(name: filterKeys[name])
		}
	}
	
	//Jeff Gayle's create feature
	func createFilterThumbnailFromImage(image: UIImage, completionHandler: (image: UIImage) -> Void) {
		var baseImage = CIImage(image: image)
		var theFilter = CIFilter(name: self.name)
		theFilter.setDefaults()
		theFilter.setValue(baseImage, forKey: kCIInputImageKey)
		
		var filteredImage = theFilter.outputImage
		var finalUImg = UIImage(CIImage: filteredImage)
		
		completionHandler(image: finalUImg)
	}
	
}