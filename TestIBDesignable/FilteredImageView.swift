
//
//  FilteredImageView.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/10/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit

@IBDesignable class FilteredImageView : UIImageView {
	
	var filterKeys = ["Sepia":"CISepiaTone", "Gaussian":"CIGaussianBlur", "Vibrant":"CIVibrance", "Posterize":"CIColorPosterize", "Noir":"CIPhotoEffectNoir"]
	var vibranceFilter = CIFilter(name: "CIVibrance")
	var gaussianFilter = CIFilter(name: "CIGaussianBlur")
	var sepiaFilter = CIFilter(name: "CISepiaTone")
	var posterizeFilter = CIFilter(name: "CIColorPosterize")

	
	@IBInspectable var sepiaIntensity : CGFloat = 1.0 {
		didSet {
			sepiaFilter.setValue(self.coreImageBackedImage(), forKey: kCIInputImageKey)
			sepiaFilter.setValue(sepiaIntensity, forKey: kCIInputIntensityKey)
			self.image = UIImage(CIImage: sepiaFilter.outputImage)
		}
	}
	
	@IBInspectable var vibranceInputAmount : CGFloat = 1.0 {
		didSet {
			vibranceFilter.setValue(self.coreImageBackedImage(), forKey: kCIInputImageKey)
			self.image = UIImage(CIImage: vibranceFilter.outputImage)
		}
	}
	
	func coreImageBackedImage() -> CIImage {
		let ciImage = CIImage(CGImage: self.image.CGImage)
		return ciImage
	}
	
	
}
