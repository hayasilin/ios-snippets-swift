//
//  CustomTableViewCell.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import UIKit

final class CustomTableViewCell: UITableViewCell {
    static let cellReuseIdentifier = String(describing: CustomTableViewCell.self)

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = .zero
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        titleLabel.text = text
    }
}
