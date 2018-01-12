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

        var layout = UICollectionViewFlowLayout()
        layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let value = view.frame.size.width / 3
        layout.itemSize = CGSize(width: value, height: value)
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0)


        let headerViewNib = UINib(nibName: "ShopPhotoCollectionHeaderView", bundle: nil)
        collectionView.register(headerViewNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "PhotoListHeader")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
    }
    
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        print("did select = \(indexPath.row)")

        let gid = ShopPhotoManager.sharedInstance.gids[indexPath.section]
        let image = ShopPhotoManager.sharedInstance.getImage(gid, indexPath.row)

        let shopPhotoEndVC = ShopPhotoEndViewController(nibName: "ShopPhotoEndViewController", bundle: nil, image)
        navigationController?.pushViewController(shopPhotoEndVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: view.frame.size.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        if kind == UICollectionElementKindSectionHeader
        {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "PhotoListHeader", for: indexPath) as! ShopPhotoCollectionHeaderView

            let gid = ShopPhotoManager.sharedInstance.gids[indexPath.section]
            let name = ShopPhotoManager.sharedInstance.names[gid]

            header.headerLabel.text = name

            return header
        }

        return UICollectionReusableView()
    }


    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool
    {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool
    {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?)
    {

    }
}





