//
//  DTURLSessionSwizzler.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 09.11.23.
//

import Foundation
import InterposeKit

protocol URLSessionSwizzling {
    func startURLSessionMonitoring()
}

class DTURLSessionSwizzler: NSObject, URLSessionSwizzling {
    
    let monitor: URLSessionTaskMonitorable

    init(monitor: URLSessionTaskMonitorable) {
        self.monitor = monitor
    }
    
    func startURLSessionMonitoring() {
        swizzleDataTaskWithRequest(monitor)
        swizzleDataTaskWithCompletionRequest(monitor)
        swizzleDownloadTaskWithRequest(monitor)
        swizzleUploadTaskWithRequest(monitor)
        swizzleDownloadTaskWithData(monitor)
        swizzleDownloadTaskWithCompletionHandler(monitor)
        swizzleUploadTaskWithData(monitor)
        swizzleUploadTaskWithDataAndCompletionHandler(monitor)
        swizzleUploadTaskWithFile(monitor)
        swizzleUploadTaskWithFileAndCompletionHandler(monitor)
    }
}
