//
//  StopwatchStatus.swift
//  Stopwatches
//
//  Created by Matsulenko on 11.03.2024.
//

import Foundation

enum StopwatchStatus: String, Decodable {
    case new = "New"
    case zero = "Zero"
    case active = "Active"
    case paused = "Paused"
    case deleted = "Deleted"
}
