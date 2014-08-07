//
//  SimpleCI.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/6/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import Foundation

struct SimpleCI {
	
	struct filter {
		
		struct blur {
			var category: String {
				return "CIBoxBlur"
			}
			var disc = "CIDiscBlur"
			var gaussian = "CIGaussianBlur"
			var media = "CIMedianFilter"
			var motion = "CIMotionBlur"
			var noiseReduction = "CINoiseReduction"
			var zoom = "CIZoomBlur"
		}
	}
	
	struct colorAdjustment {
		
	}
}