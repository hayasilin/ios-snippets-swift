//
//  CustomCollectionViewCell.swift
//  Demo
//
//  Created by user on 2023/07/04.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    static let cellReuseIdentifier = String(describing: CustomCollectionViewCell.self)

    lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
