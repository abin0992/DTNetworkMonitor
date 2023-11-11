//
//  URLSessionTaskTrackingExtensions.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 11.11.23.
//

import Foundation

protocol DTURLSessionMonitorDelegate: AnyObject {
    func trackStart(of sessionTask: URLSessionTask)
    func trackCompletion(of sessionTask: URLSessionTask, wasSuccessful: Bool)
    func trackRedirection(of sessionTask: URLSessionTask, to finalURL: URL)
}

extension DTURLSessionMonitor: DTURLSessionMonitorDelegate {

    func trackStart(of sessionTask: URLSessionTask) {
        print("----> Network monitor - track start action \(sessionTask.originalRequest?.url)")
        let taskData = DTURLSessionTaskData(
            initialURL: sessionTask.originalRequest?.url ?? URL(string: "https://example.com")!,
            startTime: Date()
        )
        queue.async(flags: .barrier) {
     //       self.taskDatas[sessionTask] = taskData
        }
    }

    func trackCompletion(of sessionTask: URLSessionTask, wasSuccessful: Bool) {
        print("----> Network monitor - track complete action \(wasSuccessful)")
        queue.async(flags: .barrier) {
//            guard let taskData = self.taskDatas[sessionTask] else { return }
//            let endTime = Date()
//            let duration = endTime.timeIntervalSince(taskData.startTime)
//            let finalURL = taskData.finalURL ?? taskData.initialURL
//            print("\(taskData.initialURL), \(duration * 1000)ms, \(finalURL), \(wasSuccessful ? "SUCCESS" : "FAILURE")")
//
//            self.taskDatas[sessionTask]?.endTime = endTime
//            self.taskDatas[sessionTask]?.wasSuccessful = wasSuccessful
        }
    }

    func trackRedirection(of sessionTask: URLSessionTask, to finalURL: URL) {
        print("----> Network monitor - track redirect action \(finalURL)")
        queue.async(flags: .barrier) {
     //       self.taskDatas[sessionTask]?.finalURL = finalURL
        }
    }
}
