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

    var dataArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",]

    var canEdit = false

    var recipeImages = [String]()
    var selectedRecipes = [String]()

    var longPressGesture = UILongPressGestureRecognizer();

    let tutorial = Tutorial(title: "Swift4", author: "Lin", editor: "Kuan", type: "Swift", publishDate: Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onEditButtonAction(_:)))
        navigationItem.rightBarButtonItem = editBarButtonItem

        setCollectionView()

        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(tutorial)
        print("jsonData = \(jsonData)")
        let jsonString = String(data: jsonData, encoding: .utf8)
        print("jsonString = \(String(describing: jsonString))")

        let decodeer = JSONDecoder()
        let article = try! decodeer.decode(Tutorial.self, from: jsonData)
        let info = "\(article.title) \(article.author) \(article.editor) \(article.type) \(article.publishDate)"
        print("info = \(info)")

        longPressGesture =  UILongPressGestureRecognizer(target: self, action: #selector(handlLongPress(gesture:)) );
        longPressGesture.minimumPressDuration = 1
        self.collectionView.addGestureRecognizer(longPressGesture);
    }

    @objc func onEditButtonAction(_ sender: UIBarButtonItem) {
        canEdit = !canEdit

    }

    func setCollectionView() {

        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.allowsMultipleSelection = true

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

    @objc func handlLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break;
            }
            print("长按开始");
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath);
        case UIGestureRecognizerState.changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view));

        case UIGestureRecognizerState.ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement();
        }

    }
}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource  {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell

        cell.contentView.backgroundColor = UIColor.blue
        cell.titleLabel.text = dataArray[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didselectItemAt = \(indexPath.row)")

        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.yellow

        if canEdit {
            dataArray.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("didDeselectItemAt = \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.blue
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

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        let data = dataArray[sourceIndexPath.row]
        dataArray.remove(at: sourceIndexPath.row)

        dataArray.insert(data, at: destinationIndexPath.row)
    }


}
