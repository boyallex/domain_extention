import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "CharacterIcon") else {
      return
    }
    let channel = FlutterMethodChannel(
      name: "domain_extention/native_widget",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "setCharacter",
            let arguments = call.arguments as? [String: Any],
            let characterId = arguments["characterId"] as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      let iconName: String? = characterId == "gojo" ? "AppIconGojo" : "AppIconSukuna"
      if let typedImage = arguments["imageBytes"] as? FlutterStandardTypedData,
         let shared = FileManager.default.containerURL(
           forSecurityApplicationGroupIdentifier: "group.com.example.domainExtention.shared"
         ) {
        try? typedImage.data.write(to: shared.appendingPathComponent("character_widget.png"), options: .atomic)
      } else if let shared = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: "group.com.example.domainExtention.shared"
      ) {
        try? FileManager.default.removeItem(at: shared.appendingPathComponent("character_widget.png"))
      }
      UserDefaults(suiteName: "group.com.example.domainExtention.shared")?
        .set(characterId, forKey: "characterId")
      DispatchQueue.main.async {
        WidgetCenter.shared.reloadTimelines(ofKind: "CharacterHomeWidget")
        guard UIApplication.shared.alternateIconName != iconName else {
          result(nil)
          return
        }
        UIApplication.shared.setAlternateIconName(iconName) { error in
          if let error {
            result(FlutterError(code: "ICON_UPDATE_FAILED", message: error.localizedDescription, details: nil))
          } else {
            result(nil)
          }
        }
      }
    }
  }
}
