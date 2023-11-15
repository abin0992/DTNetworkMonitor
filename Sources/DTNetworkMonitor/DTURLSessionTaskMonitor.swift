//
//  DTURLSessionTaskMonitor.swift
//
//
//  Created by Abin Baby on 14.11.23.
//

import Foundation

protocol URLSessionTaskMonitorable: NSObject {
    func trackStart(of sessionTask: URLSessionTask)
    func trackCompletion(of sessionTask: URLSessionTask, finalURL: URL?, wasSuccessful: Bool)
}

@objcMembers
class DTURLSessionTaskMonitor: NSObject, URLSessionTaskMonitorable {

    var taskDatas: NSMutableDictionary = [:]
    private let queue = DispatchQueue(
        label: "com.DTNetworkMonitor.URLSessionTrackerQueue",
        attributes: .concurrent
    )

    private let logger: Loggable

    init(logger: Loggable) {
        self.logger = logger
    }

    func trackStart(of sessionTask: URLSessionTask) {
        guard let initialURL = sessionTask.originalRequest?.url else { return }
        let taskData = DTURLSessionTaskData(
            initialURL: initialURL,
            startTime: Date()
        )
        queue.async(flags: .barrier) {
            self.taskDatas[sessionTask.taskIdentifier] = taskData
        }
    }

    func trackCompletion(of sessionTask: URLSessionTask, finalURL: URL?, wasSuccessful: Bool) {
        queue.async(flags: .barrier) {
            guard let taskData = self.taskDatas[sessionTask.taskIdentifier] as? DTURLSessionTaskData else { return }
            let endTime = Date()
            taskData.endTime = endTime
            taskData.wasSuccessful = wasSuccessful
            taskData.finalURL = finalURL
            let logEntry = taskData.formattedForLog()
            self.logger.save(logEntry) { result in
                if case .failure(let error) = result {
                    DLog("Error saving log entry: \(error)")
                }
            }
        }
    }
}
