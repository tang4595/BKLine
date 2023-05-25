//
//  BKLineConfigTradingView.swift
//  BKLine
//
//  Created by tang on 18.3.23.
//

import Foundation

/// 时间周期
public enum BKLineTradingViewInterval: Int, CaseIterable {
    case KLTimeline = 0
    case KLM1
    case KLM5
    case KLM15
    case KLM30
    case KLH1
    case KLH2
    case KLH4
    case KLH6
    case KLH8
    case KLH12
    case KLDay
    case KLDay3
    case KLWeek
    case KLMonth
    case KLMore
    
    public var value: String {
        switch (self) {
        case .KLTimeline, .KLM1:
            return "1"
        case .KLM5:
            return "5"
        case .KLM15:
            return "15"
        case .KLM30:
            return "30"
        case .KLH1:
            return "60"
        case .KLH2:
            return "120"
        case .KLH4:
            return "240"
        case .KLH6:
            return "360"
        case .KLH8:
            return "480"
        case .KLH12:
            return "720"
        case .KLDay:
            return "1D"
        case .KLDay3:
            return "4320"
        case .KLWeek:
            return "1W"
        case .KLMonth:
            return "1M"
        case .KLMore:
            return ""
        }
    }
}

/// 语言
public enum BKLineConfigTradingViewLanguage: String {
    case chinese = "zh"
    case english = "en"
}

/// 主题色
public enum BKLineConfigTradingViewTheme: String {
    case light, dark
}

/// 涨跌色模式
public enum BKLineConfigTradingViewUpDownColor: String {
    case greenUpRedDown, redUpGreenDown
}

/// 图表类型
public enum BKLineTradingViewChartType: Int {
    /// 美国线
    case Bars = 0
    /// K线图
    case Candles = 1
    /// 线形图
    case Line = 2
    /// 面积图"
    case Area = 3
    case Renko = 4
    case Kagi = 5
    case PointAndFigure = 6
    case LineBreak = 7
    /// 平均k线图
    case HeikenAshi = 8
    /// 空心K线图
    case HollowCandles = 9
    /// 基准线
    case Baseline = 10
    /// 高低图
    case HiLo = 12
}

/// 币对/时间戳配置VO
public struct BKLineConfigTradingViewSymbol {
    public var symbol: String
    public var interval: String
    /// K线用户配置信息（持久化内容Json）
    public var savedData: String?
    public init(symbol: String, interval: String, savedData: String? = nil) {
        self.symbol = symbol
        self.interval = interval
        self.savedData = savedData
    }
}

//MARK: - Base
public protocol BKLineConfigTradingViewBase {
    /// 语言
    var language: BKLineConfigTradingViewLanguage { get set }
    /// 主题色
    var theme: BKLineConfigTradingViewTheme { get set }
    /// 涨跌色模式
    var updownColor: BKLineConfigTradingViewUpDownColor { get set }
    /// 图表样式
    var chartType: BKLineTradingViewChartType { get set }
    
    /// 更新语言
    var updateLanguage: ((BKLineConfigTradingViewLanguage) -> Void)? { get set }
    /// 更新主题色
    var updateTheme: ((BKLineConfigTradingViewTheme) -> Void)? { get set }
    /// 更新涨跌色模式
    var updateUpDownColor: ((BKLineConfigTradingViewUpDownColor) -> Void)? { get set }
    /// 更新币对&时间周期
    var updateSymbol: ((BKLineConfigTradingViewSymbol) -> Void)? { get set }
    /// 更新图表样式
    var updateChartType: ((BKLineTradingViewChartType) -> Void)? { get set }
    /// 唤起指标选项菜单
    var showIndicatorDialog: (() -> Void)? { get set }
    /// 主动增量K线数据更新
    var updateBars: (([String: Any]) -> Void)? { get set }//TODO: 模型接口
}
