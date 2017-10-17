//
//  AVCaptureDevice+Extensions.swift
//  AVFoundation-Sample
//
//  Created by ExtYabecchi on 2017/05/24.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import Foundation
import AVFoundation

extension AVCaptureDevice {
    public class func videoDevice(for position: AVCaptureDevicePosition = .back) -> AVCaptureDevice! {
        return AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera,
                                             mediaType: AVMediaTypeVideo,
                                             position: position)
    }
    
}
