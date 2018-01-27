//
//  MenuBarViewController.swift
//  PageViewDemo
//
//  Created by KuanWei on 2018/4/4.
//  Copyright © 2018年 Travostyle. All rights reserved.
//

import UIKit

class MenuBarViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    var nowPage: PageType = .fragment

    let numberOfMenu: CGFloat = 3
    var homeVC: HomeViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

//        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        let nib = UINib(nibName: "PageCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: PageCollectionViewCell.identifier)

        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 1
        }

    }

    func setupNowPage(currentPage: PageType) {
        nowPage = currentPage
        collectionView.reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(numberOfMenu)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
//
//        let colors: [UIColor] = [.blue, .green, UIColor.gray, .purple]
//
//        cell.backgroundColor = colors[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageCollectionViewCell.identifier, for: indexPath) as! PageCollectionViewCell

        guard let pageType = PageType(rawValue:indexPath.row) else {
            assertionFailure("unknown page type \(indexPath.row).")
            return cell
        }

        cell.pageType = pageType

        if cell.pageType == nowPage {
            cell.isNowPage = true
        } else {
            cell.isNowPage = false
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt = \(indexPath.row)")
        homeVC?.scrollToMenuIndex(menuIndex: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / numberOfMenu, height: view.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

}
