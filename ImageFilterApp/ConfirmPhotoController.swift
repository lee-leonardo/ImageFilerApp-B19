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

class ConfirmPhotoController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

	@IBOutlet weak var confirmImageView: UIImageView!
	@IBOutlet weak var filterCollectionView: UICollectionView!
	
	let adjustmentFormatterIdentifier = "com.imageFilterAppDemo.cf"
	let adjustmentFormatVersion = "1.0"
	var context = CIContext(options: nil)
	
	var asset : PHAsset!
	var delegate : ConfirmPhotoDelegate?
	
//MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		filterCollectionView.backgroundColor = UIColor.lightGrayColor()
		var targetSize = CGSize(width: CGRectGetWidth(self.confirmImageView.frame), height: CGRectGetHeight(self.confirmImageView.frame))
		PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil)  {
			(image: UIImage!, [NSObject : AnyObject]!) -> Void in
			self.confirmImageView.image = image
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
//MARK: IBAction
	@IBAction func confirmAction(sender: AnyObject) {
		self.delegate!.photoConfirmed(self.asset)
		self.navigationController.popToRootViewControllerAnimated(true)
		
	}
	
//MARK: UICollectionViewDatasource
	func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
		return filterKeys.count
	}
	func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier("SelectFilterCell", forIndexPath: indexPath) as EffectCell
		cell.filterLabel.text = self.filterKeys[indexPath.item]
		
//		Cache this and top not run filter every time.
		PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: cell.filteredImageSize, contentMode: PHImageContentMode.AspectFill, options: nil) {
			(previewImage: UIImage!, object: [NSObject : AnyObject]!) -> Void in
			
			var ciImage = CIImage(image: previewImage)
			var filter = CIFilter(name: self.filterKeys[indexPath.item])
			filter.setDefaults()
			filter.setValue(ciImage, forKey: kCIInputImageKey)
			let outputImage = filter.outputImage
			//let cgImage = self.context.createCGImage(outputImage, fromRect: outputImage.extent())

			
			NSOperationQueue.mainQueue().addOperationWithBlock({
				() -> Void in
				cell.filteredImage.image = UIImage(CIImage: outputImage)
			})
		}
		
		return cell
		
	}
	
//MARK: UICollectionViewDelegate
	func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
		var options = PHContentEditingInputRequestOptions()
		options.canHandleAdjustmentData = {
			(data: PHAdjustmentData!) -> Bool in
			
			return data.formatIdentifier == self.adjustmentFormatterIdentifier && data.formatVersion == self.adjustmentFormatVersion
		}
		
		var selectedFilter = filterKeys[indexPath.item]
		
		self.asset!.requestContentEditingInputWithOptions(options, completionHandler: { (contentEditingInput: PHContentEditingInput!, info: [NSObject : AnyObject]!) -> Void in
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
//			let adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: self.adjustmentFormatVersion, data: jpegData)
			
			
			//What Kirby did, gotta implement this for real in code.
			let filterInfo = NSDictionary(object: "CISepiaTone", forKey: "filter")
			let saveFilter = NSKeyedArchiver.archivedDataWithRootObject(filterInfo)
//			let saveFilter = NSKeyedArchiver(forWritingWithMutableData: filterInfo)
			let adjustmentData = PHAdjustmentData(formatIdentifier: self.adjustmentFormatterIdentifier, formatVersion: self.adjustmentFormatVersion, data: saveFilter)
			
			//Gets the contentEditingInput from the completion handler.
			var contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
			jpegData.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)
			contentEditingOutput.adjustmentData = adjustmentData
			
			PHPhotoLibrary.sharedPhotoLibrary().performChanges({
				var request = PHAssetChangeRequest(forAsset: self.asset)
				request.contentEditingOutput = contentEditingOutput
				
				}, completionHandler: { (success: Bool, error: NSError!) -> Void in
					if !success {
						println("ImageFilterApp Error in PHPhotoLibrary.sharedPhotoLibrary().performChanges:\n\(error)")
					} else {
						var targetSize = CGSize(width: CGRectGetWidth(self.confirmImageView.frame), height: CGRectGetHeight(self.confirmImageView.frame))
						PHImageManager.defaultManager().requestImageForAsset(self.asset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: nil)  {
							(image: UIImage!, [NSObject : AnyObject]!) -> Void in
							self.confirmImageView.image = image
						}
					}
			})
		})
	}
	
	
	
//TEMP: This is where my stuff for the filtered images are for the time being...
	var filterKeys = ["CISepiaTone", "CIGaussianBlur", "CIVibrance", "CIColorPosterize", "CIPhotoEffectNoir"]
	
}


/*
*/
