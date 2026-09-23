import AVFoundation
import SwiftUI
import UIKit

struct OnboardingView: View {
    var body: some View {
        List {
            Section("Форматы") {
                NavigationLink {
                    InterfaceOnboardingView()
                } label: {
                    OnboardingFormatRow(
                        title: "Интерфейс",
                        subtitle: "Скриншоты и видео внутри фрейма телефона",
                        systemImage: "iphone.gen3"
                    )
                }

                NavigationLink {
                    IllustrationOnboardingView()
                } label: {
                    OnboardingFormatRow(
                        title: "Иллюстрация",
                        subtitle: "Статичная иллюстрация или моушен",
                        systemImage: "photo.on.rectangle.angled"
                    )
                }

                NavigationLink {
                    BottomSheetOnboardingView()
                } label: {
                    OnboardingFormatRow(
                        title: "Bottom-sheet",
                        subtitle: "Медиа внутри полушторы поверх контента",
                        systemImage: "rectangle.bottomhalf.inset.filled"
                    )
                }

                NavigationLink {
                    LongreadOnboardingView()
                } label: {
                    OnboardingFormatRow(
                        title: "Лонгрид",
                        subtitle: "Вертикальная лента шагов с медиа в карточках",
                        systemImage: "list.bullet.rectangle.portrait"
                    )
                }
            }
        }
        .navigationTitle("Onboarding")
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct OnboardingFormatRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var badge: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            if let badge {
                Text(badge)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct OnboardingFormatPlaceholderView: View {
    let title: String
    let description: String
    let systemImage: String

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } description: {
            Text(description)
        } actions: {
            Text("Следующий этап")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct IllustrationOnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        IllustrationStyleOnboarding(
            items: [
                .init(
                    id: 0,
                    title: "Делите покупки\nв Шопинге по карте",
                    subtitle: "Оплачивайте часть суммы сразу,\nостальное потом — каждые 2 недели",
                    imageName: "OnboardingIllustrationShopping",
                    imageAlignment: .bottom,
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 1,
                    title: "Включайте Долями\nдля оплаты в Шопинге",
                    subtitle: "Спишется только 25% от ближайшей\nпокупки и сервисный сбор 5%",
                    imageName: "OnboardingIllustrationInstallments",
                    buttonTitle: "Включить"
                )
            ],
            onBackFromFirstPage: { dismiss() }
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct IllustrationStyleOnboarding: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    let items: [Item]
    let onBackFromFirstPage: () -> Void

    @State private var currentIndex = 0
    @State private var dragTranslation: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                backgroundColor
                    .ignoresSafeArea()

                ambientLightView

                heroView

                controlsView

                backButton
            }
            .contentShape(Rectangle())
            .simultaneousGesture(pageDragGesture(pageWidth: geometry.size.width))
        }
    }

    private var ambientLightView: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(items.indices, id: \.self) { index in
                    let visibility = pageVisibility(
                        for: index,
                        pageWidth: geometry.size.width
                    )

                    Image(items[index].imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: geometry.size.width * 1.18,
                            height: min(geometry.size.width * 1.04, 410)
                        )
                        .scaleEffect(1.28)
                        .saturation(colorScheme == .dark ? 1.35 : 1.55)
                        .contrast(0.72)
                        .brightness(colorScheme == .dark ? 0.10 : 0.05)
                        .blur(radius: 82)
                        .opacity(visibility * ambientLightOpacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .mask {
                LinearGradient(
                    stops: [
                        .init(color: .black, location: 0),
                        .init(color: .black, location: 0.68),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .animation(ambientAnimation, value: currentIndex)
        }
        .frame(height: 440)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var heroView: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width * (305 / 375), 340)
            let height = width * (263 / 305)

            ZStack {
                ForEach(items.indices, id: \.self) { index in
                    let isActive = index == currentIndex

                    Image(items[index].imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: width,
                            height: height,
                            alignment: items[index].imageAlignment
                        )
                        .clipped()
                        .modifier(
                            IllustrationArcCarouselModifier(
                                relativePage: reduceMotion
                                    ? 0
                                    : relativePage(
                                        for: index,
                                        pageWidth: geometry.size.width
                                    ),
                                pageWidth: geometry.size.width,
                                arcHeight: 64
                            )
                        )
                        .opacity(reduceMotion ? (isActive ? 1 : 0) : 1)
                }
            }
            .frame(width: width, height: height)
            .frame(maxWidth: .infinity, alignment: .center)
            .animation(pageAnimation, value: currentIndex)
        }
        .padding(.top, 123)
        .accessibilityHidden(true)
    }

    private var controlsView: some View {
        VStack(spacing: 0) {
            copyView
                .frame(height: 104)

            Spacer()
                .frame(height: 34)

            indicatorView
                .frame(height: 16)

            Spacer()
                .frame(height: 16)

            continueButton
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    private var copyView: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    let relativePage = reduceMotion
                        ? CGFloat(index - currentIndex)
                        : relativePage(for: index, pageWidth: geometry.size.width)
                    let distance = min(abs(relativePage), 1)

                    VStack(spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 20, weight: .bold))
                            .tracking(0.38)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(primaryTextColor)

                        Text(item.subtitle)
                            .font(.system(size: 17, weight: .regular))
                            .tracking(-0.41)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(secondaryTextColor)
                    }
                    .frame(width: geometry.size.width)
                    .compositingGroup()
                    .offset(
                        x: reduceMotion
                            ? 0
                            : relativePage * geometry.size.width
                    )
                    .blur(radius: 30 * distance)
                    .opacity(1 - distance)
                }
            }
            .animation(pageAnimation, value: currentIndex)
        }
    }

    private var indicatorView: some View {
        HStack(spacing: 6) {
            ForEach(items.indices, id: \.self) { index in
                let isActive = index == currentIndex

                Capsule()
                    .fill(isActive ? pageIndicatorActiveColor : pageIndicatorInactiveColor)
                    .frame(width: isActive ? 25 : 6, height: 6)
            }
        }
        .animation(pageAnimation, value: currentIndex)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Страница \(currentIndex + 1) из \(items.count)")
    }

    private var continueButton: some View {
        Button {
            withAnimation(pageAnimation) {
                currentIndex = currentIndex == items.count - 1 ? 0 : currentIndex + 1
            }
        } label: {
            Text(items[currentIndex].buttonTitle)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .contentShape(Rectangle())
                .modifier(OnboardingYellowButtonSurfaceModifier())
                .transaction { transaction in
                    transaction.animation = nil
                }
        }
        .buttonStyle(.plain)
    }

    private var backButton: some View {
        Button {
            guard currentIndex > 0 else {
                onBackFromFirstPage()
                return
            }

            withAnimation(pageAnimation) {
                currentIndex -= 1
            }
        } label: {
            Image(systemName: "chevron.left")
                .font(.title3)
                .frame(width: 20, height: 30)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .foregroundStyle(primaryTextColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, 16)
        .padding(.top, 16)
    }

    private func relativePage(for index: Int, pageWidth: CGFloat) -> CGFloat {
        guard pageWidth > 0 else {
            return CGFloat(index - currentIndex)
        }

        return CGFloat(index - currentIndex) + dragTranslation / pageWidth
    }

    private func pageVisibility(for index: Int, pageWidth: CGFloat) -> Double {
        let distance = min(abs(relativePage(for: index, pageWidth: pageWidth)), 1)
        return 1 - distance
    }

    private func pageDragGesture(pageWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else {
                    dragTranslation = 0
                    return
                }

                let rawTranslation = value.translation.width
                let isAtFirstPage = currentIndex == 0 && rawTranslation > 0
                let isAtLastPage = currentIndex == items.count - 1 && rawTranslation < 0

                if isAtFirstPage || isAtLastPage {
                    dragTranslation = rawTranslation.sign == .minus
                        ? -min(abs(rawTranslation) * 0.24, 72)
                        : min(abs(rawTranslation) * 0.24, 72)
                } else {
                    dragTranslation = min(max(rawTranslation, -pageWidth), pageWidth)
                }
            }
            .onEnded { value in
                let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                let projectedTranslation = value.predictedEndTranslation.width
                let distanceThreshold = pageWidth * 0.18
                let projectedThreshold = pageWidth * 0.28
                var targetIndex = currentIndex

                if isHorizontal,
                   (value.translation.width < -distanceThreshold
                       || projectedTranslation < -projectedThreshold) {
                    targetIndex = min(currentIndex + 1, items.count - 1)
                } else if isHorizontal,
                          (value.translation.width > distanceThreshold
                              || projectedTranslation > projectedThreshold) {
                    targetIndex = max(currentIndex - 1, 0)
                }

                withAnimation(pageAnimation) {
                    currentIndex = targetIndex
                    dragTranslation = 0
                }
            }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    private var primaryTextColor: Color {
        colorScheme == .dark
            ? .white
            : Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)
    }

    private var secondaryTextColor: Color {
        Color(red: 146 / 255, green: 153 / 255, blue: 162 / 255)
    }

    private var pageIndicatorActiveColor: Color {
        colorScheme == .dark ? .white.opacity(0.92) : primaryTextColor
    }

    private var pageIndicatorInactiveColor: Color {
        colorScheme == .dark
            ? .white.opacity(0.22)
            : Color(red: 0, green: 16 / 255, blue: 36 / 255).opacity(0.12)
    }

    private var ambientLightOpacity: Double {
        colorScheme == .dark ? 0.34 : 0.40
    }

    private var pageAnimation: Animation {
        reduceMotion
            ? .easeInOut(duration: 0.2)
            : .interpolatingSpring(duration: 0.65, bounce: 0, initialVelocity: 0)
    }

    private var ambientAnimation: Animation {
        .easeInOut(duration: reduceMotion ? 0.2 : 0.68)
    }

    struct Item: Identifiable {
        let id: Int
        let title: String
        let subtitle: String
        let imageName: String
        var imageAlignment: Alignment = .center
        let buttonTitle: String
    }
}

private struct IllustrationArcCarouselModifier: AnimatableModifier {
    var relativePage: CGFloat
    let pageWidth: CGFloat
    let arcHeight: CGFloat

    var animatableData: CGFloat {
        get { relativePage }
        set { relativePage = newValue }
    }

    func body(content: Content) -> some View {
        let distance = min(abs(relativePage), 1)

        content
            .scaleEffect(1 - distance * 0.30)
            .offset(
                x: relativePage * pageWidth,
                y: arcHeight * distance * distance
            )
    }
}

private struct OnboardingDeviceFrame<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    let size: CGSize
    let hidesBezels: Bool
    private let content: Content

    init(
        size: CGSize,
        hidesBezels: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.hidesBezels = hidesBezels
        self.content = content()
    }

    var body: some View {
        let shape = ConcentricRectangle(corners: .concentric, isUniform: true)

        ZStack {
            Rectangle()
                .fill(.black)

            content
        }
        .frame(width: size.width, height: size.height)
        .clipShape(shape)
        .overlay {
            if !hidesBezels {
                ZStack {
                    shape
                        .stroke(
                            frameHighlightColor,
                            lineWidth: colorScheme == .dark ? 6 : 2
                        )
                        .padding(colorScheme == .dark ? 0 : -3)

                    shape
                        .stroke(.black, lineWidth: 4)

                    shape
                        .stroke(.black, lineWidth: 6)
                        .padding(4)
                }
                .padding(-7)
            }
        }
        .containerShape(
            RoundedRectangle(
                cornerRadius: size.height * (180 / 2622),
                style: .continuous
            )
        )
    }

    private var frameHighlightColor: Color {
        colorScheme == .dark
            ? .white
            : Color(red: 221 / 255, green: 221 / 255, blue: 221 / 255)
    }
}

private struct FigmaPhoneMockupFrame<Content: View>: View {
    let size: CGSize
    let hidesBezels: Bool
    private let content: Content

    init(
        size: CGSize,
        hidesBezels: Bool = false,
        @ViewBuilder content: (CGSize) -> Content
    ) {
        self.size = size
        self.hidesBezels = hidesBezels
        let metrics = Metrics(size: size)
        self.content = content(hidesBezels ? size : metrics.slotFrame.size)
    }

    var body: some View {
        let metrics = Metrics(size: size)

        ZStack(alignment: .topLeading) {
            Color.clear
                .frame(width: size.width, height: size.height)

            if hidesBezels {
                ZStack {
                    content
                }
                    .frame(width: size.width, height: size.height)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: metrics.outerCornerRadius,
                            style: .circular
                        )
                    )
            } else {
                RoundedRectangle(
                    cornerRadius: metrics.outerCornerRadius,
                    style: .circular
                )
                .fill(.black)
                .overlay {
                    RoundedRectangle(
                        cornerRadius: metrics.outerCornerRadius,
                        style: .circular
                    )
                    .strokeBorder(
                        Color(red: 221 / 255, green: 221 / 255, blue: 221 / 255),
                        lineWidth: metrics.outerBorderWidth
                    )
                }
                .frame(
                    width: metrics.outerFrame.width,
                    height: metrics.outerFrame.height
                )
                .offset(
                    x: metrics.outerFrame.minX,
                    y: metrics.outerFrame.minY
                )

                ZStack {
                    content
                }
                    .frame(
                        width: metrics.slotFrame.width,
                        height: metrics.slotFrame.height
                    )
                    .background(Color(.systemBackground))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: metrics.slotCornerRadius,
                            style: .circular
                        )
                    )
                    .offset(
                        x: metrics.slotFrame.minX,
                        y: metrics.slotFrame.minY
                    )
            }
        }
        .frame(width: size.width, height: size.height)
        .containerShape(
            RoundedRectangle(
                cornerRadius: metrics.outerCornerRadius,
                style: .circular
            )
        )
    }

    private struct Metrics {
        let outerFrame: CGRect
        let slotFrame: CGRect
        let outerCornerRadius: CGFloat
        let slotCornerRadius: CGFloat
        let outerBorderWidth: CGFloat

        init(size: CGSize) {
            let progress = min(max((size.width - 198) / (260 - 198), 0), 1)

            outerFrame = CGRect(
                x: Self.interpolate(2, 3, progress: progress),
                y: Self.interpolate(2, 2.669921875, progress: progress),
                width: Self.interpolate(194, 254, progress: progress),
                height: Self.interpolate(402, 536, progress: progress)
            )
            slotFrame = CGRect(
                x: Self.interpolate(10, 12.52587890625, progress: progress),
                y: Self.interpolate(10, 12.00390625, progress: progress),
                width: Self.interpolate(178, 234.94845581054688, progress: progress),
                height: Self.interpolate(386, 517.3333740234375, progress: progress)
            )
            outerCornerRadius = Self.interpolate(32, 46, progress: progress)
            slotCornerRadius = Self.interpolate(24, 36, progress: progress)
            outerBorderWidth = Self.interpolate(2, 3, progress: progress)
        }

        private static func interpolate(
            _ from: CGFloat,
            _ to: CGFloat,
            progress: CGFloat
        ) -> CGFloat {
            from + (to - from) * progress
        }
    }
}

private struct BottomSheetOnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isSheetPresented = false

    private let items: [BottomSheetStyleOnboarding.Item] = [
        .init(
            id: 0,
            title: "Новый онбординг",
            subtitle: "Умеет показывать вверх телефона",
            media: .phone(
                imageName: "OnboardingScreen2",
                viewport: .top
            ),
            buttonTitle: "Далее"
        ),
        .init(
            id: 1,
            title: "Продолжение онбординга",
            subtitle: "Умеет показывать низ телефон",
            media: .phone(
                imageName: "OnboardingScreen4",
                viewport: .bottom
            ),
            buttonTitle: "Далее"
        ),
        .init(
            id: 2,
            title: "И напоследок",
            subtitle: "Умеет показывать картинку",
            media: .illustration,
            buttonTitle: "Спасибо"
        )
    ]

    var body: some View {
        Color.clear
            .overlay {
                Image("OnboardingBottomSheetBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .clipped()
            .ignoresSafeArea()
            .toolbar(.hidden, for: .navigationBar)
            .statusBarHidden(true)
            .task { isSheetPresented = true }
            .sheet(isPresented: $isSheetPresented, onDismiss: { dismiss() }) {
                BottomSheetStyleOnboarding(items: items)
            }
    }
}

private struct BottomSheetStyleOnboarding: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    let items: [Item]

    @State private var currentIndex = 0
    @State private var dragTranslation: CGFloat = 0

    private let sheetContentHeight: CGFloat = 472
    private let sheetBottomPadding: CGFloat = 20
    private let sheetDetentHeight: CGFloat = 465

    var body: some View {
        GeometryReader { geometry in
            let pageWidth = geometry.size.width

            VStack(spacing: 0) {
                mediaCarousel(pageWidth: pageWidth)
                    .frame(height: 300)
                    .clipped()
                    .contentShape(Rectangle())
                    .simultaneousGesture(pageDragGesture(pageWidth: pageWidth))

                copyView(pageWidth: pageWidth)
                    .frame(height: 77)
                    .padding(.horizontal, 16)
                    .background(sheetBackgroundColor)
                    .overlay(alignment: .top) {
                        mediaDivider(pageWidth: pageWidth)
                            .padding(.horizontal, 16)
                    }

                indicatorView(pageWidth: pageWidth)
                    .padding(.top, 13)

                continueButton
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
            }
            .frame(
                height: sheetContentHeight + sheetBottomPadding,
                alignment: .top
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .presentationDetents([.height(sheetDetentHeight)])
        .presentationBackground(sheetBackgroundColor)
        .presentationDragIndicator(.visible)
    }

    private func mediaCarousel(pageWidth: CGFloat) -> some View {
        GeometryReader { geometry in
            ZStack {
                sheetBackgroundColor

                ForEach(items.indices, id: \.self) { index in
                    let isActive = index == currentIndex
                    let relativePage = reduceMotion
                        ? CGFloat(index - currentIndex)
                        : relativePage(for: index, pageWidth: pageWidth)

                    mediaContent(
                        for: items[index].media,
                        availableSize: geometry.size
                    )
                    .modifier(
                        IllustrationArcCarouselModifier(
                            relativePage: reduceMotion ? 0 : relativePage,
                            pageWidth: pageWidth,
                            arcHeight: 64
                        )
                    )
                    .opacity(reduceMotion ? (isActive ? 1 : 0) : 1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(pageAnimation, value: currentIndex)
        }
        .accessibilityHidden(true)
    }

    private func mediaDivider(pageWidth: CGFloat) -> some View {
        LinearGradient(
            stops: [
                .init(color: mediaDividerColor.opacity(0), location: 0),
                .init(color: mediaDividerColor.opacity(0.10), location: 0.20),
                .init(color: mediaDividerColor.opacity(0.10), location: 0.80),
                .init(color: mediaDividerColor.opacity(0), location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
        .opacity(mediaDividerVisibility(pageWidth: pageWidth))
        .animation(mediaDividerAnimation, value: currentIndex)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func mediaContent(
        for media: Item.Media,
        availableSize: CGSize
    ) -> some View {
        switch media {
        case let .phone(imageName, viewport):
            let outerWidth = min(availableSize.width - 54, 222)
            let outerHeight = phoneOuterHeight(for: outerWidth)
            let yOffset = switch viewport {
            case .top:
                CGFloat(44)
            case .bottom:
                availableSize.height - 24 - outerHeight
            }

            phoneScreen(imageName: imageName, outerWidth: outerWidth)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .offset(y: yOffset)

        case .illustration:
            let illustrationWidth = min(availableSize.width - 54, 313) * 0.9

            Image("OnboardingBottomSheetIllustration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: illustrationWidth)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
                .offset(y: 15)
        }
    }

    private func phoneScreen(imageName: String, outerWidth: CGFloat) -> some View {
        let frameInset: CGFloat = 7
        let screenWidth = outerWidth - frameInset * 2
        let screenSize = CGSize(
            width: screenWidth,
            height: screenWidth * (2622 / 1206)
        )

        return OnboardingDeviceFrame(size: screenSize) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: screenSize.width, height: screenSize.height)
        }
        .padding(frameInset)
    }

    private func phoneOuterHeight(for outerWidth: CGFloat) -> CGFloat {
        let frameInset: CGFloat = 7
        let screenWidth = outerWidth - frameInset * 2
        return screenWidth * (2622 / 1206) + frameInset * 2
    }

    private func copyView(pageWidth: CGFloat) -> some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    let relativePage = reduceMotion
                        ? CGFloat(index - currentIndex)
                        : relativePage(for: index, pageWidth: pageWidth)
                    let distance = min(abs(relativePage), 1)

                    VStack(spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 20, weight: .bold))
                            .tracking(0.38)
                            .lineLimit(1)
                            .foregroundStyle(primaryTextColor)

                        Text(item.subtitle)
                            .font(.system(size: 17, weight: .regular))
                            .tracking(-0.41)
                            .lineLimit(1)
                            .foregroundStyle(secondaryTextColor)
                    }
                    .frame(width: geometry.size.width)
                    .compositingGroup()
                    .offset(
                        x: reduceMotion
                            ? 0
                            : relativePage * pageWidth
                    )
                    .blur(radius: 30 * distance)
                    .opacity(1 - distance)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(pageAnimation, value: currentIndex)
        }
    }

    private func indicatorView(pageWidth: CGFloat) -> some View {
        HStack(spacing: 6) {
            ForEach(items.indices, id: \.self) { index in
                let visibility = reduceMotion
                    ? (index == currentIndex ? 1.0 : 0.0)
                    : pageVisibility(for: index, pageWidth: pageWidth)

                Capsule()
                    .fill(pageIndicatorInactiveColor)
                    .overlay {
                        Capsule()
                            .fill(pageIndicatorActiveColor)
                            .opacity(visibility)
                    }
                    .frame(width: 6 + 19 * visibility, height: 6)
            }
        }
        .animation(pageAnimation, value: currentIndex)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Страница \(currentIndex + 1) из \(items.count)")
    }

    private var continueButton: some View {
        Button {
            withAnimation(pageAnimation) {
                currentIndex = currentIndex == items.count - 1
                    ? 0
                    : currentIndex + 1
                dragTranslation = 0
            }
        } label: {
            Text(items[currentIndex].buttonTitle)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(
                    Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .contentShape(Rectangle())
                .modifier(OnboardingYellowButtonSurfaceModifier())
                .transaction { transaction in
                    transaction.animation = nil
                }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func relativePage(for index: Int, pageWidth: CGFloat) -> CGFloat {
        guard pageWidth > 0 else {
            return CGFloat(index - currentIndex)
        }

        return CGFloat(index - currentIndex) + dragTranslation / pageWidth
    }

    private func pageVisibility(for index: Int, pageWidth: CGFloat) -> Double {
        let distance = min(abs(relativePage(for: index, pageWidth: pageWidth)), 1)
        return 1 - distance
    }

    private func pageDragGesture(pageWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else {
                    dragTranslation = 0
                    return
                }

                let rawTranslation = value.translation.width
                let isAtFirstPage = currentIndex == 0 && rawTranslation > 0
                let isAtLastPage = currentIndex == items.count - 1 && rawTranslation < 0

                if isAtFirstPage || isAtLastPage {
                    dragTranslation = rawTranslation.sign == .minus
                        ? -min(abs(rawTranslation) * 0.24, 72)
                        : min(abs(rawTranslation) * 0.24, 72)
                } else {
                    dragTranslation = min(max(rawTranslation, -pageWidth), pageWidth)
                }
            }
            .onEnded { value in
                let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                let projectedTranslation = value.predictedEndTranslation.width
                let distanceThreshold = pageWidth * 0.18
                let projectedThreshold = pageWidth * 0.28
                var targetIndex = currentIndex

                if isHorizontal,
                   (value.translation.width < -distanceThreshold
                       || projectedTranslation < -projectedThreshold) {
                    targetIndex = min(currentIndex + 1, items.count - 1)
                } else if isHorizontal,
                          (value.translation.width > distanceThreshold
                              || projectedTranslation > projectedThreshold) {
                    targetIndex = max(currentIndex - 1, 0)
                }

                withAnimation(pageAnimation) {
                    currentIndex = targetIndex
                    dragTranslation = 0
                }
            }
    }

    private var sheetBackgroundColor: Color {
        colorScheme == .dark
            ? Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
            : Color(.systemBackground)
    }

    private var mediaDividerColor: Color {
        colorScheme == .dark
            ? .white
            : Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)
    }

    private func mediaDividerVisibility(pageWidth: CGFloat) -> Double {
        let visibility = items.indices.reduce(0.0) { result, index in
            guard items[index].media.usesPhoneFrame else {
                return result
            }

            return result + pageVisibility(for: index, pageWidth: pageWidth)
        }

        let baseVisibility = min(visibility, 1)
        guard pageWidth > 0,
              items.indices.contains(currentIndex),
              items[currentIndex].media.usesPhoneFrame,
              dragTranslation < 0 else {
            return baseVisibility
        }

        let nextIndex = currentIndex + 1
        guard items.indices.contains(nextIndex),
              !items[nextIndex].media.usesPhoneFrame else {
            return baseVisibility
        }

        let transitionProgress = min(max(-dragTranslation / pageWidth, 0), 1)
        let acceleratedVisibility = max(0, 1 - transitionProgress / 0.30)
        return min(baseVisibility, acceleratedVisibility)
    }

    private var mediaDividerAnimation: Animation {
        guard items.indices.contains(currentIndex),
              !items[currentIndex].media.usesPhoneFrame else {
            return pageAnimation
        }

        return reduceMotion
            ? .linear(duration: 0.08)
            : .easeOut(duration: 0.13)
    }

    private var primaryTextColor: Color {
        colorScheme == .dark
            ? .white
            : Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)
    }

    private var secondaryTextColor: Color {
        Color(red: 146 / 255, green: 153 / 255, blue: 162 / 255)
    }

    private var pageIndicatorActiveColor: Color {
        colorScheme == .dark ? .white.opacity(0.92) : primaryTextColor
    }

    private var pageIndicatorInactiveColor: Color {
        colorScheme == .dark
            ? .white.opacity(0.22)
            : Color(red: 0, green: 16 / 255, blue: 36 / 255).opacity(0.12)
    }

    private var pageAnimation: Animation {
        reduceMotion
            ? .easeInOut(duration: 0.2)
            : .interpolatingSpring(duration: 0.65, bounce: 0, initialVelocity: 0)
    }

    struct Item: Identifiable {
        enum Media {
            enum PhoneViewport {
                case top
                case bottom
            }

            case phone(imageName: String, viewport: PhoneViewport)
            case illustration

            var usesPhoneFrame: Bool {
                switch self {
                case .phone:
                    true
                case .illustration:
                    false
                }
            }
        }

        let id: Int
        let title: String
        let subtitle: String
        let media: Media
        let buttonTitle: String
    }
}

private struct InterfaceOnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        IOS26StyleOnboarding(
            hideBezels: false,
            items: [
                .init(
                    id: 0,
                    title: "Встречайте редизайн",
                    subtitle: "Фокусируем внимание\nна действительно важном",
                    media: .video(
                        poster: UIImage(named: "OnboardingScreen1"),
                        resourceName: "OnboardingInterface1Light",
                        darkResourceName: "OnboardingInterface1Dark"
                    )
                ),
                .init(
                    id: 1,
                    title: "Если важных счетов больше",
                    subtitle: "Переключайтесь на другое\nотображения главной",
                    media: .image(poster: UIImage(named: "OnboardingScreen2"))
                ),
                .init(
                    id: 2,
                    title: "Новое нижнее меню",
                    subtitle: "Все необходимое всегда\nпод рукой",
                    media: .image(poster: UIImage(named: "OnboardingScreen4")),
                    phonePresentation: .largeBottom
                ),
                .init(
                    id: 3,
                    title: "Центр уведомлений",
                    subtitle: "Собрали все события\nв одном месте",
                    media: .image(poster: UIImage(named: "OnboardingScreen3")),
                    phonePresentation: .largeTop
                ),
                .init(
                    id: 4,
                    title: "Настраивайте под себя",
                    subtitle: "Выберите отображение главной\nи необходимые счета",
                    media: .image(poster: UIImage(named: "OnboardingScreen5"))
                )
            ],
            onBackFromFirstPage: { dismiss() }
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct IOS26StyleOnboarding: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase

    var hideBezels = false
    var items: [Item]
    var onBackFromFirstPage: () -> Void

    @State private var currentIndex = 0
    @State private var dragTranslation: CGFloat = 0
    @State private var swipeHapticTrigger = 0

    var body: some View {
        GeometryReader { geometry in
            let pictureAreaHeight = max(360, geometry.size.height - 328)
            let bottomSafeArea = max(geometry.safeAreaInsets.bottom, 34)
            let topSafeArea = max(geometry.safeAreaInsets.top, 44)

            ZStack(alignment: .top) {
                backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    pictureAreaView(
                        pageWidth: geometry.size.width,
                        size: CGSize(
                            width: geometry.size.width,
                            height: pictureAreaHeight
                        )
                    )
                    .frame(height: pictureAreaHeight)
                    .clipped()

                    VStack(spacing: 0) {
                        textContentView(pageWidth: geometry.size.width)
                            .frame(height: 116)

                        indicatorView(pageWidth: geometry.size.width)
                            .padding(.top, 32)

                        continueButton
                            .padding(.top, 15)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24 + bottomSafeArea)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .background(backgroundColor)
                }

                backButton(topInset: topSafeArea)
            }
            .contentShape(Rectangle())
            .simultaneousGesture(pageDragGesture(pageWidth: geometry.size.width))
            .sensoryFeedback(.selection, trigger: swipeHapticTrigger)
        }
        .ignoresSafeArea()
    }

    private func pictureAreaView(pageWidth: CGFloat, size: CGSize) -> some View {
        let phoneLayout = interactivePhoneLayout(
            pageWidth: pageWidth,
            pictureAreaHeight: size.height
        )

        return ZStack(alignment: .top) {
            FigmaPhoneMockupFrame(
                size: phoneLayout.size,
                hidesBezels: hideBezels
            ) { viewportSize in
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]

                    mediaView(
                        for: item,
                        isActive: currentIndex == index
                    )
                    .frame(
                        width: viewportSize.width,
                        height: viewportSize.height
                    )
                    .offset(
                        x: CGFloat(index - currentIndex)
                            * (viewportSize.width + 12)
                            + dragTranslation
                    )
                }
            }
            .position(
                x: size.width / 2,
                y: phoneLayout.top + phoneLayout.size.height / 2
            )

            ZStack(alignment: .top) {
                // Navbar fade hides the top arch of the large-bottom phone.
                LinearGradient(
                    stops: [
                        .init(color: backgroundColor, location: 0),
                        .init(color: backgroundColor, location: 0.28),
                        .init(color: backgroundColor.opacity(0), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 98)

                // Slot fade continues below the navbar so the vertical phone
                // edges emerge gradually, matching the Figma composition.
                LinearGradient(
                    stops: [
                        .init(color: backgroundColor, location: 0),
                        .init(color: backgroundColor, location: 0.28),
                        .init(color: backgroundColor.opacity(0), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                .padding(.top, 32)
            }
            .frame(height: 132)
            .frame(maxHeight: .infinity, alignment: .top)
            .opacity(largeBottomBlurVisibility(pageWidth: pageWidth))

            LinearGradient(
                colors: [backgroundColor.opacity(0), backgroundColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 80)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .opacity(largeTopBlurVisibility(pageWidth: pageWidth))
        }
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func mediaView(
        for item: Item,
        isActive: Bool
    ) -> some View {
        ZStack {
            if let poster = item.media.poster {
                Image(uiImage: poster)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.black)
            }

            if let resourceName = item.media.videoResourceName(for: colorScheme),
               Bundle.main.url(forResource: resourceName, withExtension: "mp4") != nil {
                OnboardingVideoView(
                    resourceName: resourceName,
                    isPlaying: isActive && scenePhase == .active,
                    posterDuration: 1.5
                )
            }
        }
        .clipped()
    }

    private func textContentView(pageWidth: CGFloat) -> some View {
        GeometryReader { geometry in
            let size = geometry.size

            ZStack {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    let relativePage = relativePage(for: index, pageWidth: pageWidth)
                    let distance = min(abs(relativePage), 1)

                    VStack(spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 20, weight: .bold))
                            .tracking(0.38)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(primaryTextColor)

                        Text(item.subtitle)
                            .font(.system(size: 17, weight: .regular))
                            .tracking(-0.41)
                            .lineLimit(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(secondaryTextColor)
                    }
                    .frame(width: size.width)
                    .compositingGroup()
                    .offset(x: relativePage * pageWidth)
                    .blur(radius: reduceMotion ? 0 : 30 * distance)
                    .opacity(1 - distance)
                }
            }
        }
    }

    private func indicatorView(pageWidth: CGFloat) -> some View {
        Group {
            if items.count > 1 {
                HStack(spacing: 7) {
                    ForEach(items.indices, id: \.self) { index in
                        let visibility = pageVisibility(for: index, pageWidth: pageWidth)

                        Circle()
                            .fill(pageIndicatorInactiveColor)
                            .overlay {
                                Circle()
                                    .fill(pageIndicatorActiveColor)
                                    .opacity(visibility)
                            }
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
        .frame(height: 14)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Страница \(currentIndex + 1) из \(items.count)")
    }

    private var continueButton: some View {
        Button {
            transition(to: currentIndex == items.count - 1 ? 0 : currentIndex + 1)
        } label: {
            Text(currentIndex == items.count - 1 ? "Настроить" : "Далее")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color("TUITextPrimaryOnAccent1"))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .contentShape(Rectangle())
                .modifier(InterfacePrimaryButtonSurfaceModifier())
        }
        .buttonStyle(InterfacePrimaryButtonStyle())
        .frame(maxWidth: 355)
    }

    private func backButton(topInset: CGFloat) -> some View {
        Button {
            guard currentIndex > 0 else {
                onBackFromFirstPage()
                return
            }

            transition(to: currentIndex - 1)
        } label: {
            Image(systemName: "chevron.left")
                .font(.title3)
                .frame(width: 20, height: 30)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .foregroundStyle(primaryTextColor)
        .accessibilityLabel("Назад")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, 16)
        .padding(.top, topInset)
    }

    private func relativePage(for index: Int, pageWidth: CGFloat) -> CGFloat {
        guard pageWidth > 0 else {
            return CGFloat(index - currentIndex)
        }

        return CGFloat(index - currentIndex) + dragTranslation / pageWidth
    }

    private func pageVisibility(for index: Int, pageWidth: CGFloat) -> Double {
        let distance = min(abs(relativePage(for: index, pageWidth: pageWidth)), 1)
        return 1 - distance
    }

    private func transitionTargetIndex() -> Int {
        if dragTranslation < 0 {
            return min(currentIndex + 1, items.count - 1)
        }

        if dragTranslation > 0 {
            return max(currentIndex - 1, 0)
        }

        return currentIndex
    }

    private func transitionProgress(pageWidth: CGFloat) -> CGFloat {
        guard pageWidth > 0 else {
            return 0
        }

        return min(abs(dragTranslation) / pageWidth, 1)
    }

    private func interactivePhoneLayout(
        pageWidth: CGFloat,
        pictureAreaHeight: CGFloat
    ) -> PhoneLayout {
        let targetIndex = transitionTargetIndex()
        let progress = transitionProgress(pageWidth: pageWidth)
        let currentLayout = items[currentIndex].phonePresentation.layout(
            pictureAreaHeight: pictureAreaHeight
        )
        let targetLayout = items[targetIndex].phonePresentation.layout(
            pictureAreaHeight: pictureAreaHeight
        )

        return PhoneLayout(
            size: CGSize(
                width: currentLayout.size.width
                    + (targetLayout.size.width - currentLayout.size.width) * progress,
                height: currentLayout.size.height
                    + (targetLayout.size.height - currentLayout.size.height) * progress
            ),
            top: currentLayout.top + (targetLayout.top - currentLayout.top) * progress
        )
    }

    private func largeTopBlurVisibility(pageWidth: CGFloat) -> Double {
        let targetIndex = transitionTargetIndex()
        let progress = Double(transitionProgress(pageWidth: pageWidth))
        let isLeavingLargeTop = items[currentIndex].phonePresentation == .largeTop
            && items[targetIndex].phonePresentation != .largeTop
        let isEnteringLargeTop = items[currentIndex].phonePresentation != .largeTop
            && items[targetIndex].phonePresentation == .largeTop

        if isLeavingLargeTop {
            let delayedProgress = normalizedProgress(
                progress,
                startingAt: 0.72
            )

            return 1 - smoothStep(delayedProgress)
        }

        if isEnteringLargeTop {
            // The large phone reaches the lower edge of the picture area at
            // roughly 8% of the bottom-to-top transition. Finish revealing
            // the gradient before that point so the clipped phone edge never
            // becomes visible as a hard horizontal line.
            return smoothStep(min(progress / 0.08, 1))
        }

        return items[currentIndex].phonePresentation == .largeTop ? 1 : 0
    }

    private func normalizedProgress(
        _ progress: Double,
        startingAt start: Double
    ) -> Double {
        guard start < 1 else {
            return progress >= 1 ? 1 : 0
        }

        return min(max((progress - start) / (1 - start), 0), 1)
    }

    private func smoothStep(_ progress: Double) -> Double {
        progress * progress * (3 - 2 * progress)
    }

    private func largeBottomBlurVisibility(pageWidth: CGFloat) -> Double {
        let targetIndex = transitionTargetIndex()
        let progress = Double(transitionProgress(pageWidth: pageWidth))
        let currentOpacity = items[currentIndex].phonePresentation == .largeBottom ? 1.0 : 0.0
        let targetOpacity = items[targetIndex].phonePresentation == .largeBottom ? 1.0 : 0.0

        return currentOpacity + (targetOpacity - currentOpacity) * progress
    }

    private func pageDragGesture(pageWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else {
                    dragTranslation = 0
                    return
                }

                let rawTranslation = value.translation.width
                let isAtFirstPage = currentIndex == 0 && rawTranslation > 0
                let isAtLastPage = currentIndex == items.count - 1 && rawTranslation < 0

                if isAtFirstPage || isAtLastPage {
                    dragTranslation = rawTranslation.sign == .minus
                        ? -min(abs(rawTranslation) * 0.24, 72)
                        : min(abs(rawTranslation) * 0.24, 72)
                } else {
                    dragTranslation = min(max(rawTranslation, -pageWidth), pageWidth)
                }
            }
            .onEnded { value in
                let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                let projectedTranslation = value.predictedEndTranslation.width
                let distanceThreshold = pageWidth * 0.18
                let projectedThreshold = pageWidth * 0.28
                var targetIndex = currentIndex

                if isHorizontal,
                   (value.translation.width < -distanceThreshold
                       || projectedTranslation < -projectedThreshold) {
                    targetIndex = min(currentIndex + 1, items.count - 1)
                } else if isHorizontal,
                          (value.translation.width > distanceThreshold
                              || projectedTranslation > projectedThreshold) {
                    targetIndex = max(currentIndex - 1, 0)
                }

                if targetIndex != currentIndex {
                    swipeHapticTrigger += 1
                }

                withAnimation(animation) {
                    currentIndex = targetIndex
                    dragTranslation = 0
                }
            }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    private var primaryTextColor: Color {
        colorScheme == .dark
            ? .white
            : Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)
    }

    private var secondaryTextColor: Color {
        Color("TUITextSecondary")
    }

    private var pageIndicatorActiveColor: Color {
        colorScheme == .dark ? .white.opacity(0.92) : primaryTextColor
    }

    private var pageIndicatorInactiveColor: Color {
        colorScheme == .dark
            ? .white.opacity(0.22)
            : Color(red: 0, green: 16 / 255, blue: 36 / 255).opacity(0.12)
    }

    struct Item: Identifiable {
        var id: Int
        var title: String
        var subtitle: String
        var media: OnboardingMedia
        var phonePresentation: PhonePresentation = .default
    }

    fileprivate struct PhoneLayout {
        let size: CGSize
        let top: CGFloat
    }

    // Mirrors the three iOS phone variants from the Figma component.
    enum PhonePresentation: Equatable {
        case `default`
        case largeTop
        case largeBottom

        fileprivate func layout(pictureAreaHeight: CGFloat) -> PhoneLayout {
            switch self {
            case .default:
                let size = CGSize(width: 198, height: 406)
                let slotTop: CGFloat = 32
                let slotHeight = max(0, pictureAreaHeight - slotTop)

                return PhoneLayout(
                    size: size,
                    top: slotTop + max(0, (slotHeight - size.height) / 2)
                )
            case .largeTop:
                return PhoneLayout(
                    size: CGSize(width: 260, height: 542),
                    top: 122
                )
            case .largeBottom:
                let size = CGSize(width: 260, height: 542)

                return PhoneLayout(
                    size: size,
                    top: pictureAreaHeight - 16 - size.height
                )
            }
        }
    }

    private var animation: Animation {
        reduceMotion
            ? .easeInOut(duration: 0.2)
            : .interpolatingSpring(duration: 0.65, bounce: 0, initialVelocity: 0)
    }

    private func transition(to targetIndex: Int) {
        guard items.indices.contains(targetIndex), targetIndex != currentIndex else {
            return
        }

        withAnimation(animation) {
            currentIndex = targetIndex
            dragTranslation = 0
        }

        swipeHapticTrigger += 1
    }
}

private struct LongreadOnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        LongreadStyleOnboarding(
            items: [
                .init(
                    id: 0,
                    caption: "Шаг 1",
                    title: "Как поменять вид главной",
                    description: "Нажмите на кнопку “Счета и карт”\nвверху главного экрана",
                    media: .video(
                        poster: UIImage(named: "OnboardingScreen1"),
                        resourceName: "OnboardingInterface1Light",
                        darkResourceName: "OnboardingInterface1Dark"
                    ),
                    mediaHeight: 302
                ),
                .init(
                    id: 1,
                    caption: "Шаг 2",
                    title: "Зайти в настройки",
                    description: "Выберите компактный вид и нажмите\nгалочку в правом вверхнем угле",
                    media: .image(poster: UIImage(named: "OnboardingScreen5")),
                    mediaHeight: 257
                ),
                .init(
                    id: 2,
                    caption: "Шаг 3",
                    title: "Выбрать компактный вид",
                    media: .image(poster: UIImage(named: "OnboardingScreen2")),
                    mediaHeight: 274
                )
            ],
            primaryActionTitle: "К настройкам",
            onPrimaryAction: { dismiss() }
        )
        .navigationTitle("Про редизайн")
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct LongreadStyleOnboarding: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase

    var items: [Item]
    var primaryActionTitle: String
    var onPrimaryAction: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(items) { item in
                    cardView(for: item)
                }

                primaryButton
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(backgroundColor.ignoresSafeArea())
    }

    private func cardView(for item: Item) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            cardHeader(for: item)

            phoneFrame(for: item)
                .frame(height: item.mediaHeight, alignment: .top)
                .frame(maxWidth: .infinity)
                .clipped()
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 16)
    }

    private func cardHeader(for item: Item) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.caption)
                .font(.system(size: 13, weight: .medium))
                .textCase(.uppercase)
                .foregroundStyle(captionColor)
                .frame(height: 16, alignment: .center)

            Text(item.title)
                .font(.system(size: 20, weight: .bold))
                .tracking(0.38)
                .foregroundStyle(primaryTextColor)
                .fixedSize(horizontal: false, vertical: true)

            if let description = item.description {
                Text(description)
                    .font(.system(size: 15, weight: .regular))
                    .tracking(-0.24)
                    .foregroundStyle(captionColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .padding(.horizontal, 20)
    }

    private func phoneFrame(for item: Item) -> some View {
        // Ширина экрана телефона — как раньше (220 − 2·7).
        let screenWidth: CGFloat = 206
        // OnboardingDeviceFrame рисует безель на ~11pt наружу от края экрана.
        // Резервируем под него отступ, чтобы верх серого безеля не срезался обрезкой карточки.
        let bezelInset: CGFloat = 12
        let screenSize = CGSize(
            width: screenWidth,
            height: screenWidth * (2622 / 1206)
        )

        return OnboardingDeviceFrame(size: screenSize) {
            mediaContent(for: item, size: screenSize)
        }
        .padding(bezelInset)
    }

    @ViewBuilder
    private func mediaContent(for item: Item, size: CGSize) -> some View {
        ZStack {
            if let poster = item.media.poster {
                Image(uiImage: poster)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(.black)
            }

            if let resourceName = item.media.videoResourceName(for: colorScheme),
               Bundle.main.url(forResource: resourceName, withExtension: "mp4") != nil {
                OnboardingVideoView(
                    resourceName: resourceName,
                    isPlaying: scenePhase == .active,
                    posterDuration: 1.5
                )
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }

    private var primaryButton: some View {
        Button {
            onPrimaryAction()
        } label: {
            Text(primaryActionTitle)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .contentShape(Rectangle())
                .modifier(OnboardingYellowButtonSurfaceModifier())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    private var primaryTextColor: Color {
        colorScheme == .dark
            ? .white
            : Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)
    }

    private var captionColor: Color {
        Color(red: 146 / 255, green: 153 / 255, blue: 162 / 255)
    }

    private var cardBackgroundColor: Color {
        colorScheme == .dark
            ? Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
            : Color(red: 246 / 255, green: 247 / 255, blue: 248 / 255)
    }

    struct Item: Identifiable {
        var id: Int
        var caption: String
        var title: String
        var description: String? = nil
        var media: OnboardingMedia
        var mediaHeight: CGFloat = 302
    }
}

private enum OnboardingMedia {
    case image(poster: UIImage?)
    case video(
        poster: UIImage?,
        resourceName: String,
        darkResourceName: String? = nil
    )

    var poster: UIImage? {
        switch self {
        case let .image(poster), let .video(poster, _, _):
            poster
        }
    }

    func videoResourceName(for colorScheme: ColorScheme) -> String? {
        guard case let .video(_, resourceName, darkResourceName) = self else {
            return nil
        }

        return colorScheme == .dark ? darkResourceName ?? resourceName : resourceName
    }
}

private struct OnboardingVideoView: UIViewRepresentable {
    let resourceName: String
    let isPlaying: Bool
    let posterDuration: TimeInterval

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> OnboardingPlayerView {
        let view = OnboardingPlayerView()
        context.coordinator.update(
            playerLayer: view.playerLayer,
            resourceName: resourceName,
            isPlaying: isPlaying,
            posterDuration: posterDuration
        )
        return view
    }

    func updateUIView(_ uiView: OnboardingPlayerView, context: Context) {
        context.coordinator.update(
            playerLayer: uiView.playerLayer,
            resourceName: resourceName,
            isPlaying: isPlaying,
            posterDuration: posterDuration
        )
    }

    static func dismantleUIView(_ uiView: OnboardingPlayerView, coordinator: Coordinator) {
        coordinator.stop(playerLayer: uiView.playerLayer)
    }

    @MainActor
    final class Coordinator {
        private var player: AVQueuePlayer?
        private var looper: AVPlayerLooper?
        private var loadedResourceName: String?
        private var wasPlaying = false
        private var playbackStarted = false
        private var pendingPlayback: DispatchWorkItem?
        private var pendingReveal: DispatchWorkItem?

        func update(
            playerLayer: AVPlayerLayer,
            resourceName: String,
            isPlaying: Bool,
            posterDuration: TimeInterval
        ) {
            if loadedResourceName != resourceName {
                configure(playerLayer: playerLayer, resourceName: resourceName)
            }

            guard let player, wasPlaying != isPlaying else {
                return
            }

            wasPlaying = isPlaying
            pendingPlayback?.cancel()
            pendingReveal?.cancel()

            if isPlaying {
                let playback = DispatchWorkItem { [weak self] in
                    guard let self, self.wasPlaying else { return }
                    self.playbackStarted = true
                    self.player?.play()
                    self.revealVideoWhenReady(on: playerLayer)
                }
                pendingPlayback = playback
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + posterDuration,
                    execute: playback
                )
            } else {
                playbackStarted = false
                setVideoVisible(false, on: playerLayer)
                player.pause()
                player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }

        func stop(playerLayer: AVPlayerLayer) {
            pendingPlayback?.cancel()
            pendingPlayback = nil
            pendingReveal?.cancel()
            pendingReveal = nil
            playbackStarted = false
            setVideoVisible(false, on: playerLayer)
            player?.pause()
            player?.removeAllItems()
            playerLayer.player = nil
            player = nil
            looper = nil
            loadedResourceName = nil
            wasPlaying = false
        }

        private func configure(playerLayer: AVPlayerLayer, resourceName: String) {
            stop(playerLayer: playerLayer)

            guard let url = Bundle.main.url(forResource: resourceName, withExtension: "mp4") else {
                return
            }

            let player = AVQueuePlayer()
            let item = AVPlayerItem(url: url)

            player.isMuted = true
            player.automaticallyWaitsToMinimizeStalling = true
            playerLayer.player = player
            setVideoVisible(false, on: playerLayer)

            self.player = player
            looper = AVPlayerLooper(player: player, templateItem: item)
            loadedResourceName = resourceName
        }

        private func revealVideoWhenReady(on playerLayer: AVPlayerLayer) {
            guard wasPlaying, playbackStarted else {
                return
            }

            guard playerLayer.isReadyForDisplay else {
                let reveal = DispatchWorkItem { [weak self, weak playerLayer] in
                    guard let self, let playerLayer else { return }
                    self.revealVideoWhenReady(on: playerLayer)
                }
                pendingReveal = reveal
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 1.0 / 60.0,
                    execute: reveal
                )
                return
            }

            pendingReveal = nil
            setVideoVisible(true, animated: true, on: playerLayer)
        }

        private func setVideoVisible(
            _ isVisible: Bool,
            animated: Bool = false,
            on playerLayer: AVPlayerLayer
        ) {
            let opacity = isVisible ? Float(1) : Float(0)
            let currentOpacity = playerLayer.presentation()?.opacity ?? playerLayer.opacity

            playerLayer.removeAnimation(forKey: "onboardingVideoReveal")
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            playerLayer.opacity = opacity
            CATransaction.commit()

            guard animated, isVisible else {
                return
            }

            let reveal = CABasicAnimation(keyPath: "opacity")
            reveal.fromValue = currentOpacity
            reveal.toValue = opacity
            reveal.duration = 0.1
            reveal.timingFunction = CAMediaTimingFunction(name: .easeOut)
            playerLayer.add(reveal, forKey: "onboardingVideoReveal")
        }
    }
}

private final class OnboardingPlayerView: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = .clear
        isOpaque = false
        playerLayer.backgroundColor = UIColor.clear.cgColor
        playerLayer.videoGravity = .resizeAspectFill
    }
}

private struct OnboardingYellowButtonSurfaceModifier: ViewModifier {
    private let yellow = Color(red: 1, green: 221 / 255, blue: 45 / 255)

    func body(content: Content) -> some View {
        content.glassEffect(
            .regular
                .tint(yellow.opacity(0.86))
                .interactive(),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }
}

private struct InterfacePrimaryButtonSurfaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            Color("TUIBackgroundAccent1"),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }
}

private struct InterfacePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.82 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

private struct OnboardingViewPreview: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OnboardingView()
        }
    }
}
