//
//  BKLineConfigBasic.swift
//  BKLine
//
//  Created by tang on 18.3.23.
//

import UIKit

//MARK: - 基础
public protocol BKLineStyleBase {
    /// 图表方向
    var direction: BKLineDirection { get set }
    /// 指标-主图
    var mainSectionIndex: BKMainSectionIndex { get set }
    /// 指标-成交量
    var volSectionIndex: BKVolSectionIndex { get set }
    /// 附图指标
    var secondarySectionIndex: BKSecondarySectionIndex { get set }
    /// 更新配置
    var updateDirection: ((BKLineDirection) -> Void)? { get set }
    var updateSectionMain: ((BKSectionIndexProtocol) -> Void)? { get set }
    var updateSectionVolume: ((BKSectionIndexProtocol) -> Void)? { get set }
    var updateSectionSecondary: ((BKSectionIndexProtocol) -> Void)? { get set }
}

//MARK: - 开关
public protocol BKLineStyleSwitch {
    /// 分时图
    var isLine: Bool { get set }
    /// 允许点击
    var enableTap: Bool { get set }
    /// 允许滑动
    var enablePan: Bool { get set }
    /// 允许缩放
    var enablePinch: Bool { get set }
    /// 允许长按显示浮窗
    var enableStockInfoAlert: Bool { get set }
    /// 允许长按显示浮窗
    var stockInfoShowVolume: Bool { get set }
    /// 倒计时（最新一根蜡烛）
    var enableCountdown: Bool { get set }
    /// 盘口价格（买卖1价）
    var enableAskBidPrice: Bool { get set }
    /// 保持K线缩放系数
    var keepScaleRatio: Bool { get set }
    /// 更新配置
    var updateIsLine: ((Bool) -> Void)? { get set }
    var updateEnableCountdown: ((Bool) -> Void)? { get set }
    var updateEnableAskBidPrice: ((Bool) -> Void)? { get set }
    var updateKeepScaleRation: ((Bool) -> Void)? { get set }
}

//MARK: - 文案
public protocol BKLineStyleText {
    /// 基础
    var bid: String { get set }
    var ask: String { get set }
    /// 长按浮窗文案
    var stockInfoTextDate: String { get set }
    var stockInfoTextOpen: String { get set }
    var stockInfoTextClose: String { get set }
    var stockInfoTextHigh: String { get set }
    var stockInfoTextLow: String { get set }
    var stockInfoTextChangeRate: String { get set }
    var stockInfoTextChangeVolume: String { get set }
    var stockInfoTextDealVol: String { get set }
}

//MARK: - 颜色
public protocol BKLineStyleColor {
    /// 画布背景颜色
    var bgColor: UIColor { get set }
    /// 分时图颜色
    var timeLineColor: UIColor { get set }
    /// 网格颜色
    var gridColor: UIColor { get set }
    /// 各指标颜色
    var ma5Color: UIColor { get set }
    var ma10Color: UIColor { get set }
    var ma30Color: UIColor { get set }
    var upColor: UIColor { get set }
    var downColor: UIColor { get set }
    var volColor: UIColor { get set }

    var macdColor: UIColor { get set }
    var difColor: UIColor { get set }
    var deaColor: UIColor { get set }

    var kColor: UIColor { get set }
    var dColor: UIColor { get set }
    var jColor: UIColor { get set }
    var rsiColor: UIColor { get set }
    var wrColor: UIColor { get set }
    /// 最大最小值的颜色
    var maxMinTextColor: UIColor { get set }
    /// 选中十字线颜色
    var crossHlineColor: UIColor { get set }
    /// 选中后显示值边框颜色
    var markerBorderColor: UIColor { get set }
    /// 选中后显示值背景的填充颜色
    var markerBgColor: UIColor { get set }
    /// 选中后显示值文字颜色
    var markerTextColor: UIColor { get set }
    /// 当前价相关颜色
    var realTimeBgColor: UIColor { get set }
    var realTimeCountdownBgColor: UIColor { get set }
    var realTimeTextBorderColor: UIColor { get set }
    var realTimeLongLineColor: UIColor { get set }
    var realTimeTextColor: UIColor { get set }
    var rightRealTimeTextColor: UIColor { get set }
    /// 右侧y轴相关文字颜色
    var rightTextColor: UIColor { get set }
    /// 底部x轴日期颜色
    var bottomDateTextColor: UIColor { get set }
    /// 长按详细信息颜色
    var stockInfoTitleColor: UIColor { get set }
    var stockInfoValueColor: UIColor { get set }
    var stockInfoBgColor: UIColor { get set }
    var stockInfoBorderColor: UIColor { get set }
    
    /// 重新加载配置
    func reloadConfig()
}

//MARK: - 字体
public protocol BKLineStyleFont {
    /// 其他文字（最高、最低、最新、指标明细等）
    var defaultTextFont: UIFont { get set }
    /// 右侧y轴字体
    var reightTextFont: UIFont { get set }
    /// 底部x轴日期字体
    var bottomDateFont: UIFont { get set }
    /// 长按详细信息字体
    var stockInfoTitleFont: UIFont { get set }
    var stockInfoValueFont: UIFont { get set }
}

//MARK: - 数值/大小/间距/其他
public protocol BKLineStyleValue {
    /// Logo
    var logoImage: UIImage? { get set }
    /// 网格
    var gridRows: Int { get set }
    var gridColumns: Int { get set }
    /// 小数位数
    var decimalLenPrice: Int { get set }
    var decimalLenVolume: Int { get set }
    /// 蜡烛之间的间距
    var canldeMargin: CGFloat { get set }
    /// 蜡烛默认宽度
    var defaultcandleWidth: CGFloat { get set }
    /// 蜡烛宽度
    var candleWidth: CGFloat { get set }
    /// 蜡烛中间线的宽度
    var candleLineWidth: CGFloat { get set }
    /// 柱子样式
    var candleStyle: BKLineStyleCandleType { get set }
    /// vol柱子宽度
    var volWidth: CGFloat { get set }
    /// macd柱子宽度
    var macdWidth: CGFloat { get set }
    /// 垂直交叉线宽度
    var vCrossWidth: CGFloat { get set }
    /// 水平交叉线宽度
    var hCrossWidth: CGFloat { get set }
    /// 顶部指标区域高度/距主图顶部间距
    var topPadding: CGFloat { get set }
    /// 底部日期区域高度
    var bottomDateHigh: CGFloat { get set }
    /// 各图表区域内容间距
    var childPadding: CGFloat { get set }
    /// 选中十字线宽度
    var aimWidth: CGFloat { get set }
    /// 起始滚动距离侧边允许的超出范围
    var extendMaxWidthStart: CGFloat { get set }
    /// 结束滚动距离侧边允许的超出范围
    var extendMaxWidthEnd: CGFloat { get set }
    /// 成交量/附图区域尺寸模式
    var areaSizeMode: BKLineStyleAreaSize { get set }
    var areaSizeRatioVolume: CGFloat { get set }
    var areaSizeRatioSecondary: CGFloat { get set }
    var areaSizeValueVolume: CGFloat { get set }
    var areaSizeValueSecondary: CGFloat { get set }
    /// 买卖标志（当前委托/历史委托）
    var currentOrderFlagEnabled: Bool { get set }
    var currentOrderFlagBuy: UIImage? { get set }
    var currentOrderFlagSell: UIImage? { get set }
    var historyOrderFlagEnabled: Bool { get set }
    var historyOrderFlagBuy: UIImage? { get set }
    var historyOrderFlagSell: UIImage? { get set }
    /// 更新配置
    var updateCandleStyle: ((BKLineStyleCandleType) -> Void)? { get set }
    var updateDecimalLength: ((BKLineStyleDecimalLength) -> Void)? { get set }
    var updateOrderFlagSwitch: ((BKLineOrderFlagSwitch) -> Void)? { get set }
    
    /// 重新加载配置
    func reloadConfig()
}
