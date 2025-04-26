//
//  AdvancedCollectionViewController.swift
//  CollectionViewDemo
//
//  Created by user on 4/26/25.
//  Copyright © 2025 Travostyle. All rights reserved.
//

import UIKit

/// A `UIViewController` demostrates `UICollectionView` implementation with initial `UICollectionViewFlowLayout` setup and keep cell item flow with given size.
///
/// This `UIViewController` set up inital values in `UICollectionViewFlowLayout` for `UICollectionView` and will not change,
/// The difference of this implementation is `estimatedItemSize` is set, which is same size defined in AdvancedCollectionViewCell.
/// As as result it displays the cell item number per row correctly either switch between `portrait mode` or `landscape mode`.
final class AdvancedCollectionViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        collectionViewLayout.minimumInteritemSpacing = 5
        collectionViewLayout.minimumLineSpacing = 10
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20);
        // This is important.
        collectionViewLayout.estimatedItemSize = AdvancedCollectionViewCell.Design.imageSize

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.delaysContentTouches = false
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never

        collectionView.register(AdvancedCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: AdvancedCollectionViewCell.self))
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
        return collectionView
    }()

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
        title = "Advanced"

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension AdvancedCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AdvancedCollectionViewCell.self), for: indexPath) as? AdvancedCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.configure()
        return cell
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
}

extension AdvancedCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 40)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 40)
    }
}

extension AdvancedCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
