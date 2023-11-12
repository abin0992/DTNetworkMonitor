//
//  URLSessionSwizzlingExtensions.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 11.11.23.
//

import Foundation
import InterposeKit

extension DTURLSessionMonitor {

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

//    func swizzleMethod(originalSelector: Selector) {
//        do {
//            let interposer = try Interpose(URLSession.self) {
//                try $0.hook(
//                    originalSelector,
//                    methodSignature: (@convention(c) (URLSession, Selector, URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask).self,
//                    hookSignature: (@convention(block) (URLSession, URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask).self
//                ) {  store in
//                    return { `self`, request, completionHandler in
//                        let sessionTask = store.original(`self`, store.selector, request, completionHandler)
//
//                        self.trackStart(of: sessionTask)
//
//                        print("----------  URL: \(request.url?.absoluteString ?? "")")
//
//                        let originalCompletionHandler: (Data?, URLResponse?, Error?) -> Void = { data, response, error in
//                            let endTime = Date()
//                            let duration = endTime.timeIntervalSince(startTime)
//
//                            print("---------- Duration: \(duration) seconds")
//
//                            if let httpResponse = response as? HTTPURLResponse, let redirectURL = httpResponse.url, redirectURL != request.url {
//                                print("---------- Redirection occurred to: \(redirectURL.absoluteString)")
//                            }
//
//                            completionHandler(data, response, error)
//                        }
//
//                        return store.original(`self`, store.selector, request, originalCompletionHandler)
//                    }
//                }
//            }
//        } catch {
//            print("Error setting up Interpose: \(error)")
//        }
//    }
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
                            let wasSuccessful = error == nil
                            DTURLSessionMonitor.shared.trackCompletion(of: sessionTask, wasSuccessful: wasSuccessful)

                            if let httpResponse = response as? HTTPURLResponse, let redirectURL = httpResponse.url, redirectURL != request.url {
                                DTURLSessionMonitor.shared.trackRedirection(of: sessionTask, to: redirectURL)
                            }

                            completionHandler(data, response, error)
                        }

                        // Assuming sessionTask can store a modified completion handler
                   //     sessionTask.originalCompletionHandler = modifiedCompletionHandler
                        return store.original(`self`, store.selector, request, modifiedCompletionHandler)
                    //    return sessionTask
                        
                    }
                }
            }
        } catch {
            print("Error setting up Interpose: \(error)")
        }
    }
}

