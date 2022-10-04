import SwiftUI
import VisionSugar
import SwiftUISugar

public class ZoomableUIScrollView: UIView {
    
    let delegate: UIScrollViewDelegate
    let hostedView: UIView
    
    required init(delegate: UIScrollViewDelegate, hostedView: UIView) {
        self.delegate = delegate
        self.hostedView = hostedView
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        hostedView.frame = scrollView.bounds
        scrollView.addSubview(hostedView)
        scrollView.setZoomScale(1, animated: true)
        addSubview(scrollView)
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = delegate
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        return scrollView
    }()
}
extension ZoomableScrollView {

//    func scrollView(context: Context) -> ZoomableUIScrollView {
//        ZoomableUIScrollView(
//            delegate: context.coordinator,
//            hostedView: hostedView(context: context)
//        )
//    }
    
    func hostedView(context: Context) -> UIView {
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        hostedView.frame = scrollView.bounds
//        hostedView.backgroundColor = UIColor.systemGroupedBackground
        return hostedView
    }
    
    func scrollView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true

        // create a UIHostingController to hold our SwiftUI content
//        let hostedView = context.coordinator.hostingController.view!
//        hostedView.translatesAutoresizingMaskIntoConstraints = true
//        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        hostedView.frame = scrollView.bounds
//        hostedView.backgroundColor = UIColor.systemGroupedBackground
        let hosted = hostedView(context: context)
        hosted.frame = scrollView.bounds
        scrollView.addSubview(hosted)

        scrollView.setZoomScale(1, animated: true)

        NotificationCenter.default.addObserver(forName: .resetZoomableScrollViewScale, object: nil, queue: .main) { notification in
            scrollView.setZoomScale(1, animated: true)
        }

        NotificationCenter.default.addObserver(forName: .scrollZoomableScrollViewToRect, object: nil, queue: .main) { notification in
            guard let boundingBox = notification.userInfo?[Notification.Keys.boundingBox] as? CGRect,
                  let imageSize = notification.userInfo?[Notification.Keys.imageSize] as? CGSize
            else {
                return
            }
            scrollView.zoomIn(boundingBox: boundingBox, imageSize: imageSize)
        }

        return scrollView
    }
}
