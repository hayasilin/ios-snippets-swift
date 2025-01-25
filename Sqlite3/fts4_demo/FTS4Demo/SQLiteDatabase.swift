//
//  SQLiteDatabase.swift
//  FTS4Demo
//
//  Created by user on 1/25/25.
//

import Foundation
import SQLite3

protocol SQLTable {
    static var createStatement: String { get }
}

struct Contact {
    let id: Int32
    let name: String
}

extension Contact: SQLTable {
    static var createStatement: String {
        """
        CREATE TABLE contacts(
        id INT PRIMARY KEY NOT NULL,
        name CHAR(255)
        );
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
        // 1
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        // 2
        defer {
            sqlite3_finalize(createTableStatement)
        }
        // 3
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
    func insertContact(contact: Contact) throws {
        let insertSql = "INSERT INTO contacts (id, name) VALUES (?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql)

        defer {
            sqlite3_finalize(insertStatement)
        }

        guard sqlite3_bind_int(insertStatement, 1, contact.id) == SQLITE_OK  &&
                sqlite3_bind_text(insertStatement, 2, (contact.name as NSString).utf8String, -1, nil) == SQLITE_OK
        else {
            throw SQLiteError.bind(message: errorMessage)
        }

        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }

        print("Successfully inserted row.")
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
}

