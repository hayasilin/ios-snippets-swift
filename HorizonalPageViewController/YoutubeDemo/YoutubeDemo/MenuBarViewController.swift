//
//  MenuBarViewController.swift
//  YoutubeDemo
//
//  Created by KuanWei on 2018/4/3.
//  Copyright © 2018年 Travostyle. All rights reserved.
//

import UIKit

class MenuBarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    var homeVC: HomeViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = UIColor.init(red: 230, green: 32, blue: 31, alpha: 1)

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        let colors: [UIColor] = [.blue, .green, UIColor.gray, .purple]

        cell.backgroundColor = colors[indexPath.item]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt = \(indexPath.row)")
        homeVC?.scrollToMenuIndex(menuIndex: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 4, height: view.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
