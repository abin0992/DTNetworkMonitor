//
//  File.swift
//  
//
//  Created by Abin Baby on 14.11.23.
//

import Foundation

class MockFileManager: FileManager {

    var fileExists = true
    var didCreateFile = false
    var didCreateDirectory = false
    var mockFileHandle = MockFileHandle()

    override func fileExists(atPath path: String) -> Bool {
        return fileExists
    }

    override func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey: Any]? = nil) -> Bool {
        print("createFile called with path: \(path)")
        didCreateFile = true
        return true
    }

    override func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]? = nil) throws {
        didCreateDirectory = true
    }

    func saveMock(logEntry: String, to url: URL) throws {
        if !fileExists {
            throw NSError(domain: "MockFileManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "File does not exist"])
        }
        mockFileHandle.write(logEntry.data(using: .utf8) ?? Data())
    }
}

