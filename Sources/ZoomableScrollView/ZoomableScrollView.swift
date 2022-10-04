import SwiftUI
import VisionSugar
import SwiftUISugar

extension Notification.Name {
    static var resetZoomableScrollViewScale: Notification.Name { return .init("resetZoomableScrollViewScale") }
    static var scrollZoomableScrollViewToRect: Notification.Name { return .init("scrollZoomableScrollViewToRect") }
}

extension Notification {
    struct Keys {
        static let rect = "rect"
        static let boundingBox = "boundingBox"
        static let imageSize = "imageSize"
    }
}

public struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    private var content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public func makeUIView(context: Context) -> UIScrollView {
        scrollView(context: context)
    }
    
//    func userDoubleTappedScrollview(recognizer:  UITapGestureRecognizer) {
//        if (zoomScale > minimumZoomScale) {
//            setZoomScale(minimumZoomScale, animated: true)
//        }
//        else {
//            //(I divide by 3.0 since I don't wan't to zoom to the max upon the double tap)
//            let zoomRect = zoomRectForScale(scale: maximumZoomScale / 3.0, center: recognizer.location(in: recognizer.view))
//            zoom(to: zoomRect, animated: true)
//        }
//    }
//
//    func zoomRectForScale(scale : CGFloat, center : CGPoint) -> CGRect {
//        var zoomRect = CGRect.zero
//        if let imageV = self.viewForZooming {
//            zoomRect.size.height = imageV.frame.size.height / scale;
//            zoomRect.size.width  = imageV.frame.size.width  / scale;
//            let newCenter = imageV.convert(center, from: self)
//            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0));
//            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0));
//        }
//        return zoomRect;
//    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    public func updateUIView(_ uiView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
    }
    
    // MARK: - Coordinator
    public class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
        
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
    }
}

