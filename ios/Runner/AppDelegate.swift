import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Bắt buộc cho flutter_local_notifications trên iOS.
    //
    // Thiếu dòng này thì thông báo KHÔNG hiện khi app đang mở, và không có lỗi
    // nào được báo — chỉ đơn giản là không thấy gì. Đây là kiểu hỏng im lặng
    // rất tốn thời gian truy tìm nếu không biết trước.
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
