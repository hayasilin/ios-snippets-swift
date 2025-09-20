//
//  FTS5ContentlessDeleteTableViewController.swift
//  FTS5Demo
//
//  Created by user on 6/2/25.
//

import UIKit
import SQLite3

final class FTS5ContentlessDeleteTableViewController: UIViewController {
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

    private var mainDatabase: OpaquePointer?
    private var searchDatabase: OpaquePointer?

    private let ftsTable: FTSTable

    deinit {
        sqlite3_close(mainDatabase)
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

        mainDatabase = configureMainDatabase()
        createMainTable()

        searchDatabase = configureSearchDatabase()
        createFTS5ContentlessDeleteTable()

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
            ftsTable.logSuccess(function: #function)
            return db
        } else {
            assertionFailure()
            return nil
        }
    }

    private func createMainTable() {
        let sqlQueryString = """
        CREATE TABLE IF NOT EXISTS \(ftsTable.mainTableName)(
        id INTEGER PRIMARY KEY,
        text TEXT NOT NULL,
        message_id INTEGER
        );
        """
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(mainDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                ftsTable.logSuccess(function: #function)
            } else {
                logSQLErrorMessage(for: mainDatabase)
            }
        } else {
            logSQLErrorMessage(for: mainDatabase)
        }

        sqlite3_finalize(statement)
    }

    private func configureSearchDatabase() -> OpaquePointer? {
        guard let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            assertionFailure()
            return nil
        }

        let libraryURL = URL(fileURLWithPath: libraryPath).appendingPathComponent(ftsTable.ftsDatabaseFileName)
        let databasePath = libraryURL.path

        var db: OpaquePointer?
        if sqlite3_open(databasePath, &db) == SQLITE_OK {
            ftsTable.logSuccess(function: #function)
            return db
        } else {
            assertionFailure()
            return nil
        }
    }

    private func createFTS5ContentlessDeleteTable() {
        // Use ascii tokenizer allows non-ASCII characters (those with codepoints greater than 127) are always considered token characters, hence special character such as emoji ￣▽￣ is able to be searched.
        let sqlQueryString = "CREATE VIRTUAL TABLE IF NOT EXISTS \(ftsTable.ftsTableName) USING fts5(content='', text, tokenize = 'ascii', contentless_delete=1);"

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                ftsTable.logSuccess(function: #function)
            } else {
                logSQLErrorMessage(for: searchDatabase)
            }
        } else {
            logSQLErrorMessage(for: searchDatabase)
        }

        sqlite3_finalize(statement)
    }

    private func fetchItems() {
        let sqlQueryString = "SELECT * FROM \(ftsTable.mainTableName)";
        var statement: OpaquePointer?

        guard sqlite3_prepare(mainDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage(for: mainDatabase)
            return
        }

        items.removeAll()

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

    private func insertMainTable(with text: String) -> (text: String, messageID: Int32) {
        let sqlQueryString = "INSERT INTO items(id, text, message_id) VALUES (?, ?, ?);"
        var statement: OpaquePointer?

        let messageID = Int32(Date().timeIntervalSince1970)

        if sqlite3_prepare_v2(mainDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            // Don't set id manually becuase SQLite will do auto increment for it.
            sqlite3_bind_text(statement, 2, (text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 3, messageID)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage(for: mainDatabase)
            }
        } else {
            logSQLErrorMessage(for: mainDatabase)
        }

        sqlite3_finalize(statement)

        return (text, messageID)
    }

    private func insertSearchTable(with result: (text: String, messageID: Int32)) {
        let sqlQueryString = "INSERT INTO \(ftsTable.ftsTableName)(rowid, text) VALUES (?, ?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, result.messageID)
            sqlite3_bind_text(statement, 2, (result.text as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage(for: searchDatabase)
            }
        } else {
            logSQLErrorMessage(for: searchDatabase)
        }

        sqlite3_finalize(statement)
    }

    private func updateMainTable(with text: String, at index: Int32) {
        let sqlQueryString = "UPDATE \(ftsTable.mainTableName) SET text = ? WHERE id = ?;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(mainDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, index)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage(for: mainDatabase)
            }
        } else {
            logSQLErrorMessage(for: mainDatabase)
        }

        sqlite3_finalize(statement)
    }

    private func updateSearchTable(with text: String, messageID: Int32) {
        let sqlQueryString = "UPDATE \(ftsTable.ftsTableName) SET text = ? WHERE rowid = ?;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, messageID)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage(for: searchDatabase)
            }
        } else {
            logSQLErrorMessage(for: searchDatabase)
        }

        sqlite3_finalize(statement)
    }

    private func deleteFromMainTable(at index: Int32) {
        let sqlQueryString = "DELETE FROM \(ftsTable.mainTableName) WHERE id = ?"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(mainDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {

            sqlite3_bind_int(statement, 1, index)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage(for: mainDatabase)
            }
        } else {
            logSQLErrorMessage(for: mainDatabase)
        }
    }

    private func deleteFromSearchTable(at index: Int32) {
        let sqlQueryString = "DELETE FROM \(ftsTable.ftsTableName) WHERE rowid = ?"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            // Bind the row ID to the query
            sqlite3_bind_int(statement, 1, index)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage(for: searchDatabase)
            }
        } else {
            logSQLErrorMessage(for: searchDatabase)
        }
    }

    private func dropTable(name: String) {
        let queryString = "DROP TABLE \(name)"
        var statement: OpaquePointer?

        guard sqlite3_prepare(mainDatabase, queryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage(for: mainDatabase)
            return
        }

        if sqlite3_step(statement) != SQLITE_DONE {
            logSQLErrorMessage(for: mainDatabase)
        }
    }

    private func logSQLErrorMessage(for database: OpaquePointer?) {
        let errorMessage = String(cString: sqlite3_errmsg(database))
        print("SQL error: \(errorMessage)")
    }

    @objc
    private func didTapInsertButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: CommonText.insertTitle, preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = CommonText.insertTextFieldPlaceholder

        let action = UIAlertAction(title: CommonText.confirmTitle, style: .default) { _ in
            guard let textField = alert.textFields?.first, let text = textField.text else {
                return
            }
            let result = self.insertMainTable(with: text)
            self.insertSearchTable(with: result)
            self.fetchItems()
            self.tableView.reloadData()
        }

        alert.addAction(action)
        alert.addAction(UIAlertAction(title: CommonText.cancelTItle, style: .cancel))

        present(alert, animated: true)
    }

    @objc
    private func didTapDropButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: CommonText.dropTableTitle, preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = CommonText.dropTableTextFieldPlaceholder

        let action = UIAlertAction(title: CommonText.confirmTitle, style: .destructive) { _ in
            guard let textField = alert.textFields?.first, let text = textField.text else {
                return
            }

            self.dropTable(name: text)
            self.items.removeAll()
            self.tableView.reloadData()
        }

        alert.addAction(action)
        alert.addAction(UIAlertAction(title: CommonText.cancelTItle, style: .cancel))

        present(alert, animated: true)
    }
}

extension FTS5ContentlessDeleteTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredItems.count : items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: String(describing: UITableViewCell.self))

        let item = isFiltering ? filteredItems[indexPath.row] : items[indexPath.row]

        cell.textLabel?.text = item.text
        cell.detailTextLabel?.text = String(item.messageID)

        return cell
    }
}

extension FTS5ContentlessDeleteTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = isFiltering ? filteredItems[indexPath.row] : items[indexPath.row]

        let alert = UIAlertController(title: nil, message: CommonText.updateTitle, preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = item.text

        let action = UIAlertAction(title: CommonText.confirmTitle, style: .default) { _ in
            guard let textField = alert.textFields?.first, let text = textField.text else {
                return
            }
            self.updateMainTable(with: text, at: item.id)
            self.updateSearchTable(with: text, messageID: item.messageID)
            self.fetchItems()
            self.tableView.reloadData()
        }

        alert.addAction(action)
        alert.addAction(
            UIAlertAction(
                title: CommonText.copyTitle,
                style: .default,
                handler: { _ in
                    UIPasteboard.general.string = item.text
                }
            )
        )
        alert.addAction(UIAlertAction(title: CommonText.cancelTItle, style: .cancel))
        
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: CommonText.deleteTitle) { contextualAction, view, complete in
            guard contextualAction.style == .destructive else {
                complete(false)
                return
            }
            if self.isFiltering {
                let item = self.filteredItems[indexPath.row]
                self.filteredItems.remove(at: indexPath.row)
                self.deleteFromMainTable(at: item.id)
                self.deleteFromSearchTable(at: item.messageID)
            } else {
                let item = self.items[indexPath.row]
                self.items.remove(at: indexPath.row)
                self.deleteFromMainTable(at: item.id)
                self.deleteFromSearchTable(at: item.messageID)
            }

            tableView.deleteRows(at: [indexPath], with: .automatic)
            complete(true)
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension FTS5ContentlessDeleteTableViewController: UISearchResultsUpdating {
    private func performFTS5Search(with text: String) {
        filteredItems.removeAll()

        // let sqlQueryString = "SELECT rowid FROM fts5_contentless_delete AS d WHERE d.text MATCH '\(text)*';"
        let normalizedText = "\(text)*"
        let sqlQueryString = "SELECT rowid FROM \(ftsTable.ftsTableName) AS d WHERE d.text MATCH ?;"

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage(for: searchDatabase)
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

extension FTS5ContentlessDeleteTableViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        fetchItems()
        tableView.reloadData()
    }
}
