//
//  SectionHeaderReusableView.swift
//  Demo
//
//  Created by user on 2023/07/04.
//

import UIKit

final class CollectionViewSectionHeaderReusableView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: CollectionViewSectionHeaderReusableView.self)

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize,
            weight: .bold
        )
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .left
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(
            .defaultHigh, for: .horizontal
        )
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        if UIDevice.current.userInterfaceIdiom == .pad {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 5),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor,constant: -5)])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: readableContentGuide.trailingAnchor)
            ])
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor,constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class CollectionViewSectionFooterReusableView: UICollectionReusableView {
    static let reuseIdentifier = String(describing: CollectionViewSectionFooterReusableView.self)

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        if UIDevice.current.userInterfaceIdiom == .pad {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 5),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor,constant: -5)])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: readableContentGuide.trailingAnchor)
            ])
        }
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor,constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
