//import SwiftUI
//import Combine
//
//public struct ZoomableScrollView<Content: View>: View {
//    let content: Content
//    public init(@ViewBuilder content: () -> Content) {
//        self.content = content()
//    }
//    
//    @State var doubleTap = PassthroughSubject<Void, Never>()
//    
//    public var body: some View {
//        ZoomableScrollViewImpl(content: content, doubleTap: doubleTap.eraseToAnyPublisher())
//        /// The double tap gesture is a modifier on a SwiftUI wrapper view, rather than just putting a UIGestureRecognizer on the wrapped view,
//        /// because SwiftUI and UIKit gesture recognizers don't work together correctly correctly for failure and other interactions.
//            .onTapGesture(count: 2) {
//                doubleTap.send()
//            }
//    }
//}
//
//enum RelativeAspectRatioType {
//    case taller
//    case wider
//    case equal
//}
//
//class CenteringScrollView: UIScrollView {
//    
//    var shouldCenterCapture: Bool = false
//    var shouldCenterToFit: Bool = true
//    var relativeAspectRatioType: RelativeAspectRatioType? = nil
//    var isAtDefaultScale = true
//    var zoomRect: CGRect = .zero
//    
//    var shouldPositionContent = true
//    
//    func positionContent() {
//        guard !isDragging,
//              shouldPositionContent,
//              subviews.count == 1
//        else {
//            print("🔩     contentOffset: \(contentOffset), zoomScale: \(zoomScale)")
//            return
//        }
//        
//        let screenSize = bounds.size
//        let scaledImageSize = subviews[0].frame.size
//        
//        let contentOffset: CGPoint
//        if scaledImageSize.isWider(than: screenSize) {
//
//            let y: CGFloat
//            if zoomRect == .zero || scaledImageSize.height < screenSize.height  {
//                /// If we're not zooming into a rect, (or the rect is shorter than the screen's height), center it vertically
//                /// (it's negative since we want to move the offset upwards—and show the black bars above and below it)
//                y = -(screenSize.height - scaledImageSize.height) / 2
//            } else {
//                /// Otherwise leave it alone
//                y = self.contentOffset.y
//            }
//            
//            /// Get the (scaled) x position of the zoom rect.
//            let widthRatio =  scaledImageSize.width / screenSize.width
//            let x = zoomRect.origin.x * widthRatio
//
//            contentOffset = CGPoint(x: x, y: y)
//            
//        } else if scaledImageSize.isTaller(than: screenSize) {
//            
//            let x: CGFloat
//            if zoomRect == .zero || scaledImageSize.width < screenSize.width  {
//                /// If we're not zooming into a rect, (or the rect is narrower than the screen's width), center it horizontally
//                /// (it's negative since we want to move the offset leftwards—and show the black bars to the sides of it)
//                x = -(screenSize.width - scaledImageSize.width) / 2
//            } else {
//                /// Otherwise leave it alone
//                x = self.contentOffset.x
//            }
//            
//            /// Get the (scaled) y position of the zoom rect
//            let heightRatio =  scaledImageSize.height / screenSize.height
//            let y = zoomRect.origin.y * heightRatio
//
//            contentOffset = CGPoint(x: x, y: y)
//            
//        } else {
//            /// same aspect ratio's, so no offset necessary to center
//            contentOffset = self.contentOffset
//        }
//        
////        withAnimation(.interactiveSpring()) {
//            self.setContentOffset(contentOffset, animated: false)
////        }
//        
//        print("🔩     contentOffset: \(contentOffset), zoomScale: \(zoomScale)")
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        positionContent()
//    }
//    
//    func zoomToFill(_ imageSize: CGSize) {
//        print("🍉 Zoom to fill \(imageSize)")
//        let boundingBox = UIScreen.main.bounds.size.boundingBoxToFill(imageSize)
//
//        if boundingBox == .zero || boundingBox == CGRect(x: 0, y: 0, width: 1, height: 1) {
//            /// Only set the `zoomScale` to 1 if it's not already at 1
//            guard zoomScale != 1 else { return }
//            setZoomScale(1, animated: false)
//        } else {
//            shouldCenterCapture = true
//            let zoomRect = boundingBox.zoomRect(
//                forImageSize: imageSize,
//                fittedInto: bounds.size,
//                padded: false
//            )
//            zoom(to: zoomRect, animated: true)
////            setContentOffset(CGPoint(x: calculatedX, y: 0), animated: true)
//        }
//        
////        shouldCenterCapture = true
//    }
//    
//    func zoomToFit(_ imageSize: CGSize) {
//        print("Zoom to fit")
//    }
//    
//    func zoomTo(_ zoomBox: ZoomBox) {
//        /// If an `id` was provided, make sure it matches
////        if let zoomBoxImageId = zoomBox.imageId {
////                guard zoomBoxImageId == id else {
////                    /// `ZoomBox` was mean for another `ZoomableScrollView`
////                    return
////                }
////        }
//        shouldPositionContent = true
//        zoomRect = .zero
//
//        if zoomBox.boundingBox == .zero || zoomBox.boundingBox == CGRect(x: 0, y: 0, width: 1, height: 1) {
//            guard zoomScale != 1 else { return }
////            guard !isAtDefaultScale else { return }
//            relativeAspectRatioType = nil
//            shouldCenterToFit = true
//            setZoomScale(1, animated: zoomBox.animated)
//        } else {
//            relativeAspectRatioType = bounds.size.relativeAspectRatio(of: zoomBox.imageSize)
////            relativeAspectRatioType = zoomBox.boundingBox.size.relativeAspectRatio(of: bounds.size)
//            shouldCenterToFit = false
//            
//            
////            zoom(onTo: zoomBox)
//            var zoomRect = zoomBox.boundingBox.zoomRect(forImageSize: zoomBox.imageSize, fittedInto: frame.size, padded: false)
//            zoomRect = CGRect(
//                x: zoomRect.origin.x,
//                y: zoomRect.origin.y,
//                width: zoomRect.size.width,
//                height: zoomRect.size.height
//            )
//
//            /// Do this only if ZoomBox has the option (have option for both top and bottom safeAreaPoints
//            zoomRect = paddedForUI(zoomRect)
//            
//            self.zoomRect = zoomRect
//            zoom(to: zoomRect, animated: zoomBox.animated)
//        }
//        
////        isAtDefaultScale = false
//    }
//    
//    func paddedForUI(_ zoomRect: CGRect) -> CGRect {
////        let bottomUIMinY =
////        let isObstructed = zoomRect.height >
//        return zoomRect
//    }
//}
//
//import SwiftSugar
//
//extension CGFloat {
//    func rounded(toPlaces places: Int) -> CGFloat {
//        Double(self).rounded(toPlaces: places)
//    }
//}
//
//extension CGSize {
//    
//    func isWider(than other: CGSize) -> Bool {
//        widthToHeightRatio > other.widthToHeightRatio
//    }
//    
//    func isTaller(than other: CGSize) -> Bool {
//        widthToHeightRatio < other.widthToHeightRatio
//    }
//    
//    func relativeAspectRatio(of other: CGSize) -> RelativeAspectRatioType {
//        let ratio = widthToHeightRatio.rounded(toPlaces: 2)
//        let otherRatio = other.widthToHeightRatio.rounded(toPlaces: 2)
////        let ratio = widthToHeightRatio
////        let otherRatio = other.widthToHeightRatio
//        if otherRatio > ratio {
//            return .wider
//        } else if otherRatio < ratio {
//            return .taller
//        } else {
//            return .equal
//        }
//    }
//}
//
//func relativeAspectRatio(of size: CGSize, to other: CGSize) -> RelativeAspectRatioType {
//    let ratio = size.widthToHeightRatio.rounded(toPlaces: 2)
//    let otherRatio = other.widthToHeightRatio.rounded(toPlaces: 2)
////        let ratio = widthToHeightRatio
////        let otherRatio = other.widthToHeightRatio
//    if otherRatio > ratio {
//        return .wider
//    } else if otherRatio < ratio {
//        return .taller
//    } else {
//        return .equal
//    }
//}
//
//extension CGSize {
//    func boundingBoxToFill(_ size: CGSize) -> CGRect {
//        let scaledWidth: CGFloat = (size.width * self.height) / size.height
//
//        let x: CGFloat = ((scaledWidth - self.width) / 2.0)
//        let h: CGFloat = size.height
//        
//        let rect = CGRect(
//            x: x / scaledWidth,
//            y: 0,
//            width: (self.width / scaledWidth),
//            height: h / size.height
//        )
//
//        print("🧮 scaledWidth: \(scaledWidth)")
//        print("🧮 bounds size: \(self)")
//        print("🧮 imageSize: \(size)")
//        print("🧮 rect: \(rect)")
//        return rect
//    }
//
//}
//
//
//fileprivate struct ZoomableScrollViewImpl<Content: View>: UIViewControllerRepresentable {
//    let content: Content
//    let doubleTap: AnyPublisher<Void, Never>
//    
//    func makeUIViewController(context: Context) -> ViewController {
//        let viewController = ViewController(coordinator: context.coordinator, doubleTap: doubleTap)
//        Task(priority: .high) {
////            await MainActor.run {
////                viewController.scrollView.setZoomScale(1.01, animated: false)
////            }
////            await MainActor.run {
////                viewController.scrollView.setZoomScale(1, animated: false)
////            }
//        }
//        return viewController
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(hostingController: UIHostingController(rootView: self.content))
//    }
//    
//    func updateUIViewController(_ viewController: ViewController, context: Context) {
//        viewController.update(content: self.content, doubleTap: doubleTap)
//    }
//    
//    // MARK: - ViewController
//    
//    class ViewController: UIViewController, UIScrollViewDelegate {
//        let coordinator: Coordinator
//        let scrollView = CenteringScrollView()
//        
//        var doubleTapCancellable: Cancellable?
//        var updateConstraintsCancellable: Cancellable?
//        
//        private var hostedView: UIView { coordinator.hostingController.view! }
//        
//        private var contentSizeConstraints: [NSLayoutConstraint] = [] {
//            willSet { NSLayoutConstraint.deactivate(contentSizeConstraints) }
//            didSet { NSLayoutConstraint.activate(contentSizeConstraints) }
//        }
//        
//        required init?(coder: NSCoder) { fatalError() }
//        init(coordinator: Coordinator, doubleTap: AnyPublisher<Void, Never>) {
//            self.coordinator = coordinator
//            super.init(nibName: nil, bundle: nil)
//            self.view = scrollView
//            
//            scrollView.delegate = self  // for viewForZooming(in:)
////            scrollView.maximumZoomScale = 10
//            scrollView.maximumZoomScale = 20
//            scrollView.minimumZoomScale = 1
//            scrollView.bouncesZoom = true
//            scrollView.showsHorizontalScrollIndicator = false
//            scrollView.showsVerticalScrollIndicator = false
//
//            /// Changed this to `.always` after discovering that `.never` caused a slight vertical offset when displaying an image at zoom scale 1 on a full screen.
//            /// The potential repurcisions of these haven't been explored—so keep an eye on this, as it may break other uses.
////            scrollView.contentInsetAdjustmentBehavior = .never
//            //TODO: only use this if the image has a width-height ratio that's equal or tall (not for wide images)
//            scrollView.contentInsetAdjustmentBehavior = .always
//
//            let hostedView = coordinator.hostingController.view!
//            hostedView.translatesAutoresizingMaskIntoConstraints = false
//            scrollView.addSubview(hostedView)
////            hostedView.translatesAutoresizingMaskIntoConstraints = true
////            hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////            hostedView.frame = scrollView.bounds
////            hostedView.insetsLayoutMarginsFromSafeArea = false
////            if let backgroundColor {
////            hostedView.backgroundColor = .black
////            }
//            
////            scrollView.setZoomScale(2.01, animated: true)
////            scrollView.setZoomScale(1, animated: true)
//
//            NSLayoutConstraint.activate([
//                hostedView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
//                hostedView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
//                hostedView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
//                hostedView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
//            ])
//            
//            updateConstraintsCancellable = scrollView.publisher(for: \.bounds).map(\.size).removeDuplicates()
//                .sink { [unowned self] size in
//                    view.setNeedsUpdateConstraints()
//                }
//            doubleTapCancellable = doubleTap.sink { [unowned self] in handleDoubleTap() }
//            
//            NotificationCenter.default.addObserver(
//                self, selector: #selector(zoomZoomableScrollView),
//                name: .zoomZoomableScrollView, object: nil
//            )
//            
//            NotificationCenter.default.addObserver(
//                self, selector: #selector(zoomToFitZoomableScrollView),
//                name: .zoomToFitZoomableScrollView, object: nil
//            )
//
//            NotificationCenter.default.addObserver(
//                self, selector: #selector(zoomToFillZoomableScrollView),
//                name: .zoomToFillZoomableScrollView, object: nil
//            )
//        }
//        
//        @objc func zoomToFitZoomableScrollView(notification: Notification) {
//            guard let imageSize = notification.userInfo?[Notification.ZoomableScrollViewKeys.imageSize] as? CGSize
//            else { return }
//            scrollView.zoomToFit(imageSize)
//        }
//
//        @objc func zoomToFillZoomableScrollView(notification: Notification) {
//            guard let imageSize = notification.userInfo?[Notification.ZoomableScrollViewKeys.imageSize] as? CGSize
//            else { return }
//            scrollView.zoomToFill(imageSize)
//        }
//
//        func update(content: Content, doubleTap: AnyPublisher<Void, Never>) {
//            coordinator.hostingController.rootView = content
//            scrollView.setNeedsUpdateConstraints()
//            doubleTapCancellable = doubleTap.sink { [unowned self] in handleDoubleTap() }
//        }
//        
//        func handleDoubleTap() {
//            scrollView.setZoomScale(scrollView.zoomScale >= 1 ? scrollView.minimumZoomScale : 1, animated: true)
//        }
//        
//        override func updateViewConstraints() {
//            super.updateViewConstraints()
//            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
//            contentSizeConstraints = [
//                hostedView.widthAnchor.constraint(equalToConstant: hostedContentSize.width),
//                hostedView.heightAnchor.constraint(equalToConstant: hostedContentSize.height),
//            ]
//        }
//        
//        override func viewDidAppear(_ animated: Bool) {
//            scrollView.zoom(to: hostedView.bounds, animated: false)
//        }
//        
//        override func viewDidLayoutSubviews() {
//            super.viewDidLayoutSubviews()
//            
//            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
//            scrollView.minimumZoomScale = min(
//                scrollView.bounds.width / hostedContentSize.width,
//                scrollView.bounds.height / hostedContentSize.height)
//        }
//        
//        func scrollViewDidZoom(_ scrollView: UIScrollView) {
//            // For some reason this is needed in both didZoom and layoutSubviews, thanks to https://medium.com/@ssamadgh/designing-apps-with-scroll-views-part-i-8a7a44a5adf7
//            // Sometimes this seems to work (view animates size and position simultaneously from current position to center) and sometimes it does not (position snaps to center immediately, size change animates)
//            self.scrollView.positionContent()
//        }
//        
//        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//            coordinator.animateAlongsideTransition { [self] context in
//                scrollView.zoom(to: hostedView.bounds, animated: false)
//            }
//        }
//        
//        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//            return hostedView
//        }
//        
//        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//            self.scrollView.shouldPositionContent = false
//        }
//        
//        @objc func zoomZoomableScrollView(notification: Notification) {
//            guard let zoomBox = notification.userInfo?[Notification.ZoomableScrollViewKeys.zoomBox] as? ZoomBox
//            else { return }
//            scrollView.zoomTo(zoomBox)
//        }
//        
//    }
//    
//    // MARK: - Coordinator
//    
//    class Coordinator: NSObject, UIScrollViewDelegate {
//        var hostingController: UIHostingController<Content>
//        
//        init(hostingController: UIHostingController<Content>) {
//            self.hostingController = hostingController
//        }
//    }
//}
//
//
//extension UIViewControllerTransitionCoordinator {
//    // Fix UIKit method that's named poorly for trailing closure style
//    @discardableResult
//    func animateAlongsideTransition(_ animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool {
//        return animate(alongsideTransition: animation, completion: completion)
//    }
//}
//
///// Execute scoped modifications to `arg`.
/////
///// Useful when multiple modifications need to be made to a single nested property. For example,
///// ```
///// view.frame.origin.x -= view.frame.width / 2
///// view.frame.origin.y -= view.frame.height / 2
///// ```
///// can be rewritten as
///// ```
///// mutate(&view.frame) {
/////   $0.origin.x -= $0.width / 2
/////   $0.origin.y -= $0.height / 2
///// }
///// ```
/////
//public func mutate<T>(_ arg: inout T, _ body: (inout T) -> Void) {
//    body(&arg)
//}
//
///// This identifies an area of the ZoomableScrollView to focus on
//public struct ZoomBox {
//    
//    /// This is the boundingBox—in terms of a 0 to 1 ratio on each dimension of what the CGRect is (similar to the boundingBox in Vision, with the y-axis starting from the bottom)
//    public let boundingBox: CGRect
//    public let padded: Bool
//    public let animated: Bool
//    public let imageSize: CGSize
//    public let imageId: UUID?
//    
//    public init(boundingBox: CGRect, animated: Bool = true, padded: Bool = true, imageSize: CGSize, imageId: UUID? = nil) {
//        self.boundingBox = boundingBox
//        self.padded = padded
//        self.animated = animated
//        self.imageSize = imageSize
//        self.imageId = imageId
//    }
//    
////    public static let none = Self.init(boundingBox: .zero, imageSize: .zero, imageId: UUID())
//}
