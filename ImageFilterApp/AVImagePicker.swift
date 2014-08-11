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
		
		//Capture Session
		var captureSession = AVCaptureSession()
		captureSession.sessionPreset = AVCaptureSessionPresetPhoto
		
		//Set up preview layer
		var layer = self.captureMedia.layer
		var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
		println(self.captureMedia.bounds)
		previewLayer.frame = self.captureMedia.bounds
		self.view.layer.addSublayer(previewLayer)
		
		//Set up input device
		var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
		var error : NSError?
		var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput!
		
		if error != nil {
			println("There's been an error:")
			println("\(error)")
		} else {
			captureSession.addInput(input)
			
			//create output
			var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
			self.stillImageOutput.outputSettings = outputSettings
			captureSession.addOutput(self.stillImageOutput)
			captureSession.startRunning()
			
		}
	}

//MARK: IBAction
	@IBAction func takePicture(sender: AnyObject) {
		var videoConnection : AVCaptureConnection?
		
		for connection in self.stillImageOutput.connections {
			if let cameraConnection = connection as? AVCaptureConnection {
				for port in cameraConnection.inputPorts {
					if let videoPort = port as? AVCaptureInputPort {
						if videoPort.mediaType == AVMediaTypeVideo {
							videoConnection = cameraConnection
						}
					}
				}
			}
		}
		
		self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
			(buffer : CMSampleBuffer!, error : NSError!) -> Void in
			if error != nil {
				
			} else {
				//To Handle Metadata.
				//if let dict = CMGetAttachment(buffer, kCGImagePropertyExifAuxDictionary, nil) as Unmanaged<CFDictionaryRef> {
				//}
				
				var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
				var image = UIImage(data: data)
				NSOperationQueue.mainQueue().addOperationWithBlock({
					() -> Void in
					self.sampleImage.image = image
				})
			}
		})
	}
	
}



