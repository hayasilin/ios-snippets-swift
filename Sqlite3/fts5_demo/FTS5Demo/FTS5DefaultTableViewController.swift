//
//  FTS5DefaultTableViewController.swift
//  FTS5Demo
//
//  Created by user on 6/2/25.
//

import UIKit
import SQLite3

/// FTS5 using default table to perform CRUD.
/// - Create: "CREATE VIRTUAL TABLE IF NOT EXISTS fts5_default USING FTS5(title, tokenize = 'porter ascii');"
/// - Insert: "INSERT INTO fts5_default(title) VALUES (?);"
/// - Search: "SELECT rowid, title FROM fts5_default WHERE title MATCH 'text*';"
final class FTS5DefaultTableViewController: UIViewController {
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

    private var movies = [Movie]()
    private var filteredMovies = [Movie]()

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
        createSearchTable()

        fetchMovies()
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
        title TEXT NOT NULL
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

    private func createSearchTable() {
        // Use ascii tokenizer allows non-ASCII characters (those with codepoints greater than 127) are always considered token characters, hence special character such as emoji ￣▽￣ is able to be searched.
        let sqlQueryString = "CREATE VIRTUAL TABLE IF NOT EXISTS \(ftsTable.ftsTableName) USING FTS5(title, tokenize = 'ascii');"
//        let sqlQueryString = "CREATE VIRTUAL TABLE IF NOT EXISTS \(ftsTable.ftsTableName) USING FTS5(title);"

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

    private func fetchMovies() {
        let sqlQueryString = "SELECT * FROM \(ftsTable.mainTableName)";
        var statement: OpaquePointer?

        guard sqlite3_prepare(mainDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage(for: mainDatabase)
            return
        }

        movies.removeAll()

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int(statement, 0)
            let title = String(cString: sqlite3_column_text(statement, 1))

            movies.append(
                Movie(
                    id: id,
                    title: title
                )
            )
        }

        sqlite3_finalize(statement)
    }

    private func insertMainTable(with title: String) {
        let sqlQueryString = "INSERT INTO \(ftsTable.mainTableName)(id, title) VALUES (?, ?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(mainDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            // Don't set id manually becuase SQLite will do auto increment for it.
            sqlite3_bind_text(statement, 2, (title as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage(for: mainDatabase)
            }
        } else {
            logSQLErrorMessage(for: mainDatabase)
        }

        sqlite3_finalize(statement)
    }

    private func insertIntoSearchTable(with title: String) {
        let sqlQueryString = "INSERT INTO \(ftsTable.ftsTableName)(title) VALUES (?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (title as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage(for: searchDatabase)
            }
        } else {
            logSQLErrorMessage(for: searchDatabase)
        }

        sqlite3_finalize(statement)
    }

    private func updateMainTable(with title: String, at index: Int32) {
        let sqlQueryString = "UPDATE \(ftsTable.mainTableName) SET title = ? WHERE id = ?;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(mainDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, index)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage(for: mainDatabase)
            }
        } else {
            logSQLErrorMessage(for: mainDatabase)
        }

        sqlite3_finalize(statement)
    }

    private func updateSearchTable(with text: String, at index: Int32) {
        let sqlQueryString = "UPDATE \(ftsTable.ftsTableName) SET title = ? WHERE rowid = ?;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (text as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, index)

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
            // Bind the rowid to the query
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
            guard let textField = alert.textFields?.first, let title = textField.text else {
                return
            }
            self.insertMainTable(with: title)
            self.insertIntoSearchTable(with: title)
            self.fetchMovies()
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
            guard let textField = alert.textFields?.first, let title = textField.text else {
                return
            }

            self.dropTable(name: title)
            self.movies.removeAll()
            self.tableView.reloadData()
        }

        alert.addAction(action)
        alert.addAction(UIAlertAction(title: CommonText.cancelTItle, style: .cancel))
        present(alert, animated: true)
    }
}

extension FTS5DefaultTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredMovies.count : movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: String(describing: UITableViewCell.self))

        let movie = isFiltering ? filteredMovies[indexPath.row] : movies[indexPath.row]

        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = String(movie.id)

        return cell
    }
}

extension FTS5DefaultTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let movie = isFiltering ? filteredMovies[indexPath.row] : movies[indexPath.row]

        let alert = UIAlertController(title: nil, message: CommonText.updateTitle, preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = movie.title

        let action = UIAlertAction(title: CommonText.confirmTitle, style: .default) { _ in
            guard let textField = alert.textFields?.first, let title = textField.text else {
                return
            }
            self.updateMainTable(with: title, at: movie.id)
            self.updateSearchTable(with: title, at: movie.id)
            self.fetchMovies()
            self.tableView.reloadData()
        }

        alert.addAction(action)
        alert.addAction(
            UIAlertAction(
                title: CommonText.copyTitle,
                style: .default,
                handler: { _ in
                    UIPasteboard.general.string = movie.title
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
                let movie = self.filteredMovies[indexPath.row]
                self.filteredMovies.remove(at: indexPath.row)
                self.deleteFromMainTable(at: movie.id)
                self.deleteFromSearchTable(at: movie.id)
            } else {
                let movie = self.movies[indexPath.row]
                self.movies.remove(at: indexPath.row)
                self.deleteFromMainTable(at: movie.id)
                self.deleteFromSearchTable(at: movie.id)
            }

            tableView.deleteRows(at: [indexPath], with: .automatic)
            complete(true)
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension FTS5DefaultTableViewController: UISearchResultsUpdating {
    private func performFTS5Search(with text: String) {
        filteredMovies.removeAll()

        let normalizedText = "\(text)*"
        let sqlQueryString = "SELECT rowid, title FROM \(ftsTable.ftsTableName) WHERE title MATCH ? ORDER BY rank;"

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage(for: searchDatabase)
            return
        }

        sqlite3_bind_text(statement, 1, (normalizedText as NSString).utf8String, -1, nil)

        while sqlite3_step(statement) == SQLITE_ROW {
            let rowid = sqlite3_column_int(statement, 0)
            let title = String(cString: sqlite3_column_text(statement, 1))
            filteredMovies.append(Movie(id: rowid, title: title))
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

extension FTS5DefaultTableViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        fetchMovies()
        tableView.reloadData()
    }
}
