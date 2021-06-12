//
//  MasterViewController.swift
//  SplitDemo
//
//  Created by kuanwei on 2021/6/10.
//

import UIKit

protocol MasterViewControllerDelegate: AnyObject {
    func itemSelected(_ item: HotArticle?)
}

class MasterViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    weak var delegate: MasterViewControllerDelegate?

    var articles: [HotArticle]?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Menu"

        view.backgroundColor = .systemBackground

        configureViews()
        fetchArticles()
    }

    private func configureViews() {

        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchArticles() {
        let url = URL(string: "https://disp.cc/api/hot_text.json")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "")
                return
            }

            do {
                let articleList = try JSONDecoder().decode(List.self, from: data)
                self.articles = articleList.list

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }

        }.resume()
    }
}

extension MasterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let article = articles?[indexPath.row]
        cell.textLabel?.text = article?.title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

extension MasterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let article = articles?[indexPath.row]

        delegate?.itemSelected(article)

        if let detailViewController = delegate as? DetailListViewController,
           let detailNavigationController = detailViewController.navigationController {
            splitViewController?.showDetailViewController(detailNavigationController, sender: article)
        }
    }
}
