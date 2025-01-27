//
//  SQLiteDatabase.swift
//  FTS4Demo
//
//  Created by user on 1/25/25.
//

import Foundation
import SQLite3

enum DBScheme {
    case v1
    case v2
    case v3
    case v4

    var databaseFileName: String {
        switch self {
        case .v1:
            "search_v1.sqlite"
        case .v2:
            "search_v2.sqlite"
        case .v3:
            "search_v3.sqlite"
        case .v4:
            "search_v4.sqlite"
        }
    }
}

protocol SQLTable {
    static var createStatement: String { get }
}

struct Contact {
    let id: Int32
    let name: String
}

extension Contact: SQLTable {
    /// It's mandatory to use "id `INTEGER` PRIMARY KEY NOT NULL" instead of
    /// "id `INT` PRIMARY KEY NOT NULL" to create `id` as primary key with auto-increment,
    /// https://stackoverflow.com/questions/7905859/is-there-auto-increment-in-sqlite
    /// https://www.sqlite.org/faq.html#q1
    /// https://www.sqlite.org/autoinc.html
    static var createStatement: String {
        """
        CREATE TABLE IF NOT EXISTS contacts(
        id INTEGER PRIMARY KEY NOT NULL,
        name CHAR(255) NOT NULL
        );
        """
    }
}

struct FTS4 {
    let title: String
}

extension FTS4: SQLTable {
    static var createStatement: String {
        """
        CREATE VIRTUAL TABLE IF NOT EXISTS search USING fts4(title);
        """
    }
}

enum SQLiteError: Error {
    case openDatabase(message: String)
    case prepare(message: String)
    case step(message: String)
    case bind(message: String)
}

/// https://www.kodeco.com/6620276-sqlite-with-swift-tutorial-getting-started/page/3
///
/// - Usage
/// ```
/// let db: SQLiteDatabase
/// do {
///     db = try SQLiteDatabase.open(path: path)
///     print("Successfully opened connection to database.")
/// } catch SQLiteError.OpenDatabase(_) {
///     print("Unable to open database.")
/// }
/// ```
final class SQLiteDatabase {
    var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }

    private let dbPointer: OpaquePointer?

    deinit {
        sqlite3_close(dbPointer)
    }

    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }

    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer?
        // 1
        if sqlite3_open(path, &db) == SQLITE_OK {
            // 2
            return SQLiteDatabase(dbPointer: db)
        } else {
            // 3
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String(cString: errorPointer)
                throw SQLiteError.openDatabase(message: message)
            } else {
                throw SQLiteError.openDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
}

extension SQLiteDatabase {
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.prepare(message: errorMessage)
        }
        return statement
    }
}

extension SQLiteDatabase {
    /// - Usage:
    /// ```
    /// do {
    ///     try db.createTable(table: Contact.self)
    /// } catch {
    ///     print(db.errorMessage)
    /// }
    /// ```
    func createTable(table: SQLTable.Type) throws {
        let createTableStatement = try prepareStatement(sql: table.createStatement)

        defer {
            sqlite3_finalize(createTableStatement)
        }

        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }

        print("\(table) table created.")
    }
}

extension SQLiteDatabase {
    /// - Usage:
    /// ```
    /// do {
    ///     try db.insertContact(contact: Contact(id: 1, name: "Ray"))
    /// } catch {
    ///     print(db.errorMessage)
    /// }
    /// ```
    func insertContact(name: String) throws {
        let insertSql = "INSERT INTO contacts (id, name) VALUES (?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql)

        defer {
            sqlite3_finalize(insertStatement)
        }

        // Comment out below to not set id manually becuase SQLite will do auto increment for it.
        // sqlite3_bind_int(statement, 1, id)
        guard sqlite3_bind_text(insertStatement, 2, (name as NSString).utf8String, -1, nil) == SQLITE_OK
        else {
            throw SQLiteError.bind(message: errorMessage)
        }

        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }

        print("Successfully inserted contact \(name)")
    }

    func insertContactSearch(name: String) throws {
        let sqlQueryString = "INSERT INTO search (title) VALUES (?);"
        let insertStatement = try prepareStatement(sql: sqlQueryString)

        defer {
            sqlite3_finalize(insertStatement)
        }

        guard sqlite3_bind_text(insertStatement, 1, (name as NSString).utf8String, -1, nil) == SQLITE_OK else {
            throw SQLiteError.bind(message: errorMessage)
        }

        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }

        print("Successfully inserted search talbe: \(name).")
    }
}

extension SQLiteDatabase {
    /// - Usage:
    /// ```
    /// if let first = db.contact(id: 1) {
    ///     print("\(first.id) \(first.name)")
    /// }
    /// ```
    func contact(id: Int32) -> Contact? {
        let querySql = "SELECT * FROM contacts WHERE id = ?;"

        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }

        defer {
            sqlite3_finalize(queryStatement)
        }

        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
            return nil
        }

        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            return nil
        }

        let id = sqlite3_column_int(queryStatement, 0)
        guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1) else {
            print("Query result is nil.")
            return nil
        }

        let name = String(cString: queryResultCol1)

        return Contact(id: id, name: name)
    }

    func query() -> [Contact] {
        let sqlQueryString = "SELECT * FROM contacts";

        guard let queryStatement = try? prepareStatement(sql: sqlQueryString) else {
            return []
        }

        defer {
            sqlite3_finalize(queryStatement)
        }

        var contacts = [Contact]()

        while sqlite3_step(queryStatement) == SQLITE_ROW {
            let id = sqlite3_column_int(queryStatement, 0)
            let title = String(cString: sqlite3_column_text(queryStatement, 1))

            contacts.append(
                Contact(
                    id: id,
                    name: title
                )
            )
        }

        return contacts
    }
}

extension SQLiteDatabase {
    /// - Usage:
    /// ```
    /// do {
    ///     try db.updateContact(name: "Ray", at: 1)
    /// } catch {
    ///     print(db.errorMessage)
    /// }
    /// ```
    func updateContact(name: String, at index: Int32) throws {
        let sqlQueryString = "UPDATE contacts SET name = ? WHERE id = ?;"

        let statement = try prepareStatement(sql: sqlQueryString)

        defer {
            sqlite3_finalize(statement)
        }

        guard sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil) == SQLITE_OK &&
                sqlite3_bind_int(statement, 2, index) == SQLITE_OK
        else {
            throw SQLiteError.bind(message: errorMessage)
        }

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }

        print("Successfully updated contacts \(name)")
    }

    func updateContactSearch(name: String, at index: Int32) throws {
        let sqlQueryString = "UPDATE search SET title = ? WHERE rowid = ?;"

        let statement = try prepareStatement(sql: sqlQueryString)

        defer {
            sqlite3_finalize(statement)
        }

        guard sqlite3_bind_text(statement, 1, (name as NSString).utf8String, -1, nil) == SQLITE_OK &&
                sqlite3_bind_int(statement, 2, index) == SQLITE_OK
        else {
            throw SQLiteError.bind(message: errorMessage)
        }

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }

        print("Successfully updated search \(name)")
    }
}

extension SQLiteDatabase {
    func deleteContact(at index: Int32) throws {
        let sqlQueryString = "DELETE FROM contacts WHERE id = \(index)"

        let statement = try prepareStatement(sql: sqlQueryString)

        defer {
            sqlite3_finalize(statement)
        }

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }

        print("Successfully deleted contact at \(index).")
    }

    func deleteContactSearch(at index: Int32) throws {
        let sqlQueryString = "DELETE FROM search WHERE rowid = ?"

        let statement = try prepareStatement(sql: sqlQueryString)

        defer {
            sqlite3_finalize(statement)
        }

        // Bind the row ID to the query
        guard sqlite3_bind_int(statement, 1, index) == SQLITE_OK else {
            throw SQLiteError.bind(message: errorMessage)
        }

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }

        print("Successfully deleted search at \(index).")
    }
}

extension SQLiteDatabase {
    func performSearchContacts(with text: String) throws -> [Contact] {
        let sqlQueryString = "SELECT rowid, title FROM search WHERE search MATCH '\(text)*';"

        let statement = try prepareStatement(sql: sqlQueryString)

        defer {
            sqlite3_finalize(statement)
        }

        var contacts = [Contact]()

        while sqlite3_step(statement) == SQLITE_ROW {
            let rowid = sqlite3_column_int(statement, 0)
            let name = String(cString: sqlite3_column_text(statement, 1))
            contacts.append(
                Contact(
                    id: rowid,
                    name: name
                )
            )
        }

        return contacts
    }
}
