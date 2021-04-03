//
//  ViewController.swift
//  AutoCapture
//
//  Created by Krishna Kushwaha on 11/01/21.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {

    
    var captureSession = AVCaptureSession()
    var stillImageOutput = AVCapturePhotoOutput()
    var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    var  myView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            // Setup your camera here...
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = .medium
            guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
                else {
                    print("Unable to access back camera!")
                    return
            }

            do {
                let input = try AVCaptureDeviceInput(device: backCamera)
                //Step 9
                stillImageOutput = AVCapturePhotoOutput()

                if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                    captureSession.addInput(input)
                    captureSession.addOutput(stillImageOutput)
                    setupLivePreview()
                }
            }
            catch let error  {
                print("Error Unable to initialize back camera:  \(error.localizedDescription)")
            }

        }
    func setupLivePreview() {

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

            videoPreviewLayer.videoGravity = .resizeAspect
            videoPreviewLayer.connection?.videoOrientation = .portrait
            self.view.layer.addSublayer(videoPreviewLayer)

            //Step12
            //Add preview layer for drawing
            let previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
            previewLayer.frame = self.view.layer.frame
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.view.layer.addSublayer(previewLayer)
            //Add Rectangle
            let cgRect = CGRect(x: 100, y:200, width: 300, height:200)
            myView.frame = cgRect
            myView.backgroundColor = UIColor.clear
            myView.isOpaque = false
            myView.layer.cornerRadius = 10
            myView.layer.borderColor =  UIColor.lightGray.cgColor
            myView.layer.borderWidth = 3
            myView.layer.masksToBounds = true
            previewLayer.addSublayer(myView.layer)
            // Bring the camera button to front
            DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
                self.captureSession.startRunning()
                //Step 13
            }

    //        DispatchQueue.main.async {
    //            self.videoPreviewLayer.frame = self.previewView.bounds
    //        }
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

            guard let imageData = photo.fileDataRepresentation()
                else { return }

            let image = UIImage(data: imageData)
            print(image)
//            self.name.image = image
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            self.captureSession.stopRunning()
        }

}

