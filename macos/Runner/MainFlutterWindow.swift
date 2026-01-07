import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Set window background to white (matches splash screen)
    self.backgroundColor = NSColor.white

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
