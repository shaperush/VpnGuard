import UIKit
import Combine
import Adapty


final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Adapty.activate(AppConstants.PUBLIC_SDK_KEY, customerUserId: nil)
        Adapty.logLevel = .verbose
        return true
    }
}
