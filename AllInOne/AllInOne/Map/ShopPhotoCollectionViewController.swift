//
//  ShopPhotoCollectionViewController.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 1/12/18.
//  Copyright © 2018 cracktheterm. All rights reserved.
//

import UIKit

class ShopPhotoCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ShopPhotoManager.sharedInstance.loadPhotos()
        
        let nib = UINib(nibName: "ShopPhotoCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
////        let size = view.frame.size.width / 3
////        return CGSize(width: size, height: size)
//    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return ShopPhotoManager.sharedInstance.gids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return ShopPhotoManager.sharedInstance.numberOfPhotosInIndex(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ShopPhotoCollectionViewCell
        
        let gid = ShopPhotoManager.sharedInstance.gids[indexPath.section]
        cell.photoImageView.image = ShopPhotoManager.sharedInstance.getImage(gid, indexPath.row)
        
        cell.contentView.backgroundColor = UIColor.gray
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        print("did select = \(indexPath.row)")
    }
    
    
    
    
}





