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
        var configuration = UIButton.Configuration.plain()
        configuration.baseBackgroundColor = .clear

        configuration.image = UIImage(systemName: "arrow.up.circle.fill")

        let button = UIButton(configuration: configuration)
        button.isEnabled = false

        button.configurationUpdateHandler = { button in
            switch button.state {
            case .normal:
                button.configuration?.baseForegroundColor = .black
            case .disabled:
                button.configuration?.baseForegroundColor = .clear
            default:
                button.configuration?.baseForegroundColor = .clear
            }
        }
        return button
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14)
        label.text = "気になることは何でも聞いてください。"
        return label
    }()

    private let textView: GrowingTextView = {
        let textView = GrowingTextView(frame: .zero)
        textView.font = .systemFont(ofSize: 14)
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
            placeholderLabel.isHidden = !newValue.isEmpty
            textView.text = newValue
        }
    }

    var isTextViewEditable = true {
        didSet {
            if isTextViewEditable {
                placeholderLabel.text = "気になることは何でも聞いてください。"
            }
            else {
                placeholderLabel.text = "読み出し中、少々お待ちください。"
            }
            textView.isEditable = isTextViewEditable
        }
    }

    var replyType: ChatMessageReplyType = .text

    override var intrinsicContentSize: CGSize {
        .zero
    }

    override var isFirstResponder: Bool {
        textView.isFirstResponder
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)

        let separatorView = UIView(frame: .zero)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .lightGray
        addSubview(separatorView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)

        sendButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sendButton)

        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            textView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            textView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -5),

            sendButton.topAnchor.constraint(equalTo: textView.topAnchor),
            sendButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -5),
            sendButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            sendButton.heightAnchor.constraint(equalToConstant: Design.minContentHeight)
        ])

        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        sendButton.menu = UIMenu(children: [
            UIAction(title: "Reply image", handler: { [weak self] _ in
                guard let self else { return }
                replyType = .image
            }),
            UIAction(title: "Reply text", handler: { [weak self] _ in
                guard let self else { return }
                replyType = .text
            }),
        ])
        maxNumberOfLines = 1

        configurePlaceholder()
        textView.delegate = self
    }

    override func resignFirstResponder() -> Bool {
        textView.resignFirstResponder()
    }

    func configurePlaceholder() {
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5)
        ])

        placeholderLabel.isHidden = !textView.text.isEmpty
    }

    func clear() {
        textView.text = ""
    }

    func setSendButton(isEnabled: Bool) {
        sendButton.isEnabled = isEnabled
    }

    @discardableResult
    func becomeFirstResponderForTextView() -> Bool {
        textView.becomeFirstResponder()
    }

    @discardableResult
    func resignFirstResponderForTextView() -> Bool {
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

    @objc private func didTapSendButton(_ sender: UIButton) {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            return
        }
        delegate?.messageInputView(self, didTapSend: text)
    }
}

extension MessageInputView {
    private final class GrowingTextView: UITextView {
        var maxNumberOfLines = 1 {
            didSet {
                let lineHeight = font?.lineHeight ?? 0
                maxContentHeight = CGFloat(maxNumberOfLines) * lineHeight + (lineHeight * 0.3)
                updateTextViewHeightConstraint()
            }
        }

        private var maxContentHeight: CGFloat = 0

        private lazy var textViewHeightConstraint: NSLayoutConstraint = {
            let constraint = heightAnchor.constraint(equalToConstant: Design.minContentHeight)
            constraint.isActive = true
            return constraint
        }()

        private func updateTextViewHeightConstraint() {
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

extension MessageInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        setSendButton(isEnabled: !textView.text.isEmpty)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        setSendButton(isEnabled: !textView.text.isEmpty)
    }
}

extension Comparable {
    func clamped(minimum: Self, maximum: Self) -> Self {
        max(minimum, min(maximum, self))
    }
}
