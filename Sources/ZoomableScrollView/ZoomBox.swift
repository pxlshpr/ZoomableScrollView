import Foundation

extension Notification.Name {
    public static var zoomZoomableScrollView: Notification.Name { return .init("zoomZoomableScrollView") }
    public static var zoomToFillZoomableScrollView: Notification.Name { return .init("zoomToFillZoomableScrollView") }
    public static var zoomToFitZoomableScrollView: Notification.Name { return .init("zoomToFitZoomableScrollView") }
    public static var zoomableScrollViewDidEndZooming: Notification.Name { return .init("zoomableScrollViewDidEndZooming") }
}

extension Notification {
    public struct ZoomableScrollViewKeys {
        public static let zoomBox = "zoomBox"
        public static let imageSize = "imageSize"
        public static let contentOffset = "contentOffset"
        public static let contentSize = "contentSize"
    }
}

/// This identifies an area of the ZoomableScrollView to focus on
public struct ZoomBox {
    
    /// This is the boundingBox—in terms of a 0 to 1 ratio on each dimension of what the CGRect is (similar to the boundingBox in Vision, with the y-axis starting from the bottom)
    public let boundingBox: CGRect
    public let padded: Bool
    public let animated: Bool
    public let imageSize: CGSize
    public let imageId: UUID?
    
    public init(boundingBox: CGRect, animated: Bool = true, padded: Bool = true, imageSize: CGSize, imageId: UUID? = nil) {
        self.boundingBox = boundingBox
        self.padded = padded
        self.animated = animated
        self.imageSize = imageSize
        self.imageId = imageId
    }
    
//    public static let none = Self.init(boundingBox: .zero, imageSize: .zero, imageId: UUID())
}
