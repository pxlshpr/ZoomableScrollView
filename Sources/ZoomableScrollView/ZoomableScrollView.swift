import SwiftUI
import Combine

public struct ZoomableScrollView<Content: View>: View {
    let content: Content
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    @State var doubleTap = PassthroughSubject<Void, Never>()
    
    public var body: some View {
        ZoomableScrollViewImpl(content: content, doubleTap: doubleTap.eraseToAnyPublisher())
        /// The double tap gesture is a modifier on a SwiftUI wrapper view, rather than just putting a UIGestureRecognizer on the wrapped view,
        /// because SwiftUI and UIKit gesture recognizers don't work together correctly correctly for failure and other interactions.
            .onTapGesture(count: 2) {
                doubleTap.send()
            }
    }
}

class CenteringScrollView: UIScrollView {
    var shouldCenter: Bool = true
    
    func centerContent() {
//        assert(subviews.count == 1)
//        mutate(&subviews[0].frame) {
//            // not clear why view.center.{x,y} = bounds.mid{X,Y} doesn't work -- maybe transform?
//            $0.origin.x = max(0, bounds.width - $0.width) / 2
//            $0.origin.y = max(0, bounds.height - $0.height) / 2
//        }
        guard subviews.count == 1 else { return }
        let size = subviews[0].frame.size
        let x = max(0, bounds.width - size.width) / 2
        let y = max(0, bounds.height - size.height) / 2
        let frame = CGRectMake(x, y, size.width, size.height)
//        print("🔩 centerContent: setting frame of subviews[0] to \(frame)")
        subviews[0].frame = frame
        
        contentOffset = CGPoint(x: 0, y: 0)
//        print("🔩     contentOffset: \(contentOffset)")
//        print("🔩     contentSize: \(contentSize)")
    }
    
    func centerCapture() {
        guard subviews.count == 1 else { return }
        let size = subviews[0].frame.size
//        let x = max(0, bounds.width - size.width) / 2
//        let y = max(0, bounds.height - size.height) / 2
//        let frame = CGRectMake(x, y, size.width, size.height)
//        print("🔩 centerContent: setting frame of subviews[0] to \(frame)")
//        subviews[0].frame = frame
        
        contentOffset = CGPoint(x: size.width / 4.0, y: 0)
//        print("🔩     contentOffset: \(contentOffset)")
//        print("🔩     contentSize: \(contentSize)")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        if shouldCenter {
//            centerContent()
//        }
        centerCapture()
    }
}

fileprivate struct ZoomableScrollViewImpl<Content: View>: UIViewControllerRepresentable {
    let content: Content
    let doubleTap: AnyPublisher<Void, Never>
    
    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController(coordinator: context.coordinator, doubleTap: doubleTap)
        Task(priority: .high) {
//            await MainActor.run {
//                viewController.scrollView.setZoomScale(1.01, animated: false)
//            }
//            await MainActor.run {
//                viewController.scrollView.setZoomScale(1, animated: false)
//            }
        }
        return viewController
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: UIHostingController(rootView: self.content))
    }
    
    func updateUIViewController(_ viewController: ViewController, context: Context) {
        viewController.update(content: self.content, doubleTap: doubleTap)
    }
    
    // MARK: - ViewController
    
    class ViewController: UIViewController, UIScrollViewDelegate {
        let coordinator: Coordinator
        let scrollView = CenteringScrollView()
        
        var doubleTapCancellable: Cancellable?
        var updateConstraintsCancellable: Cancellable?
        
        private var hostedView: UIView { coordinator.hostingController.view! }
        
        private var contentSizeConstraints: [NSLayoutConstraint] = [] {
            willSet { NSLayoutConstraint.deactivate(contentSizeConstraints) }
            didSet { NSLayoutConstraint.activate(contentSizeConstraints) }
        }
        
        required init?(coder: NSCoder) { fatalError() }
        init(coordinator: Coordinator, doubleTap: AnyPublisher<Void, Never>) {
            self.coordinator = coordinator
            super.init(nibName: nil, bundle: nil)
            self.view = scrollView
            
            scrollView.delegate = self  // for viewForZooming(in:)
//            scrollView.maximumZoomScale = 10
            scrollView.maximumZoomScale = 20
            scrollView.minimumZoomScale = 1
            scrollView.bouncesZoom = true
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false

            /// Changed this to `.always` after discovering that `.never` caused a slight vertical offset when displaying an image at zoom scale 1 on a full screen.
            /// The potential repurcisions of these haven't been explored—so keep an eye on this, as it may break other uses.
//            scrollView.contentInsetAdjustmentBehavior = .never
            //TODO: only use this if the image has a width-height ratio that's equal or tall (not for wide images)
            scrollView.contentInsetAdjustmentBehavior = .always

            let hostedView = coordinator.hostingController.view!
            hostedView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(hostedView)
//            hostedView.translatesAutoresizingMaskIntoConstraints = true
//            hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            hostedView.frame = scrollView.bounds
//            hostedView.insetsLayoutMarginsFromSafeArea = false
//            if let backgroundColor {
//            hostedView.backgroundColor = .black
//            }
            
//            scrollView.setZoomScale(2.01, animated: true)
//            scrollView.setZoomScale(1, animated: true)

            NSLayoutConstraint.activate([
                hostedView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                hostedView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                hostedView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                hostedView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            ])
            
            updateConstraintsCancellable = scrollView.publisher(for: \.bounds).map(\.size).removeDuplicates()
                .sink { [unowned self] size in
                    view.setNeedsUpdateConstraints()
                }
            doubleTapCancellable = doubleTap.sink { [unowned self] in handleDoubleTap() }
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(zoomZoomableScrollView),
                name: .zoomZoomableScrollView,
                object: nil
            )
        }
        
        func update(content: Content, doubleTap: AnyPublisher<Void, Never>) {
            coordinator.hostingController.rootView = content
            scrollView.setNeedsUpdateConstraints()
            doubleTapCancellable = doubleTap.sink { [unowned self] in handleDoubleTap() }
        }
        
        func handleDoubleTap() {
            scrollView.setZoomScale(scrollView.zoomScale >= 1 ? scrollView.minimumZoomScale : 1, animated: true)
        }
        
        override func updateViewConstraints() {
            super.updateViewConstraints()
            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
            contentSizeConstraints = [
                hostedView.widthAnchor.constraint(equalToConstant: hostedContentSize.width),
                hostedView.heightAnchor.constraint(equalToConstant: hostedContentSize.height),
            ]
        }
        
        override func viewDidAppear(_ animated: Bool) {
            scrollView.zoom(to: hostedView.bounds, animated: false)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            let hostedContentSize = coordinator.hostingController.sizeThatFits(in: view.bounds.size)
            scrollView.minimumZoomScale = min(
                scrollView.bounds.width / hostedContentSize.width,
                scrollView.bounds.height / hostedContentSize.height)
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            // For some reason this is needed in both didZoom and layoutSubviews, thanks to https://medium.com/@ssamadgh/designing-apps-with-scroll-views-part-i-8a7a44a5adf7
            // Sometimes this seems to work (view animates size and position simultaneously from current position to center) and sometimes it does not (position snaps to center immediately, size change animates)
            self.scrollView.centerContent()
        }
        
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            coordinator.animateAlongsideTransition { [self] context in
                scrollView.zoom(to: hostedView.bounds, animated: false)
            }
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostedView
        }
        
        @objc func zoomZoomableScrollView(notification: Notification) {
            guard let zoomBox = notification.userInfo?[Notification.ZoomableScrollViewKeys.zoomBox] as? ZoomBox
            else { return }

            /// If an `id` was provided, make sure it matches
            if let zoomBoxImageId = zoomBox.imageId {
//                guard zoomBoxImageId == id else {
//                    /// `ZoomBox` was mean for another `ZoomableScrollView`
//                    return
//                }
            }

            if zoomBox.boundingBox == .zero || zoomBox.boundingBox == CGRect(x: 0, y: 0, width: 1, height: 1) {
                /// Only set the `zoomScale` to 1 if it's not already at 1
                guard scrollView.zoomScale != 1 else { return }
                scrollView.setZoomScale(1, animated: false)
            } else {
                scrollView.zoom(onTo: zoomBox)
            }
        }
        
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
    }
}

extension UIViewControllerTransitionCoordinator {
    // Fix UIKit method that's named poorly for trailing closure style
    @discardableResult
    func animateAlongsideTransition(_ animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool {
        return animate(alongsideTransition: animation, completion: completion)
    }
}

/// Execute scoped modifications to `arg`.
///
/// Useful when multiple modifications need to be made to a single nested property. For example,
/// ```
/// view.frame.origin.x -= view.frame.width / 2
/// view.frame.origin.y -= view.frame.height / 2
/// ```
/// can be rewritten as
/// ```
/// mutate(&view.frame) {
///   $0.origin.x -= $0.width / 2
///   $0.origin.y -= $0.height / 2
/// }
/// ```
///
public func mutate<T>(_ arg: inout T, _ body: (inout T) -> Void) {
    body(&arg)
}
