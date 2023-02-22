import SwiftUI

// [Usage]
//
// View()
//   .halfModal(isShow: $isShowHalfModal) {
//     Text("HalfModalText")
//   } onEnd: {
//     print("onEnd coming...")
//   }
struct HalfModalSheetViewController<Sheet: View>: UIViewControllerRepresentable {
    var sheet: Sheet
    @Binding var isShow: Bool
    var onClose: () -> Void

    private let vc = UIViewController()

    func makeUIViewController(context: Context) -> UIViewController { vc }

    func updateUIViewController(
        _ viewController: UIViewController,
        context: Context
    ) {
        if isShow {
            let sheetController = CustomHostingController(rootView: sheet)
            sheetController.presentationController!.delegate = context.coordinator
            viewController.present(sheetController, animated: true)
        } else {
            viewController.dismiss(animated: true) { onClose() }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        var parent: HalfModalSheetViewController

        init(parent: HalfModalSheetViewController) {
            self.parent = parent
        }

        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.isShow = false
        }
    }

    class CustomHostingController<Content: View>: UIHostingController<Content> {
        override func viewDidLoad() {
            super.viewDidLoad()
            if let sheet = self.sheetPresentationController {
                sheet.detents = [.medium() ]
                sheet.prefersGrabberVisible = true
            }
        }
    }
}

extension View {
    func halfModal<Sheet: View>(
        isShow: Binding<Bool>,
        @ViewBuilder sheet: @escaping () -> Sheet,
        onEnd: @escaping () -> Void
    ) -> some View {
        self.background(
            HalfModalSheetViewController(
                sheet: sheet(),
                isShow: isShow,
                onClose: onEnd
            )
        )
    }
}
