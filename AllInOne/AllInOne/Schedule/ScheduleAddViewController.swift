//
//  ScheduleAddViewController.swift
//  AllInOne
//
//  Created by KuanWei on 2017/12/28.
//  Copyright © 2017年 cracktheterm. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class ScheduleAddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var scheduleRef: DatabaseReference = Database.database().reference().ref.child("schedule")
    var createTime: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d H:m:s"
        createTime = formatter.string(from: Date())
    }
    
    func saveSchedule()
    {
        let title = titleTextField.text
        let description = descriptionTextField.text
        
        if title != "" && description != "" {
            let newSchedule: Dictionary<String, AnyObject> = [
                "title": title as AnyObject,
                "description": description as AnyObject,
                "create_time": createTime as AnyObject
            ]
            
            createNewSchedule(schedule: newSchedule)
        }
    }
    
    func createNewSchedule(schedule: Dictionary<String, AnyObject>) {
        let firebaseNewSchedule = scheduleRef.childByAutoId()
        firebaseNewSchedule.setValue(schedule)
    }
    
    @IBAction func doSaveAction(_ sender: UIButton)
    {
        saveSchedule()
        
        navigationController?.popViewController(animated: true)
    }

    @IBAction func uploadPhoto(_ sender: UIButton)
    {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let imagePickerAlertController = UIAlertController(title: "上傳圖片", message: "選擇要上傳的圖片", preferredStyle: .actionSheet)

        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { (Void) in

            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {

                // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.photoLibrary)，並 present UIImagePickerController
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { (Void) in

            if UIImagePickerController.isSourceTypeAvailable(.camera) {

                // 如果可以，指定 UIImagePickerController 的照片來源為 照片圖庫 (.camera)，並 present UIImagePickerController
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }

        // 新增一個取消動作，讓使用者可以跳出 UIAlertController
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (Void) in

            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }

        // 將上面三個 UIAlertAction 動作加入 UIAlertController
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)

        // 當使用者按下 uploadBtnAction 時會 present 剛剛建立好的三個 UIAlertAction 動作與
        present(imagePickerAlertController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        var selectedImageFromPicker: UIImage?

        // 取得從 UIImagePickerController 選擇的檔案
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

            selectedImageFromPicker = pickedImage
        }

        // 可以自動產生一組獨一無二的 ID 號碼，方便等一下上傳圖片的命名
        let uniqueString = NSUUID().uuidString

        // 當判斷有 selectedImage 時，我們會在 if 判斷式裡將圖片上傳
        if let selectedImage = selectedImageFromPicker {
            print("\(uniqueString), \(selectedImage)")
        }

        dismiss(animated: true, completion: nil)

        if let selectedImage = selectedImageFromPicker
        {
            let storageRef = Storage.storage().reference().child("AppCodaFireUpload").child("\(uniqueString).png")

            if let uploadData = UIImagePNGRepresentation(selectedImage) {
                // 這行就是 FirebaseStorage 關鍵的存取方法。
                storageRef.putData(uploadData, metadata: nil, completion: { (data, error) in

                    if error != nil {
                        // 若有接收到錯誤，我們就直接印在 Console 就好，在這邊就不另外做處理。
                        print("Error: \(error!.localizedDescription)")
                        return
                    }

                    // 連結取得方式就是：data?.downloadURL()?.absoluteString。
                    if let uploadImageUrl = data?.downloadURL()?.absoluteString {

                        // 我們可以 print 出來看看這個連結事不是我們剛剛所上傳的照片。
                        print("Photo Url: \(uploadImageUrl)")

                        let databaseRef = Database.database().reference().child("AppCodaFireUpload").child(uniqueString)
                        databaseRef.setValue(uploadImageUrl, withCompletionBlock: { (error, dataRef) in

                            if error != nil
                            {
                                print("Database error: \(String(describing: error?.localizedDescription))")
                            }
                            else
                            {
                                print("圖片儲存")
                            }
                        })

                    }
                })
            }
        }
    }

    @IBAction func pushPhotoCollectionPage(_ sender: UIButton)
    {
        let photoCollectionVC = PhotoCollectionViewController()
        navigationController?.pushViewController(photoCollectionVC, animated: true)
    }
    
}
