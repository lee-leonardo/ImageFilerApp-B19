//
//  ViewController.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/4/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ConfirmPhotoDelegate {
                            
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var actionButton: UIBarButtonItem!
	var cameraPicker = UIImagePickerController()
	//var photoPicker = UIImagePickerController()
	var imageActionSheet = UIAlertController()
	
//MARK: IBAction
	@IBAction func actionSheet(sender: AnyObject) {
		self.presentViewController(imageActionSheet, animated: true, completion: nil)
		
	}

//MARK: Viewcontroller
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if NSUserDefaults.standardUserDefaults().boolForKey("notFirstTime") {
			
		} else {
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: "notFirstTime")
			NSOperationQueue.mainQueue().addOperationWithBlock({
				() -> Void in
				self.firstTime()
				})
		}
	}
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		setupPickers()
		setupActionController()
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

//MARK: Setup methods
	func setupPickers() {
		//self.photoPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		//self.photoPicker.allowsEditing = true
		//self.photoPicker.delegate = self
		
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
			self.cameraPicker.sourceType = UIImagePickerControllerSourceType.Camera
		} else {
			//This is the default value of UIImagePickerControllerSourceType.
			self.cameraPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		}
		self.cameraPicker.allowsEditing = true
		self.cameraPicker.delegate = self
		
	}
	
	func firstTime() {
		var assetsLibrary = ALAssetsLibrary()
		if ALAssetsLibrary.authorizationStatus() != ALAuthorizationStatus.Authorized {
			var requireAuthorization = UIAlertController(title: "App Requires Authorization", message: "This application requires permissions to your Photo Library and Camera to function properly.", preferredStyle: UIAlertControllerStyle.Alert)
			let okayButton = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
			requireAuthorization.addAction(okayButton)
			self.presentViewController(requireAuthorization, animated: true, completion: nil)
			
			//If I wanted to ask for permissions, this would probably be the best place to do it. I do not want to ask them for all permissions however... That can be done with:
			//assetsLibrary.enumerateGroupsWithTypes(types: ALAssetsGroupType, usingBlock: ALAssetsLibraryGroupsEnumerationResultsBlock?, failureBlock: ALAssetsLibraryAccessFailureBlock?)
		}
	}
	
//MARK: ActionSheet
	func setupActionController() {
		imageActionSheet = UIAlertController(title: "Pick Source", message: "This will allow one to pick a source for the Image", preferredStyle: UIAlertControllerStyle.ActionSheet)
		//self.imageActionSheet.popoverPresentationController.sourceView = self.actionButton
		//Tool bar is the problem?	
		
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
			//self.presentViewController(self.photoPicker, animated: true, completion: nil)
			
			self.performSegueWithIdentifier("ShowPhotoLibrary", sender: self)
						
			})
		
		let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
		
		imageActionSheet.addAction(photoLibrary)
		imageActionSheet.addAction(cameraButton)
		imageActionSheet.addAction(cancel)
	}
	
//MARK: Segue
	override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
		if segue.identifier == "ShowPhotoLibrary" {
			var destination = segue.destinationViewController as PhotoViewController
			destination.fetchResultAssets = PHAsset.fetchAssetsWithOptions(nil)
			destination.delegate = self
		}
	}
	
//MARK: UIImagePickerController
	func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
		var imageReturn = info[UIImagePickerControllerEditedImage] as UIImage
		self.imageView.image = imageReturn
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
//MARK: ConfirmPhotoDelegate
	func photoConfirmed(asset: PHAsset) {
		var targetSize = CGSize(width: CGRectGetWidth(self.imageView.frame), height: CGRectGetHeight(self.imageView.frame))
		
		PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) {
			(image: UIImage!, [NSObject : AnyObject]!) -> Void in
			self.imageView.image = image
		}
	}


//lazy Instantiation... not polished yet?
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

