//
//  FocusViewController.swift
//  AutoCapture
//
//  Created by Krishna Kushwaha on 13/01/21.
//

import UIKit
import UIKit
import AVFoundation

class FocusViewController: UIViewController, AVCapturePhotoCaptureDelegate {

    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var stillImageOutput = AVCapturePhotoOutput()
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSession.Preset.high

        let devices = AVCaptureDevice.devices()

        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaType.video)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevice.Position.back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        print("Capture device found")
                        beginSession()
                    }
                }
            }
        }

    }
    func updateDeviceSettings(focusValue : Float, isoValue : Float) {
        let error: NSErrorPointer = nil

        if let device = captureDevice {
            do {
                try captureDevice!.lockForConfiguration()

            } catch let error1 as NSError {
//                error.memory = error1
            }

            device.setFocusModeLocked(lensPosition: focusValue, completionHandler: { (time) -> Void in
                    //
                })

                // Adjust the iso to clamp between minIso and maxIso based on the active format
                let minISO = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                let clampedISO = isoValue * (maxISO - minISO) + minISO

            device.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: clampedISO, completionHandler: { (time) -> Void in
                    //
                print("comming here ",time)
//                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
//                self.stillImageOutput.capturePhoto(with: settings, delegate: self)
                })

                device.unlockForConfiguration()

        }
    }

    func touchPercent(touch : UITouch) -> CGPoint {
        // Get the dimensions of the screen in points
        let screenSize = UIScreen.main.bounds.size

        // Create an empty CGPoint object set to 0, 0
        var touchPer = CGPoint.zero

        // Set the x and y values to be the value of the tapped position, divided by the width/height of the screen
        touchPer.x = touch.location(in: self.view).x / screenSize.width
        touchPer.y = touch.location(in: self.view).y / screenSize.height

        // Return the populated CGPoint
        return touchPer
    }

    func focusTo(value : Float) {
        let error: NSErrorPointer = nil


        if let device = captureDevice {
            do {
                try captureDevice!.lockForConfiguration()

            } catch let error1 as NSError {
//                error.memory = error1
            }

            device.setFocusModeLocked(lensPosition: value, completionHandler: { (time) -> Void in
                    //
                print("comming for what ")
                })
                device.unlockForConfiguration()

        }
    }

    let screenWidth = UIScreen.main.bounds.size.width
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      //if let touchPer = touches.first {
        let touchPer = touchPercent( touch: touches.first! as UITouch )
        updateDeviceSettings(focusValue: Float(touchPer.x), isoValue: Float(touchPer.y))


        super.touchesBegan(touches, with:event)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     // if let anyTouch = touches.first {
    let touchPer = touchPercent( touch: touches.first! as UITouch )
       // let touchPercent = anyTouch.locationInView(self.view).x / screenWidth
  //      focusTo(Float(touchPercent))
    updateDeviceSettings(focusValue: Float(touchPer.x), isoValue: Float(touchPer.y))

    }

    func configureDevice() {
          let error: NSErrorPointer = nil
        if let device = captureDevice {
            //device.lockForConfiguration(nil)

            do {
                try captureDevice!.lockForConfiguration()

            } catch let error1 as NSError {
//                error.memory = error1
            }

            device.focusMode = .locked
            device.unlockForConfiguration()
        }

    }

    func beginSession() {
        configureDevice()
        var err : NSError? = nil

        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice!)

        } catch let error as NSError {
            err = error
            deviceInput = nil
        };
        stillImageOutput = AVCapturePhotoOutput()
        
        if captureSession.canAddInput(deviceInput) && captureSession.canAddOutput(stillImageOutput) {
            captureSession.addInput(deviceInput)
            captureSession.addOutput(stillImageOutput)
//            setupLivePreview()
        }

//        captureSession.addInput(deviceInput)

        if err != nil {
            print("error: \(err?.localizedDescription)")
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = self.view.layer.frame
        
        captureSession.startRunning()
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
//        captureImageView.image = image
//        imgVBtn.setBackgroundImage(image, for: .normal)
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {

            let cgimage = image.cgImage!
            let contextImage: UIImage = UIImage(cgImage: cgimage)
            let contextSize: CGSize = contextImage.size
            var posX: CGFloat = 0.0
            var posY: CGFloat = 0.0
            var cgwidth: CGFloat = CGFloat(width)
            var cgheight: CGFloat = CGFloat(height)

            // See what size is longer and create the center off of that
            if contextSize.width > contextSize.height {
                posX = ((contextSize.width - contextSize.height) / 2)
                posY = 0
                cgwidth = contextSize.height
                cgheight = contextSize.height
            } else {
                posX = 0
                posY = ((contextSize.height - contextSize.width) / 2)
                cgwidth = contextSize.width
                cgheight = contextSize.width
            }

            let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

            // Create bitmap image from context using the rect
            let imageRef: CGImage = cgimage.cropping(to: rect)!

            // Create a new image based on the imageRef and rotate back to the original orientation
            let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

            return image
        }
}
