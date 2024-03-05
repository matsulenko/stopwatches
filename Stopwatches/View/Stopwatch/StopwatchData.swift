//
//  StopwatchData.swift
//  Stopwatches
//
//  Created by Matsulenko on 20.02.2024.
//

import Foundation
import SwiftUI

struct StopwatchData: Decodable, Hashable {
    let id: String
    var isRunning: Bool
    var name: String
    var startDate: Date?
    var accumulatedTime: Double
    let creationDate: Date
    var startAll: Bool?
    
    init(id: String, isRunning: Bool, name: String, startDate: Date? = nil, accumulatedTime: Double, creationDate: Date, startAll: Bool? = false) {
        self.id = id
        self.isRunning = isRunning
        self.name = name
        self.startDate = startDate
        self.accumulatedTime = accumulatedTime
        self.creationDate = creationDate
        self.startAll = startAll
    }
    
    public init(stopwatchesModel: StopwatchesModel) {
        id = stopwatchesModel.id ?? ""
        isRunning = stopwatchesModel.isRunning
        name = stopwatchesModel.name ?? ""
        startDate = stopwatchesModel.startDate
        accumulatedTime = stopwatchesModel.accumulatedTime
        creationDate = stopwatchesModel.creationDate ?? Date()
    }
}
