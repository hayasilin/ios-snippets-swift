//
//  FTS5ContentlessTableViewController.swift
//  FTS5Demo
//
//  Created by user on 5/30/25.
//

import UIKit
import SQLite3

final class FTS5ContentlessTableViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        return tableView
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = CommonText.searchBarPlaceholder
        return searchController
    }()

    private var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    private var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    private var items = [Item]()
    private var filteredItems = [Item]()

    private var itemDatabase: OpaquePointer?
    private var fts5ContentlessDatabase: OpaquePointer?

    private let ftsTable: FTSTable

    deinit {
        sqlite3_close(itemDatabase)
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
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDropButton)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapInsertButton))
        ]
        navigationItem.rightBarButtonItems = rightBarButtonItems

        navigationItem.searchController = searchController

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        itemDatabase = configureMainDatabase()
        createItemTable()

        fts5ContentlessDatabase = configureFTS5ContentlessDatabase()
        createFTS5ContentlessTable()

        fetchItems()
        tableView.reloadData()
    }

    private func configureMainDatabase() -> OpaquePointer? {
        guard let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            assertionFailure()
            return nil
        }

        let libraryURL = URL(fileURLWithPath: libraryPath).appendingPathComponent(ftsTable.mainDatabaseFileName)
        let databasePath = libraryURL.path

        var db: OpaquePointer?
        if sqlite3_open(databasePath, &db) == SQLITE_OK {
            print("Open main database success, path: \(databasePath)")
            return db
        } else {
            assertionFailure()
            return nil
        }
    }

    private func createItemTable() {
        let sqlQueryString = """
                            CREATE TABLE IF NOT EXISTS items(
                            id INTEGER PRIMARY KEY,
                            text TEXT NOT NULL,
                            message_id INTEGER
                            );
                            """
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(itemDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print(ftsTable.log)
            } else {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func configureFTS5ContentlessDatabase() -> OpaquePointer? {
        guard let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            assertionFailure()
            return nil
        }

        let libraryURL = URL(fileURLWithPath: libraryPath).appendingPathComponent(ftsTable.fts5DatabaseFileName)
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

    private func createFTS5ContentlessTable() {
        let sqlQueryString = "CREATE VIRTUAL TABLE IF NOT EXISTS fts5_contentless USING fts5(content='', text);"

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(fts5ContentlessDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print(ftsTable.log)
            } else {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func fetchItems() {
        items.removeAll()

        let sqlQueryString = "SELECT * FROM items";
        var statement: OpaquePointer?

        guard sqlite3_prepare(itemDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage()
            return
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int(statement, 0)
            let text = String(cString: sqlite3_column_text(statement, 1))
            let messageID = sqlite3_column_int(statement, 2)

            items.append(
                Item(
                    id: id,
                    text: text,
                    messageID: messageID
                )
            )
        }

        sqlite3_finalize(statement)
    }

    private func insertItem(with text: String) -> (text: String, messageID: Int32) {
        let sqlQueryString = "INSERT INTO items(id, text, message_id) VALUES (?, ?, ?);"
        var statement: OpaquePointer?

        let randomInt = Int32.random(in: 1..<10000)

        if sqlite3_prepare_v2(itemDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            // Don't set id manually becuase SQLite will do auto increment for it.
            sqlite3_bind_text(statement, 2, (text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, randomInt)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)

        return (text, randomInt)
    }

    private func insertFTS5Contentless(with result: (text: String, messageID: Int32)) {
        let sqlQueryString = "INSERT INTO fts5_contentless(rowid, text) VALUES (?, ?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(self.fts5ContentlessDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, result.messageID)
            sqlite3_bind_text(statement, 2, (result.text as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func updateItem(text: String, at index: Int32) {
        let sqlQueryString = "UPDATE items SET text = ? WHERE id = ?;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(itemDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, index)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func updateFTS5Contentless(text: String, messageID: Int32) {
        let sqlQueryString = "UPDATE fts5_contentless SET text=? WHERE rowid=?;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(fts5ContentlessDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, messageID)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func deleteFromItemTable(at index: Int32) {
        let sqlQueryString = "DELETE FROM items WHERE id = \(index)"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(itemDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }
    }

    private func deleteFromFTS5ContentlessTable(at index: Int32) {
        let sqlQueryString = "INSERT INTO fts5_contentless(fts5_contentless, rowid) VALUES('delete', ?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(fts5ContentlessDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            // Bind the row ID to the query
            sqlite3_bind_int(statement, 1, index)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }
    }

    private func dropTable(name: String) {
        let queryString = "DROP TABLE \(name)"
        var statement: OpaquePointer?

        guard sqlite3_prepare(itemDatabase, queryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage()
            return
        }

        if sqlite3_step(statement) != SQLITE_DONE {
            logSQLErrorMessage()
        }
    }

    private func logSQLErrorMessage() {
        let errorMessage = String(cString: sqlite3_errmsg(itemDatabase))
        print("SQL error: \(errorMessage)")
    }

    @objc
    private func didTapInsertButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "Insert", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = CommonText.insertTextFieldPlaceholder

        let action = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alert.textFields?.first, let text = textField.text else {
                return
            }
            let result = self.insertItem(with: text)
            self.insertFTS5Contentless(with: result)
            self.fetchItems()
            self.tableView.reloadData()
        }

        alert.addAction(action)
        present(alert, animated: true)
    }

    @objc
    private func didTapDropButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "Drop Table", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = CommonText.dropTableTextFieldPlaceholder

        let action = UIAlertAction(title: "Drop table", style: .destructive) { _ in
            guard let textField = alert.textFields?.first, let text = textField.text else {
                return
            }

            self.dropTable(name: text)
            self.items.removeAll()
            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

extension FTS5ContentlessTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredItems.count : items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)

        let item = isFiltering ? filteredItems[indexPath.row] : items[indexPath.row]

        cell.textLabel?.text = item.text
        return cell
    }
}

extension FTS5ContentlessTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = isFiltering ? filteredItems[indexPath.row] : items[indexPath.row]

        let alert = UIAlertController(title: nil, message: "Update", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = item.text

        let action = UIAlertAction(title: "Update", style: .default) { _ in
            guard let textField = alert.textFields?.first, let text = textField.text else {
                return
            }
            self.updateItem(text: text, at: item.id)
            self.updateFTS5Contentless(text: text, messageID: item.messageID)
            self.fetchItems()
            self.tableView.reloadData()
        }

        alert.addAction(action)
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { contextualAction, view, complete in
            guard contextualAction.style == .destructive else {
                complete(false)
                return
            }
            if self.isFiltering {
                let item = self.filteredItems[indexPath.row]
                self.filteredItems.remove(at: indexPath.row)
                self.deleteFromItemTable(at: item.id)
                self.deleteFromFTS5ContentlessTable(at: item.messageID)
            } else {
                let item = self.items[indexPath.row]
                self.items.remove(at: indexPath.row)
                self.deleteFromItemTable(at: item.id)
                self.deleteFromFTS5ContentlessTable(at: item.messageID)
            }

            tableView.deleteRows(at: [indexPath], with: .automatic)
            complete(true)
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension FTS5ContentlessTableViewController: UISearchResultsUpdating {
    private func performFTS5Search(with text: String) {
        filteredItems.removeAll()

        let normalizedText = "\(text)*"
        let sqlQueryString = "SELECT rowid FROM fts5_contentless AS d WHERE d.text MATCH ?;"

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(fts5ContentlessDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage()
            return
        }

        sqlite3_bind_text(statement, 1, (normalizedText as NSString).utf8String, -1, nil)

        while sqlite3_step(statement) == SQLITE_ROW {
            let rowid = sqlite3_column_int(statement, 0)
            if let item = items.first(where: { item in
                item.messageID == rowid
            }) {
                filteredItems.append(item)
            }
        }

        sqlite3_finalize(statement)
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            return
        }

        performFTS5Search(with: searchText.lowercased())
        tableView.reloadData()
    }
}

extension FTS5ContentlessTableViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        fetchItems()
        tableView.reloadData()
    }
}
