import UIKit

extension UIScrollView {
    
    func focus(on focusedBox: FocusedBox, animated: Bool = true) {
        zoomIn(
            boundingBox: focusedBox.boundingBox,
            padded: focusedBox.padded,
            imageSize: focusedBox.imageSize,
            animated: focusedBox.animated
        )
    }
    
    func zoomIn(boundingBox: CGRect, padded: Bool, imageSize: CGSize, animated: Bool = true) {
        
        /// Now determine the box we want to zoom into, given the image's dimensions
        /// Now if the image's width/height ratio is less than the scrollView's
        ///     we'll have padding on the x-axis, so determine what this would be based on the scrollView's frame's ratio and the current zoom scale
        ///     Add this to the box's x-axis to determine its true rect within the scrollview
        /// Or if the image's width/height ratio is greater than the scrollView's
        ///     we'll have y-axis padding, determine this
        ///     Add this to box's y-axis to determine its true rect
        /// Now zoom to this rect
        
        /// We have a `boundingBox` (y-value to bottom), and the original `imageSize`
        
        /// First determine the current size and x or y-padding of the image given the current contentSize of the `scrollView`
        let paddingLeft: CGFloat?
        let paddingTop: CGFloat?
        let width: CGFloat
        let height: CGFloat
        
        let scrollViewSize: CGSize = frame.size
        
        if imageSize.widthToHeightRatio < frame.size.widthToHeightRatio {
            /// height would be the same as `scrollView.frame.size.height`
            height = scrollViewSize.height
            width = (imageSize.width * height) / imageSize.height
            paddingLeft = (scrollViewSize.width - width) / 2.0
            paddingTop = nil
        } else {
            /// width would be the same as `scrollView.frame.size.width`
            width = scrollViewSize.width
            height = (imageSize.height * width) / imageSize.width
            paddingLeft = nil
            paddingTop = (scrollViewSize.height - height) / 2.0
        }
        
        let scaledImageSize = CGSize(width: width, height: height)
        
        var newBox = boundingBox.rectForSize(scaledImageSize)
        if let paddingLeft = paddingLeft {
            newBox.origin.x += paddingLeft
        }
        if let paddingTop = paddingTop {
            newBox.origin.y += paddingTop
        }
        print("newBox: \(newBox)")
        
//        if let paddingType {
//            newBox = newBox.padded(for: paddingType, within: scrollViewSize)
//        }
        if padded {
            newBox = newBox.padded(within: scrollViewSize)
        }
        
        zoom(to: newBox, animated: animated)
    }
}

public enum ZoomPaddingType {
    case smallElement
    case largeSection
}

extension CGRect {
    func padded(for type: ZoomPaddingType, within parentSize: CGSize) -> CGRect {
        switch type {
        case .largeSection:
            return paddedForLargeSection(within: parentSize)
        case .smallElement:
            return paddedForSmallElement(within: parentSize)
        }
    }
    
    func paddedForSmallElement(within parentSize: CGSize) -> CGRect {
        var newBox = self
        let minimumPadding: CGFloat = 5
        let paddingRatio: CGFloat = min(parentSize.width / (newBox.size.width * 5), 3.5)
        newBox.padX(withRatio: paddingRatio, withinParentSize: parentSize)
        newBox.padY(withRatio: paddingRatio, withinParentSize: parentSize)
        return newBox
        
        /// If the box is longer than it is tall
        if newBox.size.widthToHeightRatio > 1 {
            /// Add 100% padding to its horizontal side
            let padding = newBox.size.width * paddingRatio
            newBox.origin.x -= (padding / 2.0)
            newBox.size.width += padding
            
            /// Now correct the values in case they're out of bounds
            newBox.origin.x = max(minimumPadding, newBox.origin.x)
            if newBox.maxX > parentSize.width {
                newBox.size.width = parentSize.width - newBox.origin.x - minimumPadding
            }
        } else {
            /// Add 100% padding to its vertical side
            let padding = newBox.size.height * paddingRatio
            newBox.origin.y -= (padding / 2.0)
            newBox.size.height += padding
            
            /// Now correct the values in case they're out of bounds
            newBox.origin.y = max(minimumPadding, newBox.origin.y)
            if newBox.maxY > parentSize.height {
                newBox.size.height = parentSize.height - newBox.origin.y - minimumPadding
            }
        }
        print("newBox (padded): \(newBox)")
        return newBox
    }
    
    func paddedForLargeSection(within parentSize: CGSize) -> CGRect {
        var newBox = self
        let paddingRatio: CGFloat = parentSize.width / (newBox.size.width * 5)
        newBox.padX(withRatio: paddingRatio, withinParentSize: parentSize)
        newBox.padY(withRatio: paddingRatio, withinParentSize: parentSize)
        print("newBox (padded): \(newBox)")
        return newBox
    }
    
    func padded(within parentSize: CGSize) -> CGRect {
        var newBox = self
        let paddingRatio: CGFloat = parentSize.width / (newBox.size.width * 5)
        newBox.padX(withRatio: paddingRatio, withinParentSize: parentSize)
        newBox.padY(withRatio: paddingRatio, withinParentSize: parentSize)
        print("newBox (padded): \(newBox)")
        return newBox
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

}
