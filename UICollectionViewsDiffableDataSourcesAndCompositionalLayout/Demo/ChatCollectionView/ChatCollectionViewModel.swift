//
//  ChatCollectionViewModel.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import Foundation

struct ChatCollectionSection: Hashable {
    let id: UUID
    let items: [ChatCollectionMessageItem]
}

struct ChatCollectionMessageItem: Hashable {
    let id: UUID
    let type: ChatMessageViewModel
    let text: String
    let imageItem: ChatImageItem?

    init(
        id: UUID,
        type: ChatMessageViewModel,
        text: String? = nil,
        imageItem: ChatImageItem? = nil
    ) {
        self.id = id
        self.type = type
        self.text = text ?? ""
        self.imageItem = imageItem
    }
}

struct ChatImageItem: Hashable {
    let title: String
}

enum ChatMessageReplyType {
    case text
    case image
}

enum ChatMessageViewModel {
    case userInputText
    case textSuggestion
    case imageSuggestion
}

final class ChatCollectionViewModel {
    @Published private(set) var sections: [ChatCollectionSection] = []
    @Published private(set) var isLoading = false

    var messageViewModels: [ChatMessageViewModel] = []

    func fetchAIResponse(
        inputMessageItem: ChatCollectionMessageItem,
        replyType: ChatMessageReplyType
    ) {
        switch replyType {
        case .text:
            let inputTextSection = ChatCollectionSection(id: UUID(), items: [inputMessageItem])

            let dummyResponse: [ChatCollectionMessageItem] = [
                ChatCollectionMessageItem(
                    id: UUID(),
                    type: .textSuggestion,
                    text: "This is a dummy suggestion message 1"
                ),
                ChatCollectionMessageItem(
                    id: UUID(),
                    type: .textSuggestion,
                    text: "This is a dummy suggestion message 2"
                ),
                ChatCollectionMessageItem(
                    id: UUID(),
                    type: .textSuggestion,
                    text: "This is a dummy suggestion message 3"
                ),
                ChatCollectionMessageItem(
                    id: UUID(),
                    type: .textSuggestion,
                    text: "This is a dummy suggestion message 4"
                ),
                ChatCollectionMessageItem(
                    id: UUID(),
                    type: .textSuggestion,
                    text: "This is a dummy suggestion message 5"
                ),
            ]
            let textSuggestionSection = ChatCollectionSection(id: UUID(), items: dummyResponse)

            messageViewModels.append(.userInputText)
            messageViewModels.append(.textSuggestion)

            sections = [inputTextSection, textSuggestionSection]

        case .image:
            let dummyImageNames = [
                "bubble",
                "bubble.fill",
                "bubble.circle",
                "bubble.right",
                "bubble.left",
                "exclamationmark.bubble",
                "quote.bubble",
                "star.bubble",
                "character.bubble",
                "text.bubble",
                "captions.bubble",
                "info.bubble",
                "questionmark.bubble",
                "plus.bubble",
            ]

            let imageItems = dummyImageNames.map { ChatImageItem(title: $0) }

            let inputTextSection = ChatCollectionSection(id: UUID(), items: [inputMessageItem])

            var dummyResponse: [ChatCollectionMessageItem] = []
            for imageItem in imageItems {
                dummyResponse.append(ChatCollectionMessageItem(
                    id: UUID(),
                    type: .imageSuggestion,
                    imageItem: imageItem
                ))
            }
            let imageSection = ChatCollectionSection(id: UUID(), items: dummyResponse)

            messageViewModels.append(.userInputText)
            messageViewModels.append(.imageSuggestion)

            sections = [inputTextSection, imageSection]
        }
    }
}
