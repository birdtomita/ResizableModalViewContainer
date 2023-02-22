import SwiftUI

struct StaticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct CustomModalViewContainer <Item, Content, Title, CloseButton>: View where Content: View, Title: View, CloseButton: View {
    var cornerRadius: CGFloat = 12
    var backgroundOpacity: CGFloat = 0.4
    var onEnded: () -> Void

    @Binding var item: Item?
    var titleLabel: ((Item) -> Title)?
    var closeButton: CloseButton?
    var buttonForegroundColor: Color
    var backgroundColor: Color
    var titleAlignment: Alignment
    var tapClose: Bool
    var iconName: String?
    var content: (Item) -> Content

    // Animation Property
    @State private var showPanel = false
    @State private var offset: CGFloat = 0

    init(
        item: Binding<Item?>,
        @ViewBuilder titleLabel: @escaping (Item) -> Title,
        @ViewBuilder closeButton: () -> CloseButton = { Image(systemName: "xmark.circle.fill") } as! () -> CloseButton,
        buttonForegroundColor: Color = Color.gray,
        backgroundColor: Color = Color.white,
        titleAlignment: Alignment = .center,
        tapClose: Bool = false,
        cornerRadius: CGFloat = 12,
        backgroundOpacity: CGFloat = 0.4,
        onEnded: @escaping () -> Void = {},
        @ViewBuilder content: @escaping (Item) -> Content) {
        self._item = item
        self.titleLabel = titleLabel
        self.closeButton = closeButton()
        self.buttonForegroundColor = buttonForegroundColor
        self.backgroundColor = backgroundColor
        self.titleAlignment = titleAlignment
        self.tapClose = tapClose
        self.cornerRadius = cornerRadius
        self.backgroundOpacity = backgroundOpacity
        self.onEnded = onEnded
        self.content = content
    }

    init(
        item: Binding<Item?>,
        backgroundColor: Color = Color.white,
        tapClose: Bool = false,
        iconName: String? = nil,
        cornerRadius: CGFloat = 12,
        backgroundOpacity: CGFloat = 0.4,
        onEnded: @escaping () -> Void = {},
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self._item = item
        titleLabel = nil
        closeButton = nil
        self.buttonForegroundColor = .gray
        self.backgroundColor = backgroundColor
        self.titleAlignment = .center
        self.tapClose = tapClose
        self.iconName = iconName
        self.cornerRadius = cornerRadius
        self.backgroundOpacity = backgroundOpacity
        self.onEnded = onEnded
        self.content = content
    }

    var body: some View {
        if let unwrapped = item {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    if showPanel {
                        Button {
                            if tapClose {
                                withAnimation {
                                    showPanel = false
                                }
                            }
                        } label: {
                            Color.black.opacity(backgroundOpacity)
                        }
                        .buttonStyle(StaticButtonStyle())
                        .transition(.opacity)

                        VStack {
                            if titleLabel != nil || closeButton != nil {
                                ZStack {
                                    titleLabel?(unwrapped).frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    HStack {
                                        Spacer()
                                        Button {
                                            withAnimation {
                                                showPanel = false
                                            }
                                        } label: {
                                            closeButton
                                        }
                                        .foregroundColor(buttonForegroundColor)
                                    }
                                }
                                .padding()
                            }

                            content(unwrapped)

                            Spacer()
                                .frame(height: geometry.safeAreaInsets.bottom)
                        }
                        .background(backgroundColor)
                        .cornerRadius(cornerRadius, corners: [.topLeft, .topRight])
                        .overlay(
                            ZStack {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 88, height: 88)
                                Image(iconName ?? "")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(32)
                            }
                            .frame(maxWidth: .infinity)
                            .position(x: screenBounds.width / 2, y: 0)
                            .opacity(iconName == nil ? 0 : 1)
                        )
                        .transition(.move(edge: .bottom))
                        .offset(y: offset)
                        .gesture(ModalClosableGesture(offset: $offset, showPanel: $showPanel))
                    }
                }
                .ignoresSafeArea()
            }
            .onChange(of: showPanel) { newValue in
                if !newValue {
                    withAnimation {
                        item = nil
                    }
                }
            }
            .onAppear {
                withAnimation {
                    offset = 0
                    showPanel = true
                }
            }
            .onDisappear {
                onEnded()
            }
        } else {
            EmptyView()
        }
    }

    struct ModalClosableGesture: Gesture {
        @Binding var offset: CGFloat
        @Binding var showPanel: Bool
        var body: some Gesture {
            DragGesture()
                .onChanged { gesture in
                    guard gesture.translation.height > 0 else {
                        return
                    }
                    offset = gesture.translation.height
                }
                .onEnded { _ in
                    if abs(offset) > 100 {
                        withAnimation {
                            showPanel = false
                        }
                    } else {
                        withAnimation {
                            offset = .zero
                        }
                    }
                }
        }
    }
}

extension CustomModalViewContainer where CloseButton == Image {
    init(
        item: Binding<Item?>,
        @ViewBuilder titleLabel: @escaping (Item) -> Title,
        buttonForegroundColor: Color = Color.gray,
        backgroundColor: Color = Color.white,
        titleAlignment: Alignment = .center,
        tapClose: Bool = false,
        cornerRadius: CGFloat = 12,
        backgroundOpacity: CGFloat = 0.4,
        onEnded: @escaping () -> Void = {},
        @ViewBuilder content: @escaping (Item) -> Content) {
        self._item = item
        self.titleLabel = titleLabel
        self.closeButton = Image(systemName: "xmark.circle.fill")
        self.buttonForegroundColor = buttonForegroundColor
        self.backgroundColor = backgroundColor
        self.titleAlignment = titleAlignment
        self.tapClose = tapClose
        self.cornerRadius = cornerRadius
        self.backgroundOpacity = backgroundOpacity
        self.onEnded = onEnded
        self.content = content
    }
}
