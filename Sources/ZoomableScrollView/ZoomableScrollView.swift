import SwiftUI
import VisionSugar
import SwiftUISugar

public extension Notification.Name {
    public static var resetZoomableScrollViewScale: Notification.Name { return .init("resetZoomableScrollViewScale") }
    public static var scrollZoomableScrollViewToRect: Notification.Name { return .init("scrollZoomableScrollViewToRect") }
}

public extension Notification {
    public struct Keys {
        public static let rect = "rect"
        public static let boundingBox = "boundingBox"
        public static let imageSize = "imageSize"
    }
}

/// This identifies an area of the ZoomableScrollView to focus on
public struct FocusedArea {
    
    /// This is the boundingBox (in terms of a 0 to 1 ratio on each dimension of what the CGRect is (similar to the boundingBox in Vision)
    let boundingBox: CGRect
    
    let imageSize: CGSize
    //TODO: Add padding here
}

public struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    var focusedArea: Binding<FocusedArea>?
    
    private var content: Content
    
    public init(focusedArea: Binding<FocusedArea>? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.focusedArea = focusedArea
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
        
        if let focusedArea {
            uiView.focus(on: focusedArea.wrappedValue)
        }
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

