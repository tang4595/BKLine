//
//  BKLineStockInfoView.swift
//  KLine-Chart
//
//  Created by tang on 2022/11/8.
//  Copyright © 2022 chunjian wang. All rights reserved.
//

import UIKit
import SnapKit

class BKLineStockInfoItemView: UIView {
    var config: BKLineConfigProtocol = BKLineConfigDefault()
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = config.basic.font.stockInfoTitleFont
        lbl.backgroundColor = .clear
        lbl.textColor = config.basic.color.stockInfoTitleColor
        lbl.text = "-"
        addSubview(lbl)
        return lbl
    }()
    
    lazy var valueLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = config.basic.font.stockInfoValueFont
        lbl.backgroundColor = .clear
        lbl.textColor = config.basic.color.stockInfoValueColor
        lbl.text = "-"
        addSubview(lbl)
        return lbl
    }()
    
    convenience init(config: BKLineConfigProtocol, title: String) {
        self.init()
        self.config = config
        titleLbl.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(5)
            make.top.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(0)
        }
        valueLbl.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-5)
            make.top.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(0)
        }
        titleLbl.text = title
    }
}

class BKLineStockInfoView: UIView {
    var config: BKLineConfigProtocol = BKLineConfigDefault()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            self.timeItem,
            self.openItem,
            self.highItem,
            self.lowItem,
            self.closeItem,
            self.raiseValueItem,
            self.raiseRateItem,
            self.volumeItem
        ])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 5.5
        addSubview(stack)
        return stack
    }()
    
    lazy var timeItem: BKLineStockInfoItemView = BKLineStockInfoItemView(config: config, title: config.basic.text.stockInfoTextDate)
    lazy var highItem: BKLineStockInfoItemView = BKLineStockInfoItemView(config: config, title: config.basic.text.stockInfoTextHigh)
    lazy var lowItem: BKLineStockInfoItemView = BKLineStockInfoItemView(config: config, title: config.basic.text.stockInfoTextLow)
    lazy var openItem: BKLineStockInfoItemView = BKLineStockInfoItemView(config: config, title: config.basic.text.stockInfoTextOpen)
    lazy var closeItem: BKLineStockInfoItemView = BKLineStockInfoItemView(config: config, title: config.basic.text.stockInfoTextClose)
    lazy var raiseRateItem: BKLineStockInfoItemView = BKLineStockInfoItemView(config: config, title: config.basic.text.stockInfoTextChangeRate)
    lazy var raiseValueItem: BKLineStockInfoItemView = BKLineStockInfoItemView(config: config, title: config.basic.text.stockInfoTextChangeVolume)
    lazy var volumeItem: BKLineStockInfoItemView = BKLineStockInfoItemView(config: config, title: config.basic.text.stockInfoTextDealVol)
    
    convenience init(config: BKLineConfigProtocol) {
        self.init()
        self.config = config
        backgroundColor = self.config.basic.color.stockInfoBgColor
        layer.borderColor = self.config.basic.color.stockInfoBorderColor.cgColor
        layer.cornerRadius = 3
        layer.borderWidth = 0.5
        clipsToBounds = true
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6))
        }
        if config.basic.`switch`.stockInfoShowVolume == false {
            removeVolumeItem()
        }
    }
    
    func update(model: BKLineChartModel) -> Void {
        timeItem.valueLbl.text = Date.formated(model.count, format: "yyyy/MM/dd HH:mm")
        let bit = config.basic.value.decimalLenPrice
        let amountDigits = config.basic.value.decimalLenVolume
        openItem.valueLbl.text = model.open.format(maxF: bit).shortZeroString
        highItem.valueLbl.text = model.high.format(maxF: bit).shortZeroString
        lowItem.valueLbl.text = model.low.format(maxF: bit).shortZeroString
        closeItem.valueLbl.text = model.close.format(maxF: bit).shortZeroString
        volumeItem.valueLbl.text = Double(model.vol).formatKM(maxF: amountDigits)
        let raiseValue = model.close - model.open
        let open = model.open == 0 ? 1 : model.open
        if raiseValue > 0 {
            raiseValueItem.valueLbl.text = "+\(raiseValue.format(maxF: bit).shortZeroString)"
            raiseRateItem.valueLbl.text = "+\((raiseValue * 100 / open).format(maxF: 2))%"
            raiseRateItem.valueLbl.textColor = config.basic.color.upColor
            raiseValueItem.valueLbl.textColor = config.basic.color.upColor
        } else {
            raiseValueItem.valueLbl.text = raiseValue.format(maxF: bit).shortZeroString
            raiseRateItem.valueLbl.text = "\((raiseValue * 100 / open).format(maxF: 2) )%"
            raiseRateItem.valueLbl.textColor = config.basic.color.downColor
            raiseValueItem.valueLbl.textColor = config.basic.color.downColor
        }
    }
    
    func updateQuote(quote: BKLineChartModel) {
        closeItem.valueLbl.text = quote.close.format(maxF: config.basic.value.decimalLenPrice)
    }
    
    func removeVolumeItem() {
        stackView.removeArrangedSubview(volumeItem)
        volumeItem.removeFromSuperview()
    }
}
