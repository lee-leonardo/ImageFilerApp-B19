//
//  ViewController.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/4/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, PHPhotoLibraryChangeObserver, ConfirmPhotoDelegate {
                            
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var actionButton: UIBarButtonItem!
	var cameraPicker = UIImagePickerController()
//	var imagePicker = UIImagePickerController()
	var imageActionSheet = UIAlertController()
		
	var imageAsset : PHAsset!
	var context = CIContext(options: nil)
	@IBOutlet weak var filterList: UICollectionView!
	
//MARK: IBAction Buttons
	@IBAction func actionSheet(sender: AnyObject) {
		//Checks to see if device is a iPad, else will go with the method
		if self.imageActionSheet.popoverPresentationController != nil {
			self.imageActionSheet.popoverPresentationController.barButtonItem = sender as UIBarButtonItem
		}
		self.presentViewController(imageActionSheet, animated: true, completion: nil)

	}
	
	@IBAction func showShareSheet(sender: AnyObject) {
		if imageView.image != nil {
			var activityItem : [AnyObject] = [imageView.image]
			var shareSheet = UIActivityViewController(activityItems: activityItem, applicationActivities: nil)
			if shareSheet.popoverPresentationController != nil {
				shareSheet.popoverPresentationController.barButtonItem = sender as UIBarButtonItem

			}

			self.presentViewController(shareSheet, animated: true, completion: nil)
			
		} else {
			var noImageview = UIAlertController(title: "Need to Select a Controller", message: "I'm sorry, but this app requires you to have a picture before you can share it.", preferredStyle: UIAlertControllerStyle.Alert)
			var okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
			noImageview.addAction(okay)
			self.presentViewController(noImageview, animated: true, completion: nil)
		}
	}

//MARK: Viewcontroller
	override func viewDidLoad() {
		super.viewDidLoad()
		
		PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self) //With this you need to conform to PHPhotoLibraryChangeObserver
		
		if NSUserDefaults.standardUserDefaults().boolForKey("notFirstTime") == true {
			
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
		filterList.backgroundColor = UIColor.lightGrayColor()
		setupPickers()
		setupActionController()
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
//		var assetsLibrary = ALAssetsLibrary()
//		if ALAssetsLibrary.authorizationStatus() != ALAuthorizationStatus.Authorized {
			var requireAuthorization = UIAlertController(title: "App Requires Authorization", message: "This application requires permissions to your Photo Library and Camera to function properly.", preferredStyle: UIAlertControllerStyle.Alert)
			let okayButton = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
			requireAuthorization.addAction(okayButton)
			self.presentViewController(requireAuthorization, animated: true, completion: nil)
			
			//If I wanted to ask for permissions, this would probably be the best place to do it. I do not want to ask them for all permissions however... That can be done with:
			//assetsLibrary.enumerateGroupsWithTypes(types: ALAssetsGroupType, usingBlock: ALAssetsLibraryGroupsEnumerationResultsBlock?, failureBlock: ALAssetsLibraryAccessFailureBlock?)
//		}
	}
	
	func updateImageView() {
		var targetSize = CGSize(width: CGRectGetWidth(self.imageView.frame), height: CGRectGetHeight(self.imageView.frame))

		PHImageManager.defaultManager().requestImageForAsset(imageAsset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil) {
			(image: UIImage!, [NSObject : AnyObject]!) -> Void in
			
			self.imageView.image = image
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
			
			self.checkAuthentication({ (status) -> Void in
				if status == PHAuthorizationStatus.Authorized {
					NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
						self.performSegueWithIdentifier("ShowPhotoLibrary", sender: self)
					})
				}
			})
//			self.performSegueWithIdentifier("ShowPhotoLibrary", sender: self)
			
			})
		
		let imagePicker = UIAlertAction(title: "Image Picker", style: UIAlertActionStyle.Default) {
			(action: UIAlertAction!) -> Void in
			
			if self.cameraPicker.sourceType == UIImagePickerControllerSourceType.Camera {
				self.presentViewController(self.cameraPicker, animated: true, completion: nil)
			} else {
				var noCameraAlert = UIAlertController(title: "No Camera on Device", message: "This device does not have a camera for this app to use.", preferredStyle: UIAlertControllerStyle.Alert)
				let cancel = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
				noCameraAlert.addAction(cancel)
				
				self.presentViewController(noCameraAlert, animated: true, completion: nil)
			}
		}
		
		let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
		
		imageActionSheet.addAction(photoLibrary)
		imageActionSheet.addAction(cameraButton)
		imageActionSheet.addAction(imagePicker)
		imageActionSheet.addAction(cancel)
		
	}
	
//MARK: Segue
	override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
		if segue.identifier == "ShowPhotoLibrary" {
			var destination = segue.destinationViewController as PhotoViewController
			destination.fetchResultAssets = PHAsset.fetchAssetsWithOptions(nil)
			destination.delegate = self


			//self.checkAuthentication({ (status) -> Void inif status == PHAuthorizationStatus.Authorized {}})
		}
	}
	
//MARK: UIImagePickerController
	func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
		var imageReturn = info[UIImagePickerControllerEditedImage] as UIImage
		self.imageView.image = imageReturn
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
//MARK: PHPhotoLibrary
	func checkAuthentication(completionHandler: (PHAuthorizationStatus) -> Void ) -> Void {
		
		switch PHPhotoLibrary.authorizationStatus() {
		case .NotDetermined:
			//println("Not determined")
			PHPhotoLibrary.requestAuthorization({
				(status : PHAuthorizationStatus) -> Void in
				completionHandler(status)
			})
		default:
			//println("Denied, Restricted or Authorized")
			completionHandler(PHPhotoLibrary.authorizationStatus())
		}
		
	}
	
//MARK: PHPhotoLibraryChangeObserver
	func photoLibraryDidChange(changeInstance: PHChange!) {
		NSOperationQueue.mainQueue().addOperationWithBlock {
			() -> Void in
			if self.imageAsset != nil {
				var changeDetails = changeInstance.changeDetailsForObject(self.imageAsset)
				if changeDetails != nil {
					self.imageAsset = changeDetails.objectAfterChanges as? PHAsset
					if changeDetails.assetContentChanged {
						self.photoConfirmed(self.imageAsset)
					}
				}
			}
		}
	}
	
//MARK: UICollectionViewController
	func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
		return 10
	}
	func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier("SampleFilter", forIndexPath: indexPath) as UICollectionViewCell

		return cell

	}
	
//MARK: ConfirmPhotoDelegate
	func photoConfirmed(asset: PHAsset) {
		self.imageAsset = asset
		
		updateImageView()
		
	}
}

