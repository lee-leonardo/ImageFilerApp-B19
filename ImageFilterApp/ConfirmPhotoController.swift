//
//  ConfirmPhotoController.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/5/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit
import Photos

protocol ConfirmPhotoDelegate {
	func photoConfirmed(asset: PHAsset) -> Void
}

class ConfirmPhotoController: UIViewController {

	@IBOutlet weak var confirmImageView: UIImageView!
	var asset : PHAsset!
	var delegate : ConfirmPhotoDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		var targetSize = CGSize(width: CGRectGetWidth(self.confirmImageView.frame), height: CGRectGetHeight(self.confirmImageView.frame))
		PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil)  {
			(image: UIImage!, [NSObject : AnyObject]!) -> Void in
			self.confirmImageView.image = image
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	@IBAction func confirmAction(sender: AnyObject) {
		self.delegate!.photoConfirmed(self.asset)
		self.navigationController.popToRootViewControllerAnimated(true)
		
	}
}
