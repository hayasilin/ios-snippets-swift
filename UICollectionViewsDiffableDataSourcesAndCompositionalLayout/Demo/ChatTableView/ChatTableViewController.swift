//
//  ChatTableViewController.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import UIKit
import Combine

final class ChatTableViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.alwaysBounceVertical = true
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.contentInset.bottom = 20
        tableView.register(ChatUserInputTableViewCell.self, forCellReuseIdentifier: ChatUserInputTableViewCell.cellReuseIdentifier)
        tableView.register(ChatAIReplyTextTableViewCell.self, forCellReuseIdentifier: ChatAIReplyTextTableViewCell.cellReuseIdentifier)
        return tableView
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
        snapshot.appendSections([.main])
        return snapshot
    }()

    private var subscriptions: Set<AnyCancellable> = []
    private lazy var dataSource = createDataSource()

    private let viewModel: ChatTableViewModel

    init(viewModel: ChatTableViewModel) {
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

        viewModel.$items.sink { [weak self] items in
            guard let self else {
                return
            }
            snapshot.appendItems(items)
            dataSource.apply(snapshot, animatingDifferences: true) {
                let maxContentOffset = CGPoint(x: 0, y: self.tableView.maximumVerticalContentOffset)
                self.tableView.setContentOffset(maxContentOffset, animated: true)

                self.messageInputView.isTextViewEditable = true
            }
        }
        .store(in: &subscriptions)

        keyboardObserver.view = view
        keyboardObserver.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        tableView.addGestureRecognizer(tapGesture)
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageInputView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputView.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        NSLayoutConstraint.activate([
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])
    }

    func sendTextMessage(_ text: String) {
        let item = ChatTableMessageItem(id: UUID(), text: text, type: .user)
        viewModel.refreshMessages(inputMessage: item)

        messageInputView.clear()
        messageInputView.isTextViewEditable = false
    }

    private func scrollToBottom() {
        let maxContentOffset = CGPoint(x: 0, y: tableView.maximumVerticalContentOffset)
        tableView.setContentOffset(maxContentOffset, animated: true)
    }

    @objc
    private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        messageInputView.resignFirstResponderForTextView()
    }
}

extension ChatTableViewController {
    typealias Section = ChatTableSection
    typealias Item = ChatTableMessageItem
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private func createDataSource() -> DataSource {
        DataSource(tableView: tableView) { tableView, indexPath, item in
            switch item.type {
            case .user:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ChatUserInputTableViewCell.cellReuseIdentifier, for: indexPath
                ) as? ChatUserInputTableViewCell else {
                    return UITableViewCell()
                }
                cell.configure(with: item)
                return cell

            case .ai:
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: ChatAIReplyTextTableViewCell.cellReuseIdentifier, for: indexPath
                ) as? ChatAIReplyTextTableViewCell else {
                    return UITableViewCell()
                }
                cell.configure(with: item)
                return cell
            }
        }
    }
}

extension ChatTableViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        messageInputView.inputText = item.text
    }
}

extension ChatTableViewController: KeyboardAppearanceObserverDelegate {
    func keyboardAppearanceObserverWillChange(
        _ observer: KeyboardAppearanceObserver, info: KeyboardAppearanceObserverInfo
    ) {
        scrollToBottom()
    }
}

extension ChatTableViewController: MessageInputViewDelegate {
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

extension UITableView {
    var maximumVerticalContentOffset: CGFloat {
        let contentHeight = contentSize.height
        let maxContentOffsetY = max(
            -adjustedContentInset.top,
            contentHeight - bounds.height + adjustedContentInset.bottom
        )
        return maxContentOffsetY
    }
}
