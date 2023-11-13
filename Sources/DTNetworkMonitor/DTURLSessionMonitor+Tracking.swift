//
//  URLSessionTaskTrackingExtensions.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 11.11.23.
//

import Foundation

extension DTURLSessionMonitor {

    func trackStart(of sessionTask: URLSessionTask) {
        let taskData = DTURLSessionTaskData(
            initialURL: sessionTask.originalRequest?.url ?? URL(string: "https://example.com")!,
            startTime: Date(),
            wasSuccessful: false
        )
        queue.async(flags: .barrier) {
            self.taskDatas[sessionTask.taskIdentifier] = taskData
        }

    }

    func trackCompletion(
        of sessionTask: URLSessionTask,
        finalURL: URL?,
        wasSuccessful: Bool
    ) {
        
        queue.async(flags: .barrier) {
            guard let taskData = self.taskDatas[sessionTask.taskIdentifier] as? DTURLSessionTaskData else { return }
            let endTime = Date()

            taskData.endTime = endTime
            taskData.wasSuccessful = wasSuccessful
            if let finalURL {
                taskData.finalURL = finalURL
            }
            let logEntry = self.formatTaskDataForFile(taskData)
            if let fileManager = self.dtFileManager {
                fileManager.save(logEntry)
            }
        }
    }
}
