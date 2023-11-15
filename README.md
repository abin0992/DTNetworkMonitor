# DTNetworkMonitor [![Build](https://github.com/abin0992/DTNetworkMonitor/actions/workflows/swift.yml/badge.svg)](https://github.com/abin0992/DTNetworkMonitor/actions/workflows/swift.yml) 

DTNetworkMonitor is a lightweight framework for monitoring network activity in your iOS applications. It provides an easy way to intercept and log network requests and responses made through `URLSession`.

## Features

- Easy integration with Swift and Objective-C projects.
- Automatic interception of all `URLSession` data tasks, upload tasks, and download tasks.
- Detailed logging of network requests and responses.

## Requirements

- iOS 13.0+
- Xcode 11+
- Swift 5.1+

## Installation

Currently, you can integrate DTNetworkMonitor into your project manually.

### Manual Installation

1. Clone or download the DTNetworkMonitor repository.
2. Drag and drop the `DTNetworkMonitor.xcodeproj` into your project or workspace.
3. Go to your project settings under `General`, scroll down to `Embedded Binaries`, and add `DTNetworkMonitor.framework`.
4. Make sure to `import DTNetworkMonitor` in any file you'd like to use the framework.

### Swift Package Manager
1. Add DTNetworkMonitor repo to list of packages in Package Dependencies tab in project settings
## Usage

### Swift Project

To use DTNetworkMonitor in a Swift project, you need to initialize and start the monitoring process, typically in your `AppDelegate`.

```swift
import UIKit
import DTNetworkMonitor

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Start network monitoring
        DTNetworkMonitorConfiguration.shared.startMonitoring()

        return true
    }
}
```

Objective-C Project
For an Objective-C project, you need to import the DTNetworkMonitor module in your AppDelegate and start the monitoring process.
```
#import <UIKit/UIKit.h>
@import DTNetworkMonitor;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Start network monitoring
    [[DTNetworkMonitorConfiguration shared] startMonitoring];

    return YES;
}

@end
```
### TODO
1. Add swiftlint
2. Add supprt to distribute through Cocoapods and carthage
3. Add more tests
