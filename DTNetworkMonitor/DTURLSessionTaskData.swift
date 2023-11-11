//
//  DTURLSessionTaskData.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 09.11.23.
//

import Foundation

public struct DTURLSessionTaskData {
    let initialURL: URL
    let startTime: Date
    var endTime: Date?
    var finalURL: URL?
    var wasSuccessful: Bool?

    var duration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return (endTime.timeIntervalSince(startTime) * 1000)
    }
}

