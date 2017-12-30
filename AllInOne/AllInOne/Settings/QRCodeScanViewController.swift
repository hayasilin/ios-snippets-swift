//
//  QRCodeScanViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/30/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    let session = AVCaptureSession()
    let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let device = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let videoInput = try AVCaptureDeviceInput(device: device!)
            session.addInput(videoInput)
            
            let videoOutput = AVCaptureMetadataOutput()
            session.addOutput(videoOutput)
            
            videoOutput.metadataObjectTypes = videoOutput.availableMetadataObjectTypes
            videoOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            captureVideoPreviewLayer.session = session
            captureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            cameraView.layer.addSublayer(captureVideoPreviewLayer)
        }
        catch
        {
            print("error = \(error)")
        }
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        captureVideoPreviewLayer.frame = cameraView.bounds
    }
    
    @IBAction func doStartAction(_ sender: UIButton)
    {
        session.startRunning()
    }
    
    @IBAction func doStopAction(_ sender: UIButton)
    {
        session.stopRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for metaData in metadataObjects
        {
            if let data = metaData as? AVMetadataMachineReadableCodeObject
            {
                codeLabel.text = data.stringValue
                typeLabel.text = data.type.rawValue
            }
            else
            {
                print("error")
            }
        }
    }

}
