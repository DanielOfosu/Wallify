import Cocoa
import SwiftUI
import WebKit

class WallpaperWindowController: NSWindowController {

    private var webView: WKWebView?

    convenience init() {
        let window = NSWindow(contentRect: .zero,
                              styleMask: [.borderless],
                              backing: .buffered,
                              defer: false)
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) - 1) // Position below desktop icons
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.ignoresMouseEvents = true
        
        self.init(window: window)
    }

    func setupContentView() {
        // Configure the web view for autoplaying media
        let configuration = WKWebViewConfiguration()
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // Create and configure the web view
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView = webView
        
        // Set the web view as the window's content view
        window?.contentView = webView
        
        // Set the window frame to cover the entire screen
        if let screen = NSScreen.main {
            window?.setFrame(screen.frame, display: true)
        }
        
        // Show the window
        window?.orderBack(nil)
    }
    
    func loadURL(_ url: URL) {
        // For web content (like YouTube), load it directly.
        if !url.isFileURL {
            webView?.load(URLRequest(url: url))
            return
        }

        // For local files, we must embed the video data directly into the HTML
        // to work reliably within the sandbox.
        guard let videoData = try? Data(contentsOf: url) else {
            print("Failed to load video data from URL: \(url)")
            return
        }
        
        // Encode the video data as Base64 and create a data URL.
        let base64Data = videoData.base64EncodedString()
        let dataURLString = "data:video/mp4;base64,\(base64Data)"

        guard let htmlTemplatePath = Bundle.main.path(forResource: "VideoPlayer", ofType: "html"),
              let htmlTemplate = try? String(contentsOfFile: htmlTemplatePath) else {
            print("Failed to load VideoPlayer.html from bundle.")
            return
        }
        
        // Inject the data URL into our HTML template.
        let finalHTML = htmlTemplate.replacingOccurrences(of: "VIDEO_URL_PLACEHOLDER", with: dataURLString)
        
        // Load the self-contained HTML.
        webView?.loadHTMLString(finalHTML, baseURL: nil)
    }
    
    func stop() {
        // Load a blank page to effectively stop the content
        webView?.load(URLRequest(url: URL(string:"about:blank")!))
    }
}
