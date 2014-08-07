//
//  EffectsCell.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/7/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit

class EffectCell : UICollectionViewCell {
	@IBOutlet weak var filteredImage: UIImageView!
	var filteredImageSize : CGSize {
		get {
			return CGSize(width: CGRectGetWidth(self.filteredImage.frame), height: CGRectGetHeight(self.filteredImage.frame))
		}
	}

	
}