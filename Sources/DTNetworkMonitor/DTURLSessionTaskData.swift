//
//  DTURLSessionTaskData.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 09.11.23.
//

import Foundation

@objcMembers
public class DTURLSessionTaskData: NSObject {
    let initialURL: URL
    let startTime: Date
    var endTime: Date?
    var finalURL: URL?
    var wasSuccessful: Bool? // Using NSNumber for optional Bool

    init(
        initialURL: URL,
        startTime: Date,
        endTime: Date? = nil,
        finalURL: URL? = nil,
        wasSuccessful: Bool? = nil
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
