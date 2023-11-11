//
//  DTURLSessionMonitor.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 09.11.23.
//

import Foundation
import InterposeKit

@objcMembers
public class DTURLSessionMonitor: NSObject {
    private var session: URLSession
    var taskDatas: NSMutableDictionary = [:]
  //  var taskDatas: [URLSessionTask: DTURLSessionTaskData] = [:]
    let queue = DispatchQueue(
        label: "URLSessionTrackerQueue",
        attributes: .concurrent
    )

    @objc
    public init(session: URLSession = .shared) {
        self.session = session
        self.taskDatas = [:]
        // Setup swizzling if needed
    }

    @objc
    public static func startLogging() {
        do {
            let originalSelector = #selector(URLSession.dataTask(with:completionHandler:) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
            
            let interposer = try Interpose(URLSession.self) {
                try $0.hook(
                    originalSelector,
                    methodSignature: (@convention(c) (URLSession, Selector, URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask).self,
                    hookSignature: (@convention(block) (URLSession, URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask).self
                ) { store in
                    return { `self`, request, completionHandler in
                        let startTime = Date()
                        
                        print("----------  URL: \(request.url?.absoluteString ?? "")")
                        
                        let originalCompletionHandler: (Data?, URLResponse?, Error?) -> Void = { data, response, error in
                            let endTime = Date()
                            let duration = endTime.timeIntervalSince(startTime)
                            
                            print("---------- Duration: \(duration) seconds")
                            
                            if let httpResponse = response as? HTTPURLResponse, let redirectURL = httpResponse.url, redirectURL != request.url {
                                print("---------- Redirection occurred to: \(redirectURL.absoluteString)")
                            }
                            
                            completionHandler(data, response, error)
                        }
                        
                        return store.original(`self`, store.selector, request, originalCompletionHandler)
                    }
                }
            }
        } catch {
            print("Error setting up Interpose: \(error)")
        }
    }
}

private extension DTURLSessionMonitor {

    func getTaskData(for sessionTask: URLSessionTask) -> DTURLSessionTaskData? {
        var taskData: DTURLSessionTaskData?
        queue.sync {
       //     taskData = self.taskDatas[sessionTask]
        }
        return taskData
    }

    func cleanup(for task: URLSessionTask) {
        queue.async(flags: .barrier) {
     //       self.taskDatas.removeValue(forKey: task)
        }
    }
}

extension DTURLSessionMonitor {
    
    func saveTaskDataToFile() {
        queue.async(flags: .barrier) {
            let fileURL = self.getFileURL()
            var dataToWrite = [String]()
            for (_, taskData) in self.taskDatas {
        //        let line = self.formatTaskDataForFile(taskData)
         //       dataToWrite.append(line)
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
