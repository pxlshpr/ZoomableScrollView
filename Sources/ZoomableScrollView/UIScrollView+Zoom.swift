import UIKit

extension UIScrollView {
    
    func zoomToScale(_ newZoomScale: CGFloat, on point: CGPoint) {
        let scaleChange = newZoomScale / zoomScale
        let rect = zoomRect(forFactorChangeInZoomScaleOf: scaleChange, on: point)
        zoom(to: rect, animated: true)
    }
    
    func zoomRect(forFactorChangeInZoomScaleOf factor: CGFloat, on point: CGPoint) -> CGRect {
        let size = CGSize(width: frame.size.width / factor,
                          height: frame.size.height / factor)
        let zoomSize = CGSize(width: size.width / zoomScale,
                              height: size.height / zoomScale)
        
        let origin = CGPoint(x: point.x - (zoomSize.width / factor),
                             y: point.y - (zoomSize.height / factor))
        return CGRect(origin: origin, size: zoomSize)
    }
    func focus(on focusedBox: FocusedBox, animated: Bool = true) {
        zoomIn(
            boundingBox: focusedBox.boundingBox,
            padded: focusedBox.padded,
            imageSize: focusedBox.imageSize,
            animated: focusedBox.animated
        )
    }
    
    func zoomIn(boundingBox: CGRect, padded: Bool, imageSize: CGSize, animated: Bool = true) {
        
        let zoomRect = boundingBox.zoomRect(forImageSize: imageSize, fittedInto: frame.size, padded: padded)
//        var zoomRect = boundingBox.rectForSize(imageSize, fittedInto: frame.size)
//        if padded {
//            let ratio = min(frame.size.width / (zoomRect.size.width * 5), 3.5)
//            zoomRect.pad(within: frame.size, ratio: ratio)
//        }
        
        print("🔍 zoomIn on: \(zoomRect) within \(frame.size)")
        let zoomScaleX = frame.size.width / zoomRect.width
        print("🔍 zoomScaleX is \(zoomScaleX)")
        let zoomScaleY = frame.size.height / zoomRect.height
        print("🔍 zoomScaleY is \(zoomScaleY)")

        print("🔍 🤖 calculated zoomScale is: \(zoomRect.zoomScale(within: frame.size))")

        zoom(to: zoomRect, animated: animated)
    }
}

extension CGRect {
    
    func zoomRect(forImageSize imageSize: CGSize, fittedInto frameSize: CGSize, padded: Bool) -> CGRect {
        var zoomRect = rectForSize(imageSize, fittedInto: frameSize)
        if padded {
            let ratio = min(frameSize.width / (zoomRect.size.width * 5), 3.5)
            zoomRect.pad(within: frameSize, ratio: ratio)
        }
        return zoomRect
    }
    func zoomScale(within parentSize: CGSize) -> CGFloat {
        let xScale = parentSize.width / width
        let yScale = parentSize.height / height
        return min(xScale, yScale)
    }
    
    mutating func pad(within parentSize: CGSize, ratio: CGFloat) {
        padX(withRatio: ratio, withinParentSize: parentSize)
        padY(withRatio: ratio, withinParentSize: parentSize)
    }

}

extension CGRect {

    mutating func padX(
        withRatio paddingRatio: CGFloat,
        withinParentSize parentSize: CGSize,
        minPadding padding: CGFloat = 5.0,
        maxRatioOfParent: CGFloat = 0.9
    ) {
        padX(withRatioOfWidth: paddingRatio)
        origin.x = max(padding, origin.x)
        if maxX > parentSize.width {
            size.width = parentSize.width - origin.x - padding
        }
    }

    mutating func padY(
        withRatio paddingRatio: CGFloat,
        withinParentSize parentSize: CGSize,
        minPadding padding: CGFloat = 5.0,
        maxRatioOfParent: CGFloat = 0.9
    ) {
        padY(withRatioOfHeight: paddingRatio)
        origin.y = max(padding, origin.y)
        if maxY > parentSize.height {
            size.height = parentSize.height - origin.y - padding
        }
    }
    
    mutating func padX(withRatioOfWidth ratio: CGFloat) {
        let padding = size.width * ratio
        padX(with: padding)
    }
    
    mutating func padX(with padding: CGFloat) {
        origin.x -= (padding / 2.0)
        size.width += padding
    }
    
    mutating func padY(withRatioOfHeight ratio: CGFloat) {
        let padding = size.height * ratio
        padY(with: padding)
    }
    
    mutating func padY(with padding: CGFloat) {
        origin.y -= (padding / 2.0)
        size.height += padding
    }
    
    func rectForSize(_ size: CGSize, fittedInto frameSize: CGSize) -> CGRect {
        let sizeFittingFrame = size.sizeFittingWithin(frameSize)
        var rect = rectForSize(sizeFittingFrame)

        let paddingLeft: CGFloat?
        let paddingTop: CGFloat?
        if size.widthToHeightRatio < frameSize.widthToHeightRatio {
            paddingLeft = (frameSize.width - sizeFittingFrame.width) / 2.0
            paddingTop = nil
        } else {
            paddingLeft = nil
            paddingTop = (frameSize.height - sizeFittingFrame.height) / 2.0
        }

        if let paddingLeft {
            rect.origin.x += paddingLeft
        }
        if let paddingTop {
            rect.origin.y += paddingTop
        }

        return rect
    }
}

extension CGSize {
    /// Returns a size that fits within the parent size
    func sizeFittingWithin(_ size: CGSize) -> CGSize {
        let newWidth: CGFloat
        let newHeight: CGFloat
        if widthToHeightRatio < size.widthToHeightRatio {
            /// height would be the same as parent
            newHeight = size.height
            
            /// we're scaling the width accordingly
            newWidth = (width * newHeight) / height
        } else {
            /// width would be the same as parent
            newWidth = size.width
            
            /// we're scaling the height accordingly
            newHeight = (height * newWidth) / width
        }
        return CGSize(width: newWidth, height: newHeight)
    }
}
