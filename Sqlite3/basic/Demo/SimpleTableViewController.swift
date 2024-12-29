//
//  FirstViewController.swift
//  Demo
//
//  Created by user on 2024/03/04.
//

import UIKit
import SQLite3

/// Reference
/// https://juejin.cn/post/6844903822003814413
struct Computer {
    let id: Int
    let name: String
    let weight: Int
    let price: Double
}

final class SimpleTableViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        return tableView
    }()

    private lazy var searchController = UISearchController(searchResultsController: nil)

    private var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    private var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    private var computers = [Computer]()
    private var filteredComputers: [Computer] = []
    private var dbPath = ""
    private var db: OpaquePointer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "First"
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentInsertAlert)),
            UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchCertainComputer)),
        ]

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        configureSearchController()

        fetchLibraryPath()
        db = openDatabase()
        createTable()
        queryAllComputers()

        if computers.isEmpty {
            insertMutipleData()
        }

        tableView.reloadData()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func queryAllComputers() {
        let queryString = "SELECT * FROM Computer;"
        var queryStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {

            var localComputers = [Computer]()

            while(sqlite3_step(queryStatement) == SQLITE_ROW) {
                let id = sqlite3_column_int(queryStatement, 0)
                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let weight = sqlite3_column_int(queryStatement, 2)
                let price = sqlite3_column_double(queryStatement, 3)

                localComputers.append(
                    Computer(
                        id: Int(id),
                        name: name,
                        weight: Int(weight),
                        price: price
                    )
                )
            }
            computers = localComputers
        }
        sqlite3_finalize(queryStatement)
    }

    private func fetchLibraryPath() {
        if let libraryPathString = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first {
            let pathURL = URL(fileURLWithPath: libraryPathString).appendingPathComponent("crackswift.sqlite")
            dbPath = pathURL.path
        }
    }

    private func openDatabase() -> OpaquePointer? {
        var db: OpaquePointer?
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            // It creates a database if it doesn't exist or open database if exist.
            print("Open database success: \(dbPath)")
            return db
        } else {
            print("Open database failed")
            return nil
        }
    }

    func createTable() {
        let createTableString = """
                                CREATE TABLE Computer(
                                Id INT PRIMARY KEY NOT NULL,
                                Name CHAR(255),
                                Weight Int,
                                Price Float);
                                """
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Create table success")
            } else {
                print("Create table failed")
            }
        } else {
            print("Create table failed")
        }
        // 每次操作完成都需使用來刪除statement以避免resource leak，注意一旦finalized後就不該再去使用它
        sqlite3_finalize(createTableStatement)
    }

    func insertMutipleData() {
        for index in 0...4 {
            computers.append(
                Computer(
                    id: index,
                    name: "computer" + "\(index)",
                    weight: index * 10,
                    price: 20.0
                )
            )
        }

        let insertRowString = "INSERT INTO Computer (Id, Name, Weight, Price) VALUES (?, ?, ?, ?);"
        var insertStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertRowString, -1, &insertStatement, nil) == SQLITE_OK {
            for (index, computer) in computers.enumerated() {
                let id: Int32 = Int32(index + 1)

                sqlite3_bind_int(insertStatement, 1, id)

                // sqlite3_bind_text函數比其他多2個參數，說明如下：
                // 第一個參數是你的statement
                // 第二個參數是你的statement裡面的?的順序
                // 第三個參數是想給?的值
                // 第四個參數是text的字節數，一般給-1
                // 第五個參數是closure callback，處理完String後使用
                sqlite3_bind_text(insertStatement, 2, (computer.name as NSString).utf8String, -1, nil)

                sqlite3_bind_int(insertStatement, 3, Int32(computer.weight))

                sqlite3_bind_double(insertStatement, 4, computer.price)

                if sqlite3_step(insertStatement) == SQLITE_DONE {
                    print("Insert data success")
                } else {
                    print("Insert data failed")
                }
                // 使用sqlite3_reset以便下次迴圈再次執行statement
                sqlite3_reset(insertStatement)
            }
        } else {
            print("Insert data failed")
        }
        sqlite3_finalize(insertStatement)
    }

    func updateComputer(name: String, computer: Computer, indexPath: IndexPath) {
        let updateString = "UPDATE Computer SET Name = ? WHERE Id = ?;"
        var updateStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, updateString, -1, &updateStatement, nil) == SQLITE_OK {

            sqlite3_bind_text(updateStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 2, Int32(computer.id))

            if sqlite3_step(updateStatement) == SQLITE_DONE {
                print("Update success")
                computers[indexPath.row] = Computer(
                    id: computer.id,
                    name: name,
                    weight: computer.weight,
                    price: computer.price
                )
                tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                print("Update failed")
            }
        }
        sqlite3_finalize(updateStatement)
    }

    func deleteComputer(with id: Int) {
        let deleteString = "DELETE FROM Computer WHERE Id = ?;"
        var deleteStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, deleteString, -1, &deleteStatement, nil) == SQLITE_OK {

            sqlite3_bind_int(deleteStatement, 1, Int32(id))

            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Update success")
            } else {
                print("Update failed")
            }
        } else {
            print("Update failed")
        }
        sqlite3_finalize(deleteStatement)
    }

    func queryCertainComputer() {
        let queryString = "SELECT * FROM Computer WHERE Name LIKE '%computer1%';"
        var queryStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)

                let name = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let weight = sqlite3_column_int(queryStatement, 2)
                let price = sqlite3_column_double(queryStatement, 3)

                print(name)
            } else {
                print("error")
            }
        }
        sqlite3_finalize(queryStatement)
    }

    func insert(computer: Computer) {
        let insertRowString = "INSERT INTO Computer (Id, Name, Weight, Price) VALUES (?, ?, ?, ?);"
        var insertStatement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertRowString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(insertStatement, 1, Int32(computer.id))

            // sqlite3_bind_text函數比其他多2個參數，說明如下：
            // 第一個參數是你的statement
            // 第二個參數是你的statement裡面的?的順序
            // 第三個參數是想給?的值
            // 第四個參數是text的字節數，一般給-1
            // 第五個參數是closure callback，處理完String後使用
            sqlite3_bind_text(insertStatement, 2, (computer.name as NSString).utf8String, -1, nil)

            sqlite3_bind_int(insertStatement, 3, Int32(computer.weight))

            sqlite3_bind_double(insertStatement, 4, computer.price)

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Insert data success")
                computers.append(computer)
                tableView.reloadData()
            } else {
                print("Insert data failed")
            }
        } else {
            print("Insert data failed")
        }
        sqlite3_finalize(insertStatement)
    }

    @objc
    func presentInsertAlert(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: nil, message: "Insert a computer", preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?[0].placeholder = "Computer name"

        let action = UIAlertAction(title: "Submit", style: .default) { _ in
            let name = alert.textFields?[0].text
            let computer = Computer(
                id: (self.computers.last?.id ?? 0) + 1,
                name: name ?? "inserted computuer",
                weight: 100,
                price: 2000.0
            )
            self.insert(computer: computer)
        }
        alert.addAction(action)

        present(alert, animated: true)
    }

    @objc
    private func refreshData(_ sender: UIRefreshControl) {
        queryAllComputers()
        tableView.refreshControl?.endRefreshing()
    }

    @objc
    private func searchCertainComputer() {
        queryCertainComputer()
    }
}

extension SimpleTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredComputers.count : computers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)

        let computer: Computer
        if isFiltering {
            computer = filteredComputers[indexPath.row]
        } else {
            computer = computers[indexPath.row]
        }

        cell.textLabel?.text = computer.name
        return cell
    }
}

extension SimpleTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let computer: Computer
        if isFiltering {
            computer = filteredComputers[indexPath.row]
        } else {
            computer = computers[indexPath.row]
        }

        let alert = UIAlertController(title: nil, message: "Update a computer name", preferredStyle: .alert)
        alert.addTextField()

        let action = UIAlertAction(title: "Submit", style: .default) { _ in
            alert.textFields?[0].placeholder = computer.name
            if let name = alert.textFields?[0].text {
                self.updateComputer(name: name, computer: computer, indexPath: indexPath)
            }
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
            let computer = self.computers[indexPath.row]
            self.computers.remove(at: indexPath.row)
            self.deleteComputer(with: computer.id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            complete(true)
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension SimpleTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            tableView.reloadData()
            return
        }
        filteredComputers = computers.filter { computer -> Bool in
            computer.name.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}
