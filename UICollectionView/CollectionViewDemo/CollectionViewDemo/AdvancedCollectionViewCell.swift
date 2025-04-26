//
//  AdvancedCollectionViewCell.swift
//  CollectionViewDemo
//
//  Created by user on 4/26/25.
//  Copyright © 2025 Travostyle. All rights reserved.
//

import UIKit

final class AdvancedCollectionViewCell: UICollectionViewCell {
    enum Design {
        static let imageSize = CGSize(width: 100, height: 100)
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
            imageView.widthAnchor.constraint(equalToConstant: Design.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: Design.imageSize.height),
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
