//
//  BKLineChartView+Gesture.swift
//  BKLine
//
//  Created by tang on 15.11.22.
//

import UIKit

extension BKLineChartView {
    /// 拖动k线处理事件
    @objc func dragKlineEvent(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            isScrolling = true
            let point = gesture.location(in: painterView)
            dragbeginX = point.x
            isDrag = true
            debugPrint("dragKlineEvent began")
        case .changed:
            isScrolling = true
            let point = gesture.location(in: painterView)
            let dragX = point.x - dragbeginX
            scrollX = clamp(
                value: lastScrollX + dragX,
                min: minScroll,
                max: maxScroll
            )
            if scrollX == maxScroll {
                let key = "\(scrollX)"
                guard loadMoreKeys[key] == nil else {return}
                loadMoreKeys[key] = scrollX
                delegate?.loadMoreData(chart: self)
                debugPrint("loadMoreData at \(scrollX)")
            }
            debugPrint("scrollX = \(scrollX)")
        case .ended:
            isScrolling = false
            let speed = gesture.velocity(in: gesture.view)
            speedX = speed.x
            isDrag = false
            lastScrollX = scrollX
            if speed.x != 0 {
                displayLink = CADisplayLink(
                    target: self,
                    selector: #selector(refreshEvent)
                )
                displayLink?.add(
                    to: RunLoop.current,
                    forMode: RunLoop.Mode.common
                )
            }
            processHandleMoreDataIfNeeded()
            debugPrint("speed=\(speed)")
        default:
            isScrolling = false
            processHandleMoreDataIfNeeded()
            debugPrint("拖动k线出现\(gesture.state)事件")
        }
    }
    
    /// `更多`数据刷新处理
    private func processHandleMoreDataIfNeeded() {
        guard isHandleMoreData, !currentMoreDatas.isEmpty else {return}
        load(currentMoreDatas)
        currentMoreDatas.removeAll()
        isHandleMoreData = false
    }
    
    /// 点按手势处理
    @objc func tapEvent(gesture: UITapGestureRecognizer) {
        guard
            config.basic.`switch`.enableTap,
            painterView?.realTimeLocaltion == .history,
            painterView?.realTimeRect != .zero
        else {
            return
        }
        let point = gesture.location(in: painterView)
        let rect = painterView?.realTimeRect
        if rect?.contains(point) == true {
            reset()
            debugPrint("点击当前价区域: \(point) -> \(rect ?? .zero)")
        }
    }

    /// 长按手势处理
    @objc func longPressKlineEvent(gesture: UILongPressGestureRecognizer) {
        debugPrint("longPressKlineEvent")
        switch gesture.state {
        case .began:
            let point = gesture.location(in: painterView)
            longPressX = point.x
            longPressY = point.y
            isLongPress = true
        case .changed:
            let point = gesture.location(in: painterView)
            longPressX = point.x
            longPressY = point.y
            isLongPress = true
        case .ended:
            isLongPress = false
        default:
            debugPrint("长按k线出现\(gesture.state)事件")
        }
    }
    
    /// 缩放手势处理
    @objc func secalXEvent(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            isScale = true
            let point = gesture.location(in: self)
            scaleStartX = point.x
            guard let index = calculateIndex(selectX: scaleStartX) else { return }
            scaleIndex = index
        case .changed:
            isScale = true
            let newscaleX = clamp(value: lastscaleX * gesture.scale, min: 0.1, max: 5)
            if newscaleX == scaleX { return }
            processScaleX(newscaleX)
        case .ended, .cancelled:
            isScale = false
            lastscaleX = scaleX
            lastScrollX = scrollX
        default:
            debugPrint("长按k线出现\(gesture.state)事件")
        }
    }
    
    func calculateIndex(selectX _: CGFloat) -> Int? {
        return painterView?.calculateIndex(selectX: scaleStartX)
    }
    
    func processScaleX(_ scale: CGFloat) {
        scaleX = scale
        let rightWidth = frame.width - scaleStartX
        scrollXIndicators(trailing: rightWidth)
    }
    
    func scaleManually(to scale: CGFloat) {
        processScaleX(scale)
        lastscaleX = scaleX
        lastScrollX = scrollX
    }
    
    /// 拖动结束开始线性减速，需要改为动力学引擎
    @objc func refreshEvent(_: CADisplayLink) {
        let space: CGFloat = 100
        if speedX < 0 {
            speedX = min(speedX + space, 0)
            scrollX = clamp(
                value: scrollX - 5,
                min: minScroll,
                max: maxScroll
            )
            lastScrollX = scrollX
        } else if speedX > 0 {
            speedX = max(speedX - space, 0)
            scrollX = clamp(
                value: scrollX + 5,
                min: minScroll,
                max: maxScroll
            )
            lastScrollX = scrollX
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
}
