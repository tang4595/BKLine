//
//  BKLineChartView+TradingView.swift
//  BKLine
//
//  Created by tang on 17.3.23.
//

import Foundation

/// Delegate Proxy
extension BKLineChartView: BKLineTradingViewDataSource {
    public func initTradingView() -> BKLineConfigTradingViewSymbol? {
        return tradingViewDataSouce?.initTradingView()
    }
    
    public func getSymbolInfo(_ symbol: String) -> Any? {
        return tradingViewDataSouce?.getSymbolInfo(symbol)
    }
    
    public func getHistory(_ params: [String : Any], callback: @escaping (Any?) -> Void) {
        tradingViewDataSouce?.getHistory(params, callback: { result in
            callback(result)
        })
    }
    
    public func subscribeBars(_ symbol: String, _ interval: String) {
        tradingViewDataSouce?.subscribeBars(symbol, interval)
    }
    
    public func getKlineOrders(_ symbol: String, _ interval: String, callback: @escaping (Any) -> Void) {
        tradingViewDataSouce?.getKlineOrders(symbol, interval, callback: { result in
            callback(result)
        })
    }
    
    public func getKLineChart(_ params: [String : Any], callback: @escaping (Any) -> Void) {
        tradingViewDataSouce?.getKLineChart(params, callback: { result in
            callback(result)
        })
    }
}

/// Delegate Proxy
extension BKLineChartView: BKLineTradingViewDelegate {
    public func updateKLineChart(_ params: [String : Any], callback: @escaping (Any) -> Void) {
        tradingViewDelegate?.updateKLineChart(params, callback: { result in
            callback(result)
        })
    }
    
    public func deleteKLineChart(_ params: [String : Any], callback: @escaping (Any) -> Void) {
        tradingViewDelegate?.deleteKLineChart(params, callback: { result in
            callback(result)
        })
    }
}

/// Config Handlers
extension BKLineChartView {
    func tradingViewConfigSetup() {
        /// Base
        config.tradingView.base.updateLanguage = { [weak self] conf in
            self?.painterTradingView?.set(language: conf)
        }
        config.tradingView.base.updateTheme = { [weak self] conf in
            self?.painterTradingView?.set(theme: conf)
        }
        config.tradingView.base.updateUpDownColor = { [weak self] conf in
            self?.painterTradingView?.set(upDownColor: conf)
        }
        config.tradingView.base.updateSymbol = { [weak self] conf in
            self?.painterTradingView?.set(symbol: conf.symbol, interval: conf.interval)
        }
        config.tradingView.base.updateChartType = { [weak self] conf in
            self?.painterTradingView?.set(chartType: conf)
        }
        config.tradingView.base.showIndicatorDialog = { [weak self] in
            self?.painterTradingView?.showIndicatorDialog()
        }
        config.tradingView.base.updateBars = { [weak self] bars in
            self?.painterTradingView?.updateBars(bars)
        }
    }
}
