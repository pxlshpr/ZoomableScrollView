//import SwiftUI
//import VisionSugar
//import SwiftUISugar
//
//public struct ZoomableScrollView<Content: View>: UIViewRepresentable {
//
//    var id: UUID
//    var zoomBox: Binding<ZoomBox?>?
//    let backgroundColor: UIColor?
//    var content: Content
//
//    public init(
//        id: UUID = UUID(),
//        zoomBox: Binding<ZoomBox?>? = nil,
//        backgroundColor: UIColor? = nil,
//        @ViewBuilder content: () -> Content
//    ) {
//        self.id = id
//        self.backgroundColor = backgroundColor
//        self.content = content()
//        self.zoomBox = zoomBox
//    }
//
//    public func makeUIView(context: Context) -> UIScrollView {
//        let scrollView = scrollView(context: context)
//        Task(priority: .high) {
//            await MainActor.run { scrollView.setZoomScale(1.01, animated: false) }
//            await MainActor.run { scrollView.setZoomScale(1, animated: false) }
//        }
//
//        return scrollView
//    }
//
//    public func makeCoordinator() -> Coordinator {
//        return Coordinator(
//            id: id,
//            hostingController: UIHostingController(rootView: self.content)
//        )
//    }
//
//    public func updateUIView(_ scrollView: UIScrollView, context: Context) {
//        context.coordinator.hostingController.rootView = self.content
//        assert(context.coordinator.hostingController.view.superview == scrollView)
//    }
//
//    // MARK: - Coordinator
//    public class Coordinator: NSObject, UIScrollViewDelegate {
//        let id: UUID
//        var hostingController: UIHostingController<Content>
//        var scrollView: UIScrollView? = nil
//
//        init(id: UUID, hostingController: UIHostingController<Content>) {
//            self.hostingController = hostingController
//            self.id = id
//            super.init()
//            NotificationCenter.default.addObserver(self, selector: #selector(zoomZoomableScrollView), name: .zoomZoomableScrollView, object: nil)
//        }
//
//        @objc func zoomZoomableScrollView(notification: Notification) {
//            guard let zoomBox = notification.userInfo?[Notification.ZoomableScrollViewKeys.zoomBox] as? ZoomBox,
//                  let scrollView
//            else { return }
//
//            /// If an `id` was provided, make sure it matches
//            if let zoomBoxImageId = zoomBox.imageId {
//                guard zoomBoxImageId == id else {
//                    /// `ZoomBox` was mean for another `ZoomableScrollView`
//                    return
//                }
//            }
//
//            if zoomBox.boundingBox == .zero {
//                /// Only set the `zoomScale` to 1 if it's not already at 1
//                guard scrollView.zoomScale != 1 else { return }
//                scrollView.setZoomScale(1, animated: false)
//            } else {
//                scrollView.zoom(onTo: zoomBox)
//            }
//        }
//
//        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//            self.scrollView = scrollView
//            return hostingController.view
//        }
//    }
//}
//
