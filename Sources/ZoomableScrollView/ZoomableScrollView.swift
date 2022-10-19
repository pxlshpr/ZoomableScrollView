import SwiftUI
import VisionSugar
import SwiftUISugar

/// This identifies an area of the ZoomableScrollView to focus on
public struct FocusedBox {
    
    /// This is the boundingBox (in terms of a 0 to 1 ratio on each dimension of what the CGRect is (similar to the boundingBox in Vision)
    let boundingBox: CGRect
    let padded: Bool
    let animated: Bool
    let imageSize: CGSize
    
    public init(boundingBox: CGRect, animated: Bool = true, padded: Bool = true, imageSize: CGSize) {
        self.boundingBox = boundingBox
        self.padded = padded
        self.animated = animated
        self.imageSize = imageSize
    }
    
    public static let none = Self.init(boundingBox: .zero, imageSize: .zero)
}

public struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    
    @State var lastFocusedArea: FocusedBox? = nil
    @State var firstTime: Bool = true
    
    let backgroundColor: UIColor?
    private var content: Content
    
    var focusedBox: Binding<FocusedBox?>?
    var zoomBox: Binding<FocusedBox?>?

    public init(
        focusedBox: Binding<FocusedBox?>? = nil,
        zoomBox: Binding<FocusedBox?>? = nil,
        backgroundColor: UIColor? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.content = content()
        self.focusedBox = focusedBox
        self.zoomBox = zoomBox
    }
    
    public func makeCoordinator() -> Coordinator {
        let hostingController = UIHostingController(rootView: self.content)
        return Coordinator(hostingController: hostingController)
    }
    
    public func makeUIView(context: Context) -> UIScrollView {
        scrollView(context: context)
    }

    public func updateUIView(_ scrollView: UIScrollView, context: Context) {
        // update the hosting controller's SwiftUI content
        context.coordinator.hostingController.rootView = self.content
        assert(context.coordinator.hostingController.view.superview == scrollView)

//        
//        let delay = 0.01
//        
//        /// we need to first set the `zoomScale` to something other than 1
//        /// then set it back to 1 before zooming into the actual box
//        /// in order to alleviate an issue we get with the first programmatic zoom out offseting the contents by a safe area height.
//        /// This seems to be a limitation with not being able to ignore the safe area directly over here.
//        /// We got as far as [this](https://stackoverflow.com/a/73146559), but was still unable to remove the initial glitch.
//        scrollView.layer.opacity = 0
//        scrollView.setZoomScale(1, animated: false)
//        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//            scrollView.setZoomScale(2, animated: false)
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                scrollView.setZoomScale(1, animated: false)
//                
//                UIView.animate(withDuration: 0.01) {
//                    scrollView.layer.opacity = 1
//                }
//                
//                guard let focusedBox = focusedBox?.wrappedValue, focusedBox.boundingBox != .zero else {
//                    return
//                }
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                    scrollView.focus(on: focusedBox)
//                }
//            }
//        
//        }
    }

    // MARK: - Coordinator
    public class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        
        init(hostingController: UIHostingController<Content>) {
            self.hostingController = hostingController
        }
        
        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return hostingController.view
        }
        
        @objc func doubleTapped(recognizer:  UITapGestureRecognizer) {
            
        }
        
        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
            print("🔍 zoomScale is \(scrollView.zoomScale)")
        }
    }
    
    func view(content: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .purple
        return view
    }

}

struct ContentView: View {
    var body: some View {
        Color.clear
            .fullScreenCover(isPresented: .constant(true)) {
                ZoomableScrollView {
                    Image("label")
                        .resizable()
                        .scaledToFit()
                }
                .ignoresSafeArea(edges: .all)
                .background(.yellow)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
