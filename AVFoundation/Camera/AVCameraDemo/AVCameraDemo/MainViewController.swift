//
//  MainViewController.swift
//  AVCameraDemo
//
//  Created by KuanWei on 2018/4/16.
//  Copyright © 2018年 Kuan-Wei. All rights reserved.
//

import UIKit
import Photos

class MainViewController: UIViewController {

    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var capturePreviewView: UIView!

    @IBOutlet weak var photoModeButton: UIButton!
    @IBOutlet weak var toggleCameraButton: UIButton!
    @IBOutlet weak var toggleFlashButton: UIButton!
    @IBOutlet weak var videoModeButton: UIButton!

    let cameraController = CameraController()

    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()

        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2

            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }

        styleCaptureButton()
        configureCameraController()
    }

    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }

            try? self.cameraController.displayPreview(on: self.capturePreviewView)
        }
    }


    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash Off Icon"), for: .normal)
        }

        else {
            cameraController.flashMode = .on
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash On Icon"), for: .normal)
        }
    }

    @IBAction func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        }

        catch {
            print(error)
        }

        switch cameraController.currentCameraPosition {
        case .some(.front):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Front Camera Icon"), for: .normal)

        case .some(.rear):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Rear Camera Icon"), for: .normal)

        case .none:
            return
        }
    }

    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }

            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    



}

