//
//  URLSessionSwizzlingExtensions.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 11.11.23.
//

import Foundation

public extension URLSession {

    static internal weak var urlSessionMonitorDelegate: DTURLSessionMonitorDelegate?

    func swizzleAllURLSessionTaskMethods() {
     //   swizzleDownloadTaskWithData()
        swizzleDownloadTaskWithCompletionHandler()
        swizzleUploadTaskWithData()
        swizzleUploadTaskWithDataAndCompletionHandler()
        swizzleUploadTaskWithFile()
        swizzleUploadTaskWithFileAndCompletionHandler()
        swizzleDownloadTask()
    }

//    func swizzleDownloadTaskWithData() {
//        let originalSelector = #selector(URLSession.downloadTask(with:) as (URLSession) -> (URL) -> URLSessionDownloadTask)
//        let swizzledSelector = #selector(swizzled_downloadTask(with:))
//        swizzleMethod(originalSelector: originalSelector, swizzledSelector: swizzledSelector)
//    }
    
    func swizzleDownloadTask() {
        let originalSelector = #selector(URLSession.downloadTask(with:completionHandler:) as (URLSession) -> (URL, @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask)
        let swizzledSelector = #selector(URLSession.swizzled_downloadTask(with:completionHandler:))

        guard 
            class_getInstanceMethod(URLSession.self, originalSelector) != nil,
            class_getInstanceMethod(URLSession.self, swizzledSelector) != nil
        else {
           print("Swizzling Error: Methods not found.")
           return
       }
        
        let swizzleBlock: @convention(block) (AnyObject, URL, @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask = { (session, url, completionHandler) in
            let session = session as! URLSession
            var task: URLSessionDownloadTask?

            // Start the original task
            task = session.swizzled_downloadTask(with: url) { data, response, error in
                let wasSuccessful = error == nil
                let finalURL = (response as? HTTPURLResponse)?.url ?? url

                if let task {
                    URLSession.urlSessionMonitorDelegate?.trackCompletion(of: task, wasSuccessful: wasSuccessful)
                    URLSession.urlSessionMonitorDelegate?.trackRedirection(of: task, to: finalURL)
                }

                completionHandler(data, response, error)
            }

            if let task {
                URLSession.urlSessionMonitorDelegate?.trackStart(of: task)
            }
            
            return task ?? URLSessionDownloadTask()
        }

//        let swizzledImplementation = imp_implementationWithBlock(swizzleBlock)
//
//        RSSwizzle.swizzleInstanceMethod(
//            originalSelector,
//            in: URLSession.self,
//            newImpFactory: { _ in swizzledImplementation },
//            mode: .always,
//            key: nil
//        )
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
        guard
            let swizzledMethod = class_getInstanceMethod(URLSession.self, swizzledSelector)
        else {
            print("Swizzling Error: Methods not found.")
            return
        }

//        RSSwizzle.swizzleInstanceMethod(
//            originalSelector,
//            in: URLSession.self,
//            newImpFactory: { _ in
//                method_getImplementation(swizzledMethod)
//            },
//            mode: .always,
//            key: nil
//        )
    }


//    func swizzleMethod1(originalSelector: Selector, swizzledSelector: Selector) {
//        guard let originalMethod = class_getInstanceMethod(URLSession.self, originalSelector) else {
//            fatalError("Swizzling Error: Original method \(originalSelector) not found.")
//        }
//
//        let originalIMP = method_getImplementation(originalMethod)
////        let originalFunction = unsafeBitCast(originalIMP, to: (@convention(c) (AnyObject, Selector, URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask).self)
//        let originalFunction = unsafeBitCast(originalIMP, to: (AnyObject, URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask.self)
//
//        let swizzleBlock: @convention(block) (AnyObject, URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask = { (session, url, completionHandler) in
//            // Start the original task using the cast function
//            let task = originalFunction(session, originalSelector, url, completionHandler)
//
//            // Track the start of the task
//            URLSession.urlSessionMonitorDelegate?.trackStart(of: task)
//
//            // Modify the completion handler to track completion and potential redirection
//            // newCompletionHandler is not used, common issue when attempting to modify completion handlers in swizzled methods
//            let newCompletionHandler: (Data?, URLResponse?, Error?) -> Void = { data, response, error in
//                let wasSuccessful = error == nil
//                let finalURL = (response as? HTTPURLResponse)?.url ?? url
//                URLSession.urlSessionMonitorDelegate?.trackCompletion(of: task, wasSuccessful: wasSuccessful)
//                URLSession.urlSessionMonitorDelegate?.trackRedirection(of: task, to: finalURL)
//
//                completionHandler(data, response, error)
//            }
//
//           return task
//       }
//
//        let swizzledImplementation = imp_implementationWithBlock(swizzleBlock)
//                
//        RSSwizzle.swizzleInstanceMethod(
//            originalSelector,
//            in: URLSession.self,
//            newImpFactory: { _ in swizzledImplementation },
//            mode: .always,
//            key: nil
//        )
//    }
}


extension URLSession {

    // MARK: Download tasks

//    @objc
//    func swizzled_downloadTask(with url: URL) -> URLSessionDownloadTask {
//        let originalTask = self.swizzled_downloadTask(with: url)
//
//        let originalCompletionHandler = originalTask.completionHandler
//        originalTask.completionHandler = { data, response, error in
//            // Print the end time of the URL request
//            let endTime = Date()
//            print("Request ended for URL: \(url.absoluteString) at \(endTime)")
//
//            // Print the final URL
//            if let httpResponse = response as? HTTPURLResponse {
//                print("Final URL: \(httpResponse.url?.absoluteString ?? "Unknown")")
//            }
//
//            // Call the original completion handler if it exists
//            originalCompletionHandler?(data, response, error)
//        }
//
//        return originalTask
//    }


    @objc
    func swizzled_downloadTask(
        with url: URL,
        completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void
    ) -> URLSessionDownloadTask {
        self.downloadTask(with: url) { url, response, error in
            completionHandler(url, response, error)
        }
    }

    // MARK: Upload tasks

    @objc
    func swizzled_uploadTask(
        with request: URLRequest,
        from bodyData: Data
    ) -> URLSessionUploadTask {
        self.uploadTask(with: request, from: bodyData)
    }

    @objc
    private func swizzled_uploadTask(
        with request: URLRequest,
        from bodyData: Data?,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionUploadTask {
        self.uploadTask(with: request, from: bodyData) { data, response, error in
            completionHandler(data, response, error)
        }
    }

    @objc
    private func swizzled_uploadTask(
        with request: URLRequest,
        fromFile fileURL: URL
    ) -> URLSessionUploadTask {
        self.uploadTask(with: request, fromFile: fileURL)
    }

    @objc
    private func swizzled_uploadTask(
        with request: URLRequest,
        fromFile fileURL: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionUploadTask {
        self.uploadTask(with: request, fromFile: fileURL) { data, response, error in
            completionHandler(data, response, error)
        }
    }
}
