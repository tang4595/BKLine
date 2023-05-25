//
//  BKLineChartView+config.basic.swift
//  BKLine
//
//  Created by tang on 20.11.22.
//

import Foundation

extension BKLineChartView {
    func basicConfigSetup() {
        isLine = config.basic.`switch`.isLine
        direction = config.basic.base.direction
        mainSectionIndex = config.basic.base.mainSectionIndex
        volSectionIndex = config.basic.base.volSectionIndex
        secondarySectionIndex = config.basic.base.secondarySectionIndex
        
        /// Global
        config.updateMode = { [weak self] conf in
            self?.chartMode = conf
            self?.commonSetup()
            self?.uiSetup()
        }
        
        /// Base
        config.basic.base.updateDirection = { [weak self] conf in
            self?.direction = conf
        }
        config.basic.base.updateSectionMain = { [weak self] conf in
            self?.setSectionIndexConfig(conf)
        }
        config.basic.base.updateSectionVolume = { [weak self] conf in
            self?.setSectionIndexConfig(conf)
        }
        config.basic.base.updateSectionSecondary = { [weak self] conf in
            self?.setSectionIndexConfig(conf)
        }
        
        /// Switch
        config.basic.`switch`.updateIsLine = { [weak self] conf in
            guard let self = self, self.isLine != conf else {return}
            self.isLine = conf
        }
        config.basic.`switch`.updateEnableCountdown = { [weak self] conf in
            guard let self = self, self.config.basic.`switch`.enableCountdown != conf else {return}
            self.config.basic.`switch`.enableCountdown = conf
            self.reload()
            if conf {
                self.painterView?.startCountdown()
            }
        }
        config.basic.`switch`.updateEnableAskBidPrice = { [weak self] conf in
            guard let self = self, self.config.basic.`switch`.enableAskBidPrice != conf else {return}
            self.config.basic.`switch`.enableAskBidPrice = conf
            self.reload()
        }
        config.basic.`switch`.updateKeepScaleRation = { [weak self] conf in
            guard let self = self, self.config.basic.`switch`.keepScaleRatio != conf else {return}
            self.config.basic.`switch`.keepScaleRatio = conf
            if !conf {
                self.reload(toEnd: true)
            }
        }
        
        /// Value
        config.basic.value.updateCandleStyle = { [weak self] conf in
            guard let self = self else {return}
            self.config.basic.value.candleStyle = conf
            self.reload()
        }
        config.basic.value.updateDecimalLength = { [weak self] conf in
            guard let self = self else {return}
            self.config.basic.value.decimalLenPrice = conf.price
            self.config.basic.value.decimalLenVolume = conf.volume
            if self.chartMode == .basic {
                self.reload()
            }
        }
        config.basic.value.updateOrderFlagSwitch = { [weak self] conf in
            guard let self = self else {return}
            self.config.basic.value.currentOrderFlagEnabled = conf.currentOrderEnabled
            self.config.basic.value.historyOrderFlagEnabled = conf.historyOrderEnabled
            self.reload()
        }
    }
    
    /// 指标更新
    fileprivate func setSectionIndexConfig(_ conf: BKSectionIndexProtocol) {
        if let conf = conf as? BKMainSectionIndex {
            self.mainSectionIndex = conf
        } else if let conf = conf as? BKVolSectionIndex {
            self.volSectionIndex = conf
        } else if let conf = conf as? BKSecondarySectionIndex {
            self.secondarySectionIndex = conf
        }
    }
}

extension BKLineChartView {
    /// 数据刷新限流
    /// - Parameter ignore: ignore this session
    /// - Returns: allows bool
    func canPerformDataUpdate(ignore: Bool = false) -> Bool {
        guard !ignore else {
            return true
        }
        let currentMs: Int64 = currentTimeMillis()
        let lastMs = self.lastTimeToRefreshData
        let distanceMs = currentMs - lastMs
        let thresholdMs = 333
        let allows = distanceMs >= thresholdMs
        if allows {
            self.lastTimeToRefreshData = currentMs
        }
        return allows
    }
}
