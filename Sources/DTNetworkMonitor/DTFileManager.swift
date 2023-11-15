//
//  DTFileManager.swift
//
//
//  Created by Abin Baby on 13.11.23.
//

import Foundation

protocol Loggable: NSObject {
    func save(
        _ logEntry: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

@objcMembers
class DTFileManager: NSObject, Loggable {
    private let queue = DispatchQueue(label: "com.DTNetworkMonitor.FileLogger", attributes: .concurrent)
    private let fileManager: FileManager
    let fileURL: URL

    init(fileManager: FileManager = .default) throws {
        self.fileManager = fileManager

        let logsDirectory = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("DTNetworkMonitor", isDirectory: true)

        if !fileManager.fileExists(atPath: logsDirectory.path) {
            try fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        fileURL = logsDirectory.appendingPathComponent("DTNetworkLogs.csv")

        if !fileManager.fileExists(atPath: fileURL.path) {
            fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
    }

    func save(
        _ logEntry: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        queue.async(flags: .barrier) {
            do {
                let fileHandle = try FileHandle(forWritingTo: self.fileURL)
                defer { fileHandle.closeFile() }
                fileHandle.seekToEndOfFile()
                if let data = "\(logEntry)\n".data(using: .utf8) {
                    fileHandle.write(data)
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
