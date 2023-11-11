//
//  DTURLSessionMonitor.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 09.11.23.
//

import Foundation
import RSSwizzle

public class DTURLSessionMonitor {
    private var session: URLSession
    var taskDatas: [URLSessionTask: DTURLSessionTaskData] = [:]
    let queue = DispatchQueue(
        label: "URLSessionTrackerQueue",
        attributes: .concurrent
    )

    public init(session: URLSession = .shared) {
        self.session = session
        self.taskDatas = [:]
        // Setup swizzling if needed
    }
}

private extension DTURLSessionMonitor {

    func getTaskData(for sessionTask: URLSessionTask) -> DTURLSessionTaskData? {
        var taskData: DTURLSessionTaskData?
        queue.sync {
            taskData = self.taskDatas[sessionTask]
        }
        return taskData
    }

    func cleanup(for task: URLSessionTask) {
        queue.async(flags: .barrier) {
            self.taskDatas.removeValue(forKey: task)
        }
    }
}

extension DTURLSessionMonitor {
    
    func saveTaskDataToFile() {
        queue.async(flags: .barrier) {
            let fileURL = self.getFileURL()
            var dataToWrite = [String]()
            for (_, taskData) in self.taskDatas {
                let line = self.formatTaskDataForFile(taskData)
                dataToWrite.append(line)
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
