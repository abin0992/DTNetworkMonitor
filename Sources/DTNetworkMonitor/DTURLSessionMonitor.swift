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
        label: "com.DTNetworkMonitor.URLSessionTrackerQueue",
        attributes: .concurrent
    )
    let dtFileManager = DTFileManager()

    // Singleton instance
    public static let shared = DTURLSessionMonitor()

    // Private initializer to prevent external instantiation
    private override init() {
        super.init()
    }
    
    @objc
    public func startURLSessionMonitoring() {
        swizzleDataTaskWithRequest()
        swizzleDataTaskWithCompletionRequest()
        swizzleDownloadTaskWithRequest()
        swizzleUploadTaskWithRequest()
        swizzleDownloadTaskWithData()
        swizzleDownloadTaskWithCompletionHandler()
        swizzleUploadTaskWithData()
        swizzleUploadTaskWithDataAndCompletionHandler()
        swizzleUploadTaskWithFile()
        swizzleUploadTaskWithFileAndCompletionHandler()
    }
}


extension DTURLSessionMonitor {

    func formatTaskDataForFile(_ taskData: DTURLSessionTaskData) -> String {
        // Format the task data into a string suitable for file writing
        var logEntry = "Initial URL - \(taskData.initialURL.absoluteString), \(taskData.duration)"
        if let finalURL = taskData.finalURL {
            logEntry.append(", Redirected to - \(finalURL)")
        }
        let result =  taskData.wasSuccessful ? "SUCCESS" : "FAILURE"
        logEntry.append(", \(result)")
        return logEntry
    }
}
