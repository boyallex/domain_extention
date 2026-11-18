import AVFoundation
import Cocoa
import Darwin
import FlutterMacOS
import Speech

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    MacPermissions.preflight()
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

enum MacPermissions {
  static func status() -> (mic: Bool, speech: Bool) {
    let current = (microphoneGranted(), speechGranted())
    NSLog(
      "[voice] status microphone=%@ speech=%@ speechStatus=%@ parent=%@ hostedByFlutter=%@",
      current.0 ? "true" : "false",
      current.1 ? "true" : "false",
      speechStatusName(),
      parentProcessName(),
      isHostedByFlutterTools ? "true" : "false"
    )
    return current
  }

  static func payload() -> [String: Any] {
    let current = status()
    return [
      "microphone": current.mic,
      "speech": current.speech,
      "speechStatus": speechStatusName(),
      "hostedByFlutter": isHostedByFlutterTools,
      "parent": parentProcessName(),
    ]
  }

  static func preflight() {
    NSLog("[voice] preflight parent=%@ hostedByFlutter=%@", parentProcessName(), isHostedByFlutterTools ? "true" : "false")
    guard !isHostedByFlutterTools else {
      return
    }
    guard SFSpeechRecognizer.authorizationStatus() == .notDetermined else {
      return
    }
    requestSpeech { granted in
      NSLog("[voice] preflight speech=%@", granted ? "true" : "false")
    }
  }

  static func request(_ completion: @escaping (Bool) -> Void) {
    DispatchQueue.main.async {
      requestMicrophone { microphone in
        requestSpeech { speech in
          NSLog(
            "[voice] request microphone=%@ speech=%@",
            microphone ? "true" : "false",
            speech ? "true" : "false"
          )
          completion(microphone && speech)
        }
      }
    }
  }

  static func openSettings(target: String = "auto") {
    let pane: String
    if target == "speech" || (target == "auto" && !speechGranted()) {
      pane = "Privacy_SpeechRecognition"
    } else {
      pane = "Privacy_Microphone"
    }
    let urls = [
      "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?\(pane)",
      "x-apple.systempreferences:com.apple.preference.security?\(pane)",
    ]
    for item in urls {
      if let url = URL(string: item), NSWorkspace.shared.open(url) {
        return
      }
    }
  }

  static var isHostedByFlutterTools: Bool {
    let parent = parentProcessName().lowercased()
    return parent.contains("dart") || parent.contains("flutter")
  }

  private static func speechGranted() -> Bool {
    SFSpeechRecognizer.authorizationStatus() == .authorized
  }

  private static func speechStatusName() -> String {
    switch SFSpeechRecognizer.authorizationStatus() {
    case .authorized:
      return "authorized"
    case .denied:
      return "denied"
    case .restricted:
      return "restricted"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "unknown"
    }
  }

  private static func microphoneGranted() -> Bool {
    let capture = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    if #available(macOS 14.0, *) {
      return AVAudioApplication.shared.recordPermission == .granted || capture
    }
    return capture
  }

  private static func requestMicrophone(_ completion: @escaping (Bool) -> Void) {
    if microphoneGranted() {
      completion(true)
      return
    }

    if #available(macOS 14.0, *) {
      switch AVAudioApplication.shared.recordPermission {
      case .denied:
        NSLog("[voice] microphone denied")
        completion(false)
      case .undetermined:
        NSLog("[voice] requestRecordPermission")
        AVAudioApplication.requestRecordPermission { granted in
          DispatchQueue.main.async {
            completion(granted)
          }
        }
      default:
        completion(microphoneGranted())
      }
      return
    }

    switch AVCaptureDevice.authorizationStatus(for: .audio) {
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        DispatchQueue.main.async {
          completion(granted)
        }
      }
    default:
      completion(microphoneGranted())
    }
  }

  private static func requestSpeech(_ completion: @escaping (Bool) -> Void) {
    let status = SFSpeechRecognizer.authorizationStatus()
    switch status {
    case .authorized:
      completion(true)
    case .notDetermined:
      if isHostedByFlutterTools {
        NSLog("[voice] skip requestAuthorization under %@", parentProcessName())
        completion(false)
        return
      }
      NSLog("[voice] requestSpeechAuthorization")
      SFSpeechRecognizer.requestAuthorization { newStatus in
        DispatchQueue.main.async {
          completion(newStatus == .authorized)
        }
      }
    default:
      NSLog("[voice] speech %@", speechStatusName())
      completion(false)
    }
  }

  private static func parentProcessName() -> String {
    let ppid = getppid()
    var name = [CChar](repeating: 0, count: 1024)
    let length = proc_name(ppid, &name, UInt32(name.count))
    if length <= 0 {
      return "pid-\(ppid)"
    }
    return String(cString: name)
  }
}
