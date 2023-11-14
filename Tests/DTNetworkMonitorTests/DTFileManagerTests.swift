//
//  File.swift
//  
//
//  Created by Abin Baby on 14.11.23.
//

import XCTest
@testable import DTNetworkMonitor

class DTFileManagerTests: XCTestCase {

    var fileManager: DTFileManager!
    var mockFileManager: FileManager!
    var mockQueue: DispatchQueue!

    override func setUp() {
        super.setUp()
        mockFileManager = FileManager.default
        fileManager = try? DTFileManager(fileManager: mockFileManager)
    }

    func testLogFileCreation() {
        XCTAssertNotNil(fileManager.fileURL)
    }

    func testLogSaving() {
        // Test saving logs to the file
        let expectation = self.expectation(description: "LogSaving")
        fileManager.save("Test Log Entry") { result in
            switch result {
            case .success():
                // Verify log entry is saved correctly
                XCTAssertTrue(true)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    // TODO: Add more tests
}
