import SwiftUI
import VisionSugar
import SwiftUISugar

public struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    
    @State var lastFocusedArea: FocusedBox? = nil
    @State var firstTime: Bool = true
    
    let backgroundColor: UIColor?
    private var content: Content
    
//    var focusedBox: Binding<FocusedBox?>?
    var zoomBox: Binding<FocusedBox?>?

    public init(
//        focusedBox: Binding<FocusedBox?>? = nil,
        zoomBox: Binding<FocusedBox?>? = nil,
        backgroundColor: UIColor? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.content = content()
//        self.focusedBox = focusedBox
        self.zoomBox = zoomBox
    }
    
    public func makeUIView(context: Context) -> UIScrollView {
        let scrollView = scrollView(context: context)
        Task(priority: .high) {
            await MainActor.run { scrollView.setZoomScale(1.01, animated: false) }
            await MainActor.run { scrollView.setZoomScale(1, animated: false) }
        }
        
        return scrollView
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    public func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == scrollView)
        
//        Task(priority: .high) {
//            await MainActor.run { scrollView.setZoomScale(1.01, animated: false) }
//            await MainActor.run { scrollView.setZoomScale(1, animated: false) }
//
//            await MainActor.run {
//                guard let focusedBox = focusedBox?.wrappedValue else {
//                    return
//                }
//                if focusedBox.boundingBox == .zero, scrollView.zoomScale != 1 {
//                    scrollView.setZoomScale(1, animated: false)
//                } else {
//                    scrollView.focus(on: focusedBox)
//                }
//            }
//        }
        
//        if let focusedBox = focusedBox?.wrappedValue {
//
//            /// If we've set it to `.zero` we're indicating that we want it to reset the zoom
//            if focusedBox.boundingBox == .zero {
//                uiView.setZoomScale(1, animated: true)
//            } else {
//                uiView.focus(on: focusedBox)
//            }
//            //            self.focusedBox?.wrappedValue = nil
//        }
    }
    
    // MARK: - Coordinator
    public class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        var scrollView: UIScrollView? = nil
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(focusZoomableScrollView), name: .focusZoomableScrollView, object: nil)
        }
        
        @objc func focusZoomableScrollView(notification: Notification) {
            guard let focusedBox = notification.userInfo?[Notification.ZoomableScrollViewKeys.focusedBox] as? FocusedBox,
                  let scrollView
            else {
                return
            }
            
            if focusedBox.boundingBox == .zero, scrollView.zoomScale != 1 {
                scrollView.setZoomScale(1, animated: false)
            } else {
                scrollView.focus(on: focusedBox)
            }
        }
        
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            self.scrollView = scrollView
            return hostingController.view
        }
    }
}

extension Notification.Name {
    public static var focusZoomableScrollView: Notification.Name { return .init("focusZoomableScrollView") }
}

extension Notification {
    public struct ZoomableScrollViewKeys {
        public static let focusedBox = "focusedBox"
    }
}

/// This identifies an area of the ZoomableScrollView to focus on
public struct FocusedBox {
    
    /// This is the boundingBox (in terms of a 0 to 1 ratio on each dimension of what the CGRect is (similar to the boundingBox in Vision)
    let boundingBox: CGRect
    let padded: Bool
    let animated: Bool
    let imageSize: CGSize
    
    public init(boundingBox: CGRect, animated: Bool = true, padded: Bool = true, imageSize: CGSize) {
        self.boundingBox = boundingBox
        self.padded = padded
        self.animated = animated
        self.imageSize = imageSize
    }
    
    public static let none = Self.init(boundingBox: .zero, imageSize: .zero)
}
