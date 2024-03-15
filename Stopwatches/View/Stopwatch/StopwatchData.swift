//
//  StopwatchData.swift
//  Stopwatches
//
//  Created by Matsulenko on 20.02.2024.
//

import Foundation
import SwiftUI

struct StopwatchData: Decodable, Hashable, Identifiable {
    let id: String
    var status: StopwatchStatus
    var name: String
    var startDate: Date?
    var accumulatedTime: Double
    let creationDate: Date
    var startAll: Bool?
    var num: Int
    
    init(id: String, status: StopwatchStatus, name: String, startDate: Date? = nil, accumulatedTime: Double, creationDate: Date, startAll: Bool? = false, num: Int) {
        self.id = id
        self.status = status
        self.name = name
        self.startDate = startDate
        self.accumulatedTime = accumulatedTime
        self.creationDate = creationDate
        self.startAll = startAll
        self.num = num
    }
    
    public init(stopwatchesModel: StopwatchesModel) {
        id = stopwatchesModel.id ?? ""
        status = StopwatchStatus(rawValue: stopwatchesModel.status ?? "New") ?? .new
        name = stopwatchesModel.name ?? ""
        startDate = stopwatchesModel.startDate
        accumulatedTime = stopwatchesModel.accumulatedTime
        creationDate = stopwatchesModel.creationDate ?? Date()
        num = Int(stopwatchesModel.num)
    }
}
