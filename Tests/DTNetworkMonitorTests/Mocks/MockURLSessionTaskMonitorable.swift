//
//  MockURLSessionTaskMonitorable.swift
//
//
//  Created by Abin Baby on 14.11.23.
//

import Foundation
@testable import DTNetworkMonitor

class MockURLSessionTaskMonitorable: URLSessionTaskMonitorable {
    var startCalled = false
    var completionCalled = false

    func trackStart(of sessionTask: URLSessionTask) {
        startCalled = true
    }

    func trackCompletion(of sessionTask: URLSessionTask, finalURL: URL?, wasSuccessful: Bool) {
        completionCalled = true
    }
}
