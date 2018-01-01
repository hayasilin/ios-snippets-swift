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

    var shakeAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake
        {
            shakeAlert = UIAlertController(title: "搖晃中", message: "裝置搖晃中", preferredStyle: .alert)
            self.present(shakeAlert, animated: true, completion: nil)
            perform(#selector(closeMotionShakeAlert), with: nil, afterDelay: 2.0)
        }
    }
    
    @objc func closeMotionShakeAlert() {
        shakeAlert.dismiss(animated: true, completion: nil)
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
