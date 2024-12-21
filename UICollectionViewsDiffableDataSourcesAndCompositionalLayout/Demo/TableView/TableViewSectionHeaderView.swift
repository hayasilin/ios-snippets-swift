//
//  TableViewSectionHeaderView.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import UIKit

final class TableViewSectionHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = String(describing: TableViewSectionHeaderView.self)

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .heavy)
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
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

final class TableViewSectionFooterView: UITableViewHeaderFooterView {
    static let reuseIdentifier = String(describing: TableViewSectionFooterView.self)

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
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
