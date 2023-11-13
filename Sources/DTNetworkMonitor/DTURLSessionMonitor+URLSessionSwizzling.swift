//
//  DTURLSessionMonitor+URLSessionSwizzling.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 11.11.23.
//

import Foundation
import InterposeKit

extension DTURLSessionMonitor {

    func swizzleDataTaskWithRequest() {
        let originalSelector = #selector(URLSession.dataTask(with:) as (URLSession) -> (URL) -> URLSessionDataTask)
        swizzleMethod(originalSelector: originalSelector)
    }

    func swizzleDataTaskWithCompletionRequest() {
        let originalSelector = #selector(URLSession.dataTask(with:completionHandler:) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        swizzleMethod(originalSelector: originalSelector)
    }

    func swizzleDownloadTaskWithRequest() {
        let originalSelector = #selector(URLSession.downloadTask(with:completionHandler:) as (URLSession) -> (URLRequest, @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask)
        swizzleMethod(originalSelector: originalSelector)
    }

    func swizzleUploadTaskWithRequest() {
        let originalSelector = #selector(URLSession.uploadTask(with:from:completionHandler:) as (URLSession) -> (URLRequest, Data, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask)
        swizzleMethod(originalSelector: originalSelector)
    }

    func swizzleDownloadTaskWithData() {
        let originalSelector = #selector(URLSession.downloadTask(with:) as (URLSession) -> (URL) -> URLSessionDownloadTask)
        swizzleMethod(originalSelector: originalSelector)
    }
    

    func swizzleDownloadTaskWithCompletionHandler() {
        let originalSelector = #selector(URLSession.downloadTask(with:completionHandler:) as (URLSession) -> (URL, @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask)
        swizzleMethod(originalSelector: originalSelector)
    }

    func swizzleUploadTaskWithData() {
        let originalSelector = #selector(URLSession.uploadTask(with:from:) as (URLSession) -> (URLRequest, Data) -> URLSessionUploadTask)
        swizzleMethod(originalSelector: originalSelector)
    }

    func swizzleUploadTaskWithDataAndCompletionHandler() {
        let originalSelector = #selector(URLSession.uploadTask(with:from:completionHandler:) as (URLSession) -> (URLRequest, Data, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask)
        swizzleMethod(originalSelector: originalSelector)
    }

    func swizzleUploadTaskWithFile() {
        let originalSelector = #selector(URLSession.uploadTask(with:fromFile:) as (URLSession) -> (URLRequest, URL) -> URLSessionUploadTask)
        swizzleMethod(originalSelector: originalSelector)
    }

    func swizzleUploadTaskWithFileAndCompletionHandler() {
        let originalSelector = #selector(URLSession.uploadTask(with:fromFile:completionHandler:) as (URLSession) -> (URLRequest, URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionUploadTask)
        swizzleMethod(originalSelector: originalSelector)
    }
}

extension DTURLSessionMonitor {
    func swizzleMethod(originalSelector: Selector) {
        do {
            let interposer = try Interpose(URLSession.self) {
                try $0.hook(
                    originalSelector,
                    methodSignature: (@convention(c) (URLSession, Selector, URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask).self,
                    hookSignature: (@convention(block) (URLSession, URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask).self
                ) { store in
                    return { `self`, request, completionHandler in
                        let sessionTask = store.original(`self`, store.selector, request, completionHandler)
                        DTURLSessionMonitor.shared.trackStart(of: sessionTask)
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
                            DTURLSessionMonitor.shared.trackCompletion(
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

