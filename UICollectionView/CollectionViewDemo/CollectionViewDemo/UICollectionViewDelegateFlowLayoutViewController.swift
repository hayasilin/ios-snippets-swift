//
//  UICollectionViewDelegateFlowLayoutViewController.swift
//  CollectionViewDemo
//
//  Created by user on 4/26/25.
//  Copyright © 2025 Travostyle. All rights reserved.
//

import UIKit

/// A `UIViewController` demostrates `UICollectionView` implementation with delegate functions of `UICollectionViewDelegateFlowLayout` to display fix cell item number per row.
///
/// This `UIViewController` ueses `UICollectionViewDelegateFlowLayout` so the delegate fundtions will be triggered according to system request.
/// One thing that need to be noted is delegate function `collectionView(_:layout:sizeForItemAt:)` is only triggered when trun from initial `portrait/landscape` to next mode,
/// and it won't be triggered when switch back from next mode to initial mode, so need to manually trigger `collectionView.collectionViewLayout.invalidateLayout()` when device turns
/// to trigger the delegate function otherwise the cell item number per row will be different.
final class UICollectionViewDelegateFlowLayoutViewController: UIViewController {
    private enum Design {
        static let defaultInset = 16.0
    }

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.delaysContentTouches = false
        collectionView.alwaysBounceVertical = true
        collectionView.alwaysBounceHorizontal = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never

        collectionView.register(DelegateFlowLayoutCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: AdvancedCollectionViewCell.self))
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
        title = "DelegateFlowLayout"

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension UICollectionViewDelegateFlowLayoutViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AdvancedCollectionViewCell.self), for: indexPath) as? DelegateFlowLayoutCollectionViewCell else {
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

extension UICollectionViewDelegateFlowLayoutViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }

        let itemsPerRow = 4.0
        let itemSpacing = layout.minimumInteritemSpacing
        let totalItemSpacing = itemSpacing * (itemsPerRow - 1)
        let horizontalSectionInset = Design.defaultInset
        let totalSpacing = totalItemSpacing + horizontalSectionInset * 2

        let individualWidth = floor((collectionView.bounds.width - totalSpacing) / itemsPerRow)
        return CGSize(width: individualWidth, height: individualWidth)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: 10,
            left: 20,
            bottom: 10,
            right: 20
        )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }

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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
