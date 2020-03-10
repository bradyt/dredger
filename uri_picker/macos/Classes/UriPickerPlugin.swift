import Cocoa
import FlutterMacOS

public class UriPickerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "tangential.info/uri_picker", binaryMessenger: registrar.messenger)
    let instance = UriPickerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "pickUri":

        let panel                     = NSOpenPanel()
        panel.canChooseDirectories    = false
        panel.canChooseFiles          = true
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes        = ["txt", "ledger", "dat", "journal", "org", "beancount", "hledger"]
        let clicked                   = panel.runModal()

        if clicked == NSApplication.ModalResponse.OK {
            let url = panel.url!
            result("\(url.path)")
        } else {
            result("\(NSDate().timeIntervalSince1970)")
        }
    case "getDisplayName":
        if let args = call.arguments as? NSDictionary {
            if let strung = args["uri"] as? NSString {
                result("\(strung)")
            } else {
                result("type of args[\"uri\"] is \(type(of: args["uri"]!))")
            }
        } else {
            result("oh no!")
        }
    case "isUriOpenable":
      result("")
    case "takePersistablePermission":
      result("")
    case "readTextFromUri":
        if let args = call.arguments as? NSDictionary {
            if let path = args["uri"] as? NSString {
                let optionalContents =
                  try? NSString(contentsOfFile: "\(path)",
                                encoding: String.Encoding.utf8.rawValue)
                if let contents = optionalContents as? NSString {
                    result("\(contents)")
                }
            }
        } else {
            result("2030 test")
        }
    case "alterDocument":
        if let args = call.arguments as? NSDictionary {
            if let path = args["uri"] as? NSString {
                if let newContents = args["newContents"] as? NSString {
                    try? newContents.write(toFile: "\(path)",
                                           atomically: true,
                                           encoding: String.Encoding.utf8.rawValue)
                    result("yay")
                }
            }
        }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
