import SwiftUI

struct NoAnimationCover<Nested: View>: ViewModifier {
    let isPresenting: Bool
    var nested: (@escaping () -> Void) -> Nested

    @State var reflectPresenting = false

    init(isPresenting: @autoclosure () -> Bool, nested: @escaping (@escaping () -> Void) -> Nested) {
        self.isPresenting = isPresenting()
        self.nested = nested
        self._reflectPresenting = State(initialValue: isPresenting())
    }

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresenting, perform: { newValue in
                if newValue {
                    withoutAnimation {
                        reflectPresenting = newValue
                    }
                }
            })
            .fullScreenCover(isPresented: $reflectPresenting, content: {
                EmptyView()
                    .background(BackgroundClearView())
                    .overlay(
                        nested {
                            withoutAnimation {
                                reflectPresenting = false
                            }
                        }
                    )
            })
    }
}

extension View {
    func customModal<Content: View, Title: View, CloseButton: View>(
        show: Binding<Bool>,
        @ViewBuilder titleLabel: @escaping () -> Title,
        @ViewBuilder closeButton: @escaping () -> CloseButton = { Image(systemName: "xmark.circle.fill") } as! () -> CloseButton,
        buttonForegroundColor: Color = Color.gray,
        backgroundColor: Color = Color.white,
        titleAlignment: Alignment = .center,
        tapClose: Bool = false,
        cornerRadius: CGFloat = 12,
        backgroundOpacity: CGFloat = 0.4,
        onEnded: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content) -> some View {
        let view = self
        return view.modifier(NoAnimationCover(isPresenting: show.wrappedValue) { dismiss in
            CustomModalViewContainer(
                item: .init(get: { show.wrappedValue ? () : nil },
                            set: { show.wrappedValue = $0 != nil }),
                titleLabel: { _ in titleLabel() },
                closeButton: closeButton,
                buttonForegroundColor: buttonForegroundColor,
                backgroundColor: backgroundColor,
                titleAlignment: titleAlignment,
                tapClose: tapClose,
                cornerRadius: cornerRadius,
                backgroundOpacity: backgroundOpacity,
                onEnded: {
                    onEnded()
                    dismiss()
                },
                content: { _ in content() }
            )
        })
    }

    func customModal<Item, Content: View, Title: View, CloseButton: View>(
        item: Binding<Item?>,
        @ViewBuilder titleLabel: @escaping (Item) -> Title,
        @ViewBuilder closeButton: @escaping () -> CloseButton = { Image(systemName: "xmark.circle.fill") } as! () -> CloseButton,
        buttonForegroundColor: Color = Color.gray,
        backgroundColor: Color = Color.white,
        titleAlignment: Alignment = .center,
        tapClose: Bool = false,
        cornerRadius: CGFloat = 12,
        backgroundOpacity: CGFloat = 0.4,
        onEnded: @escaping () -> Void = {},
        @ViewBuilder content: @escaping (Item) -> Content) -> some View {
        let view = self
        return view.modifier(NoAnimationCover(isPresenting: item.wrappedValue != nil) { dismiss in
            CustomModalViewContainer(
                item: item,
                titleLabel: { item in titleLabel(item) },
                closeButton: closeButton,
                buttonForegroundColor: buttonForegroundColor,
                backgroundColor: backgroundColor,
                titleAlignment: titleAlignment,
                tapClose: tapClose,
                cornerRadius: cornerRadius,
                backgroundOpacity: backgroundOpacity,
                onEnded: {
                    onEnded()
                    dismiss()
                },
                content: { item in content(item) }
            )
        })
    }

    func customModal<Content: View, Title: View>(
        show: Binding<Bool>,
        @ViewBuilder titleLabel: @escaping () -> Title,
        buttonForegroundColor: Color = Color.gray,
        backgroundColor: Color = Color.white,
        titleAlignment: Alignment = .center,
        tapClose: Bool = false,
        cornerRadius: CGFloat = 12,
        backgroundOpacity: CGFloat = 0.4,
        onEnded: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content) -> some View {
        let view = self
        return view.modifier(NoAnimationCover(isPresenting: show.wrappedValue) { dismiss in
            CustomModalViewContainer(
                item: .init(get: { show.wrappedValue ? () : nil },
                            set: { show.wrappedValue = $0 != nil }),
                titleLabel: { _ in titleLabel() },
                buttonForegroundColor: buttonForegroundColor,
                backgroundColor: backgroundColor,
                titleAlignment: titleAlignment,
                tapClose: tapClose,
                cornerRadius: cornerRadius,
                backgroundOpacity: backgroundOpacity,
                onEnded: {
                    onEnded()
                    dismiss()
                },
                content: { _ in content() }
            )
        })
    }

    func customModal<Item, Content: View, Title: View>(
        item: Binding<Item?>,
        @ViewBuilder titleLabel: @escaping (Item) -> Title,
        buttonForegroundColor: Color = Color.gray,
        backgroundColor: Color = Color.white,
        titleAlignment: Alignment = .center,
        tapClose: Bool = false,
        cornerRadius: CGFloat = 12,
        backgroundOpacity: CGFloat = 0.4,
        onEnded: @escaping () -> Void = {},
        @ViewBuilder content: @escaping (Item) -> Content) -> some View {
        let view = self
        return view.modifier(NoAnimationCover(isPresenting: item.wrappedValue != nil) { dismiss in
            CustomModalViewContainer(
                item: item,
                titleLabel: { item in titleLabel(item) },
                buttonForegroundColor: buttonForegroundColor,
                backgroundColor: backgroundColor,
                titleAlignment: titleAlignment,
                tapClose: tapClose,
                cornerRadius: cornerRadius,
                backgroundOpacity: backgroundOpacity,
                onEnded: {
                    onEnded()
                    dismiss()
                },
                content: { item in content(item) }
            )
        })
    }

    /// アイコン付きの半モーダル
    func customModal<Item, Content: View>(
        item: Binding<Item?>,
        backgroundColor: Color = .Background.White,
        tapClose: Bool = false,
        iconName: String?,
        cornerRadius: CGFloat = 12,
        backgroundOpacity: CGFloat = 0.4,
        onEnded: @escaping () -> Void = {},
        @ViewBuilder content: @escaping (Item) -> Content) -> some View {
        let view = self
        return view.modifier(NoAnimationCover(isPresenting: item.wrappedValue != nil) { dismiss in
            CustomModalViewContainer<Item, Content, Text, Image>(
                item: item,
                backgroundColor: backgroundColor,
                tapClose: tapClose,
                iconName: iconName,
                cornerRadius: cornerRadius,
                backgroundOpacity: backgroundOpacity,
                onEnded: {
                    onEnded()
                    dismiss()
                },
                content: { item in content(item) }
            )
        })
    }

    /// ヘッダーなしの半モーダル
    func customModal<Content: View>(
        show: Binding<Bool>,
        backgroundColor: Color = Color.white,
        tapClose: Bool = false,
        cornerRadius: CGFloat = 12,
        backgroundOpacity: CGFloat = 0.4,
        onEnded: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content) -> some View {
        let view = self
        return view.modifier(NoAnimationCover(isPresenting: show.wrappedValue) { dismiss in
            CustomModalViewContainer<Void, Content, Text, Image>(
                item: .init(get: { show.wrappedValue ? () : nil },
                            set: { show.wrappedValue = $0 != nil }),
                backgroundColor: backgroundColor,
                tapClose: tapClose,
                cornerRadius: cornerRadius,
                backgroundOpacity: backgroundOpacity,
                onEnded: {
                    onEnded()
                    dismiss()
                },
                content: { _ in content() }
            )
        })
    }

    /// ヘッダーなしの半モーダル
    func customModal<Item, Content: View>(
        item: Binding<Item?>,
        backgroundColor: Color = Color.white,
        tapClose: Bool = false,
        cornerRadius: CGFloat = 12,
        backgroundOpacity: CGFloat = 0.4,
        onEnded: @escaping () -> Void = {},
        @ViewBuilder content: @escaping (Item) -> Content) -> some View {
        let view = self
        return view.modifier(NoAnimationCover(isPresenting: item.wrappedValue != nil) { dismiss in
            CustomModalViewContainer<Item, Content, Text, Image>(
                item: item,
                backgroundColor: backgroundColor,
                tapClose: tapClose,
                cornerRadius: cornerRadius,
                backgroundOpacity: backgroundOpacity,
                onEnded: {
                    onEnded()
                    dismiss()
                },
                content: { item in content(item) }
            )
        })
    }
}
