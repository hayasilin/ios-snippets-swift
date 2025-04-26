//
//  CollectionViewController.swift
//  CollectionViewDemo
//
//  Created by KuanWei on 2018/4/2.
//  Copyright © 2018年 Travostyle. All rights reserved.
//

import UIKit

/// A `UIViewController` demostrates basic `UICollectionView` implementation with `.NIB` file.
///
/// This UIViewController set up inital values in `UICollectionViewFlowLayout` for `UICollectionView` and will not change.
/// Although it looks ok when UICollectionView and cells are displayed, however, UI issue could happen with this implementation.
/// Because the cell size is set according to given display area and will not be changed after it's set,
/// so the cell size could be different when enter the page either from `portrait mode` or from `landscape mode` and change it
/// because the given display area is different in each mode so the number of items per row will be different due to the fixed item size.
///
/// This UIViewController also demo how to do basic drag and drop to change order of cell item in UICollectionView.
final class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private var canEdit = false

    private var dataArray = [String]()

    init() {
        for i in 1...30 {
            dataArray.append(String(i))
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Basic"

        let editBarButtonItem = UIBarButtonItem(title: "Select Mode", style: .plain, target: self, action: #selector(onEditButtonAction))
        navigationItem.rightBarButtonItem = editBarButtonItem

        let longPressGesture =  UILongPressGestureRecognizer(target: self, action: #selector(handlLongPress(gesture:)) );
        longPressGesture.minimumPressDuration = 1
        self.collectionView.addGestureRecognizer(longPressGesture);
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureCollectionView()
    }

    func configureCollectionView() {
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.allowsMultipleSelection = true

        // 建立 UICollectionViewFlowLayout
        let layout = UICollectionViewFlowLayout()

        // 設置 section 的間距 四個數值分別代表 上、左、下、右 的間距
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20);

        // 設置每一行的間距
        layout.minimumLineSpacing = 10

        layout.minimumInteritemSpacing = 5

        // 設置每個 cell 的尺寸
        let itemsPerRow = 3.0
        let paddingSpace = layout.sectionInset.left * (itemsPerRow + 1)

        let width = collectionView.bounds.width
        let availableWidth = width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        layout.itemSize = CGSize(width: widthPerItem, height: widthPerItem)

        // 設置 header 及 footer 的尺寸
        layout.headerReferenceSize = CGSize(width: width, height: 40)
        layout.footerReferenceSize = CGSize(width: width, height: 40)

        collectionView.register(
            BasicCollectionReusableHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: String(describing: BasicCollectionReusableHeaderView.self)
        )
        collectionView.register(
            BasicCollectionReusableFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: String(describing: BasicCollectionReusableFooterView.self)
        )

        collectionView.collectionViewLayout = layout
    }

    @objc func handlLongPress(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizer.State.began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break;
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath);
        case UIGestureRecognizer.State.changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view));
        case UIGestureRecognizer.State.ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement();
        }
    }

    @objc func onEditButtonAction(_ sender: UIBarButtonItem) {
        canEdit = !canEdit
        navigationItem.rightBarButtonItem?.title = canEdit ? "Delete Mode": "Select Mode"
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

        cell.contentView.backgroundColor = UIColor.lightGray
        cell.titleLabel.text = dataArray[indexPath.row]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.blue

        if canEdit {
            dataArray.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.lightGray
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: String(describing: BasicCollectionReusableHeaderView.self),
                for: indexPath
            ) as! BasicCollectionReusableHeaderView

            headerView.configure(with: "Header")
            return headerView
        }
        else if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: String(describing: BasicCollectionReusableFooterView.self),
                for: indexPath
            ) as! BasicCollectionReusableFooterView

            footerView.configure(with: "Footer")
            return footerView
        } else {
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let data = dataArray[sourceIndexPath.row]
        dataArray.remove(at: sourceIndexPath.row)

        dataArray.insert(data, at: destinationIndexPath.row)
    }
}
