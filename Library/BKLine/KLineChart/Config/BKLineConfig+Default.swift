//
//  BKLineConfig+Default.swift
//  BKLine
//
//  Created by tang on 17.11.22.
//

import UIKit

public extension BKLineConfigProtocol where Self == BKLineConfigDefault {
    static var `default`: Self { Self() }
}

public extension BKLineConfigBasic where Self == BKLineConfigBasicDefault {
    static var `default`: Self { Self() }
}

public extension BKLineStyleBase where Self == BKLineStyleBaseDefault {
    static var `default`: Self { Self() }
}

public extension BKLineStyleSwitch where Self == BKLineStyleSwitchDefault {
    static var `default`: Self { Self() }
}

public extension BKLineStyleText where Self == BKLineStyleTextDefault {
    static var `default`: Self { Self() }
}

public extension BKLineStyleColor where Self == BKLineStyleColorDefault {
    static var `default`: Self { Self() }
}

public extension BKLineStyleFont where Self == BKLineStyleFontDefault {
    static var `default`: Self { Self() }
}

public extension BKLineStyleValue where Self == BKLineStyleValueDefault {
    static var `default`: Self { Self() }
}

public extension BKLineConfigTradingView where Self == BKLineConfigTradingViewDefault {
    static var `default`: Self { Self() }
}

public extension BKLineConfigTradingViewBase where Self == BKLineConfigTradingViewBaseDefault {
    static var `default`: Self { Self() }
}

public class BKLineConfigDefault: BKLineConfigProtocol {
    /// 图表类型
    public var mode: BKLineMode = .basic
    /// Native
    public var basic: BKLineConfigBasic = BKLineConfigBasicDefault.default
    /// TradingView
    public var tradingView: BKLineConfigTradingView = BKLineConfigTradingViewDefault.default
    /// 更新图表类型
    public var updateMode: ((BKLineMode) -> Void)?
}

//MARK: - Native
public struct BKLineConfigBasicDefault: BKLineConfigBasic {
    /// 基础
    public var base: BKLineStyleBase = BKLineStyleBaseDefault.default
    /// 开关
    public var `switch`: BKLineStyleSwitch = BKLineStyleSwitchDefault.default
    /// 文案
    public var text: BKLineStyleText = BKLineStyleTextDefault.default
    /// 颜色
    public var color: BKLineStyleColor = BKLineStyleColorDefault.default
    /// 字体
    public var font: BKLineStyleFont = BKLineStyleFontDefault.default
    /// 数值/大小/间距
    public var value: BKLineStyleValue = BKLineStyleValueDefault.default
}

//MARK: Base
public class BKLineStyleBaseDefault: BKLineStyleBase {
    /// 图表方向
    public var direction: BKLineDirection = .vertical
    /// 指标-主图
    public var mainSectionIndex: BKMainSectionIndex = .boll
    /// 指标-成交量
    public var volSectionIndex: BKVolSectionIndex = .vol
    /// 附图指标
    public var secondarySectionIndex: BKSecondarySectionIndex = .macd
    /// 更新配置
    public var updateDirection: ((BKLineDirection) -> Void)?
    public var updateSectionMain: ((BKSectionIndexProtocol) -> Void)?
    public var updateSectionVolume: ((BKSectionIndexProtocol) -> Void)?
    public var updateSectionSecondary: ((BKSectionIndexProtocol) -> Void)?
}

// MARK: - Switch
public class BKLineStyleSwitchDefault: BKLineStyleSwitch {
    /// 分时图
    public var isLine: Bool = false
    /// 允许点击
    public var enableTap: Bool = true
    /// 允许滑动
    public var enablePan: Bool = true
    /// 允许缩放
    public var enablePinch: Bool = true
    /// 允许长按显示浮窗
    public var enableStockInfoAlert: Bool = true
    /// 信息面板是否显示成交量
    public var stockInfoShowVolume: Bool = true
    /// 倒计时（最新一根蜡烛）
    public var enableCountdown: Bool = true
    /// 盘口价格（买卖1价）
    public var enableAskBidPrice: Bool = true
    /// 保持K线缩放系数
    public var keepScaleRatio: Bool = true
    /// 更新配置
    public var updateIsLine: ((Bool) -> Void)?
    public var updateEnableCountdown: ((Bool) -> Void)?
    public var updateEnableAskBidPrice: ((Bool) -> Void)?
    public var updateKeepScaleRation: ((Bool) -> Void)?
}

// MARK: - Text
public struct BKLineStyleTextDefault: BKLineStyleText {
    /// 基础
    public var bid: String = "买"
    public var ask: String = "卖"
    /// 长按浮窗文案
    public var stockInfoTextDate: String = "时间"
    public var stockInfoTextOpen: String = "开"
    public var stockInfoTextClose: String = "收"
    public var stockInfoTextHigh: String = "高"
    public var stockInfoTextLow: String = "低"
    public var stockInfoTextChangeRate: String = "涨跌幅"
    public var stockInfoTextChangeVolume: String = "涨跌额"
    public var stockInfoTextDealVol: String = "成交量"
}

// MARK: - Color
public class BKLineStyleColorDefault: BKLineStyleColor {
    /// 画布背景颜色
    public var bgColor: UIColor = BKLColor(0xFF06_141D)
    /// 分时图颜色
    public var timeLineColor: UIColor = BKLColor(0xFF4C_86CD)
    /// 网格颜色
    public var gridColor: UIColor = BKLColor(0xFF4C_5C74)
    /// 各指标颜色
    public var ma5Color: UIColor = BKLColor(0xFFC9_B885)
    public var ma10Color: UIColor = BKLColor(0xFF6C_B0A6)
    public var ma30Color: UIColor = BKLColor(0xFF99_79C6)
    public var upColor: UIColor = BKLColor(0xFF4D_AA90)
    public var downColor: UIColor = BKLColor(0xFFC1_5466)
    public var volColor: UIColor = BKLColor(0xFF47_29AE)

    public var macdColor: UIColor = BKLColor(0xFF47_29AE)
    public var difColor: UIColor = BKLColor(0xFFC9_B885)
    public var deaColor: UIColor = BKLColor(0xFF6C_B0A6)

    public var kColor: UIColor = BKLColor(0xFFC9_B885)
    public var dColor: UIColor = BKLColor(0xFF6C_B0A6)
    public var jColor: UIColor = BKLColor(0xFF99_79C6)
    public var rsiColor: UIColor = BKLColor(0xFFC9_B885)
    public var wrColor: UIColor = BKLColor(0xFFD2_D2B4)
    /// 最大最小值的颜色
    public var maxMinTextColor: UIColor = BKLColor(0xFFFF_FFFF)
    /// 选中十字线颜色
    public var crossHlineColor: UIColor = BKLColor(0xFFFF_FFFF)
    /// 选中后显示值边框颜色
    public var markerBorderColor: UIColor = BKLColor(0xFFFF_FFFF)
    /// 选中后显示值背景的填充颜色
    public var markerBgColor: UIColor = BKLColor(0xFF0D_1722)
    /// 选中后显示值文字颜色
    public var markerTextColor: UIColor = BKLColor(0xFFFF_FFFF)
    /// 当前价相关颜色
    public var realTimeBgColor: UIColor = BKLColor(0xFF0D_1722)
    public var realTimeCountdownBgColor: UIColor = BKLColor(0xFF0D_1722)
    public var realTimeTextBorderColor: UIColor = BKLColor(0xFF0D_1722)
    public var realTimeLongLineColor: UIColor = BKLColor(0xFF4C_86CD)
    public var realTimeTextColor: UIColor = BKLColor(0xFFFF_FFFF)
    public var rightRealTimeTextColor: UIColor = BKLColor(0xFF4C_86CD)
    /// 右侧y轴相关文字颜色
    public var rightTextColor: UIColor = BKLColor(0xFF70_839E)
    /// 底部x轴日期颜色
    public var bottomDateTextColor: UIColor = BKLColor(0xFF70_839E)
    /// 长按详细信息颜色
    public var stockInfoTitleColor: UIColor = BKLColor(0xFFFF_FFFF)
    public var stockInfoValueColor: UIColor = BKLColor(0xFFFF_FFFF)
    public var stockInfoBgColor: UIColor = BKLColor(0xFF06_141D)
    public var stockInfoBorderColor: UIColor = BKLColor(0xFF4C_5C74)
    
    /// 重新加载配置
    public func reloadConfig() {}
}

// MARK: - Font
public struct BKLineStyleFontDefault: BKLineStyleFont {
    /// 其他文字（最高、最低、最新、指标明细等）
    public var defaultTextFont: UIFont = UIFont.systemFont(ofSize: 10)
    /// 右侧y轴字体
    public var reightTextFont: UIFont = UIFont.systemFont(ofSize: 10)
    /// 底部x轴日期字体
    public var bottomDateFont: UIFont = UIFont.systemFont(ofSize: 10)
    /// 长按详细信息字体
    public var stockInfoTitleFont: UIFont = UIFont.systemFont(ofSize: 10)
    public var stockInfoValueFont: UIFont = UIFont.systemFont(ofSize: 10)
}

// MARK: - Value
public class BKLineStyleValueDefault: BKLineStyleValue {
    /// Logo
    public var logoImage: UIImage?
    /// 网格
    public var gridRows: Int = 4
    public var gridColumns: Int = 5
    /// 小数位数
    public var decimalLenPrice: Int = 4
    public var decimalLenVolume: Int = 2
    /// 蜡烛之间的间距
    public var canldeMargin: CGFloat = 1
    /// 蜡烛默认宽度
    public var defaultcandleWidth: CGFloat = 8.5
    /// 蜡烛宽度
    public var candleWidth: CGFloat = 8.5
    /// 蜡烛中间线的宽度
    public var candleLineWidth: CGFloat = 1.5
    /// 柱子样式
    public var candleStyle: BKLineStyleCandleType = .hollowUp
    /// vol柱子宽度
    public var volWidth: CGFloat = 8.5
    /// macd柱子宽度
    public var macdWidth: CGFloat = 3.0
    /// 垂直交叉线宽度
    public var vCrossWidth: CGFloat = 8.5
    /// 水平交叉线宽度
    public var hCrossWidth: CGFloat = 0.5
    /// 顶部指标区域高度/距主图顶部间距
    public var topPadding: CGFloat = 20.0
    /// 底部日期区域高度
    public var bottomDateHigh: CGFloat = 20.0
    /// 各图表区域内容间距
    public var childPadding: CGFloat = 25.0
    /// 选中十字线宽度
    public var aimWidth: CGFloat = 0.5
    /// 起始滚动距离侧边允许的超出范围
    public var extendMaxWidthStart: CGFloat = UIScreen.main.bounds.width * 0.66
    /// 结束滚动距离侧边允许的超出范围
    public var extendMaxWidthEnd: CGFloat = 50.0 / UIScreen.main.scale
    /// 三大区域尺寸模式
    public var areaSizeMode: BKLineStyleAreaSize = .ratio
    public var areaSizeRatioVolume: CGFloat = 0.2
    public var areaSizeRatioSecondary: CGFloat = 0.2
    public var areaSizeValueVolume: CGFloat = 70.0
    public var areaSizeValueSecondary: CGFloat = 70.0
    /// 买卖标志（当前委托/历史委托）
    public var currentOrderFlagEnabled: Bool = true
    public var currentOrderFlagBuy: UIImage? = UIImage(named: "cbuy")
    public var currentOrderFlagSell: UIImage? = UIImage(named: "csell")
    public var historyOrderFlagEnabled: Bool = true
    public var historyOrderFlagBuy: UIImage? = UIImage(named: "hbuy")
    public var historyOrderFlagSell: UIImage? = UIImage(named: "hsell")
    /// 更新配置
    public var updateCandleStyle: ((BKLineStyleCandleType) -> Void)?
    public var updateDecimalLength: ((BKLineStyleDecimalLength) -> Void)?
    public var updateOrderFlagSwitch: ((BKLineOrderFlagSwitch) -> Void)?
    
    /// 重新加载配置
    public func reloadConfig() {}
}



//MARK: - TradingView
public class BKLineConfigTradingViewDefault: BKLineConfigTradingView {
    /// 基础
    public var base: BKLineConfigTradingViewBase = BKLineConfigTradingViewBaseDefault.default
}

//MARK: Base
public class BKLineConfigTradingViewBaseDefault: BKLineConfigTradingViewBase {
    /// 语言
    public var language: BKLineConfigTradingViewLanguage = .chinese
    /// 主题色
    public var theme: BKLineConfigTradingViewTheme = .light
    /// 涨跌色模式
    public var updownColor: BKLineConfigTradingViewUpDownColor = .redUpGreenDown
    /// 图表样式
    public var chartType: BKLineTradingViewChartType = .Candles
    
    /// 更新语言
    public var updateLanguage: ((BKLineConfigTradingViewLanguage) -> Void)?
    /// 更新主题色
    public var updateTheme: ((BKLineConfigTradingViewTheme) -> Void)?
    /// 更新涨跌色模式
    public var updateUpDownColor: ((BKLineConfigTradingViewUpDownColor) -> Void)?
    /// 更新币对&时间周期
    public var updateSymbol: ((BKLineConfigTradingViewSymbol) -> Void)?
    /// 更新图表样式
    public var updateChartType: ((BKLineTradingViewChartType) -> Void)?
    /// 唤起指标选项菜单
    public var showIndicatorDialog: (() -> Void)?
    /// 主动增量K线数据更新
    public var updateBars: (([String: Any]) -> Void)?
}
