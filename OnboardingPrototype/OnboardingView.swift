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
                    subtitle: "Оплачивайте часть суммы сразу.\nОстальное — потом, равными частями.\nПлатежи списываются автоматически\nкаждые две недели",
                    imageName: "OnboardingIllustrationShopping",
                    imageAlignment: .bottom,
                    buttonTitle: "Далее",
                    textLayout: .maximum
                ),
                .init(
                    id: 1,
                    title: "Включайте Долями",
                    subtitle: "Платите за покупки частями",
                    imageName: "OnboardingIllustrationInstallments",
                    buttonTitle: "Включить",
                    textLayout: .minimum
                ),
                .init(
                    id: 2,
                    title: "Покупайте сейчас\nи платите постепенно",
                    subtitle: "Разделите оплату на части.\nПервый платёж спишется сразу,\nостальные — каждые две недели",
                    imageName: "OnboardingIllustrationShopping",
                    imageAlignment: .bottom,
                    buttonTitle: "Понятно",
                    textLayout: .medium
                ),
                .init(
                    id: 3,
                    title: "Новый онбординг\nдля интерфейсных изменений",
                    subtitle: "Здесь мы пишем что-то необходимое.\nПостарайтесь уложиться в 2–3 строки\nМаксимум в 4",
                    imageName: "OnboardingIllustrationShopping",
                    imageAlignment: .bottom,
                    buttonTitle: "Далее",
                    secondaryButtonTitle: "Secondary action",
                    textLayout: .twoButtons
                )
            ],
            onBackFromFirstPage: { dismiss() }
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct IllustrationStyleOnboarding: View {
    private static let maximumTitleLines = 2
    private static let maximumSubtitleLines = 4
    private static let copySpacing: CGFloat = 8
    private static let twoButtonSpacing: CGFloat = 16
    private static let maximumCopyHeight =
        ceil(UIFont.systemFont(ofSize: 20, weight: .bold).lineHeight)
            * CGFloat(maximumTitleLines)
        + copySpacing
        + ceil(UIFont.systemFont(ofSize: 17, weight: .regular).lineHeight)
            * CGFloat(maximumSubtitleLines)
    private static let fixedBottomReferenceHeight: CGFloat = 380

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    let items: [Item]
    let onBackFromFirstPage: () -> Void

    @State private var currentIndex = 0
    @State private var dragTranslation: CGFloat = 0
    @State private var swipeHapticTrigger = 0

    var body: some View {
        GeometryReader { geometry in
            let bottomSafeArea = max(geometry.safeAreaInsets.bottom, 34)
            let topSafeArea = max(geometry.safeAreaInsets.top, 44)
            let bottomHeight = fixedBottomHeight(bottomSafeArea: bottomSafeArea)
            let pictureAreaHeight = max(280, geometry.size.height - bottomHeight)

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

                    bottomView(
                        pageWidth: geometry.size.width,
                        bottomSafeArea: bottomSafeArea
                    )
                    .frame(height: bottomHeight)
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
        let slotTopPadding: CGFloat = 48
        let slotHorizontalPadding: CGFloat = 16
        let slotVerticalPadding: CGFloat = 12
        let slotWidth = max(0, size.width - slotHorizontalPadding * 2)
        let slotHeight = max(0, size.height - slotTopPadding)
        let imageHeight = max(0, slotHeight - slotVerticalPadding * 2)
        let fittedImageSide = min(slotWidth, imageHeight)
        let glowSide = fittedImageSide * 0.75

        return ZStack(alignment: .bottom) {
            ZStack {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    let isActive = index == currentIndex
                    let relativePage = reduceMotion
                        ? CGFloat(index - currentIndex)
                        : relativePage(for: index, pageWidth: pageWidth)
                    let visibility = pageVisibility(for: index, pageWidth: pageWidth)

                    Image(item.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: glowSide,
                            height: glowSide,
                            alignment: item.imageAlignment
                        )
                        .clipped()
                        .scaleEffect(1.08)
                        .saturation(colorScheme == .dark ? 1.18 : 1.30)
                        .blur(radius: 42)
                        .opacity(visibility * (colorScheme == .dark ? 0.20 : 0.14))

                    Image(item.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: slotWidth,
                            height: imageHeight
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
            .frame(width: slotWidth, height: imageHeight)
            .position(
                x: size.width / 2,
                y: slotTopPadding + slotHeight / 2
            )

            LinearGradient(
                colors: [backgroundColor.opacity(0), backgroundColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 80)
        }
        .frame(width: size.width, height: size.height)
        .animation(pageAnimation, value: currentIndex)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func bottomView(
        pageWidth: CGFloat,
        bottomSafeArea: CGFloat
    ) -> some View {
        ZStack(alignment: .top) {
            copyView(pageWidth: pageWidth)
                .frame(height: Self.maximumCopyHeight, alignment: .top)
                .padding(.top, 32)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                indicatorView(pageWidth: pageWidth)
                    .padding(.bottom, 12)

                VStack(spacing: 0) {
                    continueButton

                    if let secondaryButtonTitle = items[currentIndex].secondaryButtonTitle {
                        secondaryButton(title: secondaryButtonTitle)
                            .padding(.top, Self.twoButtonSpacing)
                    }
                }
                .padding(.horizontal, 16)
                .padding(
                    .bottom,
                    items[currentIndex].secondaryButtonTitle == nil ? 24 : 20
                )

                Color.clear
                    .frame(height: bottomSafeArea)
            }
        }
    }

    private func copyView(pageWidth: CGFloat) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    let relativePage = reduceMotion
                        ? CGFloat(index - currentIndex)
                        : relativePage(for: index, pageWidth: pageWidth)
                    let distance = min(abs(relativePage), 1)

                    VStack(spacing: Self.copySpacing) {
                        Text(item.title)
                            .font(.system(size: 20, weight: .bold))
                            .tracking(0.38)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(primaryTextColor)

                        Text(item.subtitle)
                            .font(.system(size: 17, weight: .regular))
                            .tracking(-0.41)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(secondaryTextColor)
                    }
                    .frame(
                        width: geometry.size.width,
                        height: Self.maximumCopyHeight,
                        alignment: .top
                    )
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
            .animation(pageAnimation, value: currentIndex)
        }
    }

    private func indicatorView(pageWidth: CGFloat) -> some View {
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
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor.opacity(0.3), in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Страница \(currentIndex + 1) из \(items.count)")
    }

    private var continueButton: some View {
        Button {
            transition(to: currentIndex == items.count - 1 ? 0 : currentIndex + 1)
        } label: {
            Text(items[currentIndex].buttonTitle)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color("TUITextPrimaryOnAccent1"))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .contentShape(Rectangle())
                .modifier(InterfacePrimaryButtonSurfaceModifier())
        }
        .buttonStyle(InterfacePrimaryButtonStyle())
    }

    private func secondaryButton(title: String) -> some View {
        Button {
            // The Figma component defines the secondary action visually only.
        } label: {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color(red: 66 / 255, green: 139 / 255, blue: 249 / 255))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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

                withAnimation(pageAnimation) {
                    currentIndex = targetIndex
                    dragTranslation = 0
                }
            }
    }

    private func fixedBottomHeight(bottomSafeArea: CGFloat) -> CGFloat {
        let safeAreaDelta = max(0, bottomSafeArea - 34)
        return Self.fixedBottomReferenceHeight + safeAreaDelta
    }

    private func transition(to targetIndex: Int) {
        guard items.indices.contains(targetIndex), targetIndex != currentIndex else {
            return
        }

        withAnimation(pageAnimation) {
            currentIndex = targetIndex
            dragTranslation = 0
        }

        swipeHapticTrigger += 1
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

    private var pageAnimation: Animation {
        reduceMotion
            ? .easeInOut(duration: 0.2)
            : .interpolatingSpring(duration: 0.65, bounce: 0, initialVelocity: 0)
    }

    struct Item: Identifiable {
        enum TextLayout {
            case maximum
            case medium
            case minimum
            case twoButtons

            var referenceBottomHeight: CGFloat {
                switch self {
                case .maximum:
                    336
                case .medium:
                    316
                case .minimum:
                    252
                case .twoButtons:
                    364
                }
            }
        }

        let id: Int
        let title: String
        let subtitle: String
        let imageName: String
        var imageAlignment: Alignment = .center
        let buttonTitle: String
        var secondaryButtonTitle: String? = nil
        let textLayout: TextLayout
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
                x: Self.interpolate(2 / 198, 3 / 260, progress: progress) * size.width,
                y: Self.interpolate(2 / 406, 2.669921875 / 542, progress: progress) * size.height,
                width: Self.interpolate(194 / 198, 254 / 260, progress: progress) * size.width,
                height: Self.interpolate(402 / 406, 536 / 542, progress: progress) * size.height
            )
            slotFrame = CGRect(
                x: Self.interpolate(10 / 198, 12.52587890625 / 260, progress: progress) * size.width,
                y: Self.interpolate(10 / 406, 12.00390625 / 542, progress: progress) * size.height,
                width: Self.interpolate(178 / 198, 234.94845581054688 / 260, progress: progress) * size.width,
                height: Self.interpolate(386 / 406, 517.3333740234375 / 542, progress: progress) * size.height
            )
            outerCornerRadius = Self.interpolate(32 / 198, 46 / 260, progress: progress) * size.width
            slotCornerRadius = Self.interpolate(24 / 198, 36 / 260, progress: progress) * size.width
            outerBorderWidth = Self.interpolate(2 / 198, 3 / 260, progress: progress) * size.width
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
            title: "Следите за всем важным",
            subtitle: "Все нужные обновления в одном месте",
            media: .illustration,
            buttonTitle: "Далее"
        ),
        .init(
            id: 1,
            title: "Все важные обновления\nтеперь всегда под рукой",
            subtitle: "Следите за новыми возможностями,\nбыстро находите нужные функции\nи управляйте всем в одном месте",
            media: .phone(
                imageName: "OnboardingScreen4",
                viewport: .bottom
            ),
            buttonTitle: "Далее"
        ),
        .init(
            id: 2,
            title: "Выбирайте удобный способ\nи продолжайте без лишних шагов",
            subtitle: "Настройте всё под себя\nили вернитесь к этому позже",
            media: .phone(
                imageName: "OnboardingScreen2",
                viewport: .top
            ),
            buttonTitle: "Далее",
            secondaryButtonTitle: "Secondary action"
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .overlay {
                    Image("OnboardingBottomSheetBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .clipped()
                .sheet(isPresented: $isSheetPresented, onDismiss: { dismiss() }) {
                    BottomSheetStyleOnboarding(
                        items: items,
                        screenWidth: geometry.size.width,
                        onClose: { isSheetPresented = false }
                    )
                }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .statusBarHidden(true)
        .task { isSheetPresented = true }
    }
}

private struct BottomSheetStyleOnboarding: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    let items: [Item]
    let screenWidth: CGFloat
    let onClose: () -> Void

    @State private var currentIndex = 0
    @State private var dragTranslation: CGFloat = 0

    private let mediaHeight: CGFloat = 284
    private let copySpacing: CGFloat = 8
    private let minimumCopyToPagerSpacing: CGFloat = 32
    private let pagerHeight: CGFloat = 32
    private let secondaryButtonSpacing: CGFloat = 8
    private let homeIndicatorInset: CGFloat = 34
    private let sheetHorizontalPadding: CGFloat = 0.8
    private let copyHorizontalPadding: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            let pageWidth = geometry.size.width

            VStack(spacing: 0) {
                mediaCarousel(pageWidth: pageWidth)
                    .frame(height: mediaHeight)
                    .clipped()
                    .contentShape(Rectangle())
                    .simultaneousGesture(pageDragGesture(pageWidth: pageWidth))

                copyView(pageWidth: pageWidth)
                    .frame(
                        height: copyHeight(for: items[currentIndex]),
                        alignment: .top
                    )
                    .padding(.top, 20)
                    .padding(.horizontal, copyHorizontalPadding)

                Color.clear
                    .frame(
                        height: copyToPagerSpacing(for: items[currentIndex])
                    )

                indicatorView(pageWidth: pageWidth)

                actionButtons
                    .padding(.horizontal, 16)
                    .padding(
                        .bottom,
                        actionButtonsBottomPadding(for: items[currentIndex])
                    )
            }
            .padding(.top, 12)
            .padding(.bottom, 20)
            .padding(.horizontal, sheetHorizontalPadding)
            .frame(height: sheetHeight, alignment: .top)
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(.container, edges: .bottom)
            .animation(pageAnimation, value: hasSecondaryAction)
        }
        .presentationDetents([.height(sheetDetentHeight)])
        .presentationBackground(sheetBackgroundColor)
        .presentationCornerRadius(36)
        .presentationDragIndicator(.hidden)
    }

    private var sheetHeight: CGFloat {
        ceil(items.map { requiredSheetHeight(for: $0) }.max() ?? minimumSheetHeight)
    }

    private var sheetDetentHeight: CGFloat {
        max(1, sheetHeight - homeIndicatorInset)
    }

    private var minimumSheetHeight: CGFloat {
        12
            + mediaHeight
            + 20
            + minimumCopyToPagerSpacing
            + pagerHeight
            + 56
            + 24
            + 20
    }

    private func requiredSheetHeight(for item: Item) -> CGFloat {
        12
            + mediaHeight
            + 20
            + copyHeight(for: item)
            + minimumCopyToPagerSpacing
            + pagerHeight
            + actionButtonsHeight(for: item)
            + actionButtonsBottomPadding(for: item)
            + 20
    }

    private func actionButtonsHeight(for item: Item) -> CGFloat {
        56 + (item.secondaryButtonTitle == nil ? 0 : secondaryButtonSpacing + 56)
    }

    private func actionButtonsBottomPadding(for item: Item) -> CGFloat {
        item.secondaryButtonTitle == nil ? 24 : 16
    }

    private func copyToPagerSpacing(for item: Item) -> CGFloat {
        minimumCopyToPagerSpacing
            + max(0, sheetHeight - requiredSheetHeight(for: item))
    }

    private var hasSecondaryAction: Bool {
        items[currentIndex].secondaryButtonTitle != nil
    }

    private func copyHeight(for item: Item) -> CGFloat {
        measuredTextHeight(
            item.title,
            font: .systemFont(ofSize: 20, weight: .bold),
            tracking: 0.38
        )
            + copySpacing
            + measuredTextHeight(
                item.subtitle,
                font: .systemFont(ofSize: 17, weight: .regular),
                tracking: -0.41
            )
    }

    private func measuredTextHeight(
        _ text: String,
        font: UIFont,
        tracking: CGFloat
    ) -> CGFloat {
        let availableWidth = max(
            1,
            screenWidth
                - sheetHorizontalPadding * 2
                - copyHorizontalPadding * 2
        )
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping

        let bounds = (text as NSString).boundingRect(
            with: CGSize(
                width: availableWidth,
                height: CGFloat.greatestFiniteMagnitude
            ),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [
                .font: font,
                .kern: tracking,
                .paragraphStyle: paragraphStyle
            ],
            context: nil
        )

        return ceil(bounds.height)
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
                    .accessibilityHidden(true)
                }

                closeButton
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.top, 16)
                    .padding(.leading, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(pageAnimation, value: currentIndex)
        }
    }

    @ViewBuilder
    private func mediaContent(
        for media: Item.Media,
        availableSize: CGSize
    ) -> some View {
        switch media {
        case let .phone(imageName, viewport):
            let phoneSize = CGSize(width: 198, height: 406)
            let phoneTop = switch viewport {
            case .top:
                CGFloat(24)
            case .bottom:
                CGFloat(-134)
            }

            ZStack(alignment: .top) {
                FigmaPhoneMockupFrame(size: phoneSize) { viewportSize in
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: viewportSize.width,
                            height: viewportSize.height
                        )
                        .clipped()
                }
                .position(
                    x: availableSize.width / 2 - 1,
                    y: phoneTop + phoneSize.height / 2
                )
            }
            .frame(width: availableSize.width, height: availableSize.height)
            .compositingGroup()
            .mask {
                phoneVisibilityMask(for: viewport)
            }

        case .illustration:
            Image("OnboardingBottomSheetIllustration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: availableSize.width, height: availableSize.height)
        }
    }

    @ViewBuilder
    private func phoneVisibilityMask(
        for viewport: Item.Media.PhoneViewport
    ) -> some View {
        switch viewport {
        case .top:
            LinearGradient(
                stops: [
                    .init(color: .white, location: 0),
                    .init(color: .white, location: 236 / mediaHeight),
                    .init(color: .white.opacity(0.88), location: 246 / mediaHeight),
                    .init(color: .white.opacity(0.45), location: 266 / mediaHeight),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

        case .bottom:
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white.opacity(0.20), location: 10 / mediaHeight),
                    .init(color: .white.opacity(0.55), location: 32 / mediaHeight),
                    .init(color: .white.opacity(0.85), location: 58 / mediaHeight),
                    .init(color: .white, location: 80 / mediaHeight),
                    .init(color: .white, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(primaryTextColor)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial, in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Закрыть")
    }

    private func copyView(pageWidth: CGFloat) -> some View {
        ZStack(alignment: .top) {
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
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(primaryTextColor)

                    Text(item.subtitle)
                        .font(.system(size: 17, weight: .regular))
                        .tracking(-0.41)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(secondaryTextColor)
                }
                .frame(maxWidth: .infinity)
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
        .animation(pageAnimation, value: currentIndex)
    }

    private func indicatorView(pageWidth: CGFloat) -> some View {
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
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(sheetBackgroundColor.opacity(0.3), in: Capsule())
        .frame(height: 24)
        .padding(.bottom, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Страница \(currentIndex + 1) из \(items.count)")
    }

    private var actionButtons: some View {
        VStack(spacing: 0) {
            continueButton

            if let secondaryButtonTitle = items[currentIndex].secondaryButtonTitle {
                secondaryButton(title: secondaryButtonTitle)
                    .padding(.top, secondaryButtonSpacing)
                    .transition(secondaryButtonTransition)
            }
        }
        .animation(pageAnimation, value: hasSecondaryAction)
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
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func secondaryButton(title: String) -> some View {
        Button {
            // The design defines the secondary action visually only.
        } label: {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(
                    Color(red: 66 / 255, green: 139 / 255, blue: 249 / 255)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var secondaryButtonTransition: AnyTransition {
        guard !reduceMotion else {
            return .opacity
        }

        return .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
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
        }

        let id: Int
        let title: String
        let subtitle: String
        let media: Media
        let buttonTitle: String
        var secondaryButtonTitle: String? = nil
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
                    title: "Всё необходимое рядом",
                    subtitle: "Следите за обновлениями,\nбыстро находите нужные функции\nи управляйте ими в одном месте",
                    media: .video(
                        poster: UIImage(named: "OnboardingScreen1"),
                        resourceName: "OnboardingInterface1Light",
                        darkResourceName: "OnboardingInterface1Dark"
                    ),
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 1,
                    title: "Новый интерфейс стал\nпроще и удобнее",
                    subtitle: "Основные разделы всегда под рукой.\nПереходите между задачами быстрее,\nнастраивайте экран под себя\nи ничего не упускайте",
                    media: .image(poster: UIImage(named: "OnboardingScreen2")),
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 2,
                    title: "Больше возможностей",
                    subtitle: "Открывайте новые функции\nи находите нужное быстрее",
                    media: .image(poster: UIImage(named: "OnboardingScreen4")),
                    phonePresentation: .largeBottom,
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 3,
                    title: "Настройте всё\nтак, как удобно вам",
                    subtitle: "Выберите подходящий вариант\nили вернитесь к настройке позже",
                    media: .image(poster: UIImage(named: "OnboardingScreen3")),
                    phonePresentation: .largeTop,
                    buttonTitle: "Далее",
                    secondaryButtonTitle: "Настроить позже"
                ),
                .init(
                    id: 4,
                    title: "Всё готово\nк началу работы",
                    subtitle: "Продолжайте знакомство\nи открывайте новые возможности",
                    media: .image(poster: UIImage(named: "OnboardingScreen3")),
                    phonePresentation: .largeTop,
                    buttonTitle: "Далее"
                )
            ],
            onBackFromFirstPage: { dismiss() }
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct IOS26StyleOnboarding: View {
    // The updated Figma component is authored on a 375 x 812 reference screen.
    // A one-action bottom area may grow to 340 pt; after that, additional
    // device height belongs to the picture area. The two-action state reserves
    // the full 384 pt bottom area from the component.
    private let referenceScreenHeight: CGFloat = 812
    private let maximumOneButtonBottomAreaHeight: CGFloat = 340
    private let twoButtonBottomAreaHeight: CGFloat = 384
    private let twoButtonSpacing: CGFloat = 8

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
            let bottomSafeArea = max(geometry.safeAreaInsets.bottom, 34)
            let topSafeArea = max(geometry.safeAreaInsets.top, 44)
            let screenLayout = interactiveScreenLayout(
                pageWidth: geometry.size.width,
                screenHeight: geometry.size.height,
                bottomSafeArea: bottomSafeArea
            )
            let pictureAreaHeight = screenLayout.pictureAreaHeight
            let bottomAreaHeight = screenLayout.bottomAreaHeight

            ZStack(alignment: .top) {
                backgroundColor
                    .ignoresSafeArea()

                pictureAreaView(
                    pageWidth: geometry.size.width,
                    screenHeight: geometry.size.height,
                    bottomSafeArea: bottomSafeArea,
                    size: CGSize(
                        width: geometry.size.width,
                        height: pictureAreaHeight
                    )
                )
                .frame(height: pictureAreaHeight)
                .clipped()
                .frame(maxHeight: .infinity, alignment: .top)

                bottomView(
                    pageWidth: geometry.size.width,
                    bottomSafeArea: bottomSafeArea
                )
                .frame(height: bottomAreaHeight)
                .background(backgroundColor)
                .frame(maxHeight: .infinity, alignment: .bottom)

                textContentView(pageWidth: geometry.size.width)
                    .frame(height: 132)
                    .padding(.horizontal, 16)
                    .offset(y: pictureAreaHeight + 32)

                backButton(topInset: topSafeArea)
            }
            .contentShape(Rectangle())
            .simultaneousGesture(pageDragGesture(pageWidth: geometry.size.width))
            .sensoryFeedback(.selection, trigger: swipeHapticTrigger)
        }
        .ignoresSafeArea()
    }

    private func bottomView(
        pageWidth: CGFloat,
        bottomSafeArea: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            indicatorView(pageWidth: pageWidth)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                continueButton

                if let secondaryButtonTitle = items[currentIndex].secondaryButtonTitle {
                    secondaryButton(title: secondaryButtonTitle)
                        .padding(.top, twoButtonSpacing)
                }
            }
            .padding(.horizontal, 16)
            .padding(
                .bottom,
                items[currentIndex].secondaryButtonTitle == nil ? 24 : 16
            )

            Color.clear
                .frame(height: bottomSafeArea)
        }
    }

    private func pictureAreaView(
        pageWidth: CGFloat,
        screenHeight: CGFloat,
        bottomSafeArea: CGFloat,
        size: CGSize
    ) -> some View {
        let phoneLayout = interactivePhoneLayout(
            pageWidth: pageWidth,
            screenHeight: screenHeight,
            bottomSafeArea: bottomSafeArea
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

                // The updated Large-bottom slot owns an additional 80 pt fade
                // at its top edge.
                LinearGradient(
                    stops: [
                        .init(color: backgroundColor, location: 0),
                        .init(color: backgroundColor, location: 0.60),
                        .init(color: backgroundColor.opacity(0), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 80)
            }
            .frame(height: 98)
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

    private func textContentView(
        pageWidth: CGFloat
    ) -> some View {
        GeometryReader { geometry in
            let size = geometry.size

            ZStack(alignment: .top) {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    let relativePage = relativePage(for: index, pageWidth: pageWidth)
                    let distance = min(abs(relativePage), 1)

                    VStack(spacing: 8) {
                        Text(item.title)
                            .font(.system(size: 20, weight: .bold))
                            .tracking(0.38)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(primaryTextColor)

                        Text(item.subtitle)
                            .font(.system(size: 17, weight: .regular))
                            .tracking(-0.41)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(secondaryTextColor)
                    }
                    .frame(width: size.width)
                    .compositingGroup()
                    .offset(
                        x: reduceMotion ? 0 : relativePage * pageWidth
                    )
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
            Text(items[currentIndex].buttonTitle)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color("TUITextPrimaryOnAccent1"))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .contentShape(Rectangle())
                .modifier(InterfacePrimaryButtonSurfaceModifier())
        }
        .buttonStyle(InterfacePrimaryButtonStyle())
    }

    private func secondaryButton(title: String) -> some View {
        Button {
            // The Figma component defines the secondary action visually only.
        } label: {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color(red: 66 / 255, green: 139 / 255, blue: 249 / 255))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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

    private func interactiveScreenLayout(
        pageWidth: CGFloat,
        screenHeight: CGFloat,
        bottomSafeArea: CGFloat
    ) -> ScreenLayout {
        let targetIndex = transitionTargetIndex()
        let progress = transitionProgress(pageWidth: pageWidth)
        let currentLayout = screenLayout(
            for: items[currentIndex],
            screenHeight: screenHeight,
            bottomSafeArea: bottomSafeArea
        )
        let targetLayout = screenLayout(
            for: items[targetIndex],
            screenHeight: screenHeight,
            bottomSafeArea: bottomSafeArea
        )

        return ScreenLayout(
            pictureAreaHeight: currentLayout.pictureAreaHeight
                + (targetLayout.pictureAreaHeight - currentLayout.pictureAreaHeight) * progress,
            bottomAreaHeight: currentLayout.bottomAreaHeight
                + (targetLayout.bottomAreaHeight - currentLayout.bottomAreaHeight) * progress
        )
    }

    private func screenLayout(
        for item: Item,
        screenHeight: CGFloat,
        bottomSafeArea: CGFloat
    ) -> ScreenLayout {
        let safeAreaDelta = max(0, bottomSafeArea - 34)
        let minimumPictureAreaHeight = item.phonePresentation.minimumPictureAreaHeight
        let bottomAreaHeight: CGFloat

        if item.secondaryButtonTitle != nil {
            bottomAreaHeight = twoButtonBottomAreaHeight + safeAreaDelta
        } else {
            let referenceBottomAreaHeight = referenceScreenHeight
                - item.phonePresentation.referenceOneButtonPictureAreaHeight
            let availableGrowth = max(0, screenHeight - referenceScreenHeight)

            bottomAreaHeight = min(
                maximumOneButtonBottomAreaHeight,
                referenceBottomAreaHeight + availableGrowth
            ) + safeAreaDelta
        }

        return ScreenLayout(
            pictureAreaHeight: max(
                minimumPictureAreaHeight,
                screenHeight - bottomAreaHeight
            ),
            bottomAreaHeight: bottomAreaHeight
        )
    }

    private func interactivePhoneLayout(
        pageWidth: CGFloat,
        screenHeight: CGFloat,
        bottomSafeArea: CGFloat
    ) -> PhoneLayout {
        let targetIndex = transitionTargetIndex()
        let progress = transitionProgress(pageWidth: pageWidth)
        let currentItem = items[currentIndex]
        let targetItem = items[targetIndex]
        let currentScreenLayout = screenLayout(
            for: currentItem,
            screenHeight: screenHeight,
            bottomSafeArea: bottomSafeArea
        )
        let targetScreenLayout = screenLayout(
            for: targetItem,
            screenHeight: screenHeight,
            bottomSafeArea: bottomSafeArea
        )
        let currentLayout = currentItem.phonePresentation.layout(
            pictureAreaHeight: currentScreenLayout.pictureAreaHeight,
            screenWidth: pageWidth,
            screenHeight: screenHeight
        )
        let targetLayout = targetItem.phonePresentation.layout(
            pictureAreaHeight: targetScreenLayout.pictureAreaHeight,
            screenWidth: pageWidth,
            screenHeight: screenHeight
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
        var buttonTitle: String
        var secondaryButtonTitle: String? = nil
    }

    fileprivate struct PhoneLayout {
        let size: CGSize
        let top: CGFloat
    }

    private struct ScreenLayout {
        let pictureAreaHeight: CGFloat
        let bottomAreaHeight: CGFloat
    }

    // Mirrors the three iOS phone variants from the Figma component. The
    // default state always uses Picture Area/Full-center-min as its source;
    // device breakpoints are the only thing allowed to change its phone size.
    enum PhonePresentation: Equatable {
        private static let defaultBottomPadding: CGFloat = 16
        private static let largeTopPadding: CGFloat = 80
        private static let largeTopSlotPadding: CGFloat = 32
        private static let largeBottomPadding: CGFloat = 48
        private static let largeBaseSize = CGSize(width: 264, height: 550)

        case `default`
        case largeTop
        case largeBottom

        fileprivate var minimumPictureAreaHeight: CGFloat {
            switch self {
            case .default:
                280
            case .largeTop, .largeBottom:
                360
            }
        }

        fileprivate var referenceOneButtonPictureAreaHeight: CGFloat {
            switch self {
            case .default:
                488
            case .largeTop:
                497
            case .largeBottom:
                496
            }
        }

        fileprivate func layout(
            pictureAreaHeight: CGFloat,
            screenWidth: CGFloat,
            screenHeight: CGFloat
        ) -> PhoneLayout {
            switch self {
            case .default:
                let size = Self.defaultPhoneSize(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )
                return PhoneLayout(
                    size: size,
                    top: pictureAreaHeight
                        - Self.defaultBottomPadding
                        - size.height
                )
            case .largeTop:
                return PhoneLayout(
                    size: Self.largePhoneSize(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight
                    ),
                    top: Self.largeTopPadding + Self.largeTopSlotPadding
                )
            case .largeBottom:
                let size = Self.largePhoneSize(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )

                return PhoneLayout(
                    size: size,
                    top: pictureAreaHeight - Self.largeBottomPadding - size.height
                )
            }
        }

        private static func largePhoneSize(
            screenWidth: CGFloat,
            screenHeight: CGFloat
        ) -> CGSize {
            let scale: CGFloat

            if screenWidth >= 431, screenHeight >= 933 {
                scale = 1.15
            } else if screenWidth >= 403, screenHeight >= 875 {
                scale = 1.10
            } else if screenWidth >= 376, screenHeight >= 813 {
                scale = 1.05
            } else {
                scale = 1
            }

            return CGSize(
                width: (largeBaseSize.width * scale).rounded(),
                height: (largeBaseSize.height * scale).rounded()
            )
        }

        private static func defaultPhoneSize(
            screenWidth: CGFloat,
            screenHeight: CGFloat
        ) -> CGSize {
            // Discrete integer sizes keep the Figma frame crisp and avoid
            // fractional geometry during swipe interpolation.
            if screenWidth >= 430, screenHeight >= 932 {
                CGSize(width: 238, height: 487)
            } else if screenWidth >= 402, screenHeight >= 874 {
                CGSize(width: 208, height: 426)
            } else if screenWidth >= 390, screenHeight >= 844 {
                CGSize(width: 198, height: 406)
            } else {
                // Exact Picture Area/Full-center-min geometry from Figma.
                CGSize(width: 180, height: 370)
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
