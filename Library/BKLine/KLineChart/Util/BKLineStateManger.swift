//
//  BKLineStateManger.swift
//  KLine-Chart
//
//  Created by tang on 2022/11/8.
//  Copyright © 2022 chunjian wang. All rights reserved.
//

import UIKit

//public class BKLineStateManger {
//    public weak var klineChart: BKLineChartView? {
//        didSet {
//            klineChart?.mainState = mainState
//            klineChart?.secondaryState = secondaryState
//            klineChart?.isLine = isLine
//            klineChart?.datas = datas
//        }
//    }
//
//    public init() {}
//
//    var addDatas: [BKLineChartModel] = []
//
//    var period: String = "5min"
//    var mainState: MainState = .ma
//    var secondaryState: SecondaryState = .macd
//    var isLine = false
//    var datas: [BKLineChartModel] = [] {
//        didSet {
//            klineChart?.datas = datas
//        }
//    }
//
//    public func setMainState(_ state: MainState) {
//        mainState = state
//        klineChart?.mainState = state
//    }
//
//    public func setSecondaryState(_ state: SecondaryState) {
//        secondaryState = state
//        klineChart?.secondaryState = state
//    }
//
//    public func setisLine(_ isLine: Bool) {
//        self.isLine = isLine
//        klineChart?.isLine = isLine
//    }
//
//    public func setDatas(_ datas: [BKLineChartModel]) {
//        self.datas = datas
//        klineChart?.datas = datas
//    }
//
//    public func setPeriod(_ period: String) {
//        self.period = period
//        datas = []
////        HTTPTool.tool.getData(period: period) { datas in
////            DataUtil.calculate(dataList: datas)
////            KLineStateManger.manager.datas = datas
////        }
//    }
//}
