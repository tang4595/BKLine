//
//  TradingViewPortraitController.swift
//  BKLineSample
//
//  Created by tang on 16.3.23.
//

import UIKit
import BKLine
import SnapKit

class TradingViewPortraitController: UIViewController {
    var config = BKLineConfigDefault.default
    lazy var lineChartView: BKLineChartView = {
        config.mode = .tradingView
        
        let line = BKLineChartView(config: config)
        line.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 500)
        //line.isLine = true
        line.delegate = self
        line.tradingViewDataSouce = self
        line.tradingViewDelegate = self
        return line
    }()
    
    lazy var updateSymbolBtn: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 500.0 + 30.0, width: 80, height: 30)
        button.setTitle("切换交易对", for: .normal)
        button.addTarget(self, action: #selector(self.updateSymbol), for: .touchUpInside)
        return button
    }()
    
    lazy var updateChartTypeBtn: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0 + 80 + 10, y: 500.0 + 30.0, width: 100, height: 30)
        button.setTitle("切换图表样式", for: .normal)
        button.addTarget(self, action: #selector(self.updateChartType), for: .touchUpInside)
        return button
    }()
    
    lazy var showIndicatorBtn: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0 + 80 + 10 + 100 + 10, y: 500.0 + 30.0, width: 80, height: 30)
        button.setTitle("切换指标", for: .normal)
        button.addTarget(self, action: #selector(self.showIndicator), for: .touchUpInside)
        return button
    }()
    
    private var language = BKLineConfigTradingViewLanguage.chinese
    lazy var updateLanguageBtn: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 500.0 + 30.0 + 30 + 20, width: 80, height: 30)
        button.setTitle("切换语言", for: .normal)
        button.addTarget(self, action: #selector(self.updateLanguage), for: .touchUpInside)
        return button
    }()
    
    private var theme = BKLineConfigTradingViewTheme.light
    lazy var updateThemeBtn: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0 + 80 + 10, y: 500.0 + 30.0 + 30 + 20, width: 100, height: 30)
        button.setTitle("切换主题色", for: .normal)
        button.addTarget(self, action: #selector(self.updateTheme), for: .touchUpInside)
        return button
    }()
    
    private var mode = BKLineMode.tradingView
    lazy var updateModeBtn: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0 + 80 + 10 + 100 + 10, y: 500.0 + 30.0 + 30 + 20, width: 100, height: 30)
        button.setTitle("切换图表类型", for: .normal)
        button.addTarget(self, action: #selector(self.updateMode), for: .touchUpInside)
        return button
    }()
    
    @objc private var socketSimTimer: Timer?
    
    private var isAreaLine: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TradingView"
        view.backgroundColor = .darkGray
        view.addSubview(lineChartView)
        view.addSubview(updateSymbolBtn)
        view.addSubview(updateChartTypeBtn)
        view.addSubview(showIndicatorBtn)
        view.addSubview(updateLanguageBtn)
        view.addSubview(updateThemeBtn)
        view.addSubview(updateModeBtn)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.dismiss(animated: true)
    }
    
    @objc func updateSymbol() {
        let vo = BKLineConfigTradingViewSymbol(symbol: "", interval: "30")
        config.tradingView.base.updateSymbol?(vo)
    }
    
    @objc func updateChartType() {
        if isAreaLine {
            isAreaLine = false
            config.tradingView.base.updateChartType?(.Candles)
        } else {
            isAreaLine = true
            config.tradingView.base.updateChartType?(.Area)
        }
    }
    
    @objc func showIndicator() {
        config.tradingView.base.showIndicatorDialog?()
    }
    
    @objc func updateLanguage() {
        let val: BKLineConfigTradingViewLanguage = language == .chinese ? .english : .chinese
        language = val
        config.tradingView.base.updateLanguage?(val)
    }
    
    @objc func updateTheme() {
        let val: BKLineConfigTradingViewTheme = theme == .dark ? .light : .dark
        theme = val
        config.tradingView.base.updateTheme?(val)
    }
    
    @objc func updateMode() {
        let val: BKLineMode = mode == .tradingView ? .basic : .tradingView
        mode = val
        config.updateMode?(val)
    }
    
    private var currentSymbol: String?
    private var currentInterval: String?
    @objc func socketSimulates() {
        self.config.tradingView.base.updateBars?([
            "symbol": currentSymbol ?? "",
            "interval": currentInterval ?? "",
            "bars": [[
                "time": 1679227270 * 1000,
                "open": 1784.59,
                "high": 1794.62,
                "low": 1780.00,
                "close": 1782.61 + Double(arc4random_uniform(20)),
                "volume": 11128.1894
            ]]
        ])
    }
}

extension TradingViewPortraitController: BKLineChartViewDelegate {
    func loadMoreData(chart: BKLine.BKLineChartView) {
        
    }
}

extension TradingViewPortraitController: BKLineTradingViewDataSource {
    func initTradingView() -> BKLineConfigTradingViewSymbol? {
        return BKLineConfigTradingViewSymbol(
            symbol: "BTC_USDT",
            interval: BKLineTradingViewInterval.KLM1.value,
            savedData: nil
        )
    }
    
    func getSymbolInfo(_ symbol: String) -> Any? {
        return nil
    }
    
    func getHistory(_ params: [String : Any], callback: @escaping (Any?) -> Void) {
        let json = BKLineChartOriginalModel.fromMap(
            JSONData: try! Data(contentsOf: Bundle.main.url(forResource: "kline-sample-bk-eth-1h", withExtension: "json")!)
        )!
        guard let jsonListValue = json.toJSON()["list"] as? [[String: Any]] else {
            return
        }
        var bars:[[String: Any?]] = []
        for json in jsonListValue {
            let e = json
            let jsonItem: [String:Any?] = [
                "time":    ((e["t"] as AnyObject).intValue ?? 0) * 1000,
                "open":    (e["o"] as AnyObject).doubleValue,
                "high":    (e["h"] as AnyObject).doubleValue,
                "low":     (e["l"] as AnyObject).doubleValue,
                "close":   (e["c"] as AnyObject).doubleValue,
                "volume":  (e["a"] as AnyObject).doubleValue]
            bars.append(jsonItem)
        }
        callback([
            "symbol": params["symbol"],
            "interval": params["interval"],
            "bars": bars//API原始list.map映射
        ])
    }
    
    func subscribeBars(_ symbol: String, _ interval: String) {
        currentSymbol = symbol
        currentInterval = interval
        
        socketSimTimer?.invalidate()
        socketSimTimer = nil
        socketSimTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.socketSimulates), userInfo: nil, repeats: true)
        socketSimTimer?.fireDate = Date()
    }
    
    func getKlineOrders(_ symbol: String, _ interval: String, callback: @escaping (Any) -> Void) {
        
    }
    
    func getKLineChart(_ params: [String : Any], callback: @escaping (Any) -> Void) {
        
    }
}

extension TradingViewPortraitController: BKLineTradingViewDelegate {
    func updateKLineChart(_ params: [String : Any], callback: @escaping (Any) -> Void) {
        
    }
    
    func deleteKLineChart(_ params: [String : Any], callback: @escaping (Any) -> Void) {
        
    }
}
