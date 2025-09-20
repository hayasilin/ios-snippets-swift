//
//  FTSTable.swift
//  FTS5Demo
//
//  Created by user on 6/2/25.
//

import Foundation

enum CommonText {
    static let insertTitle = "Insert"
    static let updateTitle = "Update"
    static let copyTitle = "Copy"
    static let cancelTItle = "Cancel"
    static let confirmTitle = "Confirm"
    static let deleteTitle = "Delete"
    static let dropTableTitle = "Drop Table"

    static let searchBarPlaceholder = "Input to search"
    static let insertTextFieldPlaceholder = "Input text"
    static let dropTableTextFieldPlaceholder = "Input table name"
}

enum FTSTable {
    case fts5DefaultTable
    case fts5ContentlessTable
    case fts5ContentlessDeleteTable
    case fts4ContentlessTable

    var title: String {
        switch self {
        case .fts5DefaultTable:
            "FTS5 Default"
        case .fts5ContentlessTable:
            "FTS5 Contentless"
        case .fts5ContentlessDeleteTable:
            "FTS5 Contentless-delete"
        case .fts4ContentlessTable:
            "FTS4 Contentless"
        }
    }

    var mainDatabaseFileName: String {
        switch self {
        case .fts5DefaultTable:
            "movie_default.sqlite"
        case .fts5ContentlessTable:
            "message_contentless.sqlite"
        case .fts5ContentlessDeleteTable:
            "message_contentless_delete.sqlite"
        case .fts4ContentlessTable:
            "movie_contentless.sqlite"
        }
    }

    var ftsDatabaseFileName: String {
        switch self {
        case .fts5DefaultTable:
            "fts5_default.sqlite"
        case .fts5ContentlessTable:
            "fts5_contentless.sqlite"
        case .fts5ContentlessDeleteTable:
            "fts5_contentless_delete.sqlite"
        case .fts4ContentlessTable:
            "fts4_contentless.sqlite"
        }
    }

    var mainTableName: String {
        switch self {
        case .fts5DefaultTable:
            "movies"
        case .fts5ContentlessTable:
            "items"
        case .fts5ContentlessDeleteTable:
            "items"
        case .fts4ContentlessTable:
            "movies"
        }
    }

    var ftsTableName: String {
        switch self {
        case .fts5DefaultTable:
            "fts5_default"
        case .fts5ContentlessTable:
            "fts5_contentless"
        case .fts5ContentlessDeleteTable:
            "fts5_contentless_delete"
        case .fts4ContentlessTable:
            "fts4_contentless"
        }
    }

    func logSuccess(function: String) {
        print("\(function) success")
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
