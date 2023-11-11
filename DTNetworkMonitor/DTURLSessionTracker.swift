//
//  DTURLSessionTracker.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 09.11.23.
//

import Foundation
import RSSwizzle

public class DTURLSessionTracker {
    var taskDatas: [URLSessionTask: DTURLSessionTaskData] = [:]
    let queue = DispatchQueue(
        label: "URLSessionTrackerQueue",
        attributes: .concurrent
    )

    public init() {
        swizzleAllURLSessionTaskMethods()
    }
}

private extension DTURLSessionTracker {

    func swizzleAllURLSessionTaskMethods() {
        swizzleDownloadTaskWithData()
        swizzleDownloadTaskWithCompletionHandler()
        swizzleUploadTaskWithData()
        swizzleUploadTaskWithDataAndCompletionHandler()
        swizzleUploadTaskWithFile()
        swizzleUploadTaskWithFileAndCompletionHandler()
    }

    func swizzleDownloadTaskWithData() {
        let originalSelector = #selector(URLSession.downloadTask(with:) as (URLSession) -> (URL) -> URLSessionDownloadTask)
        let swizzledSelector = #selector(swizzled_downloadTask(with:))
        swizzleMethod(originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }

    func swizzleDownloadTaskWithCompletionHandler() {
        let originalSelector = #selector(URLSession.downloadTask(with:completionHandler:) as (URLSession) -> (URL, @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask)
        let swizzledSelector = #selector(swizzled_downloadTask(with:completionHandler:))
        swizzleMethod(originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }

    func swizzleUploadTaskWithData() {
        let originalSelector = #selector(URLSession.uploadTask(with:from:) as (URLSession) -> (URLRequest, Data) -> URLSessionUploadTask)
        let swizzledSelector = #selector(swizzled_uploadTask(with:from:))
        swizzleMethod(originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }

    func swizzleUploadTaskWithDataAndCompletionHandler() {
        let originalSelector = #selector(URLSession.uploadTask(with:from:completionHandler:) as (URLSession) -> (URLRequest, Data, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask)
        let swizzledSelector = #selector(swizzled_uploadTask(with:from:completionHandler:))
        swizzleMethod(originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }

    func swizzleUploadTaskWithFile() {
        let originalSelector = #selector(URLSession.uploadTask(with:fromFile:) as (URLSession) -> (URLRequest, URL) -> URLSessionUploadTask)
        let swizzledSelector = #selector(swizzled_uploadTask(with:fromFile:))
        swizzleMethod(originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }

    func swizzleUploadTaskWithFileAndCompletionHandler() {
        let originalSelector = #selector(URLSession.uploadTask(with:fromFile:completionHandler:) as (URLSession) -> (URLRequest, URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask)
        let swizzledSelector = #selector(swizzled_uploadTask(with:fromFile:completionHandler:))
        swizzleMethod(originalSelector: originalSelector, swizzledSelector: swizzledSelector)
    }

    func swizzleMethod(originalSelector: Selector, swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(URLSession.self, originalSelector) else {
            fatalError("Swizzling Error: Original method \(originalSelector) not found.")
        }

        let originalIMP = method_getImplementation(originalMethod)
        let originalFunction = unsafeBitCast(originalIMP, to: (@convention(c) (AnyObject, Selector, URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask).self)

        let swizzleBlock: @convention(block) (AnyObject, URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask = { [weak self] (session, url, completionHandler) in
            // Start the original task using the cast function
            let task = originalFunction(session, originalSelector, url, completionHandler)

            // Track the start of the task
            self?.trackStart(of: task)

            // Modify the completion handler to track completion and potential redirection
            // newCompletionHandler is not used, common issue when attempting to modify completion handlers in swizzled methods
            let newCompletionHandler: (Data?, URLResponse?, Error?) -> Void = { data, response, error in
                let wasSuccessful = error == nil
                let finalURL = (response as? HTTPURLResponse)?.url ?? url
                self?.trackCompletion(of: task, wasSuccessful: wasSuccessful)
                self?.trackRedirection(of: task, to: finalURL)

                completionHandler(data, response, error)
            }

           return task
       }

        let swizzledImplementation = imp_implementationWithBlock(swizzleBlock)
                
        RSSwizzle.swizzleInstanceMethod(
            originalSelector,
            in: URLSession.self,
            newImpFactory: { _ in swizzledImplementation },
            mode: .always,
            key: nil
        )
    }
}

private extension DTURLSessionTracker {

    // MARK: Download tasks

    @objc
    func swizzled_downloadTask(with url: URL) -> URLSessionDownloadTask {
        let originalTask = URLSession.shared.downloadTask(with: url)
        self.trackStart(of: originalTask)
        return originalTask
    }

    @objc
    func swizzled_downloadTask(
        with url: URL,
        completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void
    ) -> URLSessionDownloadTask {
        let originalTask = URLSession.shared.downloadTask(with: url) { url, response, error in
            completionHandler(url, response, error)
        }
        return originalTask
    }

    // MARK: Upload tasks

    @objc
    func swizzled_uploadTask(with request: URLRequest, from bodyData: Data) -> URLSessionUploadTask {
        let originalTask = URLSession.shared.uploadTask(with: request, from: bodyData)
        return originalTask
    }

    @objc
    private func swizzled_uploadTask(
        with request: URLRequest,
        from bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionUploadTask {
        let originalTask = URLSession.shared.uploadTask(with: request, from: bodyData) { data, response, error in
            completionHandler(data, response, error)
        }
        return originalTask
    }

    @objc
    private func swizzled_uploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTask {
        let originalTask = URLSession.shared.uploadTask(with: request, fromFile: fileURL)
        return originalTask
    }

    @objc
    private func swizzled_uploadTask(
        with request: URLRequest,
        fromFile fileURL: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionUploadTask {
        let originalTask = URLSession.shared.uploadTask(with: request, fromFile: fileURL) { data, response, error in
            completionHandler(data, response, error)
        }
        return originalTask
    }


}

private extension DTURLSessionTracker {

    func startTracking(sessionTask: URLSessionTask) {
        // This would be called at the start of a session task
        trackStart(of: sessionTask)
    }

    func completeTracking(sessionTask: URLSessionTask, wasSuccessful: Bool) {
        // This would be called when a session task completes
        trackCompletion(of: sessionTask, wasSuccessful: wasSuccessful)
    }

    func redirectTracking(sessionTask: URLSessionTask, to finalURL: URL) {
        // This would be called if a session task is redirected to a new URL
        trackRedirection(of: sessionTask, to: finalURL)
    }
}

private extension DTURLSessionTracker {

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

extension DTURLSessionTracker {
    
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
