import Foundation
import UIKit
import ImageIO

@MainActor
enum ILImageStorageService {
    private static let folderName = "IsFishingImages"
    private static let legacyFolderName = "IceLedgerImages"

    private static var supportRoot: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }

    private static func subdirectory(_ name: String) -> URL {
        supportRoot.appendingPathComponent(folderName, isDirectory: true).appendingPathComponent(name, isDirectory: true)
    }

    static func ensureDirectories() {
        let fm = FileManager.default
        let root = supportRoot.appendingPathComponent(folderName, isDirectory: true)
        let legacyRoot = supportRoot.appendingPathComponent(legacyFolderName, isDirectory: true)
        if !fm.fileExists(atPath: root.path), fm.fileExists(atPath: legacyRoot.path) {
            try? fm.moveItem(at: legacyRoot, to: root)
        }
        try? fm.createDirectory(at: root, withIntermediateDirectories: true)
        for sub in ["avatar", "spots", "sessions", "notes"] {
            try? fm.createDirectory(at: subdirectory(sub), withIntermediateDirectories: true)
        }
    }

    static func saveJPEG(_ image: UIImage, subfolder: String, id: UUID = UUID()) throws -> String {
        ensureDirectories()
        let resized = resizeIfNeeded(image, maxSide: 2048)
        guard let data = resized.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ILImage", code: 1)
        }
        let name = id.uuidString
        let url = subdirectory(subfolder).appendingPathComponent("\(name).jpg")
        try data.write(to: url, options: .atomic)
        return name
    }

    static func url(for id: String, subfolder: String) -> URL {
        subdirectory(subfolder).appendingPathComponent("\(id).jpg")
    }

    static func removeFile(id: String, subfolder: String) {
        let u = url(for: id, subfolder: subfolder)
        try? FileManager.default.removeItem(at: u)
    }

    static func removeAll(in subfolder: String) {
        let dir = subdirectory(subfolder)
        guard let items = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { return }
        for u in items {
            try? FileManager.default.removeItem(at: u)
        }
    }

    static func loadImage(id: String, subfolder: String) -> UIImage? {
        let u = url(for: id, subfolder: subfolder)
        return UIImage(contentsOfFile: u.path)
    }

    private static func resizeIfNeeded(_ image: UIImage, maxSide: CGFloat) -> UIImage {
        let maxDimension = max(image.size.width, image.size.height)
        guard maxDimension > maxSide else { return image }
        let scale = maxSide / maxDimension
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    static func gpsCoordinate(from imageData: Data) -> (lat: Double, lon: Double)? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let gps = props[kCGImagePropertyGPSDictionary as String] as? [String: Any],
              let lat = gps[kCGImagePropertyGPSLatitude as String] as? Double,
              let lon = gps[kCGImagePropertyGPSLongitude as String] as? Double
        else { return nil }
        let latRef = gps[kCGImagePropertyGPSLatitudeRef as String] as? String
        let lonRef = gps[kCGImagePropertyGPSLongitudeRef as String] as? String
        var la = lat
        var lo = lon
        if latRef == "S" { la = -la }
        if lonRef == "W" { lo = -lo }
        return (la, lo)
    }
}
