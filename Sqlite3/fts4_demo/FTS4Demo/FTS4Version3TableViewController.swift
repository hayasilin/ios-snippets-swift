//
//  FTS4Version3TableViewController.swift
//  FTS4Demo
//
//  Created by user on 1/25/25.
//

import UIKit
import SQLite3

final class FTS4Version3TableViewController: UIViewController {
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

    private var contacts = [Contact]()
    private var filteredContacts = [Contact]()

    var contactDatabase: SQLiteDatabase?
    var searchDatabase: SQLiteDatabase?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        navigationItem.title = "Version 3"
        let rightBarButtonItems = [
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

        openContactDatabaseConnection()
        createContactTable()

        openSearchDatabaseConnection()
        createSearchTable()

        queryContacts()
        tableView.reloadData()
    }

    private func openContactDatabaseConnection() {
        guard let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            assertionFailure("Open movie database failure")
            return
        }

        let libraryURL = URL(fileURLWithPath: libraryPath).appendingPathComponent("contacts.sqlite")
        let databasePath = libraryURL.path

        do {
            contactDatabase = try SQLiteDatabase.open(path: databasePath)
            print("Successfully opened connection to database.")
        } catch SQLiteError.openDatabase(let error) {
            print(error)
        } catch {
            print("Unable to open database. error: \(error)")
        }
    }

    private func createContactTable() {
        do {
            try contactDatabase?.createTable(table: Contact.self)
        } catch {
            if let error = contactDatabase?.errorMessage {
                print(error)
            }
        }
    }

    private func openSearchDatabaseConnection() {
        guard let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first else {
            assertionFailure("Open search database failure")
            return
        }

        let libraryURL = URL(fileURLWithPath: libraryPath).appendingPathComponent(DBScheme.v3.databaseFileName)
        let databasePath = libraryURL.path

        do {
            searchDatabase = try SQLiteDatabase.open(path: databasePath)
            print("Successfully opened connection to database.")
        } catch SQLiteError.openDatabase(let error) {
            print(error)
        } catch {
            print("Unable to open database. error: \(error)")
        }
    }

    private func createSearchTable() {
        do {
            try searchDatabase?.createTable(table: FTS4.self)
        } catch {
            if let errorMessage = contactDatabase?.errorMessage {
                print(errorMessage)
            }
        }
    }

    private func queryContacts() {
        guard let contacts = contactDatabase?.query() else {
            return
        }
        self.contacts = contacts
    }

    private func insertContact(name: String) {
        do {
            try contactDatabase?.insertContact(name: name)
        } catch {
            if let errorMessage = contactDatabase?.errorMessage {
                print(errorMessage)
            }
        }
    }

    private func insertSearchDatabase(with name: String) {
        do {
            try searchDatabase?.insertContactSearch(name: name)
        } catch {
            if let errorMessage = contactDatabase?.errorMessage {
                print(errorMessage)
            }
        }
    }

    private func updateContact(name: String, at index: Int32) {
        do {
            try contactDatabase?.updateContact(name: name, at: index)
        } catch {
            if let errorMessage = contactDatabase?.errorMessage {
                print(errorMessage)
            }
        }
    }

    private func updateSearchContact(name: String, at index: Int32) {
        do {
            try searchDatabase?.updateContactSearch(name: name, at: index)
        } catch {
            if let errorMessage = contactDatabase?.errorMessage {
                print(errorMessage)
            }
        }
    }

    private func deleteContact(at index: Int32) {
        do {
            try contactDatabase?.deleteContact(at: index)
        } catch {
            if let errorMessage = contactDatabase?.errorMessage {
                print(errorMessage)
            }
        }
    }

    private func deleteSearchContact(at index: Int32) {
        do {
            try searchDatabase?.deleteContactSearch(at: index)
        } catch {
            if let errorMessage = contactDatabase?.errorMessage {
                print(errorMessage)
            }
        }
    }

    @objc
    private func refresh(_ sender: UIRefreshControl) {
        queryContacts()
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }

    @objc
    private func didTapInsertButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "Insert", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = "Input contact name"

        let action = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alert.textFields?.first, let title = textField.text else {
                return
            }
            self.insertContact(name: title)
            self.insertSearchDatabase(with: title)
            self.queryContacts()
            self.tableView.reloadData()
        }

        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension FTS4Version3TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredContacts.count : contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: String(describing: UITableViewCell.self))

        let contact = isFiltering ? filteredContacts[indexPath.row] : contacts[indexPath.row]

        cell.textLabel?.text = contact.name
        cell.detailTextLabel?.text = String(contact.id)

        return cell
    }
}

extension FTS4Version3TableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let contact = isFiltering ? filteredContacts[indexPath.row] : contacts[indexPath.row]

        let alert = UIAlertController(title: nil, message: "Update", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = contact.name

        let action = UIAlertAction(title: "Update", style: .default) { _ in
            guard let textField = alert.textFields?.first, let title = textField.text else {
                return
            }
            self.updateContact(name: title, at: contact.id)
            self.updateSearchContact(name: title, at: contact.id)
            self.queryContacts()
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
                let contact = self.filteredContacts[indexPath.row]
                self.filteredContacts.remove(at: indexPath.row)
                self.deleteContact(at: contact.id)
                self.deleteSearchContact(at: contact.id)
            } else {
                let contact = self.contacts[indexPath.row]
                self.contacts.remove(at: indexPath.row)
                self.deleteContact(at: contact.id)
                self.deleteSearchContact(at: contact.id)
            }

            tableView.deleteRows(at: [indexPath], with: .automatic)
            complete(true)
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension FTS4Version3TableViewController: UISearchResultsUpdating {
    private func performFTS4Search(with text: String) {
        do {
            self.filteredContacts = try searchDatabase?.performSearchContacts(with: text) ?? []
        } catch {
            if let errorMessage = searchDatabase?.errorMessage {
                print(errorMessage)
            }
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            return
        }

        performFTS4Search(with: searchText.lowercased())
        tableView.reloadData()
    }
}
