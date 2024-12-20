//
//  CollectionDiffableDataSourceViewController.swift
//  Demo
//
//  Created by user on 12/21/24.
//

import UIKit
import SafariServices

// https://www.kodeco.com/8241072-ios-tutorial-collection-view-and-diffable-data-source
final class CollectionDiffableDataSourceViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    private var sections = Section.allSections
    private lazy var dataSource = makeDataSource()

    private lazy var searchController = UISearchController(searchResultsController: nil)

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureLayout()
        configureSearchController()
        applySnapshot(animatingDifferences: false)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }

    private func setupViews() {
        let navigationBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushNextPage))
        navigationItem.rightBarButtonItem = navigationBarButtonItem

        collectionView.register(
            CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.cellReuseIdentifier
        )
        collectionView.register(
            CollectionViewSectionHeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CollectionViewSectionHeaderReusableView.reuseIdentifier
        )
        collectionView.register(
            CollectionViewSectionFooterReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: CollectionViewSectionFooterReusableView.reuseIdentifier
        )
        collectionView.delegate = self
        collectionView.dataSource = dataSource

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func configureLayout() {
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            let isPhone = layoutEnvironment.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.phone
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(isPhone ? 280 : 250)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

            let iPadGroupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1/3),
                heightDimension: .absolute(250)
            )

            let group = isPhone ?
                NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item]) :
                NSCollectionLayoutGroup.horizontal(layoutSize: iPadGroupSize, repeatingSubitem: item, count: 3)

            let headerFooterSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(20)
            )

            // Supplementary header view setup
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )

            // Supplementary footer view setup
            let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerFooterSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            section.interGroupSpacing = 10
            section.boundarySupplementaryItems = [sectionHeader, sectionFooter]

            return section
        })
    }

    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search..."
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CustomCollectionViewCell.cellReuseIdentifier,
                for: indexPath
            ) as? CustomCollectionViewCell else {
                return .init()
            }
            cell.textLabel.text = itemIdentifier.title
            return cell
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: CollectionViewSectionHeaderReusableView.reuseIdentifier,
                    for: indexPath
                ) as? CollectionViewSectionHeaderReusableView

                view?.titleLabel.text = section.title

                return view
            case UICollectionView.elementKindSectionFooter:
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: CollectionViewSectionFooterReusableView.reuseIdentifier,
                    for: indexPath
                ) as? CollectionViewSectionFooterReusableView

                view?.titleLabel.text = "Footer"

                return view

            default:
                return nil
            }
        }

        return dataSource
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

extension CollectionDiffableDataSourceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        guard let link = item.link else {
            return
        }

        let safariViewController = SFSafariViewController(url: link)
        present(safariViewController, animated: true, completion: nil)
    }
}

extension CollectionDiffableDataSourceViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        sections = filteredSections(for: searchController.searchBar.text)
        applySnapshot()
    }

    func filteredSections(for searchText: String?) -> [Section] {
        let sections = Section.allSections
        guard let searchText, !searchText.isEmpty else {
            return sections
        }

        return sections.filter { section in
            var matches = section.title.lowercased().contains(searchText.lowercased())
            for video in section.items {
                if video.title.lowercased().contains(searchText.lowercased()) {
                    matches = true
                    break
                }
            }
            return matches
        }
    }
}
