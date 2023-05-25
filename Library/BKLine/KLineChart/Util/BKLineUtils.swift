//
//  BKLineUtils.swift
//  BKLine
//
//  Created by tang on 15.11.22.
//

import Foundation
import SwifterSwift

//MARK: - 临时Util代码
//todo: BKUtil组件部署后，所有依赖此Util工具的引用改为依赖外部BKUtil组件的相同实现

extension String {
    /// 多个0的字符串简化处理（小数点后0个数大于等于5个适用）
    var shortZeroString: String {
        let ps = prefix(1)
        let hasPrefixSymbol = false
        guard count >= (hasPrefixSymbol ? 9 : 8) else {
            return self
        }
        
        let pref = hasPrefixSymbol ? String(prefix(4).suffix(3)) : String(prefix(3))
        guard pref == "0.0" else {
            return self
        }
        let tail = removingPrefix(hasPrefixSymbol ? "\(ps)\(pref)" : pref)
        guard tail.contains("0000") else {
            return self
        }
        
        var lastZeroIndex: Int = -1
        for (i, c) in tail.enumerated() {
            if c != "0" {
                break
            }
            lastZeroIndex = i
        }
        guard lastZeroIndex > -1 else {
            return self
        }
        
        let suffStartIndex = tail.index(tail.startIndex, offsetBy: lastZeroIndex + 1)
        let suff = String(tail[suffStartIndex..<tail.endIndex])
        let zeroCount: Int = self.distance(from: tail.startIndex, to: suffStartIndex) + (hasPrefixSymbol ? 1 : 0)
        if hasPrefixSymbol {
            return "\(ps)\(pref){\(zeroCount)}\(suff)"
        }
        return "\(pref){\(zeroCount)}\(suff)"
    }
}

extension CGFloat {
    
    /**
     转化为字符串格式
     - parameter minF:
     - parameter maxF:
     - parameter minI:
     
     - returns:
     */
    func format(_ minF: Int = 2, maxF: Int = 8, minI: Int = 1,roundingMode:NumberFormatter.RoundingMode = .floor) -> String {
        let value: CGFloat = String(format: "%.\(maxF+1)f", self).cgFloat() ?? self
        return Double(value).format(minF, maxF: maxF, minI: minI,roundingMode: roundingMode)
    }
}

extension Double {
    
    /**
     转化为字符串格式
     - parameter minF:
     - parameter maxF:
     - parameter minI:
     
     - returns:
     */
    func format(_ minF: Int = 0, maxF: Int = 8, minI: Int = 1,roundingMode:NumberFormatter.RoundingMode = .floor) -> String {
        let value: Double = String(format: "%.\(maxF+1)f", self).double() ?? self
        let twoDecimalPlacesFormatter = NumberFormatter()
        twoDecimalPlacesFormatter.roundingMode = roundingMode
        twoDecimalPlacesFormatter.maximumFractionDigits = maxF
        twoDecimalPlacesFormatter.minimumFractionDigits = minF
        twoDecimalPlacesFormatter.minimumIntegerDigits = minI
        twoDecimalPlacesFormatter.locale = Locale(identifier: "en_US")
        if let value = twoDecimalPlacesFormatter.string(from: value.decimalWrapper) {
            return value
        }
        return  "-"
    }
    
    func formatKM(_ minF: Int = 2, maxF: Int = 8, minI: Int = 1,roundingMode:NumberFormatter.RoundingMode = .floor) -> String {
        return self > 1000000000 ? (self/1000000000).format(minF, maxF: 2, minI: minI,roundingMode: roundingMode) + "Bn"
            : self > 1000000 ? (self/1000000).format(minF, maxF: 2, minI: minI,roundingMode: roundingMode) + "M"
            : self > 1000 ? (self/1000).format(minF, maxF: 2, minI: minI,roundingMode: roundingMode) + "K"
            : self.format(minF, maxF: maxF, minI: minI,roundingMode: roundingMode)
    }
    
    /// 最多精确到15位
    var decimalWrapper:NSDecimalNumber {
        return NSDecimalNumber(string: String(self))
    }
    
    /// 最多精确到15位
    var decimal:Decimal {
        return Decimal(self)
    }
}

extension Date {
    
    /*!
     * @method 把时间戳转换为用户格式时间
     * @abstract
     * @discussion
     * @param   timestamp     时间戳
     * @param   format        格式
     * @result                时间
     */
    static func formated(_ timestamp: Int, format: String) -> String {
        if (timestamp == 0) {
            return ""
        }
        var time = ""
        let confromTimesp = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = format
        time = formatter.string(from: confromTimesp)
        return time;
    }
}


/// Method to get Unix-style time (Java variant), i.e., time since 1970 in milliseconds. This
/// copied from here: http://stackoverflow.com/a/24655601/253938 and here:
/// http://stackoverflow.com/a/7885923/253938
/// (This should give good performance according to this:
///  http://stackoverflow.com/a/12020300/253938 )
///
/// Note that it is possible that multiple calls to this method and computing the difference may
/// occasionally give problematic results, like an apparently negative interval or a major jump
/// forward in time. This is because system time occasionally gets updated due to synchronization
/// with a time source on the network (maybe "leap second"), or user setting the clock.
@inline(__always) public func currentTimeMillis() -> Int64 {
  var darwinTime : timeval = timeval(tv_sec: 0, tv_usec: 0)
  gettimeofday(&darwinTime, nil)
  return (Int64(darwinTime.tv_sec) * 1000) + Int64(darwinTime.tv_usec / 1000)
}
