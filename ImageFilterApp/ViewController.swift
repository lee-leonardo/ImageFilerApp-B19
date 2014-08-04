//
//  ViewController.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/4/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
                            
	@IBOutlet weak var imageView: UIImageView!
	var cameraPicker = UIImagePickerController()
	var photoPicker = UIImagePickerController()
	var imageActionSheet = UIAlertController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		setupPickers()
		setupActionController()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
//MARK: ViewController Methods
	@IBAction func actionSheet(sender: AnyObject) {
		self.presentViewController(imageActionSheet, animated: true, completion: nil)
		
	}
	
	func setupPickers() {
		self.photoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		self.photoPicker.allowsEditing = true
		self.photoPicker.delegate = self
		
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
			self.cameraPicker.sourceType = UIImagePickerControllerSourceType.Camera
		} else {
			self.cameraPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		}
		self.cameraPicker.allowsEditing = true
		self.cameraPicker.delegate = self
		
	}

	
//MARK: UIImagePickerController
	func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
		var imageReturn = info[UIImagePickerControllerEditedImage] as UIImage
		self.imageView.image = imageReturn
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	func setupActionController() {
		imageActionSheet = UIAlertController(title: "Pick Source", message: "This will allow one to pick a source for the Image", preferredStyle: UIAlertControllerStyle.ActionSheet)
		
		let cameraButton = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {
		(action : UIAlertAction!) -> Void in
		
			if self.cameraPicker.sourceType == UIImagePickerControllerSourceType.Camera {
				self.presentViewController(self.cameraPicker, animated: true, completion: nil)
			} else {
				var noCameraAlert = UIAlertController(title: "No Camera on Device", message: "This device does not have a camera for this app to use.", preferredStyle: UIAlertControllerStyle.Alert)
			let cancel = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
				noCameraAlert.addAction(cancel)
			
			self.presentViewController(noCameraAlert, animated: true, completion: nil)
			}
		
		})
		let photoLibrary = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {
		(action: UIAlertAction!) -> Void in
			self.presentViewController(self.photoPicker, animated: true, completion: nil)
		
		})
		
		let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
		
		imageActionSheet.addAction(photoLibrary)
		imageActionSheet.addAction(cameraButton)
		imageActionSheet.addAction(cancel)
	}
	
//	lazy var imageActionSheet : UIAlertController = {
//		var imageActionSheet = UIAlertController(title: "Pick Source", message: "This will allow one to pick a source for the Image", preferredStyle: UIAlertControllerStyle.ActionSheet)
//		
//		let cameraButton = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: {
//			(action : UIAlertAction!) -> Void in
//			
//			if self.cameraPicker.sourceType == UIImagePickerControllerSourceType.Camera {
//				self.presentViewController(self.cameraPicker, animated: true, completion: nil)
//			} else {
//				var noCameraAlert = UIAlertController(title: "No Camera on Device", message: "This device does not have a camera for this app to use.", preferredStyle: UIAlertControllerStyle.Alert)
//				let cancel = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
//				noCameraAlert.addAction(cancel)
//				
//				self.presentViewController(noCameraAlert, animated: true, completion: nil)
//			}
//			
//			})
//		let photoLibrary = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: {
//			(action: UIAlertAction!) -> Void in
//			self.presentViewController(self.photoPicker, animated: true, completion: nil)
//			
//			})
//		
//		let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil)
//		
//		imageActionSheet.addAction(photoLibrary)
//		imageActionSheet.addAction(cameraButton)
//		imageActionSheet.addAction(cancel)
//		return imageActionSheet
//		}()
}

