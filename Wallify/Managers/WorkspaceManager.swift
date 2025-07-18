
import Cocoa

class WorkspaceManager {
    func setWallpaper(url: URL, for screen: NSScreen) throws {
        try NSWorkspace.shared.setDesktopImageURL(url, for: screen)
    }
}
