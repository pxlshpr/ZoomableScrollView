import UIKit

extension UIScrollView {

    func focus(on message: FocusedBox, animated: Bool = true) {
        zoomIn(boundingBox: message.boundingBox, padded: message.padded, imageSize: message.imageSize, animated: message.animated)
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

//            let scrollViewSize: CGSize = CGSize(width: 428, height: 376)
        let scrollViewSize: CGSize = frame.size
//            let scrollViewSize: CGSize
//            if let view = scrollView.delegate?.viewForZooming?(in: scrollView) {
//                scrollViewSize = view.frame.size
//            } else {
//                scrollViewSize = scrollView.contentSize
//            }

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

        let newImageSize = CGSize(width: width, height: height)

        if let paddingLeft = paddingLeft {
            print("paddingLeft: \(paddingLeft)")
        } else {
            print("paddingLeft: nil")
        }
        if let paddingTop = paddingTop {
            print("paddingTop: \(paddingTop)")
        } else {
            print("paddingTop: nil")
        }
        print("newImageSize: \(newImageSize)")

        var newBox = boundingBox.rectForSize(newImageSize)
        if let paddingLeft = paddingLeft {
            newBox.origin.x += paddingLeft
        }
        if let paddingTop = paddingTop {
            newBox.origin.y += paddingTop
        }
        print("newBox: \(newBox)")

        if padded {
            let minimumPadding: CGFloat = 5
            let zoomOutPaddingRatio: CGFloat = min(newImageSize.width / (newBox.size.width * 5), 3.5)
            print("zoomOutPaddingRatio: \(zoomOutPaddingRatio)")

            /// If the box is longer than it is tall
            if newBox.size.widthToHeightRatio > 1 {
                /// Add 100% padding to its horizontal side
                let padding = newBox.size.width * zoomOutPaddingRatio
                newBox.origin.x -= (padding / 2.0)
                newBox.size.width += padding

                /// Now correct the values in case they're out of bounds
                newBox.origin.x = max(minimumPadding, newBox.origin.x)
                if newBox.maxX > newImageSize.width {
                    newBox.size.width = newImageSize.width - newBox.origin.x - minimumPadding
                }
            } else {
                /// Add 100% padding to its vertical side
                let padding = newBox.size.height * zoomOutPaddingRatio
                newBox.origin.y -= (padding / 2.0)
                newBox.size.height += padding

                /// Now correct the values in case they're out of bounds
                newBox.origin.y = max(minimumPadding, newBox.origin.y)
                if newBox.maxY > newImageSize.height {
                    newBox.size.height = newImageSize.height - newBox.origin.y - minimumPadding
                }
            }
            print("newBox (padded): \(newBox)")
        }

        zoom(to: newBox, animated: animated)
    }
}
