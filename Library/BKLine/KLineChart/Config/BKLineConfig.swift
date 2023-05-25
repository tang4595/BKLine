//
//  BKLineConfig.swift
//  BKLine
//
//  Created by tang on 11.11.22.
//

import UIKit

/// 图表类型（原生，TradingView）
public enum BKLineMode: Int {
    case basic, tradingView
}

/// 成交量/附图指标区域尺寸模式，主图区域取决于成交量和附图区域
public enum BKLineStyleAreaSize {
    /// 比例/固定值
    case ratio, value
}

/// 蜡烛样式
public enum BKLineStyleCandleType {
    /// 实心/涨空心/跌空心
    case solid, hollowUp, hollowDown
}

/// 小数位数配置VO
public struct BKLineStyleDecimalLength {
    public var price: Int
    public var volume: Int
    public init(price: Int, volume: Int) {
        self.price = price
        self.volume = volume
    }
}

/// 买卖标志配置VO
public struct BKLineOrderFlagSwitch {
    public var currentOrderEnabled: Bool
    public var historyOrderEnabled: Bool
    public init(currentOrderEnabled: Bool, historyOrderEnabled: Bool) {
        self.currentOrderEnabled = currentOrderEnabled
        self.historyOrderEnabled = historyOrderEnabled
    }
}

public protocol BKLineConfigProtocol {
    /// 图表类型
    var mode: BKLineMode { get set }
    /// Native
    var basic: BKLineConfigBasic { get set }
    /// TradingView
    var tradingView: BKLineConfigTradingView { get set }
    /// 更新图表类型
    var updateMode: ((BKLineMode) -> Void)? { get set }
}


//MARK: - Native
public protocol BKLineConfigBasic {
    /// 基础
    var base: BKLineStyleBase { get set }
    /// 开关
    var `switch`: BKLineStyleSwitch { get set }
    /// 文案
    var text: BKLineStyleText { get set }
    /// 颜色
    var color: BKLineStyleColor { get set }
    /// 字体
    var font: BKLineStyleFont { get set }
    /// 数值/大小/间距
    var value: BKLineStyleValue { get set }
}

//MARK: - TradingView
public protocol BKLineConfigTradingView {
    /// 基础
    var base: BKLineConfigTradingViewBase { get set }
}
