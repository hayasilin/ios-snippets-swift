//
//  TableDiffableDataSourceViewController.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import UIKit
import SafariServices

final class TableDiffableDataSourceViewController: UIViewController {
    private lazy var tableView: UITableView = {
        // UITableView with `.plain` style has top content inset area.
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.cellReuseIdentifier)
        tableView.register(TableViewSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: TableViewSectionHeaderView.reuseIdentifier)
        tableView.register(TableViewSectionFooterView.self, forHeaderFooterViewReuseIdentifier: TableViewSectionFooterView.reuseIdentifier)
        return tableView
    }()

    private var sections = Section.allSections

    private lazy var dataSource = createDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushNextPage))
        navigationItem.rightBarButtonItem = navigationBarButtonItem

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        applySnapshot()
    }

    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(sections)
        sections.forEach { section in
            snapshot.appendItems(section.items, toSection: section)
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    @objc
    private func pushNextPage() {
        let detailVC = DetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension TableDiffableDataSourceViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private func createDataSource() -> DataSource {
        DataSource(tableView: tableView) { tableView, indexPath, item in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CustomTableViewCell.cellReuseIdentifier, for: indexPath
            ) as? CustomTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: item.title)
            return cell
        }
    }
}

extension TableDiffableDataSourceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        guard let link = item.link else {
            return
        }

        let safariViewController = SFSafariViewController(url: link)
        present(safariViewController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = dataSource.sectionIdentifier(for: section) else {
            return nil
        }

        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewSectionHeaderView.reuseIdentifier) as? TableViewSectionHeaderView else {
            return nil
        }
        headerView.configure(with: section.title)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let estimatedLabelHeight = 20.0
        return estimatedLabelHeight + TableViewSectionHeaderView.Design.contentInset.top + TableViewSectionHeaderView.Design.contentInset.bottom
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewSectionFooterView.reuseIdentifier) as? TableViewSectionFooterView else {
            return nil
        }
        footerView.configure(with: "footer")
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let estimatedLabelHeight = 20.0
        return estimatedLabelHeight + TableViewSectionFooterView.Design.contentInset.top + TableViewSectionFooterView.Design.contentInset.bottom
    }
}
