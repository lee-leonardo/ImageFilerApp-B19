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

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPhotoLibraryChangeObserver, ConfirmPhotoDelegate {
                            
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var actionButton: UIBarButtonItem!
	var cameraPicker = UIImagePickerController()
	//var photoPicker = UIImagePickerController()
	var imageActionSheet = UIAlertController()
	
	let photoAssetController = PhotosAssetController()
	
	var imageAsset : PHAsset!
	let adjustmentFormatterIdentifier = "com.imageFilterAppDemo.cf"
	let adjustmentFormatVersion = "1.0"
	var context = CIContext(options: nil)
	
//MARK: IBAction Buttons
	@IBAction func actionSheet(sender: AnyObject) {
		//Checks to see if device is a iPad, else will go with the method
		if self.imageActionSheet.popoverPresentationController != nil {
			self.imageActionSheet.popoverPresentationController.barButtonItem = sender as UIBarButtonItem
		}
		self.presentViewController(imageActionSheet, animated: true, completion: nil)

	}
	
	@IBAction func imageEffectsActionSheet(sender: AnyObject) {
		//println("RootVC: Image Effects Action Sheet Fired!")
		
		if self.imageAsset != nil {
			
			var imageEffectsSheet = UIAlertController(title: "Effects Available", message: "Select the effect you want applied to the photo.", preferredStyle: UIAlertControllerStyle.ActionSheet)
			
			let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
			let sepiaButton = UIAlertAction(title: "Sepia", style: UIAlertActionStyle.Default, handler: {
				(action: UIAlertAction!) -> Void in
				let filterTest = "CISepiaTone"
				self.applyFilter(filterTest)
			})
			let gaussianButton = UIAlertAction(title: "Gaussian Blur", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction!) -> Void in
				let gaussFilter = "CIGaussianBlur"
				self.applyFilter(gaussFilter)
			})
			let vibrant = UIAlertAction(title: "Vibrant", style: UIAlertActionStyle.Default, handler: {
				(action: UIAlertAction!) -> Void in
				let vibrance = "CIVibrance"
				self.applyFilter(vibrance)
			})
			let posterize = UIAlertAction(title: "Posterize", style: UIAlertActionStyle.Default, handler: {
				(action: UIAlertAction!) -> Void in
				let vibrance = "CIColorPosterize"
				self.applyFilter(vibrance)
			})
			let noirButton = UIAlertAction(title: "Noir", style: UIAlertActionStyle.Default, handler: {
				(action: UIAlertAction!) -> Void in
				let noir = "CIPhotoEffectNoir"
				self.applyFilter(noir)
			})
			
			imageEffectsSheet.addAction(cancelButton)
			imageEffectsSheet.addAction(sepiaButton)
			imageEffectsSheet.addAction(gaussianButton)
			imageEffectsSheet.addAction(vibrant)
			imageEffectsSheet.addAction(posterize)
			imageEffectsSheet.addAction(noirButton)
			
			self.presentViewController(imageEffectsSheet, animated: true, completion: nil)
			
		} else {
			var alert = UIAlertController(title: "Nothing to Edit!", message: "This app is designed to edit images. Therefore this application cannot edit when you have not selected anything!", preferredStyle: UIAlertControllerStyle.Alert)
			let okay = UIAlertAction(title: "Sorry...", style: UIAlertActionStyle.Cancel, handler: nil)
			alert.addAction(okay)
			presentViewController(alert, animated: true, completion: nil)
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
			//self.presentViewController(self.photoPicker, animated: true, completion: nil)
			
			self.checkAuthentication({ (status) -> Void in
				if status == PHAuthorizationStatus.Authorized {
					NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
						self.performSegueWithIdentifier("ShowPhotoLibrary", sender: self)
					})
				}
			})
			
			
			//self.performSegueWithIdentifier("ShowPhotoLibrary", sender: self)
						
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

			//self.checkAuthentication({ (status) -> Void inif status == PHAuthorizationStatus.Authorized {}})
		}
	}
//General segue.
//	override func performSegueWithIdentifier(identifier: String!, sender: AnyObject!) {
//		if identifier == "ShowPhotoLibrary" {
//			
//		}
//	}
	
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
	
//MARK: FilterApplicationMethod
	func applyFilter(selectedFilter: String) {
		
		var options = PHContentEditingInputRequestOptions()
		options.canHandleAdjustmentData = {
			(data: PHAdjustmentData!) -> Bool in
			
			return data.formatIdentifier == self.adjustmentFormatterIdentifier && data.formatVersion == self.adjustmentFormatVersion
		}
		
		self.imageAsset!.requestContentEditingInputWithOptions(options, completionHandler: { (contentEditingInput: PHContentEditingInput!, info: [NSObject : AnyObject]!) -> Void in
			//This part 'decomposes' parts of the code by grabbing the url and orientation. From this it pulls a copy of the image and applies the correct orientation (so that our modifications affect the image in the correct way).
			let url = contentEditingInput.fullSizeImageURL
			let orientation = contentEditingInput.fullSizeImageOrientation
			let inputImage = CIImage(contentsOfURL: url)
			inputImage.imageByApplyingOrientation(orientation)
			
			//Init filter, the filter has a CI name. The filter needs to be set to a default before setting specific values. After that sent the inputImage into the filter, the forKey tells the filterto modify the foreground image of the CIImage? After than the output is referenced.
			
			let filter = CIFilter(name: selectedFilter)
			filter.setDefaults()
			filter.setValue(inputImage, forKey: kCIInputImageKey)
			let outputImage = filter.outputImage
			
			//This takes the outputImage and generates a CGImage from the CIImage using the context of the VC. This outputImage's coordinates are translated with it with outputImage.extent(?). The CGImage then is converted into a UIImage object, which then is translated into jpeg data with a resolution.
			let cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
			let finishedImage = UIImage(CGImage: cgImage)
			//				let finishedImage = UIImage(CIImage: outputImage)
			var jpegData = UIImageJPEGRepresentation(finishedImage, 0.5) //Resolution is intensive memory-wise.
			
			//Adjustment data (data from after being modified).
			//This means that the changes we created is going to be saved as adjustmentData that will become metadata for the PHAsset.
			let adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: self.adjustmentFormatVersion, data: jpegData)
			
			//Gets the contentEditingInput from the completion handler.
			var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
			jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
			contentEditingOutput.adjustmentData = adjustmentData
			
			PHPhotoLibrary.sharedPhotoLibrary().performChanges({
				var request = PHAssetChangeRequest(forAsset: self.imageAsset)
				request.contentEditingOutput = contentEditingOutput
				
				}, completionHandler: { (success: Bool, error: NSError!) -> Void in
					if !success {
						println("ImageFilterApp Error in PHPhotoLibrary.sharedPhotoLibrary().performChanges:\n\(error)")
					}
			})
		})
	}
	
//MARK: ConfirmPhotoDelegate
	func photoConfirmed(asset: PHAsset) {
		self.imageAsset = asset
		
		updateImageView()
		
	}
}

