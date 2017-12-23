//
//  HotArticle.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import Foundation

struct HotArticles: Codable {
    let hotArticles: [HotArticle]
}

struct HotArticle: Codable {
    let hotNum: String
    let author: String
    let title: String
    let boardName: String
    let desc: String
    let url: String
}

