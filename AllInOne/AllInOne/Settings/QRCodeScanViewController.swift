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
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var scanResultButton: UIButton!
    
    var urlString = ""
    
    let session = AVCaptureSession()
    let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        tabBarController?.tabBar.isTranslucent = false

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
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        captureVideoPreviewLayer.frame = cameraView.bounds
        session.startRunning()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        session.stopRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for metaData in metadataObjects
        {
            if let data = metaData as? AVMetadataMachineReadableCodeObject
            {
                scanResultButton.setTitle(data.stringValue, for: .normal)
                scanResultButton.isEnabled = true
                urlString = data.stringValue!
                typeLabel.text = data.type.rawValue
            }
            else
            {
                print("error")
            }
        }
    }

    @IBAction func scanResultButtonPressed(_ sender: UIButton)
    {
        let webView = UIWebView(frame: view.bounds)
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        
        view.addSubview(webView)
    }
}
