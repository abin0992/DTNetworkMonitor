//
//  URLSessionTaskTrackingExtensions.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 11.11.23.
//

import Foundation

extension DTURLSessionTracker {

    func trackStart(of sessionTask: URLSessionTask) {
        let taskData = DTURLSessionTaskData(
            initialURL: sessionTask.originalRequest?.url ?? URL(string: "https://example.com")!,
            startTime: Date()
        )
        queue.async(flags: .barrier) {
            self.taskDatas[sessionTask] = taskData
        }
    }

    func trackCompletion(of sessionTask: URLSessionTask, wasSuccessful: Bool) {
        queue.async(flags: .barrier) {
            guard let taskData = self.taskDatas[sessionTask] else { return }
            let endTime = Date()
            let duration = endTime.timeIntervalSince(taskData.startTime)
            let finalURL = taskData.finalURL ?? taskData.initialURL
            print("\(taskData.initialURL), \(duration * 1000)ms, \(finalURL), \(wasSuccessful ? "SUCCESS" : "FAILURE")")

            self.taskDatas[sessionTask]?.endTime = endTime
            self.taskDatas[sessionTask]?.wasSuccessful = wasSuccessful
        }
    }

    func trackRedirection(of sessionTask: URLSessionTask, to finalURL: URL) {
        queue.async(flags: .barrier) {
            self.taskDatas[sessionTask]?.finalURL = finalURL
        }
    }
}
