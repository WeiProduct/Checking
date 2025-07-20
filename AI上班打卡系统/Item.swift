//
//  Item.swift
//  AI上班打卡系统
//
//  Created by weifu on 7/19/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
