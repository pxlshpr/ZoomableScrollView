import SwiftUI
import VisionSugar
import SwiftUISugar

public struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    
    var id: UUID
    var zoomBox: Binding<ZoomBox?>?
    let backgroundColor: UIColor?
    var content: Content

    public init(
        id: UUID = UUID(),
        zoomBox: Binding<ZoomBox?>? = nil,
        backgroundColor: UIColor? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.backgroundColor = backgroundColor
        self.content = content()
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
        return Coordinator(
            id: id,
            hostingController: UIHostingController(rootView: self.content)
        )
    }
    
    public func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == scrollView)
    }
    
    // MARK: - Coordinator
    public class Coordinator: NSObject, UIScrollViewDelegate {
        let id: UUID
        var hostingController: UIHostingController<Content>
        var scrollView: UIScrollView? = nil
        
        init(id: UUID, hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
            self.id = id
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(zoomZoomableScrollView), name: .zoomZoomableScrollView, object: nil)
        }
        
        @objc func zoomZoomableScrollView(notification: Notification) {
            guard let zoomBox = notification.userInfo?[Notification.ZoomableScrollViewKeys.zoomBox] as? ZoomBox,
                  let scrollView
            else { return }
            
            /// If an `id` was provided, make sure it matches
            if let zoomBoxImageId = zoomBox.imageId {
                guard zoomBoxImageId == id else {
                    /// `ZoomBox` was mean for another `ZoomableScrollView`
                    return
                }
            }
            
            if zoomBox.boundingBox == .zero {
                /// Only set the `zoomScale` to 1 if it's not already at 1
                guard scrollView.zoomScale != 1 else { return }
                scrollView.setZoomScale(1, animated: false)
            } else {
                scrollView.zoom(onTo: zoomBox)
            }
        }
        
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            self.scrollView = scrollView
            return hostingController.view
        }
    }
}

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
