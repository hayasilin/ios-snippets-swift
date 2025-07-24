//
//  FTS4ExternalContentTableViewController.swift
//  FTS4Demo
//
//  Created by user on 7/23/25.
//

import UIKit
import SQLite3

private struct Message {
    let id: Int32
    let text: String
}

final class FTS4ExternalContentTableViewController: UIViewController {
//    private lazy var tableView: UITableView = {
//        let tableView = UITableView(frame: .zero)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.estimatedRowHeight = 44
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
//        return tableView
//    }()
//
//    private lazy var searchController: UISearchController = {
//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.searchResultsUpdater = self
//        searchController.searchBar.delegate = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = CommonText.searchBarPlaceholder
//        return searchController
//    }()

//    private var isSearchBarEmpty: Bool {
//        searchController.searchBar.text?.isEmpty ?? true
//    }
//
//    private var isFiltering: Bool {
//        searchController.isActive && !isSearchBarEmpty
//    }

    private var messages = [Message]()
    private var filteredMessages = [Message]()

    private var searchDatabase: OpaquePointer?

    private let ftsTable: FTSTable

    deinit {
        sqlite3_close(searchDatabase)
    }

    init(ftsTable: FTSTable) {
        self.ftsTable = ftsTable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.title = ftsTable.title

        let rightBarButtonItems = [
//            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDropButton)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapInsertButton))
        ]
        navigationItem.rightBarButtonItems = rightBarButtonItems

//        navigationItem.searchController = searchController
//
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(tableView)
//
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])

        searchDatabase = openFTS4DatabaseConnection()
        createTables()
        insertData()
//        createFTS4ExternalContentTable()
//
//        fetchMessages()
//        tableView.reloadData()
    }

    private func openFTS4DatabaseConnection() -> OpaquePointer? {
        guard let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            assertionFailure()
            return nil
        }

        let libraryURL = URL(fileURLWithPath: libraryPath).appendingPathComponent(ftsTable.fts4DatabaseFileName)
        let databasePath = libraryURL.path

        var db: OpaquePointer?
        if sqlite3_open(databasePath, &db) == SQLITE_OK {
            print("Open fts database success, path: \(databasePath)")
            return db
        } else {
            assertionFailure()
            return nil
        }
    }

    private func createTables() {
        let createT2TableQuery = """
        CREATE TABLE IF NOT EXISTS t2 (
            id INTEGER PRIMARY KEY,
            text TEXT
        );
        """

        let createT3TableQuery = """
        CREATE VIRTUAL TABLE IF NOT EXISTS t3 USING fts4(content="t2", text);
        """

        if sqlite3_exec(searchDatabase, createT2TableQuery, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(searchDatabase)!)
            print("Error creating t2 table: \(errmsg)")
        }

        if sqlite3_exec(searchDatabase, createT3TableQuery, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(searchDatabase)!)
            print("Error creating t3 table: \(errmsg)")
        }
    }

    private func insertData() {
        let insertT2Query = """
            INSERT INTO t2 (id, text) VALUES
            (2, 'qaz'),
            (3, 'wsx');
            """

        if sqlite3_exec(searchDatabase, insertT2Query, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(searchDatabase)!)
            print("Error inserting into t2: \(errmsg)")
        }

        let insertT3Query = """
            INSERT INTO t3 (docid, text)
            SELECT id, text FROM t2;
            """

        if sqlite3_exec(searchDatabase, insertT3Query, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(searchDatabase)!)
            print("Error inserting into t3: \(errmsg)")
        }
    }

    func search(for term: String) {
        let query = "SELECT * FROM t3 WHERE t3 MATCH 'qaz';"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(searchDatabase, query, -1, &statement, nil) == SQLITE_OK {
//            sqlite3_bind_text(statement, 1, term, -1, nil)

            while sqlite3_step(statement) == SQLITE_ROW {
                let b = String(cString: sqlite3_column_text(statement, 0))
//                let c = String(cString: sqlite3_column_text(statement, 1))

//                print("Result: docid = \(docid), b = \(b), c = \(c)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(searchDatabase)!)
            print("Error preparing search statement: \(errmsg)")
        }

        sqlite3_finalize(statement)
    }

//    private func createFTS4ExternalContentTable() {
//        let sqlQueryString = """
//        CREATE VIRTUAL TABLE IF NOT EXISTS \(ftsTable.fts4DatabaseTableName) \
//        USING FTS4 (content='\(ftsTable.mainDatabaseTableName)', text);
//        """
//
//        var statement: OpaquePointer?
//
//        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
//            if sqlite3_step(statement) != SQLITE_DONE {
//                logSQLErrorMessage()
//            }
//        } else {
//            logSQLErrorMessage()
//        }
//
//        sqlite3_finalize(statement)
//    }
//
//    private func fetchMessages() {
//        let sqlQueryString = "SELECT * FROM \(ftsTable.mainDatabaseTableName)";
//        var statement: OpaquePointer?
//
//        guard sqlite3_prepare(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
//            logSQLErrorMessage()
//            return
//        }
//
//        messages.removeAll()
//
//        while sqlite3_step(statement) == SQLITE_ROW {
//            let id = sqlite3_column_int(statement, 0)
//            let text = String(cString: sqlite3_column_text(statement, 1))
//
//            messages.append(
//                Message(
//                    id: id,
//                    text: text
//                )
//            )
//        }
//
//        sqlite3_finalize(statement)
//    }
//
//    private func insertMessageDatabase(with message: Message) {
//        let sqlQueryString = "INSERT INTO \(ftsTable.mainDatabaseTableName)(id, text) VALUES (?, ?);"
//        var statement: OpaquePointer?
//
//        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
//            sqlite3_bind_int(statement, 1, message.id)
//            sqlite3_bind_text(statement, 2, (message.text as NSString).utf8String, -1, nil)
//
//            if sqlite3_step(statement) != SQLITE_DONE {
//                logSQLErrorMessage()
//            }
//        } else {
//            logSQLErrorMessage()
//        }
//
//        sqlite3_finalize(statement)
//    }
//
//    private func insertFTS4Database(with message: Message) {
//        let sqlQueryString = "INSERT INTO \(ftsTable.fts4DatabaseTableName)(docid, text) SELECT id, text FROM \(ftsTable.mainDatabaseTableName)"
//        var statement: OpaquePointer?
//
//        if sqlite3_prepare_v2(self.searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
//            sqlite3_bind_int(statement, 1, message.id)
//            sqlite3_bind_text(statement, 2, (message.text as NSString).utf8String, -1, nil)
//
//            if sqlite3_step(statement) != SQLITE_DONE {
//                logSQLErrorMessage()
//            }
//        } else {
//            logSQLErrorMessage()
//        }
//
//        sqlite3_finalize(statement)
//    }
//
//    private func updateMessage(text: String, at index: Int32) {
//        let sqlQueryString = "UPDATE \(ftsTable.mainDatabaseTableName) SET text = ? WHERE id = ?;"
//        var statement: OpaquePointer?
//
//        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
//            sqlite3_bind_text(statement, 1, (text as NSString).utf8String, -1, nil)
//            sqlite3_bind_int(statement, 2, index)
//
//            if sqlite3_step(statement) != SQLITE_DONE {
//                logSQLErrorMessage()
//            }
//        } else {
//            logSQLErrorMessage()
//        }
//
//        sqlite3_finalize(statement)
//    }
//
//    private func updateFTS4Database(text: String, at index: Int32) {
//        let sqlQueryString = "UPDATE \(ftsTable.fts4DatabaseTableName) SET text = ? WHERE rowid = ?;"
//        var statement: OpaquePointer?
//
//        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
//            sqlite3_bind_text(statement, 1, (text as NSString).utf8String, -1, nil)
//            sqlite3_bind_int(statement, 2, index)
//
//            if sqlite3_step(statement) != SQLITE_DONE {
//                logSQLErrorMessage()
//            }
//        } else {
//            logSQLErrorMessage()
//        }
//
//        sqlite3_finalize(statement)
//    }
//
//    private func deleteFromMessageDatabase(at index: Int32) {
//        let sqlQueryString = "DELETE FROM \(ftsTable.mainDatabaseTableName) WHERE id = \(index)"
//        var statement: OpaquePointer?
//
//        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
//            if sqlite3_step(statement) == SQLITE_DONE {
//                print("Delete data success")
//            } else {
//                logSQLErrorMessage()
//            }
//        } else {
//            logSQLErrorMessage()
//        }
//    }
//
//    private func deleteFromFTS4Database(at index: Int32) {
//        let sqlQueryString = "DELETE FROM \(ftsTable.fts4DatabaseTableName) WHERE rowid = \(index)"
//        var statement: OpaquePointer?
//
//        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
//            if sqlite3_step(statement) == SQLITE_DONE {
//                print("Delete data success")
//            } else {
//                logSQLErrorMessage()
//            }
//        } else {
//            logSQLErrorMessage()
//        }
//    }
//
//    private func dropTable(name: String) {
//        let queryString = "DROP TABLE \(name)"
//        var statement: OpaquePointer?
//
//        guard sqlite3_prepare(searchDatabase, queryString, -1, &statement, nil) == SQLITE_OK else {
//            logSQLErrorMessage()
//            return
//        }
//
//        if sqlite3_step(statement) == SQLITE_DONE {
//            print("Drop table success")
//        } else {
//            logSQLErrorMessage()
//        }
//    }
//
//    private func logSQLErrorMessage() {
//        let errorMessage = String(cString: sqlite3_errmsg(searchDatabase))
//        print("SQL error: \(errorMessage)")
//    }
//
    @objc
    private func didTapInsertButton(_ sender: UIBarButtonItem) {
        search(for: "k")

//        let alert = UIAlertController(title: nil, message: "Insert", preferredStyle: .alert)
//        alert.addTextField()
//        alert.textFields?.first?.placeholder = "Input text"
//
//        let action = UIAlertAction(title: "Save", style: .default) { _ in
//            guard let textField = alert.textFields?.first, let text = textField.text else {
//                return
//            }

//            let message = Message(
//                id: Int32(Date().timeIntervalSince1970),
//                text: text
//            )
//
//            self.insertMessageDatabase(with: message)
//            self.insertFTS4Database(with: message)
//            self.fetchMessages()
//            self.tableView.reloadData()
//        }
//
//        alert.addAction(action)
//        present(alert, animated: true)
    }
//
//    @objc
//    private func didTapDropButton(_ sender: UIBarButtonItem) {
//        let alert = UIAlertController(title: nil, message: "Drop Table", preferredStyle: .alert)
//        alert.addTextField()
//        alert.textFields?.first?.placeholder = "Input table name"
//
//        let action = UIAlertAction(title: "Drop table", style: .destructive) { _ in
//            guard let textField = alert.textFields?.first, let text = textField.text else {
//                return
//            }
//
//            self.dropTable(name: text)
//            self.messages.removeAll()
//            self.tableView.reloadData()
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//
//        alert.addAction(action)
//        alert.addAction(cancelAction)
//        present(alert, animated: true)
//    }
}

//extension FTS4ExternalContentTableViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        isFiltering ? filteredMessages.count : messages.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: String(describing: UITableViewCell.self))
//        let message = isFiltering ? filteredMessages[indexPath.row] : messages[indexPath.row]
//
//        cell.textLabel?.text = message.text
//        cell.detailTextLabel?.text = String(message.id)
//
//        return cell
//    }
//}
//
//extension FTS4ExternalContentTableViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        let message = isFiltering ? filteredMessages[indexPath.row] : messages[indexPath.row]
//
//        let alert = UIAlertController(title: nil, message: "Update", preferredStyle: .alert)
//        alert.addTextField()
//        alert.textFields?.first?.placeholder = message.text
//
//        let action = UIAlertAction(title: "Update", style: .default) { _ in
//            guard let textField = alert.textFields?.first, let text = textField.text else {
//                return
//            }
//            self.updateMessage(text: text, at: message.id)
//            self.updateFTS4Database(text: text, at: message.id)
//            self.fetchMessages()
//            self.tableView.reloadData()
//        }
//
//        alert.addAction(action)
//        present(alert, animated: true)
//    }
//
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { contextualAction, view, complete in
//            guard contextualAction.style == .destructive else {
//                complete(false)
//                return
//            }
//            if self.isFiltering {
//                let message = self.filteredMessages[indexPath.row]
//                self.filteredMessages.remove(at: indexPath.row)
//                self.deleteFromMessageDatabase(at: message.id)
//            } else {
//                let message = self.messages[indexPath.row]
//                self.messages.remove(at: indexPath.row)
//                self.deleteFromMessageDatabase(at: message.id)
//            }
//
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            complete(true)
//        }
//        deleteAction.backgroundColor = .red
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }
//}

//extension FTS4ExternalContentTableViewController: UISearchResultsUpdating {
//    private func performFTS4Search(with text: String) -> [Int32] {
//        let sqlQueryString = "SELECT * FROM \(ftsTable.fts4DatabaseTableName) WHERE \(ftsTable.fts4DatabaseTableName) MATCH '\(text)*';"
//        var statement: OpaquePointer?
//
//        guard sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
//            logSQLErrorMessage()
//            return []
//        }
//
//        var messageIDs = [Int32]()
//
//        while sqlite3_step(statement) == SQLITE_ROW {
//            let rowID = sqlite3_column_int(statement, 0)
//            messageIDs.append(rowID)
//        }
//
//        sqlite3_finalize(statement)
//
//        return messageIDs
//    }
//
//    private func querySelectedMessages(with messageIDs: [Int32]) {
//        filteredMessages.removeAll()
//
//        guard !messageIDs.isEmpty else {
//            return
//        }
//
//        let messageIDCollectionString = messageIDs.map{ String($0) }.joined(separator: ",")
//        let sqlQueryString = "SELECT * FROM \(ftsTable.mainDatabaseTableName) WHERE rowid IN (\(messageIDCollectionString)) ORDER BY id DESC";
//
//        var statement: OpaquePointer?
//
//        guard sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
//            logSQLErrorMessage()
//            return
//        }
//
//        while sqlite3_step(statement) == SQLITE_ROW {
//            let id = sqlite3_column_int(statement, 0)
//            let text = String(cString: sqlite3_column_text(statement, 1))
//            filteredMessages.append(Message(id: id, text: text))
//        }
//
//        sqlite3_finalize(statement)
//    }
//
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
//            return
//        }
//
//        let messageIDs = performFTS4Search(with: searchText.lowercased())
//        querySelectedMessages(with: messageIDs)
//        tableView.reloadData()
//    }
//}
//
//extension FTS4ExternalContentTableViewController: UISearchBarDelegate {
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        fetchMessages()
//        tableView.reloadData()
//    }
//}
