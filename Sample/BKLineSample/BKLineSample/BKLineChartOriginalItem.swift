//
//  BKLineChartOriginalItem.swift
//  BKLineSample
//
//  Created by tang on 19.3.23.
//

import Foundation

class BKLineChartOriginalModel: Codable {
    var no: String?
    var list: [BKLineChartOriginalItem]?
    var noMore: Bool?
}

class BKLineChartOriginalItem: Codable {
    var v: String?
    var l: String?
    var a: String?
    var h: String?
    var o: String?
    var s: String?
    var c: String?
    var t: Int?
}
