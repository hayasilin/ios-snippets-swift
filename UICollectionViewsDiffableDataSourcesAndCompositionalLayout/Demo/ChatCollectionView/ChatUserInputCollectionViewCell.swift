//
//  ChatUserInputCollectionViewCell.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import UIKit

final class ChatUserInputCollectionViewCell: UICollectionViewCell {
    private enum Design {
        static let contentInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
    }

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = .zero
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Design.contentInsets.right),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.6)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: ChatCollectionMessageItem) {
        titleLabel.text = item.text
    }
}
