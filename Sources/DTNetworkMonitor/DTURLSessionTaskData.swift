//
//  DTURLSessionTaskData.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 09.11.23.
//

import Foundation

@objcMembers
class DTURLSessionTaskData: NSObject {
    let initialURL: URL
    let startTime: Date
    var endTime: Date?
    var finalURL: URL?
    var wasSuccessful: Bool

    init(
        initialURL: URL,
        startTime: Date,
        endTime: Date? = nil,
        finalURL: URL? = nil,
        wasSuccessful: Bool = false
    ) {
        self.initialURL = initialURL
        self.startTime = startTime
        self.endTime = endTime
        self.finalURL = finalURL
        self.wasSuccessful = wasSuccessful
    }

    var duration: TimeInterval {
        guard let endTime = endTime else { return 0 }
        return endTime.timeIntervalSince(startTime) * 1000
    }
}

extension DTURLSessionTaskData {
    
    func formattedForLog() -> String {
        var logEntry = "Initial URL - \(initialURL.absoluteString), Duration - \(duration)"
        if let finalURL = finalURL {
            logEntry.append(", Redirected to - \(finalURL)")
        }
        let result = wasSuccessful ? "SUCCESS" : "FAILURE"
        logEntry.append(", Result - \(result)")
        return logEntry
    }
}
