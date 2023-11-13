//
//  DTFileManager.swift
//
//
//  Created by Abin Baby on 13.11.23.
//

import Foundation

class DTFileManager {

    private let queue = DispatchQueue(
        label: "com.DTNetworkMonitor.FileLogger",
        attributes: .concurrent
    )

    private let fileManager = FileManager.default
    private var fileURL: URL

    init?() {
        do {
            let fileManager = FileManager.default
            let logsDirectory = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("DTNetworkMonitor", isDirectory: true)

            // Create the logs directory if it doesn't exist
            if !fileManager.fileExists(atPath: logsDirectory.path) {
                try fileManager.createDirectory(
                    at: logsDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }

            fileURL = logsDirectory.appendingPathComponent("DTNetworkLogs.csv")

            // Create the file if it doesn't exist
            if !fileManager.fileExists(atPath: fileURL.path) {
                fileManager.createFile(
                    atPath: fileURL.path,
                    contents: nil,
                    attributes: nil
                )
            }
        } catch {
            // Handle errors such as failing to create the directory or file
            DLog("Initialization of DTFileManager failed with error: \(error)")
            return nil
        }
    }

    func save(_ logEntry: String) {
        queue.async(flags: .barrier) {
            do {
                // Append to the end of the file
                if let fileHandle = try? FileHandle(forWritingTo: self.fileURL) {
                    defer {
                        fileHandle.closeFile()
                    }
                    fileHandle.seekToEndOfFile()
                    if let data = "\(logEntry)\n".data(using: .utf8) {
                        fileHandle.write(data)
                    }
                } else {
                    // If for some reason the file handle could not be created, write directly
                    try "\(logEntry)\n".write(
                        to: self.fileURL,
                        atomically: true,
                        encoding: .utf8
                    )
                }
            } catch {
                DLog("Failed to write log entry: \(error)")
            }
        }
    }
}
