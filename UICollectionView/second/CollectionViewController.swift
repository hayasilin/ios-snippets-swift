//
//  CollectionViewController.swift
//  CollectionViewDemo
//
//  Created by KuanWei on 2018/4/2.
//  Copyright © 2018年 Travostyle. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 3

    var fullScreenSize :CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setCollectionView()
    }

    func setCollectionView() {

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self

        // 取得螢幕的尺寸
        fullScreenSize = UIScreen.main.bounds.size

        // 建立 UICollectionViewFlowLayout
        let layout = UICollectionViewFlowLayout()

        // 設置 section 的間距 四個數值分別代表 上、左、下、右 的間距
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);

        // 設置每一行的間距
        layout.minimumLineSpacing = 5

        // 設置每個 cell 的尺寸
        layout.itemSize = CGSize(width: fullScreenSize.width / 3 - 10.0, height: fullScreenSize.width / 3 - 10.0)

        // 設置 header 及 footer 的尺寸
        layout.headerReferenceSize = CGSize(width: fullScreenSize.width, height: 40)
        layout.footerReferenceSize = CGSize(width: fullScreenSize.width, height: 40)

        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footer")

        collectionView.collectionViewLayout = layout
    }
}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource  {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        cell.contentView.backgroundColor = UIColor.blue

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didselectItemAt = \(indexPath.row)")
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        var reusableView = UICollectionReusableView()

        // 顯示文字
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: fullScreenSize.width, height: 40))
        label.textAlignment = .center

        // header
        if kind == UICollectionElementKindSectionHeader {
            // 依據前面註冊設置的識別名稱 "Header" 取得目前使用的 header
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                           withReuseIdentifier: "header",
                                                                           for: indexPath)
            // 設置 header 的內容
            reusableView.backgroundColor = UIColor.darkGray
            label.text = "Header";
            label.textColor = UIColor.white

        } else if kind == UICollectionElementKindSectionFooter {
            // 依據前面註冊設置的識別名稱 "Footer" 取得目前使用的 footer
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                                           withReuseIdentifier: "footer",
                                                                           for: indexPath)
            // 設置 footer 的內容
            reusableView.backgroundColor = UIColor.cyan
            label.text = "Footer";
            label.textColor = UIColor.black
        }

        reusableView.addSubview(label)
        return reusableView
    }
}
