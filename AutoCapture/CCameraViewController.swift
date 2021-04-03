//
//  CCameraViewController.swift
//  AutoCapture
//
//  Created by Krishna Kushwaha on 12/01/21.
//

import UIKit
import AVFoundation
import AVKit
class CCameraViewController: UIViewController {

    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var imgVBtn: UIButton!
    @IBOutlet weak var view1: UIView!
    var stillImageOutput = AVCapturePhotoOutput()
    var toggle = false
    var captureTime = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let captureSession = AVCaptureSession()
         var previewLayer = AVCaptureVideoPreviewLayer()


          guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {return}
        stillImageOutput = AVCapturePhotoOutput()
        
        if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
            captureSession.addInput(input)
            captureSession.addOutput(stillImageOutput)
//            setupLivePreview()
        }
//          captureSession.addInput(input)
          captureSession.startRunning()

          previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
          previewLayer.frame = view1.frame
          previewLayer.videoGravity = .resizeAspectFill
          view1.layer.addSublayer(previewLayer)
    }


    @IBAction func openPhotoL(_ sender: Any) {
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CCameraViewController : AVCapturePhotoCaptureDelegate {
   
    @IBAction func didTakePhoto(_ sender: Any) {
            
            let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            stillImageOutput.capturePhoto(with: settings, delegate: self)
        }
    
    
    
    @IBAction func toggleFlash(_ sender: Any) {
        if !toggle {
            flashBtn.setBackgroundImage(#imageLiteral(resourceName: "Flash On Icon"), for: .normal)
            toggleTorch(on: true)
            toggle = true
        } else {
            flashBtn.setBackgroundImage(#imageLiteral(resourceName: "Flash Off Icon"), for: .normal)

            toggleTorch(on: false)
            toggle = false

        }
        }

    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        if device.hasTorch {
            do {
                try device.lockForConfiguration()

                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }

                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
//        captureImageView.image = image
        imgVBtn.setBackgroundImage(image, for: .normal)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let screenSize = view1.bounds.size
//            let touchPer = touches.anyObject() as UITouch
            if let touchPoint = touches.first {
                let x = touchPoint.location(in: view1).y / screenSize.height
                let y = touchPoint.location(in: view1).x / screenSize.width
                let focusPoint = CGPoint(x: x, y: y)

                guard let device = AVCaptureDevice.default(for: .video) else { return }
                    do {
                        try device.lockForConfiguration()

                        print("comming here")
                        device.focusPointOfInterest = focusPoint
                        device.focusMode = .continuousAutoFocus
                        device.focusMode = .autoFocus
                        device.focusMode = .locked
                        device.exposurePointOfInterest = focusPoint
                        device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                        
                        //Auto capture
                        let delay = 1.0
                        captureTime.invalidate()
                        captureTime = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(delayedAction), userInfo: nil, repeats: false)
                        
                        
                        
                        device.unlockForConfiguration()
                        
                        
                    }
                    catch {
                        // just ignore
                    }
                }
            
        }
    @objc func delayedAction() {
                                let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                                stillImageOutput.capturePhoto(with: settings, delegate: self)
        //

    }
}
