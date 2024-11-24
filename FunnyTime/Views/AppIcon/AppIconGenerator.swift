import SwiftUI
import UIKit

struct AppIconGenerator {
    static func generateIcons() throws -> [URL] {
        let lightView = AppIconPreview(isDark: false)
        let darkView = AppIconPreview(isDark: true)
        
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = 1.0
        
        let lightImage = renderIcon(view: lightView, format: format)
        let darkImage = renderIcon(view: darkView, format: format)
        
        let fileManager = FileManager.default
        let desktopPath = try fileManager.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let exportPath = desktopPath.appendingPathComponent("FunnyTimeIcons", isDirectory: true)
        
        if fileManager.fileExists(atPath: exportPath.path) {
            try fileManager.removeItem(at: exportPath)
        }
        
        try fileManager.createDirectory(at: exportPath, withIntermediateDirectories: true)
        
        let lightPath = exportPath.appendingPathComponent("Light", isDirectory: true)
        let darkPath = exportPath.appendingPathComponent("Dark", isDirectory: true)
        
        try fileManager.createDirectory(at: lightPath, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: darkPath, withIntermediateDirectories: true)
        
        var generatedUrls: [URL] = []
        
        let sizes = [
            ("AppIcon-20@2x", CGSize(width: 40, height: 40)),
            ("AppIcon-20@3x", CGSize(width: 60, height: 60)),
            ("AppIcon-29@2x", CGSize(width: 58, height: 58)),
            ("AppIcon-29@3x", CGSize(width: 87, height: 87)),
            ("AppIcon-40@2x", CGSize(width: 80, height: 80)),
            ("AppIcon-40@3x", CGSize(width: 120, height: 120)),
            ("AppIcon-60@2x", CGSize(width: 120, height: 120)),
            ("AppIcon-60@3x", CGSize(width: 180, height: 180)),
            ("AppIcon-76", CGSize(width: 76, height: 76)),
            ("AppIcon-76@2x", CGSize(width: 152, height: 152)),
            ("AppIcon-83.5@2x", CGSize(width: 167, height: 167)),
            ("AppIcon-1024", CGSize(width: 1024, height: 1024))
        ]
        
        for (name, size) in sizes {
            let resizedLightImage = resizeIcon(image: lightImage, to: size)
            let resizedDarkImage = resizeIcon(image: darkImage, to: size)
            
            let lightUrl = lightPath.appendingPathComponent("\(name).png")
            let darkUrl = darkPath.appendingPathComponent("\(name).png")
            
            if let lightData = resizedLightImage.pngData() {
                try lightData.write(to: lightUrl)
                generatedUrls.append(lightUrl)
            }
            
            if let darkData = resizedDarkImage.pngData() {
                try darkData.write(to: darkUrl)
                generatedUrls.append(darkUrl)
            }
        }
        
        return generatedUrls
    }
    
    private static func renderIcon(view: AppIconPreview, format: UIGraphicsImageRendererFormat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024), format: format)
        return renderer.image { context in
            let hostingController = UIHostingController(rootView: view)
            hostingController.view.frame = CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))
            hostingController.view.backgroundColor = .clear
            hostingController.view.layoutIfNeeded()
            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
    }
    
    private static func resizeIcon(image: UIImage, to size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
} 