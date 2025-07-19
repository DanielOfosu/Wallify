import SwiftUI

struct MenuBarIconView: View {
    let size: CGFloat
    let isDarkMode: Bool
    
    init(size: CGFloat = 16, isDarkMode: Bool = false) {
        self.size = size
        self.isDarkMode = isDarkMode
    }
    
    var body: some View {
        ZStack {
            // Background circle/rounded square
            RoundedRectangle(cornerRadius: size * 0.25)
                .stroke(
                    LinearGradient(
                        colors: isDarkMode ? 
                            [Color.white.opacity(0.9), Color.white.opacity(0.7)] :
                            [Color.black.opacity(0.9), Color.black.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.08
                )
                .frame(width: size, height: size)
                .shadow(
                    color: isDarkMode ? Color.white.opacity(0.3) : Color.black.opacity(0.2),
                    radius: size * 0.1,
                    x: 0,
                    y: 0
                )
            
            // Mountains
            VStack(spacing: 0) {
                // Left mountain
                Path { path in
                    let leftMountainWidth = size * 0.4
                    let leftMountainHeight = size * 0.35
                    let leftMountainX = size * 0.2
                    let leftMountainY = size * 0.6
                    
                    path.move(to: CGPoint(x: leftMountainX, y: leftMountainY))
                    path.addLine(to: CGPoint(x: leftMountainX + leftMountainWidth * 0.5, y: leftMountainY - leftMountainHeight))
                    path.addLine(to: CGPoint(x: leftMountainX + leftMountainWidth, y: leftMountainY))
                }
                .stroke(
                    isDarkMode ? Color.white : Color.black,
                    lineWidth: size * 0.06
                )
                
                // Right mountain (smaller)
                Path { path in
                    let rightMountainWidth = size * 0.25
                    let rightMountainHeight = size * 0.25
                    let rightMountainX = size * 0.55
                    let rightMountainY = size * 0.65
                    
                    path.move(to: CGPoint(x: rightMountainX, y: rightMountainY))
                    path.addLine(to: CGPoint(x: rightMountainX + rightMountainWidth * 0.5, y: rightMountainY - rightMountainHeight))
                    path.addLine(to: CGPoint(x: rightMountainX + rightMountainWidth, y: rightMountainY))
                }
                .stroke(
                    isDarkMode ? Color.white : Color.black,
                    lineWidth: size * 0.06
                )
            }
            
            // Sun
            Circle()
                .stroke(
                    isDarkMode ? Color.white : Color.black,
                    lineWidth: size * 0.06
                )
                .frame(width: size * 0.2, height: size * 0.2)
                .position(x: size * 0.75, y: size * 0.3)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            MenuBarIconView(size: 16, isDarkMode: false)
            MenuBarIconView(size: 16, isDarkMode: true)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        
        HStack(spacing: 20) {
            MenuBarIconView(size: 32, isDarkMode: false)
            MenuBarIconView(size: 32, isDarkMode: true)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
} 