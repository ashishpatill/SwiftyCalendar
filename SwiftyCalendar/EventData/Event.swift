//
//  Event.swift
//  SwiftyCalendar
//
//  Created by Ashish Pisey on 06/11/24.
//

import UIKit
import Foundation

struct Event {
    var name: String
    var startTime: Date
    var endTime: Date
    var color: UIColor
    var hasLivestream: Bool
    
    init(name: String, startTime: Date, endTime: Date, color: UIColor, hasLivestream: Bool = false) {
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.color = color
        self.hasLivestream = hasLivestream
    }
}


