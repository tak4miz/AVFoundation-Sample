//
//  previewViewController.swift
//  AVFoundation-Sample
//
//  Created by ExtYabecchi on 2017/05/16.
//  Copyright © 2017年 ExtYabecchi. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    var previewImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard previewImage != nil else { return }
        
        let imageView = UIImageView(image: previewImage)
        imageView.frame = CGRect(x: 0.0,
                                 y: 0.0,
                                 width: UIScreen.main.bounds.size.width,
                                 height: UIScreen.main.bounds.size.height)

        previewView.addSubview(imageView)
    }
}
