import Foundation

extension Notification.Name {
    public static var zoomZoomableScrollView: Notification.Name { return .init("zoomZoomableScrollView") }
}

extension Notification {
    public struct ZoomableScrollViewKeys {
        public static let zoomBox = "zoomBox"
    }
}

/// This identifies an area of the ZoomableScrollView to focus on
public struct ZoomBox {
    
    /// This is the boundingBox—in terms of a 0 to 1 ratio on each dimension of what the CGRect is (similar to the boundingBox in Vision, with the y-axis starting from the bottom)
    let boundingBox: CGRect
    let padded: Bool
    let animated: Bool
    let imageSize: CGSize
    let imageId: UUID?
    
    public init(boundingBox: CGRect, animated: Bool = true, padded: Bool = true, imageSize: CGSize, imageId: UUID? = nil) {
        self.boundingBox = boundingBox
        self.padded = padded
        self.animated = animated
        self.imageSize = imageSize
        self.imageId = imageId
    }
    
//    public static let none = Self.init(boundingBox: .zero, imageSize: .zero, imageId: UUID())
}

