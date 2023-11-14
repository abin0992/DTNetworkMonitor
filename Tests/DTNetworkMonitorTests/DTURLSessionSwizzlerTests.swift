//
//  DTURLSessionSwizzlerTests.swift
//
//
//  Created by Abin Baby on 14.11.23.
//

import XCTest
@testable import DTNetworkMonitor

class DTURLSessionSwizzlerTests: XCTestCase {

    var swizzler: DTURLSessionSwizzler!
    var mockMonitor: MockURLSessionTaskMonitorable!

    override func setUp() {
        super.setUp()
        mockMonitor = MockURLSessionTaskMonitorable()
        swizzler = DTURLSessionSwizzler(monitor: mockMonitor)
    }

    func testStartURLSessionMonitoring() {
        // Test if startURLSessionMonitoring correctly swizzles all methods
        swizzler.startURLSessionMonitoring()
        // Create a URLSession and perform a data task to trigger the swizzled method
        let expectation = self.expectation(description: "DataTask")
        let url2 = URL(string: "https://yahoo.com")!
        let session2 = URLSession.shared.dataTask(with: URLRequest(url: url2)) { _, _, _ in expectation.fulfill()
        }
        session2.resume()
        

        waitForExpectations(timeout: 5, handler: nil)

        // Verify that the mock monitor's methods were called
        XCTAssertTrue(mockMonitor.startCalled, "start method on monitor was not called")
    }

    // TODO: Add more tests for swizzling other URLSession methods
}


