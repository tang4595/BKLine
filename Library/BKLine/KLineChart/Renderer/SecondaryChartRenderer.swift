//
//  SecondaryChartRenderer.swift
//  KLine-Chart
//
//  Created by tang on 2022/11/8.
//  Copyright © 2022 chunjian wang. All rights reserved.
//

import UIKit

class SecondaryChartRenderer: BaseChartRenderer {
    var mMACDWidth: CGFloat = 5
    var state: BKSecondarySectionIndex = .none

    init(
        config: BKLineConfigProtocol,
        maxValue: CGFloat,
        minValue: CGFloat,
        chartRect: CGRect,
        candleWidth: CGFloat,
        topPadding: CGFloat,
        state: BKSecondarySectionIndex
    ) {
        super.init(
            config: config,
            maxValue: maxValue,
            minValue: minValue,
            chartRect: chartRect,
            candleWidth: candleWidth,
            topPadding: topPadding
        )
        self.state = state
    }

    override func drawGrid(context: CGContext, gridRows _: Int, gridColums: Int) {
        context.setStrokeColor(config.basic.color.gridColor.cgColor)
        context.setLineWidth(0.5)
        let columsSpace = chartRect.width / CGFloat(gridColums)
        for index in 0 ..< gridColums {
            context.move(to: CGPoint(x: CGFloat(index) * columsSpace, y: chartRect.minY))
            context.addLine(to: CGPoint(x: CGFloat(index) * columsSpace, y: chartRect.maxY))
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        }
        context.move(to: CGPoint(x: 0, y: chartRect.maxY))
        context.addLine(to: CGPoint(x: chartRect.maxX, y: chartRect.maxY))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
    }

    override func drawChart(context: CGContext, lastPoint: BKLineChartModel?, curPoint: BKLineChartModel, curX: CGFloat) {
        if state == BKSecondarySectionIndex.macd {
            drawMACD(context: context, lastPoint: lastPoint, curPoint: curPoint, curX: curX)
        } else if state == BKSecondarySectionIndex.kdj {
            if let _lastPoint = lastPoint {
                if curPoint.k != 0 {
                    drawLine(context: context, lastValue: _lastPoint.k, curValue: curPoint.k, curX: curX, color: config.basic.color.kColor)
                }
                if curPoint.d != 0 {
                    drawLine(context: context, lastValue: _lastPoint.d, curValue: curPoint.d, curX: curX, color: config.basic.color.dColor)
                }
                if curPoint.j != 0 {
                    drawLine(context: context, lastValue: _lastPoint.j, curValue: curPoint.j, curX: curX, color: config.basic.color.jColor)
                }
            }
        } else if state == BKSecondarySectionIndex.rsi {
            if let _lastPoint = lastPoint {
                if curPoint.rsi != 0 {
                    drawLine(context: context, lastValue: _lastPoint.rsi, curValue: curPoint.rsi, curX: curX, color: config.basic.color.rsiColor)
                }
            }
        } else if state == BKSecondarySectionIndex.wr {
            if let _lastPoint = lastPoint {
                if curPoint.r != 0 {
                    drawLine(context: context, lastValue: _lastPoint.r, curValue: curPoint.r, curX: curX, color: config.basic.color.wrColor)
                }
            }
        }
    }

    override func drawTopText(context _: CGContext, curPoint: BKLineChartModel) {
        let topAttributeText = NSMutableAttributedString()
        switch state {
        case .macd:
            let valueAttr = NSAttributedString(string: "MACD(12,26,9)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.bottomDateTextColor])
            topAttributeText.append(valueAttr)
            if curPoint.macd != 0 {
                let value = curPoint.macd.format(maxF: config.basic.value.decimalLenPrice)
                let valueAttr = NSAttributedString(string: "MACD:\(value)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.macdColor])
                topAttributeText.append(valueAttr)
            }
            if curPoint.dif != 0 {
                let value = curPoint.dif.format(maxF: config.basic.value.decimalLenPrice)
                let valueAttr = NSAttributedString(string: "DIF:\(value)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.difColor])
                topAttributeText.append(valueAttr)
            }
            if curPoint.dea != 0 {
                let value = curPoint.dea.format(maxF: config.basic.value.decimalLenPrice)
                let valueAttr = NSAttributedString(string: "DEA:\(value)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.deaColor])
                topAttributeText.append(valueAttr)
            }
        case .rsi:
            let value = curPoint.rsi.format(maxF: config.basic.value.decimalLenPrice)
            let valueAttr = NSAttributedString(string: "RSI(14):\(value)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.rsiColor])
            topAttributeText.append(valueAttr)
        case .wr:
            let value = curPoint.r.format(maxF: config.basic.value.decimalLenPrice)
            let valueAttr = NSAttributedString(string: "WR(14):\(value)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.wrColor])
            topAttributeText.append(valueAttr)
        case .kdj:
            let valueAttr = NSAttributedString(string: "KDJ(14,1,3)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.bottomDateTextColor])
            topAttributeText.append(valueAttr)
            if curPoint.k != 0 {
                let value = curPoint.k.format(maxF: config.basic.value.decimalLenPrice)
                let valueAttr = NSAttributedString(string: "K:\(value)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.kColor])
                topAttributeText.append(valueAttr)
            }
            if curPoint.d != 0 {
                let value = curPoint.d.format(maxF: config.basic.value.decimalLenPrice)
                let valueAttr = NSAttributedString(string: "D:\(value)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.dColor])
                topAttributeText.append(valueAttr)
            }
            if curPoint.j != 0 {
                let value = curPoint.j.format(maxF: config.basic.value.decimalLenPrice)
                let valueAttr = NSAttributedString(string: "J:\(value)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.jColor])
                topAttributeText.append(valueAttr)
            }
        case .none:
            break
        }
        topAttributeText.draw(at: CGPoint(x: 5, y: chartRect.minY))
    }

    override func drawRightText(context _: CGContext, gridRows _: Int, gridColums _: Int) {
        let text = volFormat(value: maxValue)
        let rect = calculateTextRect(text: text, font: config.basic.font.reightTextFont)
        (text as NSString).draw(at: CGPoint(x: chartRect.width - rect.width, y: chartRect.minY), withAttributes: [NSAttributedString.Key.font: config.basic.font.reightTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.rightTextColor])
    }

    func drawMACD(context: CGContext, lastPoint: BKLineChartModel?, curPoint: BKLineChartModel, curX: CGFloat) {
        let maxdY = getY(curPoint.macd)
        let zeroy = getY(0)
        if curPoint.macd > 0 {
            context.setStrokeColor(config.basic.color.upColor.cgColor)
        } else {
            context.setStrokeColor(config.basic.color.downColor.cgColor)
        }
        context.setLineWidth(mMACDWidth)
        context.move(to: CGPoint(x: curX, y: maxdY))
        context.addLine(to: CGPoint(x: curX, y: zeroy))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        if let _lastPoint = lastPoint {
            if curPoint.dif != 0 {
                drawLine(context: context, lastValue: _lastPoint.dif, curValue: curPoint.dif, curX: curX, color: config.basic.color.difColor)
            }
            if curPoint.dea != 0 {
                drawLine(context: context, lastValue: _lastPoint.dea, curValue: curPoint.dea, curX: curX, color: config.basic.color.deaColor)
            }
        }
    }
}
