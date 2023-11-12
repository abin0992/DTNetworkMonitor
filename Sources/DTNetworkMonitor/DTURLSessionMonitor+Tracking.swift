//
//  URLSessionTaskTrackingExtensions.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 11.11.23.
//

import Foundation

extension DTURLSessionMonitor {

    func trackStart(of sessionTask: URLSessionTask) {
        print("----> Network monitor - track start action \(sessionTask.originalRequest?.url?.absoluteString ?? "")")
        let taskData = DTURLSessionTaskData(
            initialURL: sessionTask.originalRequest?.url ?? URL(string: "https://example.com")!,
            startTime: Date()
        )
        queue.async(flags: .barrier) {
            self.taskDatas[sessionTask] = taskData
        }
    }

    func trackCompletion(of sessionTask: URLSessionTask, wasSuccessful: Bool) {
        print("----> Network monitor - track complete action \(wasSuccessful)")
        queue.async(flags: .barrier) {
            guard let taskData = self.taskDatas[sessionTask] as? DTURLSessionTaskData else { return }
            let endTime = Date()
            let duration = endTime.timeIntervalSince(taskData.startTime)
            let finalURL = taskData.finalURL ?? taskData.initialURL
            print("\(taskData.initialURL), \(duration * 1000)ms, \(finalURL), \(wasSuccessful ? "SUCCESS" : "FAILURE")")

            taskData.endTime = endTime
            taskData.wasSuccessful = wasSuccessful
        }
    }

    func trackRedirection(of sessionTask: URLSessionTask, to finalURL: URL) {
        print("----> Network monitor - track redirect action \(finalURL)")
        queue.async(flags: .barrier) {
            if let taskData = self.taskDatas[sessionTask] as? DTURLSessionTaskData {
                taskData.finalURL = finalURL
            }
        }
    }
}
