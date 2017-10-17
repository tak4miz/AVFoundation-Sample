//
//  CameraViewController.swift
//  AVFoundation-Sample
//
//  Created by ExtYabecchi on 2017/05/15.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    var session = AVCaptureSession()
    var previewImage: UIImage?
    var photoOutput = AVCapturePhotoOutput()
    var videoDataOutput = AVCaptureVideoDataOutput()
    var input: AVCaptureDeviceInput!
    var activeVideoInput: AVCaptureDeviceInput!
    
    lazy var sessionQueue: DispatchQueue = {
        DispatchQueue(label: "zombieges.AVFoundation-Sample", qos: DispatchQoS.default)
    }()
    
    let focusView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        launchCamere()
        setupDisplay()
        setCameraFocusView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        guard session.isRunning else { return }
        
        sessionQueue.async {
            self.session.stopRunning()
            
            for output in self.session.outputs {
                self.session.removeOutput(output as? AVCaptureOutput)
            }
            
            for input in self.session.inputs {
                self.session.removeInput(input as? AVCaptureInput)
            }
        }
        
        focus(tapPoint: self.view.center)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.getString(status: .toPreviewViewController) {
            let dest = segue.destination as! PreviewViewController
            dest.previewImage = previewImage
        }
    }
}

extension CameraViewController: CAAnimationDelegate {
    
    fileprivate func setupDisplay(){
        navigationController?.presentTransparentNavigationBar()
        navigationItem.backBarButtonItem?.title = ""
        
        takePhotoButton.layer.cornerRadius = (previewView.layer.bounds.width / 5) / 2
        takePhotoButton.layer.borderWidth = 7
        takePhotoButton.layer.borderColor = UIColor.white.cgColor
    }
    
    fileprivate func setupCamera() {
        previewView.session = session
        
        guard let camera = AVCaptureDevice.videoDevice() else { return }
        
        let deviceInput = try? AVCaptureDeviceInput(device: camera)
        
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
        
        if self.session.canAddOutput(self.photoOutput) {
            self.session.addOutput(self.photoOutput)
        }
        
        self.session.sessionPreset = AVCaptureSessionPresetHigh
        self.session.startRunning()
        
        do {
            try camera.lockForConfiguration()
            camera.activeVideoMinFrameDuration = CMTimeMake(1, 30)
            camera.unlockForConfiguration()
            
        } catch {
            // error
        }
        
        self.activeVideoInput = deviceInput
    }
    
    func tapOnFocus(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: self.view)
        focus(tapPoint: tapPoint)
    }
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        let captureSetting = AVCapturePhotoSettings()
        captureSetting.isAutoStillImageStabilizationEnabled = true
        captureSetting.isHighResolutionPhotoEnabled = false
        
        photoOutput.capturePhoto(with: captureSetting, delegate: self)
    }

    @IBAction func changeCamera(_ sender: Any) {
        session.beginConfiguration()
        
        let newPosition: AVCaptureDevicePosition =
            activeVideoInput.device.position == .back ? .front : .back
        
        guard let camera = AVCaptureDevice.videoDevice(for: newPosition) else {
            return
        }
        
        session.removeInput(activeVideoInput)
        session.sessionAddInput(with: camera) { [unowned self] result in
            switch result {
            case .success(let deviceInput):
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
                self.activeVideoInput = deviceInput
            case .error: break
            }
        }
        
        session.commitConfiguration()
        
        focus(tapPoint: self.view.center)
    }
    
    fileprivate func focus(tapPoint: CGPoint) {
        focusView.frame.size = CGSize(width: 120, height: 120)
        focusView.layer.cornerRadius = 60
        focusView.center = tapPoint
        focusView.backgroundColor = UIColor.white.withAlphaComponent(0)
        focusView.layer.borderColor = UIColor.white.cgColor
        focusView.layer.borderWidth = 2
        focusView.alpha = 1
        self.view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.3, animations: {
            self.focusView.frame.size = CGSize(width: 80, height: 80)
            self.focusView.layer.cornerRadius = 40
            self.focusView.center = tapPoint
        }, completion: { Void in
            UIView.animate(withDuration: 0.5, animations: {
                self.focusView.alpha = 0
            })
        })
        
        sessionQueue.async {
            self.focusAtPoint(point: tapPoint)
        }
    }
    
    private func focusAtPoint(point: CGPoint) {
        guard let device = activeVideoInput.device else { return }
        
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
            do {
                try device.lockForConfiguration()
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
                device.unlockForConfiguration()
                
            } catch {
                print("error : \(error)")
            }
        }
    }
    
    fileprivate func launchCamere() {
        DispatchQueue.main.async {
            switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
            case .authorized:
                break
            case .notDetermined:
                self.sessionQueue.suspend()
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
                    self.sessionQueue.resume()
                })
            case .denied:
                self.showCamereAlert()
            default:
                break
            }
        }
    }
    
    fileprivate func showCamereAlert() {
        UIAlertController.showAlertOKCancel("", message: "camera", actiontitle: "permission") { action in
            if action == .cancel { return }
            
            if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
}
