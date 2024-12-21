//
//  ChatReplyTableViewCell.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import UIKit

final class ChatAIReplyTableViewCell: UITableViewCell {
    static let cellReuseIdentifier = String(describing: ChatAIReplyTableViewCell.self)

    private enum Design {
        static let contentInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        static let labelInsets = UIEdgeInsets(top: 12, left: 30, bottom: 12, right: 30)
    }

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        let bubbleImage = UIImage(systemName: "bubble.fill") ?? UIImage()
        let capInsets = UIEdgeInsets(
            top: bubbleImage.size.height * 0.5,
            left: bubbleImage.size.width * 0.5,
            bottom: bubbleImage.size.height * 0.5,
            right: bubbleImage.size.width * 0.5
        )

        imageView.image = bubbleImage
            .resizableImage(withCapInsets: capInsets)
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 15)
        label.textColor = .label
        label.numberOfLines = .zero
        label.textAlignment = .left
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(backgroundImageView)
        backgroundImageView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: Design.labelInsets.top),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor, constant: Design.labelInsets.left),
            titleLabel.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -Design.labelInsets.bottom),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor, constant:  -Design.labelInsets.right)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: ChatMessageItem) {
        titleLabel.text = item.text
    }
}
