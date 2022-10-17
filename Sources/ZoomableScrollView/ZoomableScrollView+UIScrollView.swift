import SwiftUI
import VisionSugar
import SwiftUISugar

extension ZoomableScrollView {
    
    func hostedView(context: Context) -> UIView {
        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return hostedView
    }
    
    func scrollView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
        scrollView.maximumZoomScale = 20
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        
        let hosted = hostedView(context: context)
        hosted.frame = scrollView.bounds
        if let backgroundColor {
            hosted.backgroundColor = backgroundColor
        }
        scrollView.addSubview(hosted)
        
        scrollView.setZoomScale(1, animated: true)
        
        scrollView.addTapGestureRecognizer { sender in
            
            //TODO: Rewrite this
            /// - Default should be to have a maximum scale, and
            ///     If we're less than that (and not super-close to it): zoom into it
            ///     Otherwise, if we're close to it, at it, or past it: zoom back out to full scale
            /// - Now also have a handler that can be provided to this, which overrides this default
            ///     It should provide the current zoom scale and
            ///     Get back an enum called ZoomPosition as a result
            ///         This can be either fullScale, maxScale, or rect(let CGRect) where we provide a rect
            ///         The scrollview than either zooms to full, max or the provided rect
            /// - Now have TextPicker use this to
            ///     See if the zoomScale is above or below the selected bound's scale
            ///         This can be determined by dividing the rects dimensions by the image's and returning the larger? amount
            ///     If it's greater than the selectedBoundZoomScale:
            ///         If the selectedBoundZoomScale is less than the constant MaxScale of ZoomScrollView
            ///         (by at least a minimum distance—also set by ZoomedScrollView)
            ///             Then we return MaxScale as the ZoomPosition
            ///         Else we return FullScale as the ZoomPosition (scale = 1)
            ///     Else we return rect(selectedBound) as the ZoomPosition
            
            let hostedView = hostedView(context: context)
            let point = sender.location(in: hostedView)
            let sizeToBaseRectOn = scrollView.frame.size
            //            let sizeToBaseRectOn = hostedView.frame.size
            
            let size = CGSize(width: sizeToBaseRectOn.width / 2,
                              height: sizeToBaseRectOn.height / 2)
            let zoomSize = CGSize(width: size.width / scrollView.zoomScale,
                                  height: size.height / scrollView.zoomScale)
            
            print("""
Got a tap at: \(point), when:
    hostedView.size: \(hostedView.frame.size)
    scrollView.size: \(scrollView.frame.size)
    scrollView.contentSize: \(scrollView.contentSize)
    scrollView.zoomScale: \(scrollView.zoomScale)
    size: \(size)
    🔍 zoomSize: \(zoomSize)
""")
            
            let origin = CGPoint(x: point.x - zoomSize.width / 2,
                                 y: point.y - zoomSize.height / 2)
            scrollView.zoom(to:CGRect(origin: origin, size: zoomSize), animated: true)
        }
        
        return scrollView
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint, scrollView: UIScrollView, context: Context) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = hostedView(context: context).frame.size.height / scale
        zoomRect.size.width  = hostedView(context: context).frame.size.width  / scale
        let newCenter = scrollView.convert(center, from: hostedView(context: context))
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
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
}
