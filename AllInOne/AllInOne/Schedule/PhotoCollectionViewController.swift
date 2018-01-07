//
//  PhotoCollectionViewController.swift
//  AllInOne
//
//  Created by KuanWei on 2018/1/8.
//  Copyright © 2018年 cracktheterm. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PhotoCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!

    var fireUploadDictionary: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")

        let databaseRef = Database.database().reference().child("AppCodaFireUpload")
        databaseRef.observe(.value) { [weak self] (snapshot) in

            if let uploadDataDic = snapshot.value as? [String: Any]
            {
                self?.fireUploadDictionary = uploadDataDic
                self?.collectionView.reloadData()
            }
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if let dataDic = fireUploadDictionary
        {
            return dataDic.count
        }

        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCollectionViewCell else
        {
            fatalError()
        }

        cell.contentView.backgroundColor = UIColor.groupTableViewBackground

        if let dataDic = fireUploadDictionary
        {
            let keyArray = Array(dataDic.keys)
            if let imageUrlString = dataDic[keyArray[indexPath.row]] as? String
            {
                if let imageUrl = URL(string: imageUrlString)
                {
                    URLSession.shared.dataTask(with: imageUrl, completionHandler: { (data, response, error) in

                        if error != nil
                        {
                            print("Download image task fail: \(String(describing: error?.localizedDescription))")
                        }
                        else if let imageData = data
                        {
                            DispatchQueue.main.async {
                                cell.photoImageView.image = UIImage(data: imageData)
                            }
                        }
                    })
                }
            }
        }
        else
        {
            cell.photoImageView.image = UIImage(named: "no_image")
        }


        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
    }

}
