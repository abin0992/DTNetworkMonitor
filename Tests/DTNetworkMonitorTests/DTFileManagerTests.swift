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
    var mockFileManager: MockFileManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockFileManager = MockFileManager()
        mockFileManager.fileExists = false // Simulate that the file already exists
        fileManager = try DTFileManager(fileManager: mockFileManager)
    }
    
    override func tearDownWithError() throws {
        fileManager = nil
        mockFileManager = nil
        try super.tearDownWithError()
    }
    
    func testSaveLogEntry() throws {
        let expectation = self.expectation(description: "SaveLogEntry")

        let logEntry = "Test Entry"
        let mockFileURL = URL(fileURLWithPath: "mock/path/DTNetworkLogs.csv")
        do {
            try mockFileManager.saveMock(logEntry: logEntry, to: mockFileURL)
            XCTAssertTrue(self.mockFileManager.didCreateFile, "The file should have been created.")
            XCTAssertNotNil(self.mockFileManager.mockFileHandle.writtenData, "Data should have been written to the file.")
            expectation.fulfill()
        } catch {
            XCTFail("Saving log entry should not fail. Error: \(error)")
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}
