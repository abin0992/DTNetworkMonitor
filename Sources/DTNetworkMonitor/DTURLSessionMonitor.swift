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
  //  private var session: URLSession
    var taskDatas: NSMutableDictionary = [:]
  //  var taskDatas: [URLSessionTask: DTURLSessionTaskData] = [:]
    let queue = DispatchQueue(
        label: "URLSessionTrackerQueue",
        attributes: .concurrent
    )

    // Singleton instance
    public static let shared = DTURLSessionMonitor()

    // Private initializer to prevent external instantiation
    private override init() {
        self.taskDatas = [:]
        // Setup swizzling if needed
   //     swizzleAllURLSessionTaskMethods()
    }
//    @objc
//    public init(session: URLSession = .shared) {
//        self.session = session
//        self.taskDatas = [:]
//        // Setup swizzling if needed
//    }

    @objc
    public func startURLSessionMonitoring() {
        swizzleDownloadTaskWithData()
        swizzleDownloadTaskWithCompletionHandler()
        swizzleUploadTaskWithData()
        swizzleUploadTaskWithDataAndCompletionHandler()
        swizzleUploadTaskWithFile()
        swizzleUploadTaskWithFileAndCompletionHandler()
    }
}

private extension DTURLSessionMonitor {

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
