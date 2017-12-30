//
//  ControlDeviceViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/30/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit
import AVFoundation

class ControlDeviceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func torchOnOff(_ sender: UISwitch)
    {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
                                                       mediaType: AVMediaType.video,
                                                       position: .back)
        
        for device: AVCaptureDevice in session.devices
        {
            if device.hasTorch {
                if device.isTorchModeSupported(.on)
                {
                    do
                    {
                        try! device.lockForConfiguration()
                        
                        if sender.isOn
                        {
                            device.torchMode = .on
                        }
                        else
                        {
                            device.torchMode = .off
                        }
                        
                        device.unlockForConfiguration()
                    }
                }
            }
        }
    }
    
    @IBAction func vibrateDevice(_ sender: UIButton)
    {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
    

}
