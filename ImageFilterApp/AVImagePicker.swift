//
//  AVImagePicker.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/10/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit
import AVFoundation
import CoreVideo
import ImageIO
import QuartzCore
import CoreMedia

class AVImagePicker: UIViewController {
	
	//This allows AVFoundation to output a still image with metadata.
	var stillImageOutput = AVCaptureStillImageOutput()
	
	@IBOutlet weak var captureMedia: UIView!
	@IBOutlet weak var sampleImage: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

//MARK: IBAction
	@IBAction func takePicture(sender: AnyObject) {
	}
}