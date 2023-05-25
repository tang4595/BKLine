//
//  BKLineChartPainterView.swift
//  KLine-Chart
//
//  Created by tang on 2022/11/8.
//  Copyright © 2022 chunjian wang. All rights reserved.
//

import UIKit

enum BKLineRealTimeLocaltion {
    case latest, history
}

class BKLineChartPainterView: UIView {
    var config: BKLineConfigProtocol = BKLineConfigDefault()
    var datas: [BKLineChartModel] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    var askBidPrice: BKLineChartAskBidPriceModel? {
        didSet {
            setNeedsDisplay()
        }
    }

    var scrollX: CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    /// 距离右边的距离
    var startX: CGFloat = 0
    var isLine = false {
        didSet {
            setNeedsDisplay()
        }
    }

    var scaleX: CGFloat = 1.0 {
        didSet {
            self.candleWidth = scaleX * config.basic.value.candleWidth
            self.setNeedsDisplay()
        }
    }

    var isLongPress: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 长按坐标
    var longPressX: CGFloat = 0
    var longPressY: CGFloat = 0

    /// 图表区域
    var mainRect: CGRect!
    var volRect: CGRect?
    var secondaryRect: CGRect?
    var dateRect: CGRect!
    
    /// 当前价指示器区域
    var realTimeRect: CGRect = .zero
    var realTimeLocaltion: BKLineRealTimeLocaltion = .latest

    /// 主图指标
    var mainSectionIndex: BKMainSectionIndex = .none {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 附图指标
    var volSectionIndex: BKVolSectionIndex = .vol {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 附图次指标
    var secondarySectionIndex: BKSecondarySectionIndex = .none {
        didSet {
            setNeedsDisplay()
        }
    }

    var displayHeight: CGFloat = 0

    /// 图表分区（主图、附图、附图指标）
    var mainRenderer: MainChartRenderer!
    var volRenderer: VolChartRenderer?
    var seconderyRender: SecondaryChartRenderer?
    
    /// 区域尺寸
    var mainHeight: CGFloat { _mainHeight }
    var volHeight: CGFloat  { _volHeight }
    var secondaryHeight: CGFloat  { _secondaryHeight }
    private var _mainHeight: CGFloat = 0
    private var _volHeight: CGFloat = 0
    private var _secondaryHeight: CGFloat = 0

    /// 需要绘制的开始和结束下标
    var startIndex: Int = 0
    var stopIndex: Int = 0

    var mMainMaxIndex: Int = 0
    var mMainMinIndex: Int = 0

    var mMainMaxValue: CGFloat = 0
    var mMainMinValue: CGFloat = CGFloat(MAXFLOAT)

    var mVolMaxValue: CGFloat = -CGFloat(MAXFLOAT)
    var mVolMinValue: CGFloat = CGFloat(MAXFLOAT)

    var mSecondaryMaxValue: CGFloat = -CGFloat(MAXFLOAT)
    var mSecondaryMinValue: CGFloat = CGFloat(MAXFLOAT)

    var mMainHighMaxValue: CGFloat = -CGFloat(MAXFLOAT)
    var mMainLowMinValue: CGFloat = CGFloat(MAXFLOAT)

    var dateFromat: String = "yyyy-MM-dd"

    var showInfoBlock: ((BKLineChartModel, Bool) -> Void)?

    var candleWidth: CGFloat!

    var direction: BKLineDirection = .vertical
    
    /// 倒计时（最后一根蜡烛距离结束）
    private var countdownTimer: Timer?
    private var countdownText: String?

    var fuzzylayer: CALayer = {
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        layer.backgroundColor = UIColor.rgb(r: 0, 0, 0, alpha: 0.3).cgColor
        layer.cornerRadius = 10
        layer.masksToBounds = true
        return layer
    }()

    init(
        frame: CGRect,
        config: BKLineConfigProtocol,
        datas: [BKLineChartModel],
        scrollX: CGFloat,
        isLine: Bool,
        scaleX: CGFloat,
        isLongPress: Bool,
        mainSectionIndex: BKMainSectionIndex,
        secondarySectionIndex: BKSecondarySectionIndex
    ) {
        super.init(frame: frame)
        self.config = config
        self.datas = datas
        self.scrollX = scrollX
        self.isLine = isLine
        self.scaleX = scaleX
        self.isLongPress = isLongPress
        self.mainSectionIndex = mainSectionIndex
        self.volSectionIndex = config.basic.base.volSectionIndex
        self.secondarySectionIndex = secondarySectionIndex
        candleWidth = self.scaleX * config.basic.value.candleWidth
        
        createCountdownTimer()
        if (config.basic.`switch`.enableCountdown) {
            startCountdown()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        countdownTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.countdownTimerProcess),
            userInfo: nil,
            repeats: true
        )
    }
    
    func startCountdown() {
        countdownTimer?.fireDate = Date()
    }
    
    @objc private func countdownTimerProcess() {
        guard let data = self.datas.first, data.isValidCountdown else {
            countdownText = nil
            return
        }
        let now = Int(Date().timeIntervalSince1970)
        let distance = (data.interval ?? 0) - (now - data.count)
        var d: Int = -1
        var h: Int = -1
        var m: Int = -1
        var s: Int = -1
        if distance < 3600 {
            m = distance / 60
            s = distance % 60
        } else if distance < 3600 * 24 {
            h = distance / 3600
            m = (distance % 3600) / 60
            s = (distance % 3600) % 60
        } else {
            d = distance / (3600 * 24)
            h = (distance % (3600 * 24)) / 3600
        }
        if d != -1 {
            countdownText = "\(d)D:\(h)H"
        } else if h != -1 {
            countdownText = "\(h < 10 ? "0\(h)" : "\(h)"):\(m < 10 ? "0\(m)" : "\(m)"):\(s < 10 ? "0\(s)" : "\(s)")"
        } else {
            countdownText = "\(m < 10 ? "0\(m)" : "\(m)"):\(s < 10 ? "0\(s)" : "\(s)")"
        }
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        displayHeight = rect.height - config.basic.value.topPadding - config.basic.value.bottomDateHigh
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        divisionRect()
        calculateValue()
        calculateFormats()
        initRenderer()
        drawBgColor(context: context, rect: rect)
        drawGrid(context: context)
        drawLogo(in: rect)
        guard !datas.isEmpty else {
            return
        }
        
        drawChart(context: context)
        drawRightText(context: context)
        drawDate(context: context)
        drawMaxAndMin(context: context)
        if isLongPress {
            drawLongPressCrossLine(context: context)
        } else {
            drawTopText(context: context, curPoint: datas.first!)
        }
        drawCurrentPrice(context: context)
        UIGraphicsPopContext()
    }

    func calculateValue() {
        if datas.count == 0 { return }
        let itemWidth = candleWidth + config.basic.value.canldeMargin
        if scrollX <= 0 {
            startX = -scrollX
            startIndex = 0
        } else {
            let start: CGFloat = scrollX / itemWidth
            var offsetX: CGFloat = 0
            if floor(start) == ceil(start) {
                startIndex = Int(floor(start))
            } else {
                startIndex = Int(floor(scrollX / itemWidth))
                offsetX = CGFloat(startIndex) * CGFloat(itemWidth) - scrollX
            }
            startX = offsetX
        }
        
        let diffIndex = Int(ceil((frame.width - startX) / itemWidth))
        stopIndex = min(startIndex + diffIndex, datas.count - 1)
        mMainMaxValue = 0
        mMainMinValue = CGFloat(MAXFLOAT)
        mMainHighMaxValue = -CGFloat(MAXFLOAT)
        mMainLowMinValue = CGFloat(MAXFLOAT)
        mVolMaxValue = -CGFloat(MAXFLOAT)
        mVolMinValue = CGFloat(MAXFLOAT)
        mSecondaryMaxValue = -CGFloat(MAXFLOAT)
        mSecondaryMinValue = CGFloat(MAXFLOAT)
        
        guard startIndex <= stopIndex else {
            return
        }
        for i in startIndex ... stopIndex {
            let item = datas[i]
            getMianMaxMinValue(item: item, i: i)
            getVolMaxMinValue(item: item)
            getSecondaryMaxMinValue(item: item)
        }
    }

    /// 核心绘制入口
    func drawChart(context: CGContext) {
        guard startIndex <= stopIndex, startIndex < datas.count, stopIndex < datas.count else {
            return
        }
        for index in startIndex ... stopIndex {
            drawChart(context: context, index: index)
        }
    }
    
    func drawChart(context: CGContext, index: Int) {
        let curpoint = datas[index]
        let itemWidth = candleWidth + config.basic.value.canldeMargin
        let curX = CGFloat(index - startIndex) * itemWidth + startX
        let _curX = frame.width - curX - candleWidth / 2
        var lastPoint: BKLineChartModel?
        if index != startIndex {
            lastPoint = datas[index - 1]
        }
        mainRenderer.drawChart(context: context, lastPoint: lastPoint, curPoint: curpoint, curX: _curX)
        volRenderer?.drawChart(context: context, lastPoint: lastPoint, curPoint: curpoint, curX: _curX)
        seconderyRender?.drawChart(context: context, lastPoint: lastPoint, curPoint: curpoint, curX: _curX)
    }

    func drawRightText(context: CGContext) {
        mainRenderer.drawRightText(context: context, gridRows: config.basic.value.gridRows, gridColums: config.basic.value.gridColumns)
        volRenderer?.drawRightText(context: context, gridRows: config.basic.value.gridRows, gridColums: config.basic.value.gridColumns)
        seconderyRender?.drawRightText(context: context, gridRows: config.basic.value.gridRows, gridColums: config.basic.value.gridColumns)
    }

    func drawTopText(context: CGContext, curPoint: BKLineChartModel) {
        mainRenderer.drawTopText(context: context, curPoint: curPoint)
        volRenderer?.drawTopText(context: context, curPoint: curPoint)
        seconderyRender?.drawTopText(context: context, curPoint: curPoint)
    }

    func drawBgColor(context: CGContext, rect: CGRect) {
        context.setFillColor(config.basic.color.bgColor.cgColor)
        context.fill(rect)
        /** 分区渐变色绘制
        mainRenderer.drawBg(context: context)
        volRenderer?.drawBg(context: context)
        seconderyRender?.drawBg(context: context)*/
    }
    
    func drawLogo(in rect: CGRect) {
        guard let logoImage = config.basic.value.logoImage else {return}
        let height: CGFloat = 30.0
        let width = logoImage.size.width / (logoImage.size.height / height)
        
        let logoX = (rect.width - width) / 2
        let logoY = (mainHeight - height) / 2 + config.basic.value.topPadding
        logoImage.draw(in: CGRect(x: logoX, y: logoY, width: width, height: height))
    }

    func drawGrid(context: CGContext) {
        context.setStrokeColor(config.basic.color.gridColor.cgColor)
        context.setLineWidth(0.5)
        context.addRect(bounds)
        context.drawPath(using: CGPathDrawingMode.stroke)
        mainRenderer.drawGrid(context: context, gridRows: config.basic.value.gridRows, gridColums: config.basic.value.gridColumns)
        volRenderer?.drawGrid(context: context, gridRows: config.basic.value.gridRows, gridColums: config.basic.value.gridColumns)
        seconderyRender?.drawGrid(context: context, gridRows: config.basic.value.gridRows, gridColums: config.basic.value.gridColumns)
    }

    func drawDate(context _: CGContext) {
        let columSpace = frame.width / CGFloat(config.basic.value.gridColumns)
        for i in 0 ..< config.basic.value.gridColumns {
            let index = calculateIndex(selectX: CGFloat(i) * columSpace)
            if outRangeIndex(index) { continue }
            let data = datas[index]

            let dateStr = calculateDateText(timestamp: data.id, dateFormat: dateFromat) as NSString
            let rect = calculateTextRect(text: dateStr as String, font: config.basic.font.bottomDateFont)
            let y = dateRect.minY + (config.basic.value.bottomDateHigh - rect.height) / 2
            dateStr.draw(at: CGPoint(x: CGFloat(columSpace * CGFloat(i)) - rect.width / 2, y: y), withAttributes: [NSAttributedString.Key.font: config.basic.font.bottomDateFont, NSAttributedString.Key.foregroundColor: config.basic.color.bottomDateTextColor])
        }
    }

    func drawLongPressCrossLine(context: CGContext) {
        let index = calculateIndex(selectX: longPressX)
        if outRangeIndex(index) { return }
        let point = datas[index]
        let itemWidth = candleWidth + config.basic.value.canldeMargin
        let curX = frame.width - (CGFloat(index - startIndex) * itemWidth + startX + candleWidth / 2)

        context.setStrokeColor(config.basic.color.crossHlineColor.cgColor)
        context.setLineWidth(config.basic.value.aimWidth)
        context.move(to: CGPoint(x: curX, y: 0))
        context.addLine(to: CGPoint(x: curX, y: frame.height - config.basic.value.bottomDateHigh))
        context.drawPath(using: CGPathDrawingMode.fillStroke)

        let y = longPressY

        context.setStrokeColor(config.basic.color.crossHlineColor.cgColor)
        context.setLineWidth(config.basic.value.aimWidth)
        context.move(to: CGPoint(x: 0, y: y))
        context.addLine(to: CGPoint(x: frame.width, y: y))
        context.drawPath(using: CGPathDrawingMode.fillStroke)

        context.setFillColor(config.basic.color.crossHlineColor.cgColor)
        context.addArc(center: CGPoint(x: curX, y: y), radius: 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        drawLongPressCrossLineText(context: context, curPoint: point, curX: curX, y: y)
    }

    func drawLongPressCrossLineText(context: CGContext, curPoint: BKLineChartModel, curX: CGFloat, y: CGFloat) {
        let positionInMainRender = mainRect.height - (longPressY - config.basic.value.topPadding)
        let selectedYValue = mainRenderer.getYValue(positionInMainRender)
        let priceText = selectedYValue.format(maxF: config.basic.value.decimalLenPrice)
        let priceRect = calculateTextRect(text: priceText, font: config.basic.font.defaultTextFont)
        let pricePadding: CGFloat = 1.5
        let textHeight = priceRect.height + pricePadding * 2
        let textWidth = priceRect.width
        var isLeft = false
        
        /// 绘制选中价格
        if curX > frame.width / 2 {
            isLeft = true
            context.move(to: CGPoint(x: frame.width, y: y - textHeight / 2))
            context.addLine(to: CGPoint(x: frame.width, y: y + textHeight / 2))
            context.addLine(to: CGPoint(x: frame.width - textWidth, y: y + textHeight / 2))
            context.addLine(to: CGPoint(x: frame.width - textWidth - 10, y: y))
            context.addLine(to: CGPoint(x: frame.width - textWidth, y: y - textHeight / 2))
            context.addLine(to: CGPoint(x: frame.width, y: y - textHeight / 2))
            context.setLineWidth(1)
            context.setStrokeColor(config.basic.color.markerBorderColor.cgColor)
            context.setFillColor(config.basic.color.markerBgColor.cgColor)
            context.drawPath(using: CGPathDrawingMode.fillStroke)
            (priceText as NSString).draw(at: CGPoint(x: frame.width - textWidth - 2, y: y - priceRect.height / 2), withAttributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.markerTextColor])
        } else {
            isLeft = false
            context.move(to: CGPoint(x: 0, y: y - textHeight / 2))
            context.addLine(to: CGPoint(x: 0, y: y + textHeight / 2))
            context.addLine(to: CGPoint(x: textWidth, y: y + textHeight / 2))
            context.addLine(to: CGPoint(x: textWidth + 10, y: y))
            context.addLine(to: CGPoint(x: textWidth, y: y - textHeight / 2))
            context.addLine(to: CGPoint(x: 0, y: y - textHeight / 2))
            context.setLineWidth(1)
            context.setStrokeColor(config.basic.color.markerBorderColor.cgColor)
            context.setFillColor(config.basic.color.markerBgColor.cgColor)
            context.drawPath(using: CGPathDrawingMode.fillStroke)
            (priceText as NSString).draw(at: CGPoint(x: 2, y: y - priceRect.height / 2), withAttributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.markerTextColor])
        }
        
        /// 绘制选中时间
        let dateText = calculateDateText(timestamp: curPoint.id, dateFormat: dateFromat)
        let dateRect = calculateTextRect(text: dateText, font: config.basic.font.defaultTextFont)
        let datePadding: CGFloat = 1.5
        context.setStrokeColor(config.basic.color.markerBorderColor.cgColor)
        context.setFillColor(config.basic.color.markerBgColor.cgColor)
        context.addRect(CGRect(x: curX - dateRect.width / 2 - datePadding, y: self.dateRect.minY, width: dateRect.width + 2 * datePadding, height: dateRect.height + datePadding * 2))
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        (dateText as NSString).draw(at: CGPoint(x: curX - dateRect.width / 2, y: self.dateRect.minY + datePadding), withAttributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.markerTextColor])

        showInfoBlock?(curPoint, isLeft)
        drawTopText(context: context, curPoint: curPoint)
    }

    func drawMaxAndMin(context _: CGContext) {
        if isLine { return }
        let itemWidth = candleWidth + config.basic.value.canldeMargin
        let y1 = mainRenderer.getY(mMainHighMaxValue)
        let x1 = frame.width - (CGFloat(mMainMaxIndex - startIndex) * itemWidth + startX + candleWidth / 2)
        if x1 < frame.width / 2 {
            let text = "——" + mMainHighMaxValue.format(maxF: config.basic.value.decimalLenPrice).shortZeroString
            let rect = calculateTextRect(text: text, font: config.basic.font.defaultTextFont)
            (text as NSString).draw(at: CGPoint(x: x1, y: y1 - rect.height / 2), withAttributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.maxMinTextColor])
        } else {
            let text = mMainHighMaxValue.format(maxF: config.basic.value.decimalLenPrice).shortZeroString + "——"
            let rect = calculateTextRect(text: text, font: config.basic.font.defaultTextFont)
            (text as NSString).draw(at: CGPoint(x: x1 - rect.width, y: y1 - rect.height / 2), withAttributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.maxMinTextColor])
        }
        let y2 = mainRenderer.getY(mMainLowMinValue)
        let x2 = frame.width - (CGFloat(mMainMinIndex - startIndex) * itemWidth + startX + candleWidth / 2)
        if x2 < frame.width / 2 {
            let text = "——" + mMainLowMinValue.format(maxF: config.basic.value.decimalLenPrice).shortZeroString
            let rect = calculateTextRect(text: text, font: config.basic.font.defaultTextFont)
            (text as NSString).draw(at: CGPoint(x: x2, y: y2 - rect.height / 2), withAttributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.maxMinTextColor])
        } else {
            let text = mMainLowMinValue.format(maxF: config.basic.value.decimalLenPrice).shortZeroString + "——"
            let rect = calculateTextRect(text: text, font: config.basic.font.defaultTextFont)
            (text as NSString).draw(at: CGPoint(x: x2 - rect.width, y: y2 - rect.height / 2), withAttributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.maxMinTextColor])
        }
    }

    /// 绘制当前价内容
    func drawCurrentPrice(context: CGContext) {
        guard let point = datas.first else { return }
        let text = point.close.format(maxF: config.basic.value.decimalLenPrice).shortZeroString
        var priceRect = calculateTextRect(text: text, font: config.basic.font.defaultTextFont)
        let priceRealWidth = priceRect.width
        var countdownRect: CGRect = .zero
        var y = mainRenderer.getY(point.close)
        if point.close > mMainMaxValue {
            y = mainRenderer.getY(mMainMaxValue)
        } else if point.close < mMainMinValue {
            y = mainRenderer.getY(mMainMinValue)
        }
        
        /// 计算倒计时宽度
        if config.basic.`switch`.enableCountdown, let countdown = countdownText {
            countdownRect = calculateTextRect(text: countdown, font: config.basic.font.defaultTextFont)
            if countdownRect.width > priceRect.width {
                priceRect = CGRect(x: priceRect.minX, y: priceRect.minY, width: countdownRect.width, height: priceRect.height)
            }
        }
        
        if (-scrollX - priceRect.width) > 0 {
            /// 处于最新位置
            realTimeLocaltion = .latest
            context.setStrokeColor(config.basic.color.realTimeLongLineColor.cgColor)
            context.setLineWidth(0.5)
            context.setLineDash(phase: 0, lengths: [7, 3])
            context.move(to: CGPoint(x: frame.width + scrollX, y: y))
            context.addLine(to: CGPoint(x: frame.width, y: y))
            context.drawPath(using: CGPathDrawingMode.stroke)

            context.addRect(CGRect(x: frame.width - priceRect.width, y: y - priceRect.height / 2, width: priceRect.width, height: priceRect.height))
            context.setFillColor(config.basic.color.realTimeBgColor.cgColor)
            context.drawPath(using: CGPathDrawingMode.fill)
            (text as NSString).draw(at: CGPoint(x: frame.width - priceRealWidth, y: y - priceRect.height / 2), withAttributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.realTimeTextColor])
            
            /// 绘制倒计时
            if config.basic.`switch`.enableCountdown, !isLine, let countdown = countdownText {
                context.addRect(CGRect(x: frame.width - priceRect.width, y: y + priceRect.height / 2, width: priceRect.width, height: priceRect.height))
                context.setFillColor(config.basic.color.realTimeCountdownBgColor.cgColor)
                context.drawPath(using: CGPathDrawingMode.fill)
                (countdown as NSString).draw(at: CGPoint(x: frame.width - countdownRect.width, y: y + priceRect.height / 2), withAttributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.realTimeTextColor])
            }
            
            /// 绘制分时图圆点
            if isLine {
                context.setFillColor(config.basic.color.timeLineColor.cgColor)
                context.addArc(center: CGPoint(x: frame.width + scrollX - candleWidth / 2, y: y), radius: 2, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
                context.drawPath(using: CGPathDrawingMode.fill)

                context.setFillColor(config.basic.color.timeLineColor.withAlphaComponent(0.3).cgColor)
                context.addArc(center: CGPoint(x: frame.width + scrollX - candleWidth / 2, y: y), radius: 6, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
                context.drawPath(using: CGPathDrawingMode.fill)
            }
            
            /// 绘制盘口价格
            drawAskBidPrice(
                context,
                top: y - priceRect.height / 2,
                right: frame.width - (priceRect.width + 2.0),
                height: priceRect.height
            )
        } else {
            /// 处于历史记录位置
            realTimeLocaltion = .history
            context.setStrokeColor(config.basic.color.realTimeLongLineColor.cgColor)
            context.setLineWidth(0.5)
            context.setLineDash(phase: 0, lengths: [7, 3])
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: frame.width, y: y))
            context.drawPath(using: CGPathDrawingMode.stroke)

            let r: CGFloat = 8
            let w: CGFloat = priceRect.width + 16
            context.setLineWidth(0.8)
            context.setLineDash(phase: 0, lengths: [])
            context.setFillColor(config.basic.color.realTimeBgColor.cgColor)
            context.move(to: CGPoint(x: frame.width * 0.8, y: y - r))
            let curX = frame.width * 0.8
            let fillRect = CGRect(x: curX - w / 2, y: y - r, width: w, height: 2 * r)
            context.addRect(fillRect)
            context.setStrokeColor(config.basic.color.realTimeTextBorderColor.cgColor)
            context.drawPath(using: CGPathDrawingMode.fillStroke)

            /// 绘制三角箭头
            let _startX = fillRect.maxX - 4
            context.setFillColor(config.basic.color.realTimeTextColor.cgColor)
            context.move(to: CGPoint(x: _startX, y: y))
            context.addLine(to: CGPoint(x: _startX - 3, y: y - 3))
            context.addLine(to: CGPoint(x: _startX - 3, y: y + 3))
            context.closePath()
            context.drawPath(using: CGPathDrawingMode.fill)
            (text as NSString).draw(at: CGPoint(x: curX - priceRect.width / 2 - 4, y: y - priceRect.height / 2), withAttributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: config.basic.color.realTimeTextColor])
            realTimeRect = fillRect
        }
    }
    
    /// 绘制盘口价格
    private func drawAskBidPrice(_ context: CGContext, top: CGFloat, right: CGFloat, height: CGFloat) {
        guard config.basic.`switch`.enableAskBidPrice else {
            return
        }
        let priceAsk = askBidPrice?.ask.shortZeroString
        let textAsk = "\(config.basic.text.ask) \(priceAsk ?? "")"
        let priceAskRect = calculateTextRect(text: textAsk, font: config.basic.font.defaultTextFont)
        let priceAskBgOrigRect = CGRect(x: right - (priceAskRect.width + 2.0), y: top, width: priceAskRect.width + 4.0, height: height)
        
        let priceBid = askBidPrice?.bid.shortZeroString
        let textBid = "\(config.basic.text.bid) \(priceBid ?? "")"
        let priceBidRect = calculateTextRect(text: textBid, font: config.basic.font.defaultTextFont)
        let priceBidBgOrigRect = CGRect(x: right - (priceBidRect.width + 2.0), y: priceAskBgOrigRect.maxY, width: priceBidRect.width + 4.0, height: height)
        
        /// 计算最大背景宽度
        let maxBgWidth = max(priceAskRect.width + 4.0, priceBidRect.width + 4.0)
        let minX = right - (maxBgWidth + 2.0)
        let priceAskBgRect = CGRect(x: minX, y: priceAskBgOrigRect.minY, width: maxBgWidth, height: priceAskBgOrigRect.height)
        let priceBidBgRect = CGRect(x: minX, y: priceBidBgOrigRect.minY, width: maxBgWidth, height: priceBidBgOrigRect.height)
        
        /// 卖
        context.addRect(priceAskBgRect)
        context.setFillColor(config.basic.color.downColor.cgColor)
        context.drawPath(using: CGPathDrawingMode.fill)
        (textAsk as NSString).draw(at: CGPoint(x: priceAskBgRect.minX + 2.0, y: top), withAttributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: UIColor.white])
        
        /// 买
        context.addRect(priceBidBgRect)
        context.setFillColor(config.basic.color.upColor.cgColor)
        context.drawPath(using: CGPathDrawingMode.fill)
        (textBid as NSString).draw(at: CGPoint(x: priceBidBgRect.minX + 2.0, y: priceAskBgRect.maxY), withAttributes: [NSAttributedString.Key.font: config.basic.font.defaultTextFont, NSAttributedString.Key.foregroundColor: UIColor.white])
    }

    func initRenderer() {
        mainRenderer = MainChartRenderer(
            config: config,
            maxValue: mMainMaxValue,
            minValue: mMainMinValue,
            chartRect: mainRect,
            candleWidth: candleWidth,
            topPadding: config.basic.value.topPadding,
            isLine: isLine,
            state: mainSectionIndex
        )
        if let rect = volRect {
            volRenderer = VolChartRenderer(
                config: config,
                maxValue: mVolMaxValue,
                minValue: mVolMinValue,
                chartRect: rect,
                candleWidth: candleWidth,
                topPadding: config.basic.value.childPadding
            )
        } else {
            volRenderer = nil
        }
        if let rect = secondaryRect {
            seconderyRender = SecondaryChartRenderer(
                config: config,
                maxValue: mSecondaryMaxValue,
                minValue: mSecondaryMinValue,
                chartRect: rect,
                candleWidth: candleWidth,
                topPadding: config.basic.value.childPadding,
                state: secondarySectionIndex
            )
        } else {
            seconderyRender = nil
        }
    }

    /// 区分三大区域
    func divisionRect() {
        volRect = nil
        secondaryRect = nil
        calculateAreaHeight()
        
        /// 主图位置
        mainRect = CGRect(x: 0, y: config.basic.value.topPadding, width: frame.width, height: mainHeight)
        
        /// 量/附图指标位置
        if direction == .horizontal {
            dateRect = CGRect(x: 0, y: mainRect.maxY, width: frame.width, height: config.basic.value.bottomDateHigh)
            if volSectionIndex != .none {
                volRect = CGRect(x: 0, y: dateRect.maxY, width: frame.width, height: volHeight)
            }
            if secondarySectionIndex != .none {
                let startY = volSectionIndex == .none ? mainRect.maxY : (volRect?.maxY ?? 0)
                secondaryRect = CGRect(x: 0, y: startY, width: frame.width, height: secondaryHeight)
            }
        } else {
            if volSectionIndex != .none {
                volRect = CGRect(x: 0, y: mainRect.maxY, width: frame.width, height: volHeight)
            }
            if secondarySectionIndex != .none {
                let startY = volSectionIndex == .none ? mainRect.maxY : (volRect?.maxY ?? 0)
                secondaryRect = CGRect(x: 0, y: startY, width: frame.width, height: secondaryHeight)
            }
            dateRect = CGRect(x: 0, y: displayHeight + config.basic.value.topPadding, width: frame.width, height: config.basic.value.bottomDateHigh)
        }
    }
    
    /// 各区域尺寸计算
    func calculateAreaHeight() {
        switch config.basic.value.areaSizeMode {
        case .ratio:
            _volHeight = displayHeight * config.basic.value.areaSizeRatioVolume
            _secondaryHeight = displayHeight * config.basic.value.areaSizeRatioSecondary
            if volSectionIndex == .none && secondarySectionIndex == .none {
                _mainHeight = displayHeight
            } else if volSectionIndex == .none {
                _mainHeight = displayHeight * (1 - config.basic.value.areaSizeRatioVolume)
            } else if secondarySectionIndex == .none {
                _mainHeight = displayHeight * (1 - config.basic.value.areaSizeRatioSecondary)
            } else {
                _mainHeight = displayHeight * (1 - config.basic.value.areaSizeRatioVolume - config.basic.value.areaSizeRatioSecondary)
            }
        case .value:
            _volHeight = volSectionIndex == .none ? 0 : config.basic.value.areaSizeValueVolume
            _secondaryHeight = secondarySectionIndex == .none ? 0 : config.basic.value.areaSizeValueSecondary
            _mainHeight = displayHeight - _volHeight - _secondaryHeight
        }
    }

    func getMianMaxMinValue(item: BKLineChartModel, i: Int) {
        if isLine == true {
            mMainMaxValue = max(mMainMaxValue, item.close)
            mMainMinValue = min(mMainMinValue, item.close)
        } else {
            var maxPrice = item.high
            var minPrice = item.low
            if mainSectionIndex == BKMainSectionIndex.ma {
                if item.MA5Price != 0 {
                    maxPrice = max(maxPrice, item.MA5Price)
                    minPrice = min(minPrice, item.MA5Price)
                }
                if item.MA10Price != 0 {
                    maxPrice = max(maxPrice, item.MA10Price)
                    minPrice = min(minPrice, item.MA10Price)
                }
                if item.MA20Price != 0 {
                    maxPrice = max(maxPrice, item.MA20Price)
                    minPrice = min(minPrice, item.MA20Price)
                }
                if item.MA30Price != 0 {
                    maxPrice = max(maxPrice, item.MA30Price)
                    minPrice = min(minPrice, item.MA30Price)
                }
            } else if mainSectionIndex == BKMainSectionIndex.boll {
                if item.up != 0 {
                    maxPrice = max(item.up, item.high)
                }
                if item.dn != 0 {
                    minPrice = min(item.dn, item.low)
                }
            }
            mMainMaxValue = max(mMainMaxValue, maxPrice)
            mMainMinValue = min(mMainMinValue, minPrice)

            if mMainHighMaxValue < item.high {
                mMainHighMaxValue = item.high
                mMainMaxIndex = i
            }
            if mMainLowMinValue > item.low {
                mMainLowMinValue = item.low
                mMainMinIndex = i
            }
        }
    }

    func getVolMaxMinValue(item: BKLineChartModel) {
        mVolMaxValue = max(mVolMaxValue, max(item.vol, max(item.MA5Volume, item.MA10Volume)))
        mVolMinValue = min(mVolMinValue, min(item.vol, min(item.MA5Volume, item.MA10Volume)))
    }

    func getSecondaryMaxMinValue(item: BKLineChartModel) {
        if secondarySectionIndex == BKSecondarySectionIndex.macd {
            mSecondaryMaxValue = max(mSecondaryMaxValue, max(item.macd, max(item.dif, item.dea)))
            mSecondaryMinValue = min(mSecondaryMinValue, min(item.macd, min(item.dif, item.dea)))
        } else if secondarySectionIndex == BKSecondarySectionIndex.kdj {
            mSecondaryMaxValue = max(mSecondaryMaxValue, max(item.k, max(item.d, item.j)))
            mSecondaryMinValue = min(mSecondaryMinValue, min(item.k, min(item.d, item.j)))
        } else if secondarySectionIndex == BKSecondarySectionIndex.rsi {
            mSecondaryMaxValue = max(mSecondaryMaxValue, item.rsi)
            mSecondaryMinValue = min(mSecondaryMinValue, item.rsi)
        } else {
            mSecondaryMaxValue = max(mSecondaryMaxValue, item.r)
            mSecondaryMinValue = min(mSecondaryMinValue, item.r)
        }
    }

    func calculateFormats() {
        if datas.count < 2 { return }
        let fristTime = datas.first?.id ?? 0
        let secondTime = datas[1].id
        let time = abs(fristTime - secondTime)
        if time >= 24 * 60 * 60 * 28 {
            dateFromat = "yyyy-MM"
        } else if time >= 24 * 60 * 60 {
            dateFromat = "yyyy-MM-dd"
        } else {
            dateFromat = "MM-dd HH:mm"
        }
    }

    func calculateIndex(selectX: CGFloat) -> Int {
        let index = Int((frame.width - startX - selectX) / (candleWidth + config.basic.value.canldeMargin)) + startIndex
        return index
    }

    func outRangeIndex(_ index: Int) -> Bool {
        if index < 0 || index >= datas.count {
            return true
        } else {
            return false
        }
    }
}

extension BKLineChartPainterView {
    /// 重绘最新价
    func drawLatestPrice(price: CGFloat) {
        guard price >= 0, !datas.isEmpty, let first = datas.first else {return}
        datas.first?.close = price
        if price < first.low {
            datas.first?.low = price
        } else if price > first.high {
            datas.first?.high = price
        }
        setNeedsDisplay()
    }
}
