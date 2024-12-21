//
//  ChatUserInputTableViewCell.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import UIKit

final class ChatUserInputTableViewCell: UITableViewCell {
    static let cellReuseIdentifier = String(describing: ChatUserInputTableViewCell.self)

    private enum Design {
        static let contentInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .label
        label.numberOfLines = .zero
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

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

    func configure(with item: ChatTableMessageItem) {
        titleLabel.text = item.text
    }
}
