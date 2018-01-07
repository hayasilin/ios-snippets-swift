//
//  CameraViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/7/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isTranslucent = false
        tabBarController?.tabBar.isTranslucent = false
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        checkCameraConfiguration()
        
        startCamera()
    }

    func checkCameraConfiguration()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            print("有拍照功能")
        }
        if UIImagePickerController.isFlashAvailable(for: .front)
        {
            print("有前閃光燈")
        }
        if UIImagePickerController.isFlashAvailable(for: .rear)
        {
            print("後閃光燈")
        }
    }
}

extension CameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate
{
    func startCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .camera
            imagePickerVC.delegate = self
            
            show(imagePickerVC, sender: self)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
}





