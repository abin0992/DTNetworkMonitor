//
//  Logging.swift
//  DTNetworkMonitor
//
//  Created by Abin Baby on 19/01/2022.
//

import Foundation

public func DLog(
    _ message: String,
    filename: String = #file,
    function: String = #function,
    line: Int = #line
) {
    #if DEBUG
        NSLog(" DTNetworkMonitor -------> [\((filename as NSString).lastPathComponent):\(line) (\(function))] \(message)")
    #endif
}
