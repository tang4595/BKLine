//
//  MainChartRenderer.swift
//  KLine-Chart
//
//  Created by tang on 2022/11/8.
//  Copyright © 2022 chunjian wang. All rights reserved.
//

import UIKit

class MainChartRenderer: BaseChartRenderer {
    var contentPadding: CGFloat = 20

    var isLine: Bool = false
    var state: BKMainSectionIndex = .none

    init(
        config: BKLineConfigProtocol,
        maxValue: CGFloat,
        minValue: CGFloat,
        chartRect: CGRect,
        candleWidth: CGFloat,
        topPadding: CGFloat,
        isLine: Bool,
        state: BKMainSectionIndex
    ) {
        super.init(
            config: config,
            maxValue: maxValue,
            minValue: minValue,
            chartRect: chartRect,
            candleWidth: candleWidth,
            topPadding: topPadding
        )
        self.isLine = isLine
        self.state = state
        let diff = maxValue - minValue
        let newScalY = (chartRect.height - contentPadding) / diff
        let newDiff = chartRect.height / newScalY
        let value = (newDiff - diff) / 2
        if newDiff > diff {
            scaleY = newScalY
            self.maxValue += value
            self.minValue -= value
        }
    }

    override func drawGrid(context: CGContext, gridRows: Int, gridColums: Int) {
        context.setStrokeColor(config.basic.color.gridColor.cgColor)
        context.setLineWidth(0.5)
        let columsSpace = chartRect.width / CGFloat(gridColums)
        for index in 0 ..< gridColums {
            context.move(to: CGPoint(x: CGFloat(index) * columsSpace, y: 0))
            context.addLine(to: CGPoint(x: CGFloat(index) * columsSpace, y: chartRect.maxY))
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        }
        let rowSpace = chartRect.height / CGFloat(gridRows)
        for index in 0 ... gridRows {
            context.move(to: CGPoint(x: 0, y: CGFloat(index) * rowSpace + config.basic.value.topPadding))
            context.addLine(to: CGPoint(x: chartRect.maxX, y: CGFloat(index) * rowSpace + config.basic.value.topPadding))
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        }
    }

    override func drawChart(context: CGContext, lastPoint: BKLineChartModel?, curPoint: BKLineChartModel, curX: CGFloat) {
        if !isLine {
            drawCandle(context: context, curPoint: curPoint, curX: curX)
        }
        if let _lastPoint = lastPoint {
            if isLine {
                drawTimeLine(context: context, lastValue: _lastPoint.close, curValue: curPoint.close, curX: curX)
            } else if state == BKMainSectionIndex.ma {
                drawMaLine(context: context, lastPoint: _lastPoint, curPoint: curPoint, curX: curX)
            } else if state == BKMainSectionIndex.boll {
                drawBOLL(context: context, lastPoint: _lastPoint, curPoint: curPoint, curX: curX)
            }
        }
    }

    func drawTimeLine(context: CGContext, lastValue: CGFloat, curValue: CGFloat, curX: CGFloat) {
        let x1 = curX
        let y1 = getY(curValue)
        let x2 = curX + candleWidth + config.basic.value.canldeMargin
        let y2 = getY(lastValue)
        let color = config.basic.color.timeLineColor
        context.setLineWidth(1)
        context.setStrokeColor(color.cgColor)
        context.move(to: CGPoint(x: x1, y: y1))
        context.addCurve(to: CGPoint(x: x2, y: y2), control1: CGPoint(x: (x1 + x2) / 2, y: y1), control2: CGPoint(x: (x1 + x2) / 2, y: y2))
        context.drawPath(using: CGPathDrawingMode.fillStroke)

        // 创建并设置路径
        let path = CGMutablePath()
        path.move(to: CGPoint(x: x1, y: chartRect.maxY))
        path.addLine(to: CGPoint(x: x1, y: y1))
        path.addCurve(to: CGPoint(x: x2, y: y2), control1: CGPoint(x: (x1 + x2) / 2, y: y1), control2: CGPoint(x: (x1 + x2) / 2, y: y2))
        path.addLine(to: CGPoint(x: x2, y: chartRect.maxY))
        path.closeSubpath()
        // 添加路径到图形上下文
        context.addPath(path)
        context.clip()
        
        // 使用rgb颜色空间
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // 颜色数组
        var r: CGFloat = 1
        var g: CGFloat = 1
        var b: CGFloat = 1
        color.getRed(&r, green: &g, blue: &b, alpha: nil)
        let compoents:[CGFloat] = [
            r, g, b, 0.5,
            r, g, b, 0
        ]
        // 每组颜色所在位置（范围0~1)
        let locations: [CGFloat] = [0, 1]
        // 生成渐变色（count参数表示渐变个数）
        if let gradient = CGGradient(colorSpace: colorSpace,
                                     colorComponents: compoents,
                                     locations: locations,
                                     count: locations.count) {
            // 渐变开始位置
            let start = CGPoint(x: (x1 + x2) / 2, y: chartRect.minY)
            // 渐变结束位置
            let end = CGPoint(x: (x1 + x2) / 2, y: chartRect.maxY)
            // 绘制渐变
            context.drawLinearGradient(gradient, start: start, end: end,
                                       options: .drawsAfterEndLocation)
        }

        context.resetClip()
    }

    func drawMaLine(context: CGContext, lastPoint: BKLineChartModel, curPoint: BKLineChartModel, curX: CGFloat) {
        if curPoint.MA5Price != 0 {
            drawLine(context: context, lastValue: lastPoint.MA5Price, curValue: curPoint.MA5Price, curX: curX, color: config.basic.color.ma5Color)
        }
        if curPoint.MA10Price != 0 {
            drawLine(context: context, lastValue: lastPoint.MA10Price, curValue: curPoint.MA10Price, curX: curX, color: config.basic.color.ma10Color)
        }
        if curPoint.MA30Price != 0 {
            drawLine(context: context, lastValue: lastPoint.MA30Price, curValue: curPoint.MA30Price, curX: curX, color: config.basic.color.ma30Color)
        }
    }

    func drawBOLL(context: CGContext, lastPoint: BKLineChartModel, curPoint: BKLineChartModel, curX: CGFloat) {
        if curPoint.up != 0 {
            drawLine(context: context, lastValue: lastPoint.up, curValue: curPoint.up, curX: curX, color: config.basic.color.ma5Color)
        }
        if curPoint.mb != 0 {
            drawLine(context: context, lastValue: lastPoint.mb, curValue: curPoint.mb, curX: curX, color: config.basic.color.ma10Color)
        }
        if curPoint.dn != 0 {
            drawLine(context: context, lastValue: lastPoint.dn, curValue: curPoint.dn, curX: curX, color: config.basic.color.ma30Color)
        }
    }

    func drawCandle(context: CGContext, curPoint: BKLineChartModel, curX: CGFloat) {
        let high = getY(curPoint.high)
        let low = getY(curPoint.low)
        let open = getY(curPoint.open)
        let close = getY(curPoint.close)
        var color = config.basic.color.downColor
        let isUp = open > close
        if isUp {
            color = config.basic.color.upColor
        }
        
        /// 实心蜡烛
        let drawSolidClosure = { (config: BKLineConfigProtocol, candleWidth: CGFloat) in
            /// 画贯穿线条
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(config.basic.value.candleLineWidth)
            context.move(to: CGPoint(x: curX, y: high))
            context.addLine(to: CGPoint(x: curX, y: low))
            context.drawPath(using: CGPathDrawingMode.fillStroke)
            
            /// 画开/收主体
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(candleWidth)
            context.move(to: CGPoint(x: curX, y: open))
            context.addLine(to: CGPoint(x: curX, y: close))
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        }
        
        /// 空心蜡烛
        let drawHollowClosure = { (config: BKLineConfigProtocol, candleWidth: CGFloat) in
            let lineWidth: CGFloat = config.basic.value.candleLineWidth
            /// 画贯穿线条
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(lineWidth)
            if isUp {
                if close > high {
                    context.move(to: CGPoint(x: curX, y: high))
                    context.addLine(to: CGPoint(x: curX, y: close))
                }
                if low > open {
                    context.move(to: CGPoint(x: curX, y: open))
                    context.addLine(to: CGPoint(x: curX, y: low))
                }
            } else {
                if open > high {
                    context.move(to: CGPoint(x: curX, y: high))
                    context.addLine(to: CGPoint(x: curX, y: open))
                }
                if low > close {
                    context.move(to: CGPoint(x: curX, y: close))
                    context.addLine(to: CGPoint(x: curX, y: low))
                }
            }
            context.drawPath(using: CGPathDrawingMode.fillStroke)
            
            /// 画开/收主体
            let halfCandleWidth: CGFloat = candleWidth / 2.0
            let candleMargin: CGFloat = lineWidth / 2.0
            let xMin: CGFloat = curX - halfCandleWidth + candleMargin
            let xMax: CGFloat = curX + halfCandleWidth - candleMargin
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(lineWidth)
            context.move(to: CGPoint(x: xMin, y: open))
            context.addLine(to: CGPoint(x: xMax, y: open))
            context.addLine(to: CGPoint(x: xMax, y: close))
            context.addLine(to: CGPoint(x: xMin, y: close))
            context.addLine(to: CGPoint(x: xMin, y: open))
            context.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        /// 画蜡烛
        switch config.basic.value.candleStyle {
        case .solid:
            drawSolidClosure(config, candleWidth)
        case .hollowUp:
            if isUp {
                drawHollowClosure(config, candleWidth)
            } else {
                drawSolidClosure(config, candleWidth)
            }
        case .hollowDown:
            if !isUp {
                drawHollowClosure(config, candleWidth)
            } else {
                drawSolidClosure(config, candleWidth)
            }
        }
        
        /// 画单子买卖标志
        drawOrderFlag(curPoint: curPoint, curX: curX, maxY: max(low, close), minY: min(high, close))
    }
    
    @inline(__always)
    func drawOrderFlag(curPoint: BKLineChartModel, curX: CGFloat, maxY: CGFloat, minY: CGFloat) {
        guard
            (config.basic.value.currentOrderFlagEnabled || config.basic.value.historyOrderFlagEnabled),
            (curPoint.flagBuy != nil || curPoint.flagSell != nil)
        else {
            return
        }
        
        let padding: CGFloat = 5.0
        let drawFlagBuyClosure = { (config: BKLineConfigProtocol, candleWidth: CGFloat) in
            if let flag = curPoint.flagBuy?.flagIcon(withConfig: config.basic.value) {
                let height = flag.size.height * (candleWidth / flag.size.width)
                flag.draw(in: CGRect(
                    x: curX - (candleWidth / 2.0),
                    y: maxY + padding,
                    width: candleWidth,
                    height: height
                ))
            }
        }
        let drawFlagSellClosure = { (config: BKLineConfigProtocol, candleWidth: CGFloat) in
            if let flag = curPoint.flagSell?.flagIcon(withConfig: config.basic.value) {
                let height = flag.size.height * (candleWidth / flag.size.width)
                flag.draw(in: CGRect(
                    x: curX - (candleWidth / 2.0),
                    y: minY - padding - height,
                    width: candleWidth,
                    height: height
                ))
            }
        }
        
        if (curPoint.flagBuy?.isCurrentOrder == true && config.basic.value.currentOrderFlagEnabled)
            || (curPoint.flagBuy?.isHistoryOrder == true && config.basic.value.historyOrderFlagEnabled) {
            drawFlagBuyClosure(config, config.basic.value.candleWidth)
        }
        if (curPoint.flagSell?.isCurrentOrder == true && config.basic.value.currentOrderFlagEnabled)
            || (curPoint.flagSell?.isHistoryOrder == true && config.basic.value.historyOrderFlagEnabled) {
            drawFlagSellClosure(config, config.basic.value.candleWidth)
        }
    }

    override func drawRightText(context _: CGContext, gridRows: Int, gridColums _: Int) {
        let rowSpace = chartRect.height / CGFloat(gridRows)
        for i in 0 ... gridRows {
            var position: CGFloat = 0
            position = CGFloat(gridRows - i) * rowSpace
            var value = getYValue(position)
            if value < 0 {
                value = 0
            }
            let valueStr = value.format(maxF: config.basic.value.decimalLenPrice).shortZeroString
            let rect = calculateTextRect(text: valueStr, font: config.basic.font.reightTextFont)
            var y: CGFloat = 0
            if i == 0 {
                y = getY(value)
            } else {
                y = getY(value) - rect.height
            }
            valueStr.draw(at: CGPoint(x: chartRect.width - rect.width, y: y), withAttributes: [NSAttributedString.Key.font: config.basic.font.reightTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.rightTextColor])
        }
    }

    override func drawTopText(context _: CGContext, curPoint: BKLineChartModel) {
        switch state {
        case .none:
            break
        case .ma:
            let topAttributeText = NSMutableAttributedString()
            if curPoint.MA5Price != 0 {
                let ma5Price = curPoint.MA5Price.format(maxF: config.basic.value.decimalLenPrice)
                let ma5Attr = NSAttributedString(string: "MA5:\(ma5Price)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.ma5Color])
                topAttributeText.append(ma5Attr)
            }
            if curPoint.MA10Price != 0 {
                let ma10Price = curPoint.MA10Price.format(maxF: config.basic.value.decimalLenPrice)
                let ma10Attr = NSAttributedString(string: "MA10:\(ma10Price)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.ma10Color])
                topAttributeText.append(ma10Attr)
            }
            if curPoint.MA30Price != 0 {
                let ma30Price = curPoint.MA30Price.format(maxF: config.basic.value.decimalLenPrice)
                let ma30Attr = NSAttributedString(string: "MA30:\(ma30Price)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.ma30Color])
                topAttributeText.append(ma30Attr)
            }
            topAttributeText.draw(at: CGPoint(x: 5, y: 6))
        case .boll:
            let topAttributeText = NSMutableAttributedString()
            if curPoint.mb != 0 {
                let ma5Price = curPoint.mb.format(maxF: config.basic.value.decimalLenPrice)
                let ma5Attr = NSAttributedString(string: "BOLL:\(ma5Price)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.ma5Color])
                topAttributeText.append(ma5Attr)
            }
            if curPoint.up != 0 {
                let ma10Price = curPoint.up.format(maxF: config.basic.value.decimalLenPrice)
                let ma10Attr = NSAttributedString(string: "UB:\(ma10Price)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.ma10Color])
                topAttributeText.append(ma10Attr)
            }
            if curPoint.dn != 0 {
                let ma30Price = curPoint.dn.format(maxF: config.basic.value.decimalLenPrice)
                let ma30Attr = NSAttributedString(string: "LB:\(ma30Price)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.ma30Color])
                topAttributeText.append(ma30Attr)
            }
            topAttributeText.draw(at: CGPoint(x: 5, y: 6))
        }
    }

    override func getY(_ value: CGFloat) -> CGFloat {
        return scaleY * (maxValue - value) + chartRect.minY
    }
}
