import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
//  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//
//          switch manager.authorizationStatus {
//              case .authorizedAlways , .authorizedWhenInUse:
//                  break
//              case .notDetermined , .denied , .restricted:
//                  break
//              default:
//                  break
//          }
//
//          switch manager.accuracyAuthorization {
//              case .fullAccuracy:
//                  break
//              case .reducedAccuracy:
//                  break
//              default:
//                  break
//          }
//  }
}
