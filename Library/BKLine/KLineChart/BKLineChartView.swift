//
//  BKLineChartView.swift
//  KLine-Chart
//
//  Created by tang on 2022/11/8.
//  Copyright © 2022 chunjian wang. All rights reserved.
//

import UIKit
import SnapKit

/// Native协议
public protocol BKLineChartViewDelegate: NSObject {
    /// Native - 加载跟多数据
    func loadMoreData(chart: BKLineChartView)
}

/// TradingView协议
public protocol BKLineTradingViewDataSource: NSObject {
    /// 初始化配置
    func initTradingView() -> BKLineConfigTradingViewSymbol?
    
    /// 获取当前标的信息
    ///
    /// `symbol`: 标的名称
    func getSymbolInfo(_ symbol: String) -> Any?
    
    /// 获取K线Api数据
    ///
    /// `params`: Api调用参数
    func getHistory(_ params: [String: Any], callback: @escaping (Any?) -> Void)
    
    /// 增量获取K线数据
    ///
    /// `symbol`: 标的名称
    func subscribeBars(_ symbol: String, _ interval: String)
    
    /// 获取委托订单数据
    ///
    /// `symbol`: 标的名称
    /// `interval`: 时间周期
    func getKlineOrders(_ symbol: String, _ interval: String, callback: @escaping (Any) -> Void)
    
    /// 获取K线配置（业务方一般会要求登录，可本地实现持久化）
    ///
    /// `params`: --
    func getKLineChart(_ params: [String: Any], callback: @escaping (Any) -> Void)
}

public protocol BKLineTradingViewDelegate: NSObject {
    /// 用户更新K线配置回调（业务方一般会要求登录，可本地实现持久化）
    ///
    /// `params`: configJson from API
    func updateKLineChart(_ params: [String: Any], callback: @escaping (Any) -> Void)
    
    /// 用户删除K线配置回调（业务方一般会要求登录，可本地实现持久化）
    ///
    /// `params`: --
    func deleteKLineChart(_ params: [String: Any], callback: @escaping (Any) -> Void)
}

public class BKLineChartView: UIView {
    public weak var delegate: BKLineChartViewDelegate?
    public weak var tradingViewDataSouce: BKLineTradingViewDataSource?
    public weak var tradingViewDelegate: BKLineTradingViewDelegate?
    public var config: BKLineConfigProtocol = BKLineConfigDefault()
    
    /// 图表模式
    var chartMode: BKLineMode = .basic
    
    /// 分时图
    var isLine = false {
        didSet {
            painterView?.isLine = isLine
            if self.chartMode == .tradingView {
                painterTradingView?.isLine = isLine
            }
        }
    }

    // X起始位置（最新一根线一侧相对于边界的距离）
    var scrollX: CGFloat = 0.0 {
        didSet {
            painterView?.scrollX = scrollX
        }
    }
    var defaultScrollX: CGFloat = 0.0

    /// 滚动系数
    var maxScroll: CGFloat = 0.0
    var minScroll: CGFloat = 0.0
    
    /// 缩放系数
    var scaleX: CGFloat = 1.0 {
        didSet {
            painterView?.scaleX = scaleX
        }
    }
    
    /// 当前状态
    var isScrolling: Bool = false
    var isScale: Bool = false
    var isDrag: Bool = false
    var isLongPress: Bool = false {
        didSet {
            painterView?.isLongPress = isLongPress
            if !isLongPress {
                infoView.removeFromSuperview()
            }
        }
    }
    
    /// 图表方向
    var direction: BKLineDirection = .vertical {
        didSet {
            painterView?.direction = direction
        }
    }

    /// 指标-主图
    var mainSectionIndex: BKMainSectionIndex = .ma {
        didSet {
            painterView?.mainSectionIndex = mainSectionIndex
        }
    }
    
    /// 指标-成交量
    var volSectionIndex: BKVolSectionIndex = .vol {
        didSet {
            painterView?.volSectionIndex = volSectionIndex
        }
    }

    /// 附图指标
    var secondarySectionIndex: BKSecondarySectionIndex = .none {
        didSet {
            painterView?.secondarySectionIndex = secondarySectionIndex
        }
    }
    
    /// 长按坐标
    var longPressX: CGFloat = 0 {
        didSet {
            painterView?.longPressX = longPressX
        }
    }
    var longPressY: CGFloat = 0 {
        didSet {
            painterView?.longPressY = longPressY
        }
    }

    /// 拖动相关参数
    var lastScrollX: CGFloat = 0.0
    var dragbeginX: CGFloat = 0

    /// 上一次缩放的比例
    var lastscaleX: CGFloat = 1
    /// 缩放的中心点
    var scaleStartX: CGFloat = 0
    /// 缩放中心点对应的index
    var scaleIndex: Int = 0

    /// k线初始位置
    var minTrailing: CGFloat = 0
    var maxTrailing: CGFloat = 0

    /// 横向拖动速度
    var speedX: CGFloat = 0
    
    /// 加载更多参数
    var loadMoreKeys: [String: CGFloat] = [:]
    /// 处于加载更多数据状态，下一个end事件中触发刷新
    var isHandleMoreData: Bool = false
    var currentMoreDatas: [BKLineChartModel] = []
    
    /// 数据源
    var lastTimeToRefreshData: Int64 = 0
    var datas: [BKLineChartModel] = [] {
        didSet {
            loadMoreKeys.removeAll(keepingCapacity: true)
            initIndicators()
            painterView?.datas = datas
        }
    }
    
    /// 盘口价格
    var askBidPirce: BKLineChartAskBidPriceModel? {
        didSet {
            painterView?.askBidPrice = askBidPirce
        }
    }

    var displayLink: CADisplayLink?
    
    var painterView: BKLineChartPainterView?
    var painterTradingView: BKLinePainterTradingView?

    lazy var infoView: BKLineStockInfoView = {
        let view = BKLineStockInfoView(config: config)
        view.frame = CGRect(x: 0, y: 0, width: 160.0, height: 155.0)
        return view
    }()

    public override var frame: CGRect {
        didSet {
            self.painterView?.frame = self.bounds
            initIndicators()
        }
    }
    
    public convenience init(config: BKLineConfigProtocol) {
        self.init()
        self.config = config
        self.chartMode = config.mode
        self.commonSetup()
        self.basicConfigSetup()
        self.tradingViewConfigSetup()
        self.uiSetup()
    }
    
    // MARK: - Init
    func commonSetup() {
        if chartMode == .basic {
            if let contains = painterView {
                contains.removeFromSuperview()
            }
            painterView = BKLineChartPainterView(
                frame: bounds,
                config: config,
                datas: datas,
                scrollX: scrollX,
                isLine: isLine,
                scaleX: scaleX,
                isLongPress: isLongPress,
                mainSectionIndex: mainSectionIndex,
                secondarySectionIndex: secondarySectionIndex
            )
        } else {
            if let contains = painterTradingView {
                contains.removeFromSuperview()
            }
            painterTradingView = BKLinePainterTradingView(
                frame: bounds,
                config: config,
                isLine: isLine,
                dataSource: self,
                delegate: self
            )
        }
    }
    
    func uiSetup() {
        initTrailing()
        scrollX = -70
        defaultScrollX = scrollX
        initIndicators()
        painterView?.isHidden = chartMode == .basic ? false : true
        painterTradingView?.isHidden = chartMode == .basic ? true : false
        if let painterView = painterView {
            addSubview(painterView)
        }
        if let painterTradingView = painterTradingView {
            addSubview(painterTradingView)
        }
        painterView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        painterTradingView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        /// 展示长按信息
        painterView?.showInfoBlock = { [weak self] model, isleft in
            guard let self = self, self.config.basic.`switch`.enableStockInfoAlert else { return }
            self.infoView.update(model: model)
            self.addSubview(self.infoView)
            let padding: CGFloat = 5
            if isleft {
                self.infoView.frame = CGRect(
                    x: padding,
                    y: 30,
                    width: self.infoView.frame.width,
                    height: self.infoView.frame.height
                )
            } else {
                self.infoView.frame = CGRect(
                    x: self.frame.width - self.infoView.frame.width - padding,
                    y: 30,
                    width: self.infoView.frame.width,
                    height: self.infoView.frame.height
                )
            }
        }
        
        /// 事件注册
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(dragKlineEvent(gesture:))
        )
        panGesture.delegate = self
        painterView?.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(tapEvent(gesture:))
        )
        tapGesture.delegate = self
        painterView?.addGestureRecognizer(tapGesture)
        let longPressGreture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPressKlineEvent(gesture:))
        )
        painterView?.addGestureRecognizer(longPressGreture)
        let pinGesture = UIPinchGestureRecognizer(
            target: self,
            action: #selector(secalXEvent(gesture:))
        )
        pinGesture.delegate = self
        painterView?.addGestureRecognizer(pinGesture)
    }

    func initTrailing() {
        minTrailing = frame.width * 0.2
        maxTrailing = frame.width * 0.2
    }

    func initScrollWidth() {
        let dataLength: CGFloat = CGFloat(datas.count) * (config.basic.value.candleWidth * scaleX + config.basic.value.canldeMargin) - config.basic.value.canldeMargin
        if dataLength > frame.width {
            maxScroll = dataLength - frame.width
        } else {
            maxScroll = -(frame.width - dataLength)
        }
        let dataScroll = frame.width - dataLength
        let normalminScroll = -maxTrailing + (config.basic.value.candleWidth * scaleX) / 2
        
        /** 蜡烛总数小于可滑动超出范围，则不允许滑动超出范围，防止数据计算异常（不考虑缩放系数，避免缩放至临界状态切换时导致异常） */
        let candleCountOnScreen = Int(config.basic.value.extendMaxWidthStart / config.basic.value.candleWidth)
        let extendMaxWidthStart = datas.count <= candleCountOnScreen ? 0 : config.basic.value.extendMaxWidthStart
        
        /** 缩放系数小于1时边界padding跟随比例调整 */
        let extendStart = extendMaxWidthStart * (scaleX >= 1.0 ? 1.0 : scaleX+0.1)
        minScroll = min(normalminScroll, -dataScroll) - extendStart
        maxScroll += config.basic.value.extendMaxWidthEnd
    }

    func scrollXIndicators(trailing: CGFloat) {
        initScrollWidth()
        let selectIndexOffset = CGFloat(scaleIndex) * (config.basic.value.candleWidth * scaleX + config.basic.value.canldeMargin) - config.basic.value.canldeMargin
        scrollX = clamp(
            value: selectIndexOffset - trailing,
            min: minScroll,
            max: maxScroll
        )
        debugPrint(scrollX)
    }

    func initIndicators() {
        if datas.count == 0 { return }
        initScrollWidth()
        scrollX = clamp(value: scrollX, min: minScroll, max: maxScroll)
        lastScrollX = scrollX
    }
    
    func reset() {
        let resetScaleX = !self.config.basic.`switch`.keepScaleRatio
        if resetScaleX {
            scaleManually(to: 1.0)
        }
        scrollX = defaultScrollX
        initIndicators()
    }
}

// MARK: - Gesture
extension BKLineChartView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        switch gestureRecognizer {
        case is UITapGestureRecognizer:
            return config.basic.`switch`.enableTap
        case is UIPanGestureRecognizer:
            return config.basic.`switch`.enablePan
        case is UIPinchGestureRecognizer:
            return config.basic.`switch`.enablePinch
        default:
            return false
        }
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer, let view = gesture.view else {
            return true
        }
        let velocityX = abs(gesture.velocity(in: view).x)
        let velocityY = abs(gesture.velocity(in: view).y)
        guard velocityX != 0 else {
            return false
        }
        guard velocityY != 0 else {
            return true
        }
        let result = velocityY / velocityX
        return result < 2.0
    }
}
