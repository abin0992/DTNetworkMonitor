//
//  DTURLSessionMonitor.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 09.11.23.
//

import Foundation
import InterposeKit

@objcMembers
public class DTURLSessionMonitor: NSObject {
    var taskDatas: NSMutableDictionary = [:]
    let queue = DispatchQueue(
        label: "URLSessionTrackerQueue",
        attributes: .concurrent
    )

    // Singleton instance
    public static let shared = DTURLSessionMonitor()

    // Private initializer to prevent external instantiation
    private override init() {
        super.init()
        startURLSessionMonitoring()
    }
}

private extension DTURLSessionMonitor {

    @objc
    func startURLSessionMonitoring() {
        swizzleDataTaskWithRequest()
        swizzleDownloadTaskWithRequest()
        swizzleUploadTaskWithRequest()
        swizzleDownloadTaskWithData()
        swizzleDownloadTaskWithCompletionHandler()
        swizzleUploadTaskWithData()
        swizzleUploadTaskWithDataAndCompletionHandler()
        swizzleUploadTaskWithFile()
        swizzleUploadTaskWithFileAndCompletionHandler()
    }

    func getTaskData(for sessionTask: URLSessionTask) -> DTURLSessionTaskData? {
        var taskData: DTURLSessionTaskData?
        queue.sync {
       //     taskData = self.taskDatas[sessionTask]
        }
        return taskData
    }

    func cleanup(for task: URLSessionTask) {
        queue.async(flags: .barrier) {
     //       self.taskDatas.removeValue(forKey: task)
        }
    }
}

extension DTURLSessionMonitor {
    
    func saveTaskDataToFile() {
        queue.async(flags: .barrier) {
            let fileURL = self.getFileURL()
            var dataToWrite = [String]()
            for (_, taskData) in self.taskDatas {
        //        let line = self.formatTaskDataForFile(taskData)
         //       dataToWrite.append(line)
            }
            do {
                try dataToWrite.joined(separator: "\n").write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                // Handle file write error
            }
        }
    }

    private func getFileURL() -> URL {
        // Returns the file URL where data will be stored
        return URL(string: "")!
    }

    private func formatTaskDataForFile(_ taskData: DTURLSessionTaskData) -> String {
        // Format the task data into a string suitable for file writing
        return ""
    }
}

// Logging and tracking methods
extension DTURLSessionMonitor {
    func trackURL(of sessionTask: URLSessionTask, request: URLRequest) {
        // Log the URL or perform any other tracking/logging operations here
        if let url = request.url {
            print("API call: \(url.absoluteString)")
        }
    }
}
