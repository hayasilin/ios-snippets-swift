//
//  HotArticle.swift
//  SplitDemo
//
//  Created by kuanwei on 2021/6/12.
//

import Foundation

struct List: Codable {
    let list: [HotArticle]
}

struct HotArticle: Codable {
    let author: String?
    let title: String
    let boardName: String?
    let desc: String?
    let url: String?
    let imageList: [String]?

    private enum CodingKeys: String, CodingKey {
        case author
        case title
        case boardName = "board_name"
        case desc
        case url
        case imageList = "img_list"
    }
}
