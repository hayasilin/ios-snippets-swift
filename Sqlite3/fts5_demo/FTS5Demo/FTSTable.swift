//
//  FTSTable.swift
//  FTS5Demo
//
//  Created by user on 6/2/25.
//

import Foundation

enum CommonText {
    static let searchBarPlaceholder = "Input to search"
    static let insertTextFieldPlaceholder = "Input text"
    static let dropTableTextFieldPlaceholder = "Input table name"
}

enum FTSTable {
    case defaultTable
    case contentlessTable
    case contentlessDeleteTable

    var title: String {
        switch self {
        case .defaultTable:
            "Default FTS5"
        case .contentlessTable:
            "Contentless FTS5"
        case .contentlessDeleteTable:
            "Contentless-delete FTS5"
        }
    }

    var mainDatabaseFileName: String {
        switch self {
        case .defaultTable:
            "movie.sqlite"
        case .contentlessTable:
            "message_contentless.sqlite"
        case .contentlessDeleteTable:
            "message_contentless_delete.sqlite"
        }
    }

    var fts5DatabaseFileName: String {
        switch self {
        case .defaultTable:
            "search.sqlite"
        case .contentlessTable:
            "fts5_contentless.sqlite"
        case .contentlessDeleteTable:
            "fts5_contentless_delete.sqlite"
        }
    }

    var log: String {
        "Create \(title) table success"
    }
}

struct Movie {
    let id: Int32
    let title: String
}

struct Item {
    let id: Int32
    let text: String
    let messageID: Int32
}
