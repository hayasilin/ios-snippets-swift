//
//  MessageInputView.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import UIKit

protocol MessageInputViewDelegate: AnyObject {
    func messageInputView(
        _ inputView: MessageInputView,
        didTapSend text: String
    )

    func messageInputView(
        _ inputView: MessageInputView,
        didChangeHeight changes: (old: CGFloat, new: CGFloat)
    )
}

final class MessageInputView: UIView {
    private enum Design {
        static let minContentHeight: CGFloat = 40
    }

    weak var delegate: (any MessageInputViewDelegate)?
    private let sendButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Send"
        configuration.buttonSize = .small
        configuration.cornerStyle = .capsule
        configuration.titlePadding = 5
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let textView: GrowingTextView = {
        let textView = GrowingTextView(frame: .zero)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    var maxNumberOfLines: Int {
        get {
            textView.maxNumberOfLines
        }
        set {
            textView.maxNumberOfLines = newValue
        }
    }

    var inputText: String {
        get {
            textView.text
        }
        set {
            textView.text = newValue
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .secondarySystemBackground
        addSubview(textView)
        addSubview(sendButton)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            textView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5),

            sendButton.topAnchor.constraint(equalTo: textView.topAnchor),
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 5),
            sendButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            sendButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -5),
            sendButton.heightAnchor.constraint(equalToConstant: Design.minContentHeight)
        ])

        textView.font = .systemFont(ofSize: 18)

        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        sendButton.menu = UIMenu(children: [
            UIAction(title: "Send", handler: { [weak self] _ in
                guard let self else { return }
                sendButton.configuration?.title = "Send"
            }),
            UIAction(title: "Receive", handler: { [weak self] _ in
                guard let self else { return }
                sendButton.configuration?.title = "Receive"
            }),
        ])
        maxNumberOfLines = 1
    }

    @objc private func didTapSendButton(_ sender: UIButton) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            return
        }
        delegate?.messageInputView(self, didTapSend: text)
    }

    func clear() {
        textView.text = ""
    }

    override var intrinsicContentSize: CGSize {
        .zero
    }

    override func resignFirstResponder() -> Bool {
        textView.resignFirstResponder()
    }

    private var currentHeight: CGFloat?
    override func layoutSubviews() {
        super.layoutSubviews()
        let nextHeight = frame.height
        defer { currentHeight = nextHeight }
        guard let currentHeight, currentHeight != nextHeight else { return }
        delegate?.messageInputView(self, didChangeHeight: (currentHeight, nextHeight))
    }
}

extension MessageInputView {
    private final class GrowingTextView: UITextView {
        lazy var textViewHeightConstraint: NSLayoutConstraint = {
            let constraint = heightAnchor.constraint(equalToConstant: Design.minContentHeight)
            constraint.isActive = true
            return constraint
        }()

        var maxNumberOfLines = 1 {
            didSet {
                let lineHeight = font?.lineHeight ?? 0
                maxContentHeight = CGFloat(maxNumberOfLines) * lineHeight + (lineHeight * 0.3)
                updateTextViewHeightConstraint()
            }
        }

        var maxContentHeight: CGFloat = 0

        func updateTextViewHeightConstraint() {
            textViewHeightConstraint.constant = contentSize.height.clamped(
                minimum: Design.minContentHeight,
                maximum: maxContentHeight
            )
        }

        override var contentSize: CGSize {
            didSet {
                updateTextViewHeightConstraint()
                superview?.invalidateIntrinsicContentSize()
            }
        }
    }
}

extension Comparable {
    func clamped(minimum: Self, maximum: Self) -> Self {
        max(minimum, min(maximum, self))
    }
}
