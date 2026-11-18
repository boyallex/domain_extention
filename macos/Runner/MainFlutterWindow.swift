import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    contentViewController = flutterViewController
    setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    registerPermissionChannel(flutterViewController)

    super.awakeFromNib()
  }

  private func registerPermissionChannel(_ controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "domain_extention/permissions",
      binaryMessenger: controller.engine.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "status":
        result(MacPermissions.payload())
      case "request":
        MacPermissions.request { granted in
          result(granted)
        }
      case "openSettings":
        let target = (call.arguments as? String) ?? "auto"
        MacPermissions.openSettings(target: target)
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
