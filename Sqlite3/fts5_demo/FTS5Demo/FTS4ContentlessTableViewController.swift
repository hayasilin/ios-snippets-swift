//
//  FTS4ContentlessTableViewController.swift
//  FTS5Demo
//
//  Created by user on 6/2/25.
//

import UIKit
import SQLite3

/// FTS4 using contentless table to perform CRUD.
/// - Create: "CREATE VIRTUAL TABLE IF NOT EXISTS search USING fts4(title);"
/// - Insert: "INSERT INTO search(title) VALUES (?);"
/// - Search: "SELECT rowid, title FROM search WHERE search MATCH '\(text)*';"
final class FTS4ContentlessTableViewController: UIViewController {
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

    private var movieDatabase: OpaquePointer?
    private var searchDatabase: OpaquePointer?

    deinit {
        sqlite3_close(movieDatabase)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.title = "FTS4 Contentless"

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

        movieDatabase = openMovieDatabaseConnection()
        createMoviesTable()

        searchDatabase = openSearchDatabaseConnection()
        createSearchTable()

        fetchMovies()
        tableView.reloadData()
    }

    private func openMovieDatabaseConnection() -> OpaquePointer? {
        guard let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            assertionFailure()
            return nil
        }

        let libraryURL = URL(fileURLWithPath: libraryPath).appendingPathComponent("movie.sqlite")
        let databasePath = libraryURL.path

        var db: OpaquePointer?
        if sqlite3_open(databasePath, &db) == SQLITE_OK {
            print("Open movie database success path: \(databasePath)")
            return db
        } else {
            assertionFailure()
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
            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func openSearchDatabaseConnection() -> OpaquePointer? {
        guard let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            assertionFailure()
            return nil
        }

        let libraryURL = URL(fileURLWithPath: libraryPath).appendingPathComponent("fts4_contentless.sqlite")
        let databasePath = libraryURL.path

        var db: OpaquePointer?
        if sqlite3_open(databasePath, &db) == SQLITE_OK {
            print("Open search database success, path: \(databasePath)")
            return db
        } else {
            assertionFailure()
            return nil
        }
    }

    private func createSearchTable() {
        let sqlQueryString = """
        CREATE VIRTUAL TABLE IF NOT EXISTS search \
        USING FTS4 (content="", text, order=desc);
        """

        var statement: OpaquePointer?

        if sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
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

    private func insertMovieDatabase(with movie: Movie) {
        let sqlQueryString = "INSERT INTO movies(id, title) VALUES (?, ?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(movieDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, movie.id)
            sqlite3_bind_text(statement, 2, (movie.title as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func insertSearchDatabase(with movie: Movie) {
        let sqlQueryString = "INSERT INTO search (rowid, text) VALUES (?, ?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(self.searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, movie.id)
            sqlite3_bind_text(statement, 2, (movie.title as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func updateMovie(title: String, at index: Int32) {
        let sqlQueryString = "UPDATE movies SET title = ? WHERE id = ?;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(movieDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, index)

            if sqlite3_step(statement) != SQLITE_DONE {
                logSQLErrorMessage()
            }
        } else {
            logSQLErrorMessage()
        }

        sqlite3_finalize(statement)
    }

    private func deleteFromMovieTable(at index: Int32) {
        let sqlQueryString = "DELETE FROM movies WHERE id = \(index)"
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

    private func dropTable(name: String) {
        let queryString = "DROP TABLE \(name)"
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

    private func logSQLErrorMessage() {
        let errorMessage = String(cString: sqlite3_errmsg(searchDatabase))
        print("SQL error: \(errorMessage)")
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

            let movie = Movie(
                id: Int32(Date().timeIntervalSince1970),
                title: title
            )

            self.insertMovieDatabase(with: movie)
            self.insertSearchDatabase(with: movie)
            self.fetchMovies()
            self.tableView.reloadData()
        }

        alert.addAction(action)
        present(alert, animated: true)
    }

    @objc
    private func didTapDropButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "Drop Table", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = "Input table name"

        let action = UIAlertAction(title: "Drop table", style: .destructive) { _ in
            guard let textField = alert.textFields?.first, let title = textField.text else {
                return
            }

            self.dropTable(name: title)
            self.movies.removeAll()
            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(action)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

extension FTS4ContentlessTableViewController: UITableViewDataSource {
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

extension FTS4ContentlessTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let movie = isFiltering ? filteredMovies[indexPath.row] : movies[indexPath.row]

        let alert = UIAlertController(title: nil, message: "Update", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = movie.title

        let action = UIAlertAction(title: "Update", style: .default) { _ in
            guard let textField = alert.textFields?.first, let title = textField.text else {
                return
            }
            self.updateMovie(title: title, at: movie.id)
            self.fetchMovies()
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
                let movie = self.filteredMovies[indexPath.row]
                self.filteredMovies.remove(at: indexPath.row)
                self.deleteFromMovieTable(at: movie.id)
            } else {
                let movie = self.movies[indexPath.row]
                self.movies.remove(at: indexPath.row)
                self.deleteFromMovieTable(at: movie.id)
            }

            tableView.deleteRows(at: [indexPath], with: .automatic)
            complete(true)
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension FTS4ContentlessTableViewController: UISearchResultsUpdating {
    private func performFTS4Search(with text: String) -> [Int32] {
        let sqlQueryString = "SELECT rowid FROM search AS d WHERE d.text MATCH '\(text)*';"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(searchDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage()
            return []
        }

        var movieIDs = [Int32]()

        while sqlite3_step(statement) == SQLITE_ROW {
            let docid = sqlite3_column_int(statement, 0)
            movieIDs.append(docid)
        }

        sqlite3_finalize(statement)

        return movieIDs
    }

    private func querySelectedMovices(with movieIDs: [Int32]) {
        filteredMovies.removeAll()

        guard !movieIDs.isEmpty else {
            return
        }

        let movieIDCollectionString = movieIDs.map{ String($0) }.joined(separator: ",")
        let sqlQueryString = "SELECT * FROM movies WHERE id IN (\(movieIDCollectionString)) ORDER BY id DESC";

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(movieDatabase, sqlQueryString, -1, &statement, nil) == SQLITE_OK else {
            logSQLErrorMessage()
            return
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = sqlite3_column_int(statement, 0)
            let title = String(cString: sqlite3_column_text(statement, 1))
            filteredMovies.append(Movie(id: id, title: title))
        }

        sqlite3_finalize(statement)
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            return
        }

        let movieIDs = performFTS4Search(with: searchText.lowercased())
        querySelectedMovices(with: movieIDs)
        tableView.reloadData()
    }
}

extension FTS4ContentlessTableViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        fetchMovies()
        tableView.reloadData()
    }
}
