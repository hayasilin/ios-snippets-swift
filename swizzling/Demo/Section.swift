//
//  Section.swift
//  Demo
//
//  Created by user on 2023/07/04.
//

import Foundation

struct Item: Hashable {
    let title: String
    let link: URL?
}

struct Section: Hashable {
    let title: String
    let items: [Item]

    init(title: String, items: [Item]) {
        self.title = title
        self.items = items
    }
}

extension Section {
    static var allSections: [Section] = [
        Section(title: "SwiftUI", items: [
            Item(
                title: "SwiftUI",
                link: URL(string: "https://www.raywenderlich.com/4001741-swiftui")
            )
        ]),
        Section(title: "UIKit", items: [
            Item(
                title: "Demystifying Views in iOS",
                link:
                    URL(string:
                            "https://www.raywenderlich.com/4518-demystifying-views-in-ios")
            ),
            Item(
                title: "Reproducing Popular iOS Controls",
                link: URL(string: "https://www.raywenderlich.com/5298-reproducing-popular-ios-controls")
            )
        ]),
        Section(title: "Frameworks", items: [
            Item(
                title: "Fastlane for iOS",
                link: URL(string:"https://www.raywenderlich.com/1259223-fastlane-for-ios")
            ),
            Item(
                title: "Beginning RxSwift",
                link: URL(string:"https://www.raywenderlich.com/4743-beginning-rxswift")
            )
        ]),
        Section(title: "Miscellaneous", items: [
            Item(
                title: "Data Structures & Algorithms in Swift",
                link: URL(string: "https://www.raywenderlich.com/977854-data-structures-algorithms-in-swift")
            ),
            Item(
                title: "Beginning ARKit",
                link: URL(string:"https://www.raywenderlich.com/737368-beginning-arkit")
            ),
            Item(
                title: "Machine Learning in iOS",
                link: URL(string: "https://www.raywenderlich.com/1320561-machine-learning-in-ios")
            ),
            Item(
                title: "Push Notifications",
                link: URL(string:"https://www.raywenderlich.com/1258151-push-notifications")
            ),
        ])
    ]
}
