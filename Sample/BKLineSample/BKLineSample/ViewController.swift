//
//  ViewController.swift
//  BKLineSample
//
//  Created by tang on 10.11.22.
//

import UIKit
import BKLine
import SnapKit
import SwifterSwift

class ViewController: UIViewController {
    let displayHeight: CGFloat = 500.0
    var datas = [BKLineChartModel]()
    var priceDecimalLen: Int = 4
    
    let config = BKLineConfigDefault.default
    lazy var lineChartView: BKLineChartView = {
        let line = BKLineChartView(config: config)
        line.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: displayHeight)
        //line.isLine = true
        line.delegate = self
        scrollView.addSubview(line)
        return line
    }()
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 2.0)
        view.addSubview(scroll)
        return scroll
    }()
    
    lazy var tradingViewBtn: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: displayHeight + 30.0, width: 100, height: 30)
        button.setTitle("TradingView", for: .normal)
        button.addTarget(self, action: #selector(self.tradingView), for: .touchUpInside)
        return button
    }()
    
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
        scrollView.addSubview(tradingViewBtn)
        loadData()
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updatePrices), userInfo: nil, repeats: true)
        timer?.fireDate = Date()
    }

    @objc func loadData() {
        let json = [BKLineChartModel].fromMap(
            JSONData: try! Data(contentsOf: Bundle.main.url(forResource: "kline-sample", withExtension: "json")!)
        )!
        datas += json
//        datas = Array(datas[0...12])
        lineChartView.load(datas)
        
        ///买卖标志
        if datas.count > 11 {
            datas[datas.count-8].flagBuy = .currentOrderBuy
            datas[datas.count-8].flagSell = .historyOrderSell
            datas[datas.count-10].flagBuy = .currentOrderBuy
            datas[datas.count-10].flagSell = .historyOrderSell
        }
        
//        self.perform(#selector(loadData), with: nil, afterDelay: 0.3)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
//        config.base.updateSectionMain?(lineChartView.chartMainSectionIndex == .ma ? BKMainSectionIndex.boll : .ma)
        
//        config.base.updateSectionSecondary?(lineChartView.chartSecondarySectionIndex == .macd ? BKSecondarySectionIndex.none : .macd)
        
//        lineChartView.snp.updateConstraints { make in
//            make.height.equalTo(displayHeight - (lineChartView.chartSecondarySectionIndex == .macd ? 0 : lineChartView.areaHeightSecondary))
//        }
        
//        priceDecimalLen = priceDecimalLen == 4 ? 2 : 4
//        let vo = BKLineStyleDecimalLength(price: priceDecimalLen, volume: 2)
//        config.value.updateDecimalLength?(vo)
        
//        config.value.updateOrderFlagSwitch?(
//            BKLineOrderFlagSwitch(
//                currentOrderEnabled: true,
//                historyOrderEnabled: !config.value.historyOrderFlagEnabled
//            )
//        )
        
//        config.value.updateCandleStyle?(
//            config.value.candleStyle == .solid ? .hollowUp : .solid
//        )
    }
    
    @objc func updatePrices() {
        lineChartView.updateCurrentPrice(27500 + CGFloat(arc4random_uniform(5500)))
        
        lineChartView.updateAskBidPrice(
            ask: 17500 + CGFloat(arc4random_uniform(500)), bid: 17500 + CGFloat(arc4random_uniform(500))
        )
    }
    
    @objc func tradingView() {
        self.present(TradingViewPortraitController(), animated: true)
    }
}

extension ViewController: BKLineChartViewDelegate {
    public func loadMoreData(chart: BKLineChartView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let json = [BKLineChartModel].fromMap(
                JSONData: try! Data(contentsOf: Bundle.main.url(forResource: "kline-sample", withExtension: "json")!)
            )!
            self.datas += json
            self.lineChartView.load(self.datas, isMore: true)
        }
    }
}
