//
//  MockFileHandle.swift
//
//
//  Created by Abin Baby on 14.11.23.
//

import Foundation

// Mock implementation of FileHandle
class MockFileHandle: FileHandle {
    var writtenData: Data?
    
    override func seekToEndOfFile() -> UInt64 {
        // Return a dummy file offset
        return 0
    }
    
    override func write(_ data: Data) {
        writtenData = data
    }
    
    override func closeFile() {
        // Do nothing
    }
}
