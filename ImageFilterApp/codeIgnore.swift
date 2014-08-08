//
//  codeIgnore.swift
//  ImageFilterApp
//
//  Created by Leonardo Lee on 8/8/14.
//  Copyright (c) 2014 Leonardo Lee. All rights reserved.
//

import Foundation
import Photos

//This is here until I know I do not need it anymore.
class ignore {
	var imageAsset : PHAsset?
	var adjustmentFormatterIdentifier = "none"
	var adjustmentFormatVersion = "none"
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
			
//			self.presentViewController(imageEffectsSheet, animated: true, completion: nil)
			
		} else {
			var alert = UIAlertController(title: "Nothing to Edit!", message: "This app is designed to edit images. Therefore this application cannot edit when you have not selected anything!", preferredStyle: UIAlertControllerStyle.Alert)
			let okay = UIAlertAction(title: "Sorry...", style: UIAlertActionStyle.Cancel, handler: nil)
			alert.addAction(okay)
//			self.presentViewController(alert, animated: true, completion: nil)
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
//			let cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())
//			let finishedImage = UIImage(CGImage: cgImage)
			//				let finishedImage = UIImage(CIImage: outputImage)
//			var jpegData = UIImageJPEGRepresentation(finishedImage, 0.5) //Resolution is intensive memory-wise.
			
			//Adjustment data (data from after being modified).
			//This means that the changes we created is going to be saved as adjustmentData that will become metadata for the PHAsset.
//			let adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: self.adjustmentFormatVersion, data: jpegData)
			
			//Gets the contentEditingInput from the completion handler.
//			var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
//			jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
			
			
			//Adjustment data is a dictionary, NSData is wide opened due to developer define behavior.
			//We were passing in full data, on the initializer on the PHAdjustmentData
			//Item forkey filter -> to allow the finding of
			
			
			
//			contentEditingOutput.adjustmentData = adjustmentData
			
			PHPhotoLibrary.sharedPhotoLibrary().performChanges({
				var request = PHAssetChangeRequest(forAsset: self.imageAsset)
//				request.contentEditingOutput = contentEditingOutput
				
				}, completionHandler: { (success: Bool, error: NSError!) -> Void in
					if !success {
						println("ImageFilterApp Error in PHPhotoLibrary.sharedPhotoLibrary().performChanges:\n\(error)")
					}
			})
		})
	}
}