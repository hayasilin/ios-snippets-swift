//
//  ChatCollectionViewController.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import UIKit
import Combine

final class ChatCollectionViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.contentInset.bottom = 20
        return collectionView
    }()

    private let keyboardObserver = KeyboardAppearanceObserver()

    private lazy var messageInputView: MessageInputView = {
        let messageInputView = MessageInputView(frame: .zero)
        messageInputView.delegate = self
        messageInputView.maxNumberOfLines = 5
        return messageInputView
    }()

    private lazy var snapshot: Snapshot = {
        var snapshot = Snapshot()
        return snapshot
    }()

    private var subscriptions: Set<AnyCancellable> = []
    private lazy var dataSource = createDataSource()

    private let viewModel: ChatCollectionViewModel

    init(viewModel: ChatCollectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configureTitleView()
        configureViews()
        configureLayout()

        viewModel.$sections.sink { [weak self] sections in
            guard let self else {
                return
            }
            snapshot.appendSections(sections)
            for section in sections {
                snapshot.appendItems(section.items, toSection: section)
            }
            dataSource.apply(snapshot, animatingDifferences: true) {
                let maxContentOffset = CGPoint(x: 0, y: self.collectionView.maximumVerticalContentOffset)
                self.collectionView.setContentOffset(maxContentOffset, animated: true)

                self.messageInputView.isTextViewEditable = true
            }
        }
        .store(in: &subscriptions)

        keyboardObserver.view = view
        keyboardObserver.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        collectionView.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageInputView.becomeFirstResponderForTextView()
    }

    private func configureTitleView() {
        let titleLabel = UILabel(frame: .zero)
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "sparkles")?.withTintColor(.label)

        let font = UIFont.systemFont(ofSize: 15, weight: .bold)

        let attributedString = NSMutableAttributedString(
            string: "AIにリクエスト",
            attributes: [
                .font: font,
                .foregroundColor: UIColor.label,
            ]
        )
        attributedString.insert(NSAttributedString(attachment: attachment), at: 0)
        titleLabel.attributedText = attributedString
        navigationItem.titleView = titleLabel
    }

    private func configureViews() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageInputView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }

    private func configureLayout() {
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(
            sectionProvider: { sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
                // Use sectionIndex to get current data type and decide what layout to use
                guard self.viewModel.messageViewModels.count > sectionIndex else {
                    return nil
                }

                let messageViewModel = self.viewModel.messageViewModels[sectionIndex]

                switch messageViewModel {
                case .userInputText:
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(70)
                    )

                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

                    let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])

                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                    section.interGroupSpacing = 10

                    return section

                case .textSuggestion:
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(70)
                    )

                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

                    let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])

                    let section = NSCollectionLayoutSection(group: group)
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                    section.interGroupSpacing = 10

                    return section

                case .imageSuggestion:
                    let itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.25),
                        heightDimension: .fractionalHeight(1.0)
                    )

                    let item = NSCollectionLayoutItem(layoutSize: itemSize)
                    item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

                    let groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalWidth(0.2)
                    )

                    let group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: groupSize,
                        subitems: [item]
                    )

                    let section = NSCollectionLayoutSection(group: group)
                    return section
                }
            }
        )
    }

    func sendTextMessage(_ text: String) {
        let item = ChatCollectionMessageItem(id: UUID(), type: .userInputText, text: text)
        viewModel.fetchAIResponse(inputMessageItem: item, replyType: messageInputView.replyType)

        messageInputView.clear()
        messageInputView.isTextViewEditable = false
    }

    private func scrollToBottom() {
        let maxContentOffset = CGPoint(x: 0, y: collectionView.maximumVerticalContentOffset)
        collectionView.setContentOffset(maxContentOffset, animated: true)
    }

    @objc
    private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        messageInputView.resignFirstResponderForTextView()
    }
}

extension ChatCollectionViewController {
    typealias Section = ChatCollectionSection
    typealias Item = ChatCollectionMessageItem
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    typealias TextSuggestionCellRegistration = UICollectionView.CellRegistration<
        ChatAIReplyTextCollectionViewCell, Item
    >
    typealias UserInputTextCellRegistration = UICollectionView.CellRegistration<
        ChatUserInputCollectionViewCell, Item
    >
    typealias ImageSuggestionCellRegistration = UICollectionView.CellRegistration<
        ChatAIReplyImageCollectionViewCell, Item
    >

    private func createDataSource() -> DataSource {
        let textSuggestionCellRegistration = TextSuggestionCellRegistration { cell, indexPath, item in
            cell.configure(with: item)
        }

        let userInputTextCellRegistration = UserInputTextCellRegistration { cell, indexPath, item in
            cell.configure(with: item)
        }

        let imageSuggestionCellRegistration = ImageSuggestionCellRegistration { cell, indexPath, item in
            cell.configure(with: item)
        }

        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item.type {
            case .userInputText:
                collectionView.dequeueConfiguredReusableCell(
                    using: userInputTextCellRegistration,
                    for: indexPath,
                    item: item
                )
            case .textSuggestion:
                collectionView.dequeueConfiguredReusableCell(
                    using: textSuggestionCellRegistration,
                    for: indexPath,
                    item: item
                )
            case .imageSuggestion:
                collectionView.dequeueConfiguredReusableCell(
                    using: imageSuggestionCellRegistration,
                    for: indexPath,
                    item: item
                )
            }
        }

        return dataSource
    }
}

extension ChatCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        messageInputView.inputText = item.text
    }
}

extension ChatCollectionViewController: KeyboardAppearanceObserverDelegate {
    func keyboardAppearanceObserverWillChange(
        _ observer: KeyboardAppearanceObserver, info: KeyboardAppearanceObserverInfo
    ) {
        scrollToBottom()
    }
}

extension ChatCollectionViewController: MessageInputViewDelegate {
    func messageInputView(
        _ inputView: MessageInputView,
        didTapSend text: String
    ) {
        sendTextMessage(text)
    }

    func messageInputView(
        _ inputView: MessageInputView,
        didChangeHeight changes: (old: CGFloat, new: CGFloat)
    ) {
        scrollToBottom()
    }
}

extension UICollectionView {
    var maximumVerticalContentOffset: CGFloat {
        let contentHeight = collectionViewLayout.collectionViewContentSize.height
        let maxContentOffsetY = max(
            -adjustedContentInset.top,
            contentHeight - bounds.height + adjustedContentInset.bottom
        )
        return maxContentOffsetY
    }
}
