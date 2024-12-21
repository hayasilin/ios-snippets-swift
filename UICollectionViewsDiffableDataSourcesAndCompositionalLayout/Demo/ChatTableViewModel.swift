//
//  ChatTableViewModel.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import Foundation

enum ChatSection {
    case main
}

struct ChatMessageItem: Hashable {
    let id: UUID
    let text: String
    let type: ChatAILayerMessageType
}

enum ChatAILayerMessageType {
    case user
    case ai
}

final class ChatTableViewModel {
    @Published private(set) var items: [ChatMessageItem] = []
    @Published private(set) var isLoading = false

    func refreshMessages(inputMessage: ChatMessageItem) {
        let dummyResults: [ChatMessageItem] = [
            inputMessage,
            ChatMessageItem(id: UUID(), text: "This is a dummy suggestion message 1", type: .ai),
            ChatMessageItem(id: UUID(), text: "This is a dummy suggestion message 2", type: .ai),
            ChatMessageItem(id: UUID(), text: "This is a dummy suggestion message 3", type: .ai),
            ChatMessageItem(id: UUID(), text: "This is a dummy suggestion message 4", type: .ai),
            ChatMessageItem(id: UUID(), text: "This is a dummy suggestion message 5", type: .ai),
        ]
        items = dummyResults
    }
}
