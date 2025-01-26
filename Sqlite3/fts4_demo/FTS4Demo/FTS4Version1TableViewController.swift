//
//  FTS4Version1TableViewController.swift
//  FTS4Demo
//
//  Created by user on 1/25/25.
//

import UIKit
import SQLite3

private struct Movie {
    let title: String
}

/// Basic FTS4 implmentation.
/// - Create: "CREATE VIRTUAL TABLE IF NOT EXISTS search USING fts4(title);"
/// - Insert: "INSERT INTO search(title) VALUES (?);"
/// - Search: "SELECT * FROM search WHERE search MATCH '\(text)*';"
/// - Delete: "DELETE FROM search WHERE title = '\(title)'"
final class FTS4Version1TableViewController: UIViewController {
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
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type something here to search"
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

    private var movieDatabase: OpaquePointer?
    private var searchDatabase: OpaquePointer?

    deinit {
        sqlite3_close(movieDatabase)
        sqlite3_close(searchDatabase)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.title = "Version 1"
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

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        movieDatabase = openMovieDatabaseConnection()
        createMoviesTable()

        searchDatabase = openSearchDatabaseConnection()
        createSearchTable()

        fetchMovies()
        tableView.reloadData()
    }

    private func openMovieDatabaseConnection() -> OpaquePointer? {
        guard let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            assertionFailure("Open movie database failure")
            return nil
        }

        let libraryURL = URL(fileURLWithPath: libraryPath).appendingPathComponent("movie.sqlite")
        let databasePath = libraryURL.path

        var db: OpaquePointer?
        if sqlite3_open(databasePath, &db) == SQLITE_OK {
            print("Open movie database success path: \(databasePath)")
            return db
        } else {
            assertionFailure("Open movie database failure")
            return nil
        }
    }

    private func createMoviesTable() {
        let sqlQueryString = """
                            CREATE TABLE IF NOT EXISTS movies(
                            id INTEGER PRIMARY KEY NOT NULL,
                            title TEXT NOT NULL
                            );
                            """
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(movieDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Create movie table success")
            } else {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func openSearchDatabaseConnection() -> OpaquePointer? {
        guard let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            assertionFailure("Open search database failure")
            return nil
        }

        let libraryURL = URL(fileURLWithPath: libraryPath).appendingPathComponent(DBScheme.v1.databaseFileName)
        let databasePath = libraryURL.path

        var db: OpaquePointer?
        if sqlite3_open(databasePath, &db) == SQLITE_OK {
            print("Open search database success, path: \(databasePath)")
            return db
        } else {
            assertionFailure("Open search database failure")
            return nil
        }
    }

    private func createSearchTable() {
        let sqlQueryString = "CREATE VIRTUAL TABLE IF NOT EXISTS search USING fts4(title);"

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Create search table success")
            } else {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func fetchMovies() {
        let sqlQueryString = "SELECT * FROM movies";
        var statement: OpaquePointer?

        guard sqlite3_prepare(movieDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage()
            return
        }

        movies.removeAll()

        while sqlite3_step(statement) == SQLITE_ROW {
            let title = String(cString: sqlite3_column_text(statement, 1))

            movies.append(
                Movie(
                    title: title
                )
            )
        }

        sqlite3_finalize(statement)
    }

    private func insertMovieDatabase(with title: String) {
        let sqlQueryString = "INSERT INTO movies(id, title) VALUES (?, ?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(movieDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            // Comment out below to not set id manually becuase SQLite will do auto increment for it.
            // sqlite3_bind_int(statement, 1, id)
            sqlite3_bind_text(statement, 2, (title as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Insert movice data success")
            } else {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func insertSearchDatabase(with title: String) {
        let sqlQueryString = "INSERT INTO search(title) VALUES (?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(self.searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (title as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Insert search data success")
            } else {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func deleteFromMovieTable(with title: String) {
        let sqlQueryString = "DELETE FROM movies WHERE title = '\(title)'"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(movieDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Delete data success")
            } else {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }
    }

    private func deleteFromSearchTable(with title: String) {
        let sqlQueryString = "DELETE FROM search WHERE title = '\(title)'"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Delete data success")
            } else {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }
    }

    private func dropMovieTable() {
        let queryString = "DROP TABLE movies"
        var statement: OpaquePointer?

        guard sqlite3_prepare(movieDatabase, queryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage()
            return
        }

        if sqlite3_step(statement) == SQLITE_DONE {
            print("Drop table success")
        } else {
            logSQLErrorMessage()
        }
    }

    private func dropSearchTable() {
        let queryString = "DROP TABLE search"
        var statement: OpaquePointer?

        guard sqlite3_prepare(searchDatabase, queryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage()
            return
        }

        if sqlite3_step(statement) == SQLITE_DONE {
            print("Drop table success")
        } else {
            logSQLErrorMessage()
        }
    }

    private func logSQLErrorMessage() {
        let errorMessage = String(cString: sqlite3_errmsg(movieDatabase))
        print("SQL error: \(errorMessage)")
    }

    @objc
    private func refresh(_ sender: UIRefreshControl) {
        fetchMovies()
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }

    @objc
    private func didTapInsertButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "Insert", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = "Input movie title"

        let action = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alert.textFields?.first, let title = textField.text else {
                return
            }
            self.insertMovieDatabase(with: title)
            self.insertSearchDatabase(with: title)
            self.fetchMovies()
            self.tableView.reloadData()
        }

        alert.addAction(action)
        present(alert, animated: true)
    }

    @objc
    private func didTapDropButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "Drop Table", preferredStyle: .actionSheet)

        let dropMovieTableAction = UIAlertAction(title: "Drop movie table", style: .destructive) { _ in
            self.dropMovieTable()
            self.movies.removeAll()
            self.tableView.reloadData()
        }

        let dropSearchTableAction = UIAlertAction(title: "Drop search table", style: .destructive) { _ in
            self.dropSearchTable()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(dropMovieTableAction)
        alert.addAction(dropSearchTableAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

extension FTS4Version1TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredMovies.count : movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)

        let movie = isFiltering ? filteredMovies[indexPath.row] : movies[indexPath.row]

        cell.textLabel?.text = movie.title
        return cell
    }
}

extension FTS4Version1TableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { contextualAction, view, complete in
            guard contextualAction.style == .destructive else {
                complete(false)
                return
            }
            if self.isFiltering {
                let movie = self.filteredMovies[indexPath.row]
                self.filteredMovies.remove(at: indexPath.row)
                self.deleteFromMovieTable(with: movie.title)
                self.deleteFromSearchTable(with: movie.title)
            } else {
                let movie = self.movies[indexPath.row]
                self.movies.remove(at: indexPath.row)
                self.deleteFromMovieTable(with: movie.title)
                self.deleteFromSearchTable(with: movie.title)
            }

            tableView.deleteRows(at: [indexPath], with: .automatic)
            complete(true)
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension FTS4Version1TableViewController: UISearchResultsUpdating {
    private func performFTS4Search(with text: String) {
        let sqlQueryString = "SELECT * FROM search WHERE search MATCH '\(text)*';"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage()
            return
        }

        filteredMovies.removeAll()

        while sqlite3_step(statement) == SQLITE_ROW {
            let title = String(cString: sqlite3_column_text(statement, 0))
            filteredMovies.append(
                Movie(
                    title: title
                )
            )
        }

        sqlite3_finalize(statement)
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            return
        }

        performFTS4Search(with: searchText.lowercased())
        tableView.reloadData()
    }
}
