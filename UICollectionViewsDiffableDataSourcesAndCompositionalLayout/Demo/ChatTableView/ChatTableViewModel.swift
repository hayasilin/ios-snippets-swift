//
//  ChatTableViewModel.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import Foundation

enum ChatTableSection {
    case main
}

struct ChatTableMessageItem: Hashable {
    let id: UUID
    let text: String
    let type: ChatMessageType
}

enum ChatMessageType {
    case user
    case ai
}

final class ChatTableViewModel {
    @Published private(set) var items: [ChatTableMessageItem] = []
    @Published private(set) var isLoading = false

    func refreshMessages(inputMessage: ChatTableMessageItem) {
        let dummyResults: [ChatTableMessageItem] = [
            inputMessage,
            ChatTableMessageItem(id: UUID(), text: "This is a dummy suggestion message 1", type: .ai),
            ChatTableMessageItem(id: UUID(), text: "This is a dummy suggestion message 2", type: .ai),
            ChatTableMessageItem(id: UUID(), text: "This is a dummy suggestion message 3", type: .ai),
            ChatTableMessageItem(id: UUID(), text: "This is a dummy suggestion message 4", type: .ai),
            ChatTableMessageItem(id: UUID(), text: "This is a dummy suggestion message 5", type: .ai),
        ]
        items = dummyResults
    }
}
