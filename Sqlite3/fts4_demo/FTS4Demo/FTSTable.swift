//
//  FTSTable.swift
//  FTS4Demo
//
//  Created by user on 7/23/25.
//

import Foundation

enum FTSTable {
    case defaultTable
    case contentlessTable
    case externalContentTable

    var title: String {
        switch self {
        case .defaultTable:
            "Default FTS4"
        case .contentlessTable:
            "Contentless FTS4"
        case .externalContentTable:
            "External-content FTS4"
        }
    }

    var mainDatabaseTableName: String {
        switch self {
        case .defaultTable:
            "movies"
        case .contentlessTable:
            "message_contentless"
        case .externalContentTable:
            "message_external_content"
        }
    }

    var fts4DatabaseTableName: String {
        switch self {
        case .defaultTable:
            "fts4_default"
        case .contentlessTable:
            "fts4_contentless"
        case .externalContentTable:
            "fts4_external_content"
        }
    }

    var mainDatabaseFileName: String {
        "\(mainDatabaseTableName).sqlite"
    }

    var fts4DatabaseFileName: String {
        "\(fts4DatabaseTableName).sqlite"
    }
}

enum CommonText {
    static let searchBarPlaceholder = "Input to search"
    static let insertTextFieldPlaceholder = "Input text"
    static let dropTableTextFieldPlaceholder = "Input table name"
}
