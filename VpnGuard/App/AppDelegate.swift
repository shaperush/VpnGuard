import UIKit
import Combine
import Adapty
import AppsFlyerLib
import OneSignalFramework


final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Adapty.activate(AppConstants.PUBLIC_SDK_KEY, customerUserId: nil)
        Adapty.logLevel = .verbose
        
        AppsFlyerLib.shared().appsFlyerDevKey = AppConstants.APPSFLYER_DEV_KEY
        AppsFlyerLib.shared().appleAppID = AppConstants.APPSFLYER_APPLE_APP_ID
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("sendLaunch"), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        OneSignal.initialize(AppConstants.ONESIGNAL_APP_ID, withLaunchOptions: launchOptions)
        OneSignal.Notifications.requestPermission({ accepted in
            print("User accepted notifications: \(accepted)")
        }, fallbackToSettings: true)
        
        return true
    }
    
    @objc func sendLaunch() {
        AppsFlyerLib.shared().start()
    }
}
