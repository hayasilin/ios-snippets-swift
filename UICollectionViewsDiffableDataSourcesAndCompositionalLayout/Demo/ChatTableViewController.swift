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
        tableView.register(ChatUserInputTableViewCell.self, forCellReuseIdentifier: ChatUserInputTableViewCell.cellReuseIdentifier)
        tableView.register(ChatAIReplyTableViewCell.self, forCellReuseIdentifier: ChatAIReplyTableViewCell.cellReuseIdentifier)
        return tableView
    }()

    private let keyboardObserver = KeyboardAppearanceObserver()
    private let messageInputView = MessageInputView(frame: .zero)

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
        navigationItem.title = "AI Ask"

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

        viewModel.$items.sink { [weak self] items in
            guard let self else {
                return
            }
            snapshot.appendItems(items)
            dataSource.apply(snapshot, animatingDifferences: true) {
                let maxContentOffset = CGPoint(x: 0, y: self.tableView.maximumVerticalContentOffset)
                self.tableView.setContentOffset(maxContentOffset, animated: true)
            }
        }
        .store(in: &subscriptions)

        messageInputView.delegate = self
        messageInputView.maxNumberOfLines = 5

        keyboardObserver.view = view
        keyboardObserver.delegate = self
    }
}

extension ChatTableViewController {
    typealias Section = ChatSection
    typealias Item = ChatMessageItem
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
                    withIdentifier: ChatAIReplyTableViewCell.cellReuseIdentifier, for: indexPath
                ) as? ChatAIReplyTableViewCell else {
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
        let maxContentOffset = CGPoint(x: 0, y: tableView.maximumVerticalContentOffset)
        tableView.setContentOffset(maxContentOffset, animated: true)
    }
}

extension ChatTableViewController: MessageInputViewDelegate {
    func messageInputView(
        _ inputView: MessageInputView,
        didTapSend text: String
    ) {
        sendTextMessage(text)
        inputView.clear()
    }

    func messageInputView(
        _ inputView: MessageInputView,
        didChangeHeight changes: (old: CGFloat, new: CGFloat)
    ) {
        let maxContentOffset = CGPoint(x: 0, y: tableView.maximumVerticalContentOffset)
        tableView.setContentOffset(maxContentOffset, animated: true)
    }
}

extension ChatTableViewController {
    func sendTextMessage(_ text: String) {
        let item = ChatMessageItem(id: UUID(), text: text, type: .user)
        viewModel.refreshMessages(inputMessage: item)
    }
}
