//
//  BKLineChartModel.swift
//  KLine-Chart
//
//  Created by tang on 2022/11/8.
//  Copyright © 2022 chunjian wang. All rights reserved.
//

import UIKit

public enum BKLineChartModelFlag: String, Codable {
    case currentOrderBuy
    case currentOrderSell
    case historyOrderBuy
    case historyOrderSell
    
    func flagIcon(withConfig config: BKLineStyleValue) -> UIImage? {
        switch self {
        case .currentOrderBuy:
            return config.currentOrderFlagBuy
        case .currentOrderSell:
            return config.currentOrderFlagSell
        case .historyOrderBuy:
            return config.historyOrderFlagBuy
        case .historyOrderSell:
            return config.historyOrderFlagSell
        }
    }
    
    var isCurrentOrder: Bool { self == .currentOrderBuy || self == .currentOrderSell }
    var isHistoryOrder: Bool { self == .historyOrderBuy || self == .historyOrderSell }
}

public class BKLineChartModel: Codable {
    // MARK: - 序列化
    public var open: CGFloat = 0
    public var high: CGFloat = 0
    public var low: CGFloat = 0
    public var close: CGFloat = 0
    public var vol: CGFloat = 0
    public var amount: CGFloat = 0
    public var count: Int = 0
    public var id: Int = 0
    /// 时间周期(s)
    public var interval: Int? = 0
    
    /// 当前周期下倒计时是否可用
    public var isValidCountdown: Bool {
        (interval ?? 0) - (Int(Date().timeIntervalSince1970) - count) > 0
    }
    
    // MARK: - 委托标志
    public var flagBuy: BKLineChartModelFlag? = nil
    public var flagSell: BKLineChartModelFlag? = nil
    

    // MARK: - 计算结果
    public var MA5Price: CGFloat = 0
    public var MA10Price: CGFloat = 0
    public var MA20Price: CGFloat = 0
    public var MA30Price: CGFloat = 0

    public var mb: CGFloat = 0
    public var up: CGFloat = 0
    public var dn: CGFloat = 0

    public var dif: CGFloat = 0
    public var dea: CGFloat = 0
    public var macd: CGFloat = 0
    public var ema12: CGFloat = 0
    public var ema26: CGFloat = 0

    public var MA5Volume: CGFloat = 0
    public var MA10Volume: CGFloat = 0

    public var rsi: CGFloat = 0
    public var rsiABSEma: CGFloat = 0
    public var rsiMaxEma: CGFloat = 0

    public var k: CGFloat = 0
    public var d: CGFloat = 0
    public var j: CGFloat = 0

    public var r: CGFloat = 0

    public init() {}
    
    enum CodingKeys: String, CodingKey {
        case open, high, low, close, vol, amount, count, id, interval
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(open, forKey: .open)
        try container.encode(high, forKey: .high)
        try container.encode(low, forKey: .low)
        try container.encode(close, forKey: .close)
        try container.encode(vol, forKey: .vol)
        try container.encode(amount, forKey: .amount)
        try container.encode(count, forKey: .count)
        try container.encode(id, forKey: .id)
        try container.encode(interval, forKey: .interval)
    }
}

public class BKLineChartAskBidPriceModel: Codable {
    public var ask: String = "0"
    public var bid: String = "0"
}
