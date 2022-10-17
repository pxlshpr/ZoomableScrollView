import SwiftUI
import VisionSugar
import SwiftUISugar

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

public struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    
    var focusedBox: Binding<FocusedBox?>?
    @State var lastFocusedArea: FocusedBox? = nil
    @State var firstTime: Bool = true
    
    let backgroundColor: UIColor?
    private var content: Content
    
    public init(focusedBox: Binding<FocusedBox?>? = nil, backgroundColor: UIColor? = nil, @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.content = content()
        self.focusedBox = focusedBox
    }
    
    public func makeUIView(context: Context) -> UIScrollView {
        scrollView(context: context)
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    public func updateUIView(_ uiView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == uiView)
        
        if let focusedBox = focusedBox?.wrappedValue {
            
            /// If we've set it to `.zero` we're indicating that we want it to reset the zoom
            if focusedBox.boundingBox == .zero {
                uiView.setZoomScale(1, animated: true)
            } else {
                uiView.focus(on: focusedBox)
            }
            //            self.focusedBox?.wrappedValue = nil
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
        
        @objc func doubleTapped(recognizer:  UITapGestureRecognizer) {
            
        }
        
//        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
//            print("zoomScale is \(scrollView.zoomScale)")
//        }
    }
}
