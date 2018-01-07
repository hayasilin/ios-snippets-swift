//
//  HotArticle.swift
//  AllInOne
//
//  Created by Kuan-Wei Lin on 12/23/17.
//  Copyright © 2017 cracktheterm. All rights reserved.
//

import Foundation

struct List: Codable {
    let list: [HotArticle]
}

struct HotArticle: Codable {
    let author: String?
    let title: String?
    let board_name: String?
    let desc: String?
    let url: String?
    let img_list:[String]?
}

