//
//  VolChartRenderer.swift
//  KLine-Chart
//
//  Created by tang on 2022/11/8.
//  Copyright © 2022 chunjian wang. All rights reserved.
//

import UIKit

class VolChartRenderer: BaseChartRenderer {
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

        context.move(to: CGPoint(x: 0, y: chartRect.minY))
        context.addLine(to: CGPoint(x: chartRect.maxX, y: chartRect.minY))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
    }

    override func drawChart(context: CGContext, lastPoint: BKLineChartModel?, curPoint: BKLineChartModel, curX: CGFloat) {
        drawVolChart(context: context, curPoint: curPoint, curX: curX)
        guard let _lastPoint = lastPoint else {
            return
        }
        if curPoint.MA5Volume != 0 {
            drawLine(context: context, lastValue: _lastPoint.MA5Volume, curValue: curPoint.MA5Volume, curX: curX, color: config.basic.color.ma5Color)
        }
        if curPoint.MA10Volume != 0 {
            drawLine(context: context, lastValue: _lastPoint.MA10Volume, curValue: curPoint.MA10Volume, curX: curX, color: config.basic.color.ma10Color)
        }
    }

    override func drawTopText(context _: CGContext, curPoint: BKLineChartModel) {
        let topAttributeText = NSMutableAttributedString()
        let vol = volFormat(value: curPoint.vol)
        let volAttr = NSAttributedString(string: "VOL:\(vol)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.volColor])
        topAttributeText.append(volAttr)

        let ma5 = volFormat(value: curPoint.MA5Volume)
        let ma5Attr = NSAttributedString(string: "MA5:\(ma5)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.ma5Color])
        topAttributeText.append(ma5Attr)

        let ma10 = volFormat(value: curPoint.MA10Volume)
        let ma10Attr = NSAttributedString(string: "MA10:\(ma10)    ", attributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.ma10Color])
        topAttributeText.append(ma10Attr)
        topAttributeText.draw(at: CGPoint(x: 5, y: chartRect.minY))
    }

    override func drawRightText(context _: CGContext, gridRows _: Int, gridColums _: Int) {
        let text = volFormat(value: maxValue)
        let rect = calculateTextRect(text: text, font: config.basic.font.reightTextFont)
        (text as NSString).draw(at: CGPoint(x: chartRect.width - rect.width, y: chartRect.minY), withAttributes: [NSAttributedString.Key.font: config.basic.font.reightTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.rightTextColor])
    }

    func drawVolChart(context: CGContext, curPoint: BKLineChartModel, curX: CGFloat) {
        let top = getY(curPoint.vol)
        context.setLineWidth(candleWidth)
        if curPoint.close > curPoint.open {
            context.setStrokeColor(config.basic.color.upColor.cgColor)
        } else {
            context.setStrokeColor(config.basic.color.downColor.cgColor)
        }
        context.move(to: CGPoint(x: curX, y: chartRect.maxY))
        context.addLine(to: CGPoint(x: curX, y: top))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
    }
}
