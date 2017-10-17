//
//  AVCaptureSession+Extensions.swift
//  AVFoundation-Sample
//
//  Created by ExtYabecchi on 2017/05/25.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import AVFoundation

enum SCCaptureDeviceInputResult {
    case success(AVCaptureDeviceInput)
    case error(NSError)
}

extension AVCaptureSession {
    func sessionAddInput(with device: AVCaptureDevice, completion: ((SCCaptureDeviceInputResult) -> Void)? = nil) {
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if canAddInput(input) {
                addInput(input)
            }
            
            completion?(.success(input))
            
        } catch let error as NSError {
            assertionFailure("Error: \(error.localizedDescription)")
            completion?(.error(error))
        }
    }
}
