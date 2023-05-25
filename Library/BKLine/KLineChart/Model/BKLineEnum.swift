//
//  BKLineEnum.swift
//  KLine-Chart
//
//  Created by tang on 2022/11/8.
//  Copyright © 2022 chunjian wang. All rights reserved.
//

import Foundation

public protocol BKSectionIndexProtocol {}

// 图表方向
public enum BKLineDirection: Int {
    case vertical
    case horizontal
}

// 主图指标
public enum BKMainSectionIndex: Int, BKSectionIndexProtocol {
    case ma
    case boll
    case none
}

// 成交量指标
public enum BKVolSectionIndex: Int, BKSectionIndexProtocol {
    case vol
    case none
}

/// 副图指标
public enum BKSecondarySectionIndex: Int, BKSectionIndexProtocol {
    case macd
    case kdj
    case rsi
    case wr
    case none
}
