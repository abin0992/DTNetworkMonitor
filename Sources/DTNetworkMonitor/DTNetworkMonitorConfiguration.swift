//
//  DTNetworkMonitorConfiguration.swift
//
//
//  Created by Abin Baby on 14.11.23.
//

import Foundation

@objcMembers
final public class DTNetworkMonitorConfiguration: NSObject {
    public static let shared = DTNetworkMonitorConfiguration()
    private var swizzler: URLSessionSwizzling?

    private override init() {
        super.init()
    }

    public func startMonitoring() {
        do {
            let fileManager = try DTFileManager()
            let taskMonitor = DTURLSessionTaskMonitor(logger: fileManager)
            let swizzler = DTURLSessionSwizzler(monitor: taskMonitor)
            swizzler.startURLSessionMonitoring()
            self.swizzler = swizzler // Retain the swizzler instance
            DLog("Started Monitoring")
        } catch {
            DLog("Failed to initialize components: \(error)")
        }
    }
}
