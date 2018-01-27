//
//  Tutorial.swift
//  CollectionViewDemo
//
//  Created by KuanWei on 2018/6/19.
//  Copyright © 2018年 Travostyle. All rights reserved.
//

import Foundation

class Tutorial: Codable {
    let title: String
    let author: String
    let editor: String
    let type: String
    let publishDate: Date

    init(title: String, author: String, editor: String, type: String, publishDate: Date) {
        self.title = title
        self.author = author
        self.editor = editor
        self.type = type
        self.publishDate = publishDate
    }
}
