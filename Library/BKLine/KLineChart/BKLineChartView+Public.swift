//
//  BKLineChartView+Public.swift
//  BKLine
//
//  Created by tang on 18.11.22.
//

import Foundation

public extension BKLineChartView {
    /// 区域尺寸
    var areaHeightMain: CGFloat {
        painterView?.calculateAreaHeight()
        return painterView?.mainHeight ?? 0
    }
    var areaHeightVolume: CGFloat {
        painterView?.calculateAreaHeight()
        return painterView?.volHeight ?? 0
    }
    var areaHeightSecondary: CGFloat {
        painterView?.calculateAreaHeight()
        return painterView?.secondaryHeight ?? 0
    }
    
    /// 图表方向
    var chartDirection: BKLineDirection { direction }

    /// 指标
    var chartMainSectionIndex: BKMainSectionIndex { mainSectionIndex }
    var chartVolSectionIndex: BKVolSectionIndex { volSectionIndex }
    var chartSecondarySectionIndex: BKSecondarySectionIndex { secondarySectionIndex }
}

public extension BKLineChartView {
    /// 数据源刷新
    /// - Parameters:
    ///   - data: []
    ///   - isMore: 加载更多
    ///   - needsAppend: 内部自行拼接数据源
    ///   - reset: 重置绘制到起始位置
    func load(_ data: [BKLineChartModel], isMore: Bool = false, needsAppend: Bool = false, reset: Bool = false) {
        guard self.canPerformDataUpdate(ignore: reset) else {return}
        guard !self.isScrolling else {
            if isMore, !self.isHandleMoreData {
                self.currentMoreDatas = data
                self.isHandleMoreData = true
            }
            return
        }
        var newData: [BKLineChartModel] = []
        BKLineDataUtil.calculate(dataList: data)
        if needsAppend {
            newData = self.datas + data
        } else {
            newData = data
        }
        self.datas = newData.reversed()
        if reset {
            self.reset()
        }
    }
    
    /// 当前数据重刷
    func reload(toEnd: Bool = false) {
        let datasCurrent = self.datas
        self.datas = datasCurrent
        if toEnd {
            self.reset()
        }
        if self.chartMode == .tradingView {
            self.painterTradingView?.reload()
        }
    }
    
    /// 重置为空
    func resetData() {
        self.datas = []
        self.reset()
    }
    
    /// 刷新当前价
    func updateCurrentPrice(_ price: CGFloat) {
        guard self.canPerformDataUpdate() else {return}
        guard !self.isScrolling else {return}
        painterView?.drawLatestPrice(price: price)
    }
    
    /// 刷新长按浮窗，如果已展示最新一根k线的浮窗
    func updateStockInfo() {
        
    }
    
    /// 刷新盘口价格
    func updateAskBidPrice(ask: String, bid: String) {
        guard self.config.basic.`switch`.enableAskBidPrice else {
            return
        }
        let model = BKLineChartAskBidPriceModel()
        model.ask = ask
        model.bid = bid
        self.askBidPirce = model
    }
}
