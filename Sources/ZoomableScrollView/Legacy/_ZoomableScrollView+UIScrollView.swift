//
//import SwiftUI
//import VisionSugar
//import SwiftUISugar
//
//extension ZoomableScrollView {
//
//    func hostedView(context: Context) -> UIView {
//        let hostedView = context.coordinator.hostingController.view!
//        hostedView.translatesAutoresizingMaskIntoConstraints = true
//        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        return hostedView
//    }
//
//    func scrollView(context: Context) -> UIScrollView {
//        // set up the UIScrollView
//        let scrollView = UIScrollView()
//        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
//        scrollView.maximumZoomScale = 20
//        scrollView.minimumZoomScale = 1
//        scrollView.bouncesZoom = true
//
//        /// Changed this to `.always` after discovering that `.never` caused a slight vertical offset when displaying an image at zoom scale 1 on a full screen.
//        /// The potential repurcisions of these haven't been explored—so keep an eye on this, as it may break other uses.
////        scrollView.contentInsetAdjustmentBehavior = .never
//        scrollView.contentInsetAdjustmentBehavior = .always
//
//        let hosted = hostedView(context: context)
//        hosted.frame = scrollView.bounds
//        hosted.insetsLayoutMarginsFromSafeArea = false
//        if let backgroundColor {
//            hosted.backgroundColor = backgroundColor
//        }
//        scrollView.addSubview(hosted)
//
//        scrollView.setZoomScale(1, animated: true)
//
//        scrollView.addTapGestureRecognizer { recognizer in
//
//            /// 🛑 **WARNING** 🛑
//            /// This caused a retain cycle (`UIHostingController` ends up never getting released, causing a massive memory build up
//            /// due to the storage of an image here. We're using `nil` instead, which has the same effect.
//            /// 🚧 Remove this when cleasing this up.
////            let hostedView = hostedView(context: context)
////            let point = recognizer.location(in: hostedView)
//
//            let point = recognizer.location(in: nil)
//            handleDoubleTap(on: point, for: scrollView)
//        }
//
//        return scrollView
//    }
//
//    //TODO: Rewrite this
//    /// - Now also have a handler that can be provided to this, which overrides this default
//    ///     It should provide the current zoom scale and
//    ///     Get back an enum called ZoomPosition as a result
//    ///         This can be either fullScale, maxScale, or rect(let CGRect) where we provide a rect
//    ///         The scrollview than either zooms to full, max or the provided rect
//    /// - Now have TextPicker use this to
//    ///     See if the zoomScale is above or below the selected bound's scale
//    ///         This can be determined by dividing the rects dimensions by the image's and returning the larger? amount
//    ///     If it's greater than the selectedBoundZoomScale:
//    ///         If the selectedBoundZoomScale is less than the constant MaxScale of ZoomScrollView
//    ///         (by at least a minimum distance—also set by ZoomedScrollView)
//    ///             Then we return MaxScale as the ZoomPosition
//    ///         Else we return FullScale as the ZoomPosition (scale = 1)
//    ///     Else we return rect(selectedBound) as the ZoomPosition
//    func handleDoubleTap(on point: CGPoint, for scrollView: UIScrollView) {
//        let maxZoomScale = 3.5
//        let minDelta = 0.5
//        let minBoundingBoxScale = 1.3
//
//        if let zoomBox = zoomBox?.wrappedValue,
//           zoomBox.boundingBox != .zero
//        {
//            let boundingBoxScale = zoomScaleOfBoundingBox(zoomBox.boundingBox,
//                                                          forImageSize: zoomBox.imageSize,
//                                                          padded: zoomBox.padded,
//                                                          scrollView: scrollView)
//            if scrollView.zoomScale < boundingBoxScale {
//                if boundingBoxScale >= minBoundingBoxScale {
//                    scrollView.zoom(onTo: zoomBox)
//                } else {
//                    scrollView.zoomToScale(maxZoomScale, on: point)
//                }
//            } else {
//                scrollView.zoomToScale(1, on: point)
//            }
//        } else {
//            if scrollView.zoomScale < (maxZoomScale - minDelta) {
//                scrollView.zoomToScale(maxZoomScale, on: point)
//            } else {
//                scrollView.setZoomScale(1, animated: true)
//            }
//        }
//    }
//
////    func zoomRectForDoubleTap(on point: CGPoint, for scrollView: UIScrollView) -> CGRect {
////        return scrollView.zoomRect(forFactorChangeInZoomScaleOf: 5, on: point)
////    }
////
////    func zoomRectForDoubleTap_legacy(on point: CGPoint, for scrollView: UIScrollView) -> CGRect {
////        let sizeToBaseRectOn = scrollView.frame.size
////
////        let size = CGSize(width: sizeToBaseRectOn.width / 2,
////                          height: sizeToBaseRectOn.height / 2)
////        let zoomSize = CGSize(width: size.width / scrollView.zoomScale,
////                              height: size.height / scrollView.zoomScale)
////
////        let origin = CGPoint(x: point.x - zoomSize.width / 2,
////                             y: point.y - zoomSize.height / 2)
////        return CGRect(origin: origin, size: zoomSize)
////    }
//
//    func zoomScaleOfBoundingBox(_ boundingBox: CGRect, forImageSize imageSize: CGSize, padded: Bool, scrollView: UIScrollView) -> CGFloat {
//        let zoomRect = boundingBox.zoomRect(forImageSize: imageSize,
//                                            fittedInto: scrollView.frame.size,
//                                            padded: padded)
//        return zoomRect.zoomScale(within: scrollView.frame.size)
//    }
//
//    func zoomRectForScale(scale: CGFloat, center: CGPoint, scrollView: UIScrollView, context: Context) -> CGRect {
//        var zoomRect = CGRect.zero
//        zoomRect.size.height = hostedView(context: context).frame.size.height / scale
//        zoomRect.size.width  = hostedView(context: context).frame.size.width  / scale
//        let newCenter = scrollView.convert(center, from: hostedView(context: context))
//        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
//        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
//        return zoomRect
//    }
//
//    //    func userDoubleTappedScrollview(recognizer:  UITapGestureRecognizer) {
//    //        if (zoomScale > minimumZoomScale) {
//    //            setZoomScale(minimumZoomScale, animated: true)
//    //        }
//    //        else {
//    //            //(I divide by 3.0 since I don't wan't to zoom to the max upon the double tap)
//    //            let zoomRect = zoomRectForScale(scale: maximumZoomScale / 3.0, center: recognizer.location(in: recognizer.view))
//    //            zoom(to: zoomRect, animated: true)
//    //        }
//    //    }
//    //
//    //    func zoomRectForScale(scale : CGFloat, center : CGPoint) -> CGRect {
//    //        var zoomRect = CGRect.zero
//    //        if let imageV = self.viewForZooming {
//    //            zoomRect.size.height = imageV.frame.size.height / scale;
//    //            zoomRect.size.width  = imageV.frame.size.width  / scale;
//    //            let newCenter = imageV.convert(center, from: self)
//    //            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0));
//    //            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0));
//    //        }
//    //        return zoomRect;
//    //    }
//}
