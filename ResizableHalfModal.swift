import SwiftUI

struct ResizableModalView<Content: View>: View {
    @Binding var showSheet: Bool
    var enableOuterTapClose = false
    @State var offsetY: CGFloat = 100
    @State private var currentOffset: CGFloat = 0
    var minViewOffset: CGFloat = 100
    var handleBarStyle: HandleBarStyle = .solid(.secondary)
    @ViewBuilder var content: Content

    /// Handle Bar types
    enum HandleBarStyle {
        case solid(Color)
        case none
    }

    var body: some View {
        Group {
            if !showSheet {
                EmptyView()
            } else {
                ZStack(alignment: .bottom) {
                    if enableOuterTapClose {
                        Color.clear.opacity(0.3)
                            .onTapGesture {
                                showSheet = false
                            }
                    }
                    VStack {
                        header(handleBarStyle: handleBarStyle)
                        content
                    }
                    .frame(maxWidth: .infinity)
                    .background(backgroundView)
                    .offset(y: offsetY)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let _y = gesture.translation.height + currentOffset
                                guard _y > 0 else {
                                    return
                                }
                                offsetY = _y
                            }
                            .onEnded { _ in
                                if abs(offsetY) > minViewOffset / 2 {
                                    withAnimation {
                                        offsetY = minViewOffset
                                    }
                                } else {
                                    withAnimation {
                                        offsetY = .zero
                                    }
                                }
                                currentOffset = offsetY
                            }
                    )
                }
            }
        }
    }

    private var backgroundView: some View {
        Color.white.cornerRadius(8)
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.13), radius: 10.0)
            .ignoresSafeArea()
    }

    private struct header: View {
        var handleBarStyle: HandleBarStyle = .solid(.secondary)

        /// The height of the handle bar section
        var handleSectionHeight: CGFloat {
            switch handleBarStyle {
            case .solid: return 40
            case .none: return 0
            }
        }

        var body: some View {
            switch handleBarStyle {
            case .solid(let handleBarColor):
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: CGFloat(5.0) / 2.0)
                        .frame(width: 40, height: 5)
                        .foregroundColor(handleBarColor)
                    Spacer()
                }
                .frame(height: handleSectionHeight)
            case .none: EmptyView()
            }
        }
    }
}

extension View {
    /**
     - Parameters:
     - showSheet: モーダル画面の表示制御 defaultでtrue
     - enableOuterTapClose: 親ビューをタップしてクローズする機能を有効にするか。デフォルトはoffで親ビューが有効
     - defaultModeIsMin: trueだとminViewOffsetの値で最小化して表示。falseならcontentの高さで表示
     - minViewOffset: 最小化時のoffset（y）この高さの分小さくなる
     　　- handleBarStyle: .solid(Color) or none ハンドルビューを表示するか否か
     　　- content: コンテンツビュー　モーダルの最大時の高さはcontentの高さになる
     */
    func resizableHalfModal<Content: View>(
        showSheet: Binding<Bool> = .constant(true),
        enableOuterTapClose: Bool = false,
        defaultModeIsMin: Bool = false,
        minViewOffset: CGFloat = 100,
        handleBarStyle: ResizableModalView<Content>.HandleBarStyle = .solid(.secondary),
        @ViewBuilder content: () -> Content) -> some View {
        self.overlay(
            ResizableModalView(showSheet: showSheet,
                               enableOuterTapClose: enableOuterTapClose,
                               offsetY: defaultModeIsMin ? minViewOffset : .zero,
                               minViewOffset: minViewOffset,
                               handleBarStyle: handleBarStyle,
                               content: content),
            alignment: .bottom
        )
    }
}

struct ResizableModalView_Previews: PreviewProvider {
    @State static var text: String = ""

    struct ModalContentView: View {
        @Binding var text: String

        var body: some View {
            VStack {
                Text("Demodata").font(.title2)
                TextField("test", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 16)
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(Array(1...10), id: \.self) { item in
                            Text("demoItem: \(item)")
                                .frame(width: 200, height: 88)
                                .background(Color.red.cornerRadius(8))
                        }
                    }
                    .padding()
                }
            }
        }
    }

    static var previews: some View {
        NavigationView {
            VStack {
                List( Array(1...10), id: \.self ) { item in
                    Text("item \(item)")
                }
            }
            .navigationTitle("テスト")
            .navigationBarTitleDisplayMode(.inline)
        }
        .resizableHalfModal(minViewOffset: 110, handleBarStyle: .solid(.secondary)) {
            ModalContentView(text: $text)
        }
    }
}
