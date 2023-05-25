//
//  BKLinePainterTradingView.swift
//  BKLine
//
//  Created by tang on 16.3.23.
//

import UIKit
import WebViewJavascriptBridge
import SnapKit
import SwifterSwift

class BKLinePainterTradingView: UIView {
    weak var dataSource: BKLineTradingViewDataSource?
    weak var delegate: BKLineTradingViewDelegate?
    private var config: BKLineConfigProtocol = BKLineConfigDefault()
    private var language: BKLineConfigTradingViewLanguage = .english
    private var theme: BKLineConfigTradingViewTheme = .light
    private var upDownColor: BKLineConfigTradingViewUpDownColor = .greenUpRedDown
    private var chartType: BKLineTradingViewChartType = .Candles
    
    /// 切换至Area前的图表样式
    private var lastChartType: BKLineTradingViewChartType = .Candles
    var isLine = false {
        didSet {
            set(chartType: isLine ? .Area : lastChartType)
        }
    }

    /// 配置信息
    private var configObj: [String: Any] = [:]
    
    private lazy var bridge: WKWebViewJavascriptBridge = {
        let bridge = WKWebViewJavascriptBridge(for: self.webView)!
        bridge.setWebViewDelegate(self)
        #if DEBUG
        WKWebViewJavascriptBridge.enableLogging()
        #endif
        return bridge
    }()

    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.backgroundColor = config.basic.color.bgColor
        webView.scrollView.backgroundColor = config.basic.color.bgColor
        return webView
    }()
    private lazy var loadingMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = config.basic.color.bgColor
        view.isUserInteractionEnabled = false
        return view
    }()
    
    init(
        frame: CGRect,
        config: BKLineConfigProtocol,
        isLine: Bool,
        dataSource: BKLineTradingViewDataSource?,
        delegate: BKLineTradingViewDelegate?
    ) {
        super.init(frame: frame)
        self.config = config
        self.language = config.tradingView.base.language
        self.theme = config.tradingView.base.theme
        self.upDownColor = config.tradingView.base.updownColor
        self.chartType = config.tradingView.base.chartType
        self.isLine = isLine
        self.configInit()
        self.dataSource = dataSource
        self.delegate = delegate
        self.registerHandlers()
        
        addSubview(webView)
        addSubview(loadingMaskView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        loadingMaskView.snp.makeConstraints { make in
            make.edges.equalTo(webView)
        }
        self.reload()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configInit() {
        configObj["theme"] = self.theme.rawValue
        configObj["locale"] = self.language.rawValue
        configObj["upDownColor"] = self.upDownColor.rawValue
        configObj["upColor"] = self.config.basic.color.upColor.hexString
        configObj["downColor"] = self.config.basic.color.downColor.hexString
        configObj["chartType"] = self.chartType.rawValue
    }
    
    public func reload() {
        if let url = Bundle.main.url(forResource: "ChartingLibrary/index", withExtension: "html") {
            /// Pod源码依赖模式
            webView.loadFileURL(url, allowingReadAccessTo: url)
        } else if let url = Bundle.main.url(forResource: "Frameworks/BKLine.framework/ChartingLibrary/index", withExtension: "html") {
            /// Framework导入模式
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
}

//MARK: JS Handler
extension BKLinePainterTradingView {
    func registerHandlers() {
        bridge.registerHandler("symbols", handler: symbolsHandler)
        bridge.registerHandler("history", handler: historyHandler)
        bridge.registerHandler("getKlineOrders", handler: getKlineOrdersHandler)
        bridge.registerHandler("subscribeBars", handler: subscribeBarsHandler)
        bridge.registerHandler("initTradingView", handler: initTradingViewHandler)
        bridge.registerHandler("getKLineChart", handler: getKLineChartHandler)
        bridge.registerHandler("updateKLineChart", handler: updateKLineChartHandler)
        bridge.registerHandler("deleteKLineChart", handler: deleteKLineChartHandler)
    }
    
    func initTradingViewHandler(data: Any?, callback: WVJBResponseCallback?) {
        let result = dataSource?.initTradingView()
        if let result = result {
            configObj["symbol"] = result.symbol
            configObj["interval"] = result.interval
            configObj["savedData"] = result.savedData
            callback?(configObj)
        }
    }
    
    func symbolsHandler(data: Any?, callback: WVJBResponseCallback?) {
        guard
            let data = data as? [String: Any],
            let symbol = data["symbol"] as? String
        else {
            return
        }
        let result = [
            "symbol": symbol,
            "pricescale": self.config.basic.value.decimalLenPrice
        ] as [String : Any]
        callback?(result)
    }
    
    func historyHandler(data: Any?, callback: WVJBResponseCallback?) {
        guard let data = data as? [String: Any] else { return }
        dataSource?.getHistory(data, callback: callback!)
    }
    
    func subscribeBarsHandler(data: Any?, callback: WVJBResponseCallback?) {
        guard let data = data as? [String: Any],
              let symbol = data["symbol"] as? String,
              let interval = data["interval"] as? String
        else { return }
        dataSource?.subscribeBars(symbol, interval)
    }
    
    func getKlineOrdersHandler(data: Any?, callback: WVJBResponseCallback?) {
        let enabled = config.basic.value.currentOrderFlagEnabled || config.basic.value.historyOrderFlagEnabled
        guard enabled,
              let data = data as? [String: Any],
              let symbol = data["symbol"] as? String,
              let interval = data["interval"] as? String
        else { return }
        dataSource?.getKlineOrders(symbol, interval, callback: callback!)
    }
    
    func getKLineChartHandler(data: Any?, callback: WVJBResponseCallback?) {
        guard let data = data as? [String: Any] else { return }
        dataSource?.getKLineChart(data, callback: callback!)
    }
    
    func updateKLineChartHandler(data: Any?, callback: WVJBResponseCallback?) {
        guard let data = data as? [String: Any] else { return }
        delegate?.updateKLineChart(data, callback: callback!)
    }
    
    func deleteKLineChartHandler(data: Any?, callback: WVJBResponseCallback?) {
        guard let data = data as? [String: Any] else { return }
        delegate?.deleteKLineChart(data, callback: callback!)
    }
}

//MARK: 事件
extension BKLinePainterTradingView {
    /// 切换语言
    public func set(language: BKLineConfigTradingViewLanguage) {
        self.language = language
        self.configInit()
        reload()
    }
    
    /// 切换主题
    public func set(theme: BKLineConfigTradingViewTheme) {
        self.theme = theme
        self.configInit()
        reload()
    }
    
    /// 切换涨跌色模式
    public func set(upDownColor: BKLineConfigTradingViewUpDownColor) {
        self.upDownColor = upDownColor
        self.configInit()
        reload()
    }
    
    /// 切换币对、时间间隔
    public func set(symbol: String, interval: String) {
        var params: [String: Any] = [:]
        if !symbol.isEmpty {
            params["symbol"] = symbol
        }
        if !interval.isEmpty {
            params["interval"] = interval
        }
        bridge.callHandler("setSymbol", data: params)
    }
    
    /// 图表样式
    public func set(chartType: BKLineTradingViewChartType) {
        self.chartType = chartType
        bridge.callHandler("setChartType", data: ["style": chartType.rawValue])
        if chartType != .Area {
            lastChartType = chartType
        }
    }
    
    /// 显示指标弹框
    public func showIndicatorDialog() {
        bridge.callHandler("showIndicatorDialog")
    }
    
    /// 主动增量K线数据更新
    public func updateBars(_ bars: [String: Any]) {
        bridge.callHandler("updateBars", data: bars)
    }
}

extension BKLinePainterTradingView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.loadingMaskView.isHidden = true
        }
    }
}
