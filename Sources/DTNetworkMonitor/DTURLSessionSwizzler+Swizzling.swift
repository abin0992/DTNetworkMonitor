//
//  DTURLSessionMonitor+URLSessionSwizzling.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 11.11.23.
//

import Foundation
import InterposeKit

extension DTURLSessionSwizzler {

    func swizzleDataTaskWithRequest(_ monitor: URLSessionTaskMonitorable) {
        let originalSelector = #selector(URLSession.dataTask(with:) as (URLSession) -> (URL) -> URLSessionDataTask)
        swizzleMethod(originalSelector: originalSelector, monitor: monitor)
    }

    func swizzleDataTaskWithCompletionRequest(_ monitor: URLSessionTaskMonitorable) {
        let originalSelector = #selector(URLSession.dataTask(with:completionHandler:) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        swizzleMethod(originalSelector: originalSelector, monitor: monitor)
    }

    func swizzleDownloadTaskWithRequest(_ monitor: URLSessionTaskMonitorable) {
        let originalSelector = #selector(URLSession.downloadTask(with:completionHandler:) as (URLSession) -> (URLRequest, @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask)
        swizzleMethod(originalSelector: originalSelector, monitor: monitor)
    }

    func swizzleUploadTaskWithRequest(_ monitor: URLSessionTaskMonitorable) {
        let originalSelector = #selector(URLSession.uploadTask(with:from:completionHandler:) as (URLSession) -> (URLRequest, Data, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask)
        swizzleMethod(originalSelector: originalSelector, monitor: monitor)
    }

    func swizzleDownloadTaskWithData(_ monitor: URLSessionTaskMonitorable) {
        let originalSelector = #selector(URLSession.downloadTask(with:) as (URLSession) -> (URL) -> URLSessionDownloadTask)
        swizzleMethod(originalSelector: originalSelector, monitor: monitor)
    }
    

    func swizzleDownloadTaskWithCompletionHandler(_ monitor: URLSessionTaskMonitorable) {
        let originalSelector = #selector(URLSession.downloadTask(with:completionHandler:) as (URLSession) -> (URL, @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask)
        swizzleMethod(originalSelector: originalSelector, monitor: monitor)
    }

    func swizzleUploadTaskWithData(_ monitor: URLSessionTaskMonitorable) {
        let originalSelector = #selector(URLSession.uploadTask(with:from:) as (URLSession) -> (URLRequest, Data) -> URLSessionUploadTask)
        swizzleMethod(originalSelector: originalSelector, monitor: monitor)
    }

    func swizzleUploadTaskWithDataAndCompletionHandler(_ monitor: URLSessionTaskMonitorable) {
        let originalSelector = #selector(URLSession.uploadTask(with:from:completionHandler:) as (URLSession) -> (URLRequest, Data, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask)
        swizzleMethod(originalSelector: originalSelector, monitor: monitor)
    }

    func swizzleUploadTaskWithFile(_ monitor: URLSessionTaskMonitorable) {
        let originalSelector = #selector(URLSession.uploadTask(with:fromFile:) as (URLSession) -> (URLRequest, URL) -> URLSessionUploadTask)
        swizzleMethod(originalSelector: originalSelector, monitor: monitor)
    }

    func swizzleUploadTaskWithFileAndCompletionHandler(_ monitor: URLSessionTaskMonitorable) {
        let originalSelector = #selector(URLSession.uploadTask(with:fromFile:completionHandler:) as (URLSession) -> (URLRequest, URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask)
        swizzleMethod(originalSelector: originalSelector, monitor: monitor)
    }
}

extension DTURLSessionSwizzler {
    func swizzleMethod(
        originalSelector: Selector,
        monitor: URLSessionTaskMonitorable
    ) {
        do {
            let interposer = try Interpose(URLSession.self) {
                try $0.hook(
                    originalSelector,
                    methodSignature: (@convention(c) (URLSession, Selector, URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask).self,
                    hookSignature: (@convention(block) (URLSession, URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask).self
                ) { store in
                    return { `self`, request, completionHandler in
                        let sessionTask = store.original(`self`, store.selector, request, completionHandler)
                        monitor.trackStart(of: sessionTask)
                        let modifiedCompletionHandler: (Data?, URLResponse?, Error?) -> Void = { data, response, error in

                            var finalUrl: URL?
                            if 
                                let httpResponse = response as? HTTPURLResponse,
                                let redirectURL = httpResponse.url,
                                redirectURL.absoluteString != request.url?.absoluteString
                            {
                                finalUrl = redirectURL
                            }
                            
                            let wasSuccessful = error == nil
                            monitor.trackCompletion(
                                of: sessionTask,
                                finalURL: finalUrl,
                                wasSuccessful: wasSuccessful
                            )

                            completionHandler(data, response, error)
                        }

                        return store.original(
                            `self`,
                            store.selector,
                            request,
                            modifiedCompletionHandler
                        )
                    }
                }
            }
        } catch {
            let selectorName = String(describing: originalSelector)
            DLog(" \(selectorName) - Error setting up Interpose: \(error)")
        }
    }
}

