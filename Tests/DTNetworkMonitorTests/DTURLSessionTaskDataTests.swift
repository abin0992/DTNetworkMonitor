//
//  DTURLSessionTaskDataTests.swift
//
//
//  Created by Abin Baby on 14.11.23.
//

import XCTest
@testable import DTNetworkMonitor

class DTURLSessionTaskDataTests: XCTestCase {

    func testInitialization() {
        let initialURL = URL(string: "https://www.example.com")!
        let startTime = Date()
        let endTime = Date(timeIntervalSinceNow: 5) // 5 seconds later
        let finalURL = URL(string: "https://www.redirect.com")!
        let wasSuccessful = true

        let taskData = DTURLSessionTaskData(
            initialURL: initialURL,
            startTime: startTime,
            endTime: endTime,
            finalURL: finalURL,
            wasSuccessful: wasSuccessful
        )

        XCTAssertEqual(taskData.initialURL, initialURL)
        XCTAssertEqual(taskData.startTime, startTime)
        XCTAssertEqual(taskData.endTime, endTime)
        XCTAssertEqual(taskData.finalURL, finalURL)
        XCTAssertEqual(taskData.wasSuccessful, wasSuccessful)
    }

    func testDurationCalculation() {
        let initialURL = URL(string: "https://www.example.com")!
        let startTime = Date()
        let endTime = Date(timeIntervalSinceNow: 1) // 1 second later
        let taskData = DTURLSessionTaskData(
            initialURL: initialURL,
            startTime: startTime,
            endTime: endTime
        )

        // Sleep for 1 second to simulate time passing
        sleep(1)

        // The duration should be approximately 1000 milliseconds
        let duration = taskData.duration
        XCTAssertEqual(duration, 1000, accuracy: 100, "Duration should be close to 1000 milliseconds")
    }

    func testDurationWithoutEndTime() {
        let initialURL = URL(string: "https://www.example.com")!
        let startTime = Date()
        let taskData = DTURLSessionTaskData(
            initialURL: initialURL,
            startTime: startTime
        )

        // If endTime is nil, duration should be 0
        let duration = taskData.duration
        XCTAssertEqual(duration, 0, "Duration should be 0 when endTime is nil")
    }

    func testFormattedForLogSuccess() {
        let initialURL = URL(string: "https://www.example.com")!
        let startTime = Date()
        let endTime = Date(timeIntervalSinceNow: 1) // 1 second later
        let finalURL = URL(string: "https://www.redirect.com")!
        let wasSuccessful = true

        let taskData = DTURLSessionTaskData(
            initialURL: initialURL,
            startTime: startTime,
            endTime: endTime,
            finalURL: finalURL,
            wasSuccessful: wasSuccessful
        )

        let logEntry = taskData.formattedForLog()
        let expectedLogEntry = "Initial URL - \(initialURL.absoluteString), Duration - \(taskData.duration), Redirected to - \(finalURL), Result - SUCCESS"
        
        XCTAssertEqual(logEntry, expectedLogEntry, "Log entry is not formatted correctly")
    }

    func testFormattedForLogFailure() {
        let initialURL = URL(string: "https://www.example.com")!
        let startTime = Date()
        let endTime = Date(timeIntervalSinceNow: 1) // 1 second later
        let wasSuccessful = false

        let taskData = DTURLSessionTaskData(
            initialURL: initialURL,
            startTime: startTime,
            endTime: endTime,
            wasSuccessful: wasSuccessful
        )

        let logEntry = taskData.formattedForLog()
        let expectedLogEntry = "Initial URL - \(initialURL.absoluteString), Duration - \(taskData.duration), Result - FAILURE"
        
        XCTAssertEqual(logEntry, expectedLogEntry, "Log entry is not formatted correctly")
    }

    func testFormattedForLogWithoutFinalURL() {
        let initialURL = URL(string: "https://www.example.com")!
        let startTime = Date()
        let endTime = Date(timeIntervalSinceNow: 1) // 1 second later
        let wasSuccessful = true

        let taskData = DTURLSessionTaskData(
            initialURL: initialURL,
            startTime: startTime,
            endTime: endTime,
            wasSuccessful: wasSuccessful
        )

        let logEntry = taskData.formattedForLog()
        let expectedLogEntry = "Initial URL - \(initialURL.absoluteString), Duration - \(taskData.duration), Result - SUCCESS"
        
        XCTAssertEqual(logEntry, expectedLogEntry, "Log entry is not formatted correctly when there is no final URL")
    }
}
