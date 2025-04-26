//
//  DelegateFlowLayoutCollectionViewCell.swift
//  CollectionViewDemo
//
//  Created by user on 4/26/25.
//  Copyright © 2025 Travostyle. All rights reserved.
//

import UIKit

final class DelegateFlowLayoutCollectionViewCell: UICollectionViewCell {
    enum Design {
        static let imageViewInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .center
        imageView.backgroundColor = .lightGray
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .cyan

        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func configure() {
        imageView.image = UIImage(systemName: "scribble.variable")
    }
}
