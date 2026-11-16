import AVFoundation
import SwiftUI
import UIKit

private func onboardingAppBarTopInset(_ geometryInset: CGFloat) -> CGFloat {
    let windowInset = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .filter { $0.activationState == .foregroundActive }
        .flatMap(\.windows)
        .first(where: { $0.isKeyWindow })?
        .safeAreaInsets.top ?? 0

    return max(max(geometryInset, windowInset), 44) + 8
}

struct OnboardingView: View {
    var body: some View {
        List {
            Section("Форматы") {
                NavigationLink {
                    InterfaceGuideOnboardingView()
                } label: {
                    OnboardingFormatRow(
                        title: "Интерфейс",
                        subtitle: "Адаптивные Full, Top и Bottom",
                        systemImage: "iphone.gen3"
                    )
                }

                NavigationLink {
                    IllustrationOnboardingView()
                } label: {
                    OnboardingFormatRow(
                        title: "Иллюстрация",
                        subtitle: "Статичная иллюстрация или моушен",
                        systemImage: "photo.on.rectangle.angled"
                    )
                }

                NavigationLink {
                    BottomSheetGuideOnboardingView()
                } label: {
                    OnboardingFormatRow(
                        title: "Bottom-sheet 2.0",
                        subtitle: "Копия по гайду · область изображения M",
                        systemImage: "rectangle.bottomhalf.inset.filled",
                        badge: "Новая версия"
                    )
                }

                NavigationLink {
                    LongreadOnboardingView()
                } label: {
                    OnboardingFormatRow(
                        title: "Лонгрид",
                        subtitle: "Вертикальная лента шагов с медиа в карточках",
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
                    title: "Делите покупки\nв Шопинге по карте",
                    subtitle: "Оплачивайте часть суммы сразу.\nОстальное — потом, равными частями.\nПлатежи списываются автоматически\nкаждые две недели",
                    imageName: "OnboardingIllustrationShopping",
                    imageAlignment: .bottom,
                    buttonTitle: "Далее",
                    textLayout: .maximum
                ),
                .init(
                    id: 1,
                    title: "Включайте Долями",
                    subtitle: "Платите за покупки частями\nи следите за платежами",
                    imageName: "OnboardingIllustrationInstallments",
                    buttonTitle: "Далее",
                    textLayout: .minimum
                ),
                .init(
                    id: 2,
                    title: "Покупайте сейчас\nи платите постепенно",
                    subtitle: "Разделите оплату на части.\nПервый платёж спишется сразу,\nостальные — каждые две недели",
                    imageName: "OnboardingIllustrationShopping",
                    imageAlignment: .bottom,
                    buttonTitle: "Далее",
                    textLayout: .medium
                ),
                .init(
                    id: 3,
                    title: "Покупайте так,\nкак удобно вам",
                    subtitle: "Оплачивайте покупки частями\nв Шопинге по карте или Долями.\nСледите за платежами в приложении.",
                    imageName: "OnboardingIllustrationShopping",
                    imageAlignment: .bottom,
                    buttonTitle: "Понятно",
                    secondaryButtonTitle: "Вернуться к оплате частями",
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
    // Match Interface: reserve the tallest copy, then size the action area
    // for either one or two buttons using the same spacing and safe-area base.
    private static let bottomReferenceBaseHeight: CGFloat =
        32 + maximumCopyHeight + 32 + 14 + 12 + 34
    private static let oneButtonBottomReferenceHeight: CGFloat =
        bottomReferenceBaseHeight + 56 + 24
    private static let twoButtonBottomReferenceHeight: CGFloat =
        bottomReferenceBaseHeight + 56 + twoButtonSpacing + 48 + 20

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
            let topSafeArea = onboardingAppBarTopInset(geometry.safeAreaInsets.top)
            let bottomHeight = interactiveBottomHeight(
                pageWidth: geometry.size.width,
                bottomSafeArea: bottomSafeArea
            )
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
        let slotTopPadding: CGFloat = 80
        let slotHorizontalPadding: CGFloat = 24
        let slotBottomPadding: CGFloat = 40
        let slotWidth = max(0, size.width - slotHorizontalPadding * 2)
        let slotHeight = max(
            0,
            size.height - slotTopPadding - slotBottomPadding
        )

        return ZStack(alignment: .bottom) {
            ZStack {
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    let isActive = index == currentIndex
                    let relativePage = reduceMotion
                        ? CGFloat(index - currentIndex)
                        : relativePage(for: index, pageWidth: pageWidth)

                    Image(item.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: slotWidth,
                            height: slotHeight
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
            .frame(width: slotWidth, height: slotHeight)
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
                            .foregroundStyle(primaryTextColor)
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
                    .blur(radius: 20 * distance)
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
            OnboardingPrimaryButtonTitle(
                title: items[currentIndex].buttonTitle,
                color: Color("TUITextPrimaryOnAccent1")
            )
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .contentShape(Rectangle())
                .modifier(InterfacePrimaryButtonSurfaceModifier())
        }
        .buttonStyle(InterfacePrimaryButtonStyle())
    }

    private func secondaryButton(title: String) -> some View {
        Button {
            transition(to: currentIndex - 1)
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
            Image(systemName: "xmark")
                .font(.system(size: 17, weight: .medium))
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular, in: Circle())
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

    private func interactiveBottomHeight(
        pageWidth: CGFloat,
        bottomSafeArea: CGFloat
    ) -> CGFloat {
        let currentHeight = bottomReferenceHeight(for: items[currentIndex])
        let targetHeight = bottomReferenceHeight(for: items[transitionTargetIndex()])
        let progress = transitionProgress(pageWidth: pageWidth)
        let safeAreaDelta = max(0, bottomSafeArea - 34)
        return currentHeight + (targetHeight - currentHeight) * progress + safeAreaDelta
    }

    private func bottomReferenceHeight(for item: Item) -> CGFloat {
        item.secondaryButtonTitle == nil
            ? Self.oneButtonBottomReferenceHeight
            : Self.twoButtonBottomReferenceHeight
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

private struct OnboardingPrimaryButtonTitle: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let title: String
    let color: Color

    @State private var displayedTitle: String
    @State private var titleOpacity = 1.0

    init(title: String, color: Color) {
        self.title = title
        self.color = color
        _displayedTitle = State(initialValue: title)
    }

    var body: some View {
        Text(displayedTitle)
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(color)
            .opacity(titleOpacity)
            .accessibilityLabel(title)
            .task(id: title) {
                await transitionToCurrentTitle()
            }
    }

    @MainActor
    private func transitionToCurrentTitle() async {
        guard displayedTitle != title else {
            titleOpacity = 1
            return
        }

        guard !reduceMotion else {
            displayedTitle = title
            titleOpacity = 1
            return
        }

        withAnimation(.timingCurve(0.2, 0, 0.4, 0.9, duration: 0.25)) {
            titleOpacity = 0
        }

        do {
            try await Task.sleep(nanoseconds: 250_000_000)
        } catch {
            return
        }

        guard !Task.isCancelled else { return }
        displayedTitle = title

        withAnimation(.timingCurve(0.2, 0, 0.4, 0.9, duration: 0.25)) {
            titleOpacity = 1
        }
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
    let slotSize: CGSize?
    let outerCornerRadius: CGFloat?
    let slotCornerRadius: CGFloat?
    let slotBackground: Color
    private let content: Content

    init(
        size: CGSize,
        hidesBezels: Bool = false,
        slotSize: CGSize? = nil,
        outerCornerRadius: CGFloat? = nil,
        slotCornerRadius: CGFloat? = nil,
        slotBackground: Color = Color(.systemBackground),
        @ViewBuilder content: (CGSize) -> Content
    ) {
        self.size = size
        self.hidesBezels = hidesBezels
        self.slotSize = slotSize
        self.outerCornerRadius = outerCornerRadius
        self.slotCornerRadius = slotCornerRadius
        self.slotBackground = slotBackground
        let metrics = Metrics(
            size: size,
            slotSize: slotSize,
            outerCornerRadius: outerCornerRadius,
            slotCornerRadius: slotCornerRadius
        )
        self.content = content(hidesBezels ? size : metrics.slotFrame.size)
    }

    var body: some View {
        let metrics = Metrics(
            size: size,
            slotSize: slotSize,
            outerCornerRadius: outerCornerRadius,
            slotCornerRadius: slotCornerRadius
        )

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
                            style: .continuous
                        )
                    )
            } else {
                RoundedRectangle(
                    cornerRadius: metrics.outerCornerRadius,
                    style: .continuous
                )
                .fill(.black)
                .overlay {
                    RoundedRectangle(
                        cornerRadius: metrics.outerCornerRadius,
                        style: .continuous
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
                    .background(slotBackground)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: metrics.slotCornerRadius,
                            style: .continuous
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
                style: .continuous
            )
        )
    }

    private struct Metrics {
        let outerFrame: CGRect
        let slotFrame: CGRect
        let outerCornerRadius: CGFloat
        let slotCornerRadius: CGFloat
        let outerBorderWidth: CGFloat

        init(
            size: CGSize,
            slotSize: CGSize? = nil,
            outerCornerRadius: CGFloat? = nil,
            slotCornerRadius: CGFloat? = nil
        ) {
            let progress = min(max((size.width - 198) / (260 - 198), 0), 1)

            outerFrame = CGRect(
                x: Self.interpolate(2 / 198, 3 / 260, progress: progress) * size.width,
                y: Self.interpolate(2 / 406, 2.669921875 / 542, progress: progress) * size.height,
                width: Self.interpolate(194 / 198, 254 / 260, progress: progress) * size.width,
                height: Self.interpolate(402 / 406, 536 / 542, progress: progress) * size.height
            )
            if let slotSize {
                slotFrame = CGRect(
                    x: (size.width - slotSize.width) / 2,
                    y: (size.height - slotSize.height) / 2,
                    width: slotSize.width,
                    height: slotSize.height
                )
            } else {
                slotFrame = CGRect(
                    x: Self.interpolate(10 / 198, 12.52587890625 / 260, progress: progress) * size.width,
                    y: Self.interpolate(10 / 406, 12.00390625 / 542, progress: progress) * size.height,
                    width: Self.interpolate(178 / 198, 234.94845581054688 / 260, progress: progress) * size.width,
                    height: Self.interpolate(386 / 406, 517.3333740234375 / 542, progress: progress) * size.height
                )
            }
            self.outerCornerRadius = outerCornerRadius
                ?? Self.interpolate(32 / 198, 46 / 260, progress: progress) * size.width
            self.slotCornerRadius = slotCornerRadius
                ?? Self.interpolate(24 / 198, 36 / 260, progress: progress) * size.width
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
            title: "Следите за всем важным",
            subtitle: "Все нужные обновления в одном месте",
            media: .illustration,
            buttonTitle: "Далее"
        ),
        .init(
            id: 1,
            title: "Все важные обновления\nтеперь всегда под рукой",
            subtitle: "Следите за новыми возможностями,\nбыстро находите нужные функции\nи управляйте всем в одном месте",
            media: .phone(
                imageName: "OnboardingScreen4",
                viewport: .bottom
            ),
            buttonTitle: "Далее"
        ),
        .init(
            id: 2,
            title: "Выбирайте удобный способ\nи продолжайте без лишних шагов",
            subtitle: "Настройте всё под себя\nили вернитесь к этому позже",
            media: .phone(
                imageName: "OnboardingScreen2",
                viewport: .top
            ),
            buttonTitle: "Понятно",
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
            .contentShape(Rectangle())
            .simultaneousGesture(pageDragGesture(pageWidth: pageWidth))
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
                        .foregroundStyle(primaryTextColor)
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
            OnboardingPrimaryButtonTitle(
                title: items[currentIndex].buttonTitle,
                color: Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)
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
        var externalImageName: String? = nil
    }
}

// This version is independent from BottomSheetStyleOnboarding so the original
// prototype stays available while the new layout rules are evaluated.
private struct BottomSheetGuideOnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    // Keep every title within two lines at the narrowest sheet width; never truncate it.
    private let items: [BottomSheetStyleOnboarding.Item] = [
        .init(
            id: 0,
            title: "Отображайте детали\nв нижней части экрана",
            subtitle: "Для этого выберите отображение Phone-bottom и поместите свой экран в Slot",
            media: .phone(imageName: "BottomSheetGuideSlide1", viewport: .bottom),
            buttonTitle: "Далее"
        ),
        .init(
            id: 1,
            title: "Отображайте детали\nвверху экрана",
            subtitle: "Выберите отображение Phone-top и поместите свой экран во внутренний слот",
            media: .phone(imageName: "BottomSheetGuideSlide2", viewport: .top),
            buttonTitle: "Далее"
        ),
        .init(
            id: 2,
            title: "Показывайте отдельные\nблоки экрана.",
            subtitle: "Поместите интерфейс и нужный блок во внутренний и внешний слоты",
            media: .phone(imageName: "BottomSheetGuideSlide3", viewport: .top),
            buttonTitle: "Далее",
            externalImageName: "BottomSheetGuideSlide3Card"
        ),
        .init(
            id: 3,
            title: "Размещайте 3d или 2d\nиллюстрации",
            subtitle: "Поместите иллюстрацию в слот по центру",
            media: .illustration,
            buttonTitle: "Понятно",
            secondaryButtonTitle: "Secondary action"
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            Image("OnboardingBottomSheetBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .overlay(Color.black.opacity(0.45))
                .overlay(alignment: .bottom) {
                    if geometry.size.width > 56 {
                        BottomSheetGuideStyleOnboarding(
                            items: items,
                            cardWidth: geometry.size.width - 16,
                            onClose: { dismiss() }
                        )
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                    }
                }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .statusBarHidden(true)
    }
}

private struct BottomSheetGuideStyleOnboarding: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    let items: [BottomSheetStyleOnboarding.Item]
    let cardWidth: CGFloat
    let onClose: () -> Void

    @State private var currentIndex = 0
    @State private var dragTranslation: CGFloat = 0
    @State private var swipeHapticTrigger = 0

    private let mediumMediaHeight: CGFloat = 280
    private let largeMediaHeight: CGFloat = 320
    private let largePhoneInsetReduction: CGFloat = 12
    private let headerHorizontalPadding: CGFloat = 20
    private let headerVerticalPadding: CGFloat = 20
    private let copySpacing: CGFloat = 8
    private let pagerHeight: CGFloat = 16
    private let pagerBottomPadding: CGFloat = 12
    private let primaryHeight: CGFloat = 56
    private let secondaryHeight: CGFloat = 56
    private let secondaryGap: CGFloat = 8
    private let homeIndicatorInset: CGFloat = 34

    var body: some View {
        let item = items[currentIndex]
        let mediaHeight = imageAreaHeight(for: item)

        VStack(spacing: 0) {
            mediaCarousel(height: mediaHeight)
                .frame(height: mediaHeight)
                .clipped()

            Color.clear
                .frame(height: copyHeight(for: item), alignment: .top)
                .padding(.horizontal, headerHorizontalPadding)
                .padding(.vertical, headerVerticalPadding)

            indicatorView
                .frame(height: pagerHeight)
                .padding(.bottom, pagerBottomPadding)

            actionButtons
                .padding(.horizontal, 16)
                .padding(.bottom, item.secondaryButtonTitle == nil ? 24 : 16)

            Color.clear.frame(height: homeIndicatorInset)
        }
        .frame(width: cardWidth, height: cardHeight, alignment: .top)
        .overlay(alignment: .top) {
            copyCarousel()
                .mask {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: mediaHeight)
                        LinearGradient(
                            colors: [.clear, .white],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 12)
                        Color.white
                    }
                    .frame(width: cardWidth, height: cardHeight)
                }
                .allowsHitTesting(false)
        }
        .background(sheetBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        .simultaneousGesture(pageDragGesture)
        .sensoryFeedback(.selection, trigger: swipeHapticTrigger)
        .animation(pageAnimation, value: currentIndex)
    }

    private var cardHeight: CGFloat {
        (items.map {
            minimumImageAreaHeight(for: $0) + headerHeight(for: $0) + bottomHeight(for: $0)
        }.max() ?? 0)
            + homeIndicatorInset
    }

    private func minimumImageAreaHeight(for item: BottomSheetStyleOnboarding.Item) -> CGFloat {
        switch item.media {
        case .illustration: return largeMediaHeight
        case .phone:
            return item.secondaryButtonTitle == nil ? largeMediaHeight : mediumMediaHeight
        }
    }

    private func imageAreaHeight(for item: BottomSheetStyleOnboarding.Item) -> CGFloat {
        cardHeight - headerHeight(for: item) - bottomHeight(for: item) - homeIndicatorInset
    }

    private func headerHeight(for item: BottomSheetStyleOnboarding.Item) -> CGFloat {
        headerVerticalPadding * 2 + copyHeight(for: item)
    }

    private func bottomHeight(for item: BottomSheetStyleOnboarding.Item) -> CGFloat {
        pagerHeight + pagerBottomPadding + primaryHeight
            + (item.secondaryButtonTitle == nil ? 24 : secondaryGap + secondaryHeight + 16)
    }

    private func copyHeight(for item: BottomSheetStyleOnboarding.Item) -> CGFloat {
        measuredTextHeight(item.title, font: .systemFont(ofSize: 20, weight: .bold), tracking: 0.38)
            + copySpacing
            + measuredTextHeight(item.subtitle, font: .systemFont(ofSize: 17), tracking: -0.41)
    }

    private func measuredTextHeight(_ text: String, font: UIFont, tracking: CGFloat) -> CGFloat {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byWordWrapping
        let bounds = (text as NSString).boundingRect(
            with: CGSize(
                width: max(1, cardWidth - headerHorizontalPadding * 2),
                height: CGFloat.greatestFiniteMagnitude
            ),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font, .kern: tracking, .paragraphStyle: paragraph],
            context: nil
        )
        return ceil(bounds.height)
    }

    private func mediaCarousel(height: CGFloat) -> some View {
        ZStack {
            sheetBackgroundColor

            ForEach(items.indices, id: \.self) { index in
                let relative = relativePage(for: index)
                mediaContent(for: items[index], areaHeight: height)
                    .modifier(
                        IllustrationArcCarouselModifier(
                            relativePage: reduceMotion ? 0 : relative,
                            pageWidth: cardWidth,
                            arcHeight: 64
                        )
                    )
                    .opacity(reduceMotion ? (index == currentIndex ? 1 : 0) : 1)
                    .accessibilityHidden(true)
            }

            closeButton
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 16)
                .padding(.leading, 16)
        }
        .frame(width: cardWidth, height: height)
    }

    @ViewBuilder
    private func mediaContent(
        for item: BottomSheetStyleOnboarding.Item,
        areaHeight: CGFloat
    ) -> some View {
        switch item.media {
        case .illustration:
            // Illustration uses L: 220 pt slot, 60 pt above and 40 pt below.
            // Any surplus from the shared sheet height stays inside Image Area.
            Image("OnboardingBottomSheetIllustration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .saturation(1.3)
                .contrast(1.12)
                .frame(width: 220, height: 220)
                .frame(width: cardWidth, height: max(0, areaHeight - 100))
                .padding(.top, 60)
                .padding(.bottom, 40)

        case let .phone(imageName, viewport):
            let phoneSize = CGSize(width: 220, height: 453)
            let phoneSlotSize = CGSize(width: 200, height: 433)
            let viewportHeight = minimumImageAreaHeight(for: item)
            let variantPadding = max(
                0,
                floor((viewportHeight - mediumMediaHeight) / 2) - largePhoneInsetReduction
            )
            let extraHeight = max(0, areaHeight - viewportHeight)
            let topPadding = floor(extraHeight / 2)
            let bottomPadding = extraHeight - topPadding
            let phoneTop: CGFloat = switch viewport {
            case .top: 32 + variantPadding
            case .bottom: viewportHeight - 12 - phoneSize.height
            }

            VStack(spacing: 0) {
                Color.clear.frame(height: topPadding)

                FigmaPhoneMockupFrame(
                    size: phoneSize,
                    slotSize: phoneSlotSize,
                    outerCornerRadius: 36,
                    slotCornerRadius: 28
                ) { viewportSize in
                    ZStack(alignment: .top) {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: viewportSize.width, height: viewportSize.height)
                            .clipped()

                        phoneStatusBar
                    }
                    .frame(width: viewportSize.width, height: viewportSize.height)
                }
                .position(x: cardWidth / 2, y: phoneTop + phoneSize.height / 2)
                .frame(width: cardWidth, height: viewportHeight)
                .overlay(alignment: .top) {
                    if let externalImageName = item.externalImageName {
                        Image(externalImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: (phoneSlotSize.width * 1233 / 750).rounded())
                            .offset(
                                y: phoneTop
                                    + (phoneSize.height - phoneSlotSize.height) / 2
                                    + 60
                            )
                    }
                }
                .compositingGroup()
                .mask {
                    phoneVisibilityMask(for: viewport, areaHeight: viewportHeight)
                }

                Color.clear.frame(height: bottomPadding)
            }
            .frame(width: cardWidth, height: areaHeight)
        }
    }

    private var phoneStatusBar: some View {
        HStack(spacing: 3) {
            Text("9:41")
                .font(.system(size: 8, weight: .semibold))

            Spacer(minLength: 0)

            Image(systemName: "cellularbars")
            Image(systemName: "wifi")
            Image(systemName: "battery.100percent")
        }
        .font(.system(size: 7, weight: .semibold))
        .foregroundStyle(.primary)
        .padding(.leading, 18)
        .padding(.trailing, 12)
        .frame(height: 24)
    }

    @ViewBuilder
    private func phoneVisibilityMask(
        for viewport: BottomSheetStyleOnboarding.Item.Media.PhoneViewport,
        areaHeight: CGFloat
    ) -> some View {
        let fadeHeight: CGFloat = 48
        switch viewport {
        case .top:
            LinearGradient(
                stops: [
                    .init(color: .white, location: 0),
                    .init(color: .white, location: max(0, (areaHeight - fadeHeight) / areaHeight)),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .bottom:
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white, location: min(1, fadeHeight / areaHeight)),
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
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(primaryTextColor)
                .frame(width: 44, height: 44)
                .background(Color(.secondarySystemBackground), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Закрыть")
    }

    private func copyCarousel() -> some View {
        ZStack(alignment: .top) {
            ForEach(items.indices, id: \.self) { index in
                let relative = relativePage(for: index)
                let distance = min(abs(relative), 1)
                let item = items[index]

                VStack(spacing: copySpacing) {
                    Text(item.title)
                        .font(.system(size: 20, weight: .bold))
                        .tracking(0.38)
                        .foregroundStyle(primaryTextColor)
                    Text(item.subtitle)
                        .font(.system(size: 17))
                        .tracking(-0.41)
                        .foregroundStyle(secondaryTextColor)
                }
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: cardWidth - headerHorizontalPadding * 2)
                .offset(
                    x: reduceMotion ? 0 : relative * cardWidth,
                    y: imageAreaHeight(for: item) + headerVerticalPadding
                )
                .blur(radius: reduceMotion ? 0 : 20 * sqrt(distance))
                .opacity(reduceMotion ? (index == currentIndex ? 1 : 0) : 1 - distance)
            }
        }
        .frame(width: cardWidth, height: cardHeight, alignment: .top)
    }

    private var indicatorView: some View {
        HStack(spacing: 7) {
            ForEach(items.indices, id: \.self) { index in
                let visibility = 1 - min(abs(relativePage(for: index)), 1)
                Circle()
                    .fill(inactiveDotColor)
                    .overlay { Circle().fill(activeDotColor).opacity(visibility) }
                    .frame(width: 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Страница \(currentIndex + 1) из \(items.count)")
    }

    private var actionButtons: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(pageAnimation) {
                    currentIndex = currentIndex == items.count - 1 ? 0 : currentIndex + 1
                    dragTranslation = 0
                }
                swipeHapticTrigger += 1
            } label: {
                OnboardingPrimaryButtonTitle(
                    title: items[currentIndex].buttonTitle,
                    color: Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)
                )
                .frame(maxWidth: .infinity)
                .frame(height: primaryHeight)
                .modifier(InterfacePrimaryButtonSurfaceModifier())
            }
            .buttonStyle(.plain)

            if let secondary = items[currentIndex].secondaryButtonTitle {
                Button {} label: {
                    Text(secondary)
                        .font(.system(size: 17))
                        .foregroundStyle(Color(red: 66 / 255, green: 139 / 255, blue: 249 / 255))
                        .frame(maxWidth: .infinity)
                        .frame(height: secondaryHeight)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.top, secondaryGap)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private func relativePage(for index: Int) -> CGFloat {
        CGFloat(index - currentIndex) + dragTranslation / max(1, cardWidth)
    }

    private var pageDragGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                let translation = value.translation.width
                let atEdge = (currentIndex == 0 && translation > 0)
                    || (currentIndex == items.count - 1 && translation < 0)
                dragTranslation = atEdge
                    ? min(abs(translation) * 0.24, 72) * (translation < 0 ? -1 : 1)
                    : min(max(translation, -cardWidth), cardWidth)
            }
            .onEnded { value in
                let actual = value.translation.width
                let predicted = value.predictedEndTranslation.width
                var target = currentIndex
                if abs(actual) > abs(value.translation.height) {
                    if actual < -cardWidth * 0.18 || predicted < -cardWidth * 0.28 {
                        target = min(currentIndex + 1, items.count - 1)
                    } else if actual > cardWidth * 0.18 || predicted > cardWidth * 0.28 {
                        target = max(currentIndex - 1, 0)
                    }
                }
                if target != currentIndex {
                    swipeHapticTrigger += 1
                }
                withAnimation(pageAnimation) {
                    currentIndex = target
                    dragTranslation = 0
                }
            }
    }

    private var sheetBackgroundColor: Color {
        colorScheme == .dark ? Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255) : .white
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : Color(red: 51 / 255, green: 51 / 255, blue: 51 / 255)
    }

    private var secondaryTextColor: Color {
        Color(red: 146 / 255, green: 153 / 255, blue: 162 / 255)
    }

    private var activeDotColor: Color { colorScheme == .dark ? .white : primaryTextColor }
    private var inactiveDotColor: Color {
        colorScheme == .dark ? .white.opacity(0.22) : .black.opacity(0.12)
    }

    private var pageAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2)
            : .interpolatingSpring(duration: 0.65, bounce: 0, initialVelocity: 0)
    }
}

private enum InterfaceMotionMode {
    case standard
    case reducedMotion
}

private enum InterfaceLayoutVariant: Equatable {
    case original
    case version2
    case figmaGuide

    var usesFigmaGuide: Bool { self == .figmaGuide }

    var minimumPictureAreaHeight: CGFloat {
        switch self {
        case .original: 280
        case .version2: 280
        // Figma's 200-point Image-Area minimum sits below the 98-point navbar.
        case .figmaGuide: 298
        }
    }
}

private struct InterfaceOnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    let motionMode: InterfaceMotionMode

    var body: some View {
        IOS26StyleOnboarding(
            hideBezels: false,
            motionMode: motionMode,
            items: [
                .init(
                    id: 0,
                    title: "Всё необходимое рядом",
                    subtitle: "Следите за обновлениями,\nбыстро находите нужные функции\nи управляйте ими в одном месте",
                    media: .video(
                        poster: UIImage(named: "OnboardingScreen1"),
                        resourceName: "OnboardingInterface1Light",
                        darkResourceName: "OnboardingInterface1Dark"
                    ),
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 1,
                    title: "Новый интерфейс стал\nпроще и удобнее",
                    subtitle: "Основные разделы всегда под рукой.\nПереходите между задачами быстрее,\nнастраивайте экран под себя\nи ничего не упускайте",
                    media: .image(poster: UIImage(named: "OnboardingScreen2")),
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 2,
                    title: "Больше возможностей",
                    subtitle: "Открывайте новые функции\nи находите нужное быстрее",
                    media: .image(poster: UIImage(named: "OnboardingScreen4")),
                    phonePresentation: .largeBottom,
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 3,
                    title: "Настройте всё\nтак, как удобно вам",
                    subtitle: "Выберите подходящий вариант\nили вернитесь к настройке позже",
                    media: .image(poster: UIImage(named: "OnboardingScreen3")),
                    phonePresentation: .largeTop,
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 4,
                    title: "Всё готово\nк началу работы",
                    subtitle: "Продолжайте знакомство\nи открывайте новые возможности",
                    media: .image(poster: UIImage(named: "OnboardingScreen3")),
                    phonePresentation: .largeTop,
                    buttonTitle: "Понятно",
                    secondaryButtonTitle: "Вернуться к настройке"
                )
            ],
            onBackFromFirstPage: { dismiss() }
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct Interface2OnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        IOS26StyleOnboarding(
            hideBezels: false,
            motionMode: .standard,
            layoutVariant: .version2,
            items: [
                .init(
                    id: 0,
                    title: "Всё необходимое рядом",
                    subtitle: "Следите за обновлениями,\nбыстро находите нужные функции\nи управляйте ими в одном месте",
                    media: .video(
                        poster: UIImage(named: "OnboardingScreen1"),
                        resourceName: "OnboardingInterface1Light",
                        darkResourceName: "OnboardingInterface1Dark"
                    ),
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 1,
                    title: "Новый интерфейс стал\nпроще и удобнее",
                    subtitle: "Основные разделы всегда под рукой.\nПереходите между задачами быстрее,\nнастраивайте экран под себя\nи ничего не упускайте",
                    media: .image(poster: UIImage(named: "OnboardingScreen2")),
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 2,
                    title: "Больше возможностей",
                    subtitle: "Открывайте новые функции\nи находите нужное быстрее",
                    media: .image(poster: UIImage(named: "OnboardingScreen4")),
                    phonePresentation: .largeBottom,
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 3,
                    title: "Настройте всё\nтак, как удобно вам",
                    subtitle: "Выберите подходящий вариант\nили вернитесь к настройке позже",
                    media: .image(poster: UIImage(named: "OnboardingScreen3")),
                    phonePresentation: .largeTop,
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 4,
                    title: "Всё готово\nк началу работы",
                    subtitle: "Продолжайте знакомство\nи открывайте новые возможности",
                    media: .image(poster: UIImage(named: "OnboardingScreen3")),
                    phonePresentation: .largeTop,
                    buttonTitle: "Понятно",
                    secondaryButtonTitle: "Вернуться к настройке"
                )
            ],
            onBackFromFirstPage: { dismiss() }
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

// A separate demo copy of the Interface flow. It shares the gesture and
// transition engine with the original, but opts into the new Figma layout.
private struct InterfaceGuideOnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        IOS26StyleOnboarding(
            hideBezels: false,
            motionMode: .standard,
            layoutVariant: .figmaGuide,
            items: [
                .init(
                    id: 0,
                    title: "Всё необходимое рядом",
                    subtitle: "Следите за обновлениями,\nбыстро находите нужные функции\nи управляйте ими в одном месте",
                    media: .video(
                        poster: UIImage(named: "OnboardingScreen1"),
                        resourceName: "OnboardingInterface1Light",
                        darkResourceName: "OnboardingInterface1Dark"
                    ),
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 1,
                    title: "Новый интерфейс стал\nпроще и удобнее",
                    subtitle: "Основные разделы всегда под рукой.\nБыстро переходите между задачами\nи настраивайте экран под себя",
                    media: .image(poster: UIImage(named: "OnboardingScreen2")),
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 2,
                    title: "Больше возможностей",
                    subtitle: "Открывайте новые функции\nи находите нужное быстрее",
                    media: .image(poster: UIImage(named: "OnboardingScreen4")),
                    phonePresentation: .largeBottom,
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 3,
                    title: "Настройте всё\nтак, как удобно вам",
                    subtitle: "Выберите подходящий вариант\nили вернитесь к настройке позже",
                    media: .image(poster: UIImage(named: "OnboardingScreen3")),
                    phonePresentation: .largeTop,
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 4,
                    title: "Показывайте важное\nотдельно",
                    subtitle: "Выделяйте нужный блок интерфейса,\nчтобы его было проще заметить",
                    media: .assetImage(name: "InterfaceGuideDetachedBlock"),
                    phonePresentation: .default,
                    externalCardAssetName: "InterfaceGuideDetachedCard",
                    buttonTitle: "Далее"
                ),
                .init(
                    id: 5,
                    title: "Всё готово\nк началу работы",
                    subtitle: "Продолжайте знакомство\nи открывайте новые возможности",
                    media: .image(poster: UIImage(named: "OnboardingScreen3")),
                    phonePresentation: .largeTop,
                    buttonTitle: "Понятно",
                    secondaryButtonTitle: "Вернуться к настройке"
                )
            ],
            onBackFromFirstPage: { dismiss() }
        )
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct IOS26StyleOnboarding: View {
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
    // Top 32, tallest copy, 32 to pager, pager 14 + 12, then the actions
    // and a 34-point reference safe area. The second action adds 60 points.
    private static let bottomReferenceBaseHeight: CGFloat =
        32 + maximumCopyHeight + 32 + 14 + 12 + 34
    private static let oneButtonBottomReferenceHeight: CGFloat =
        bottomReferenceBaseHeight + 56 + 24
    private static let twoButtonBottomReferenceHeight: CGFloat =
        bottomReferenceBaseHeight + 56 + twoButtonSpacing + 48 + 20
    private static let externalCardCollapseDragThreshold: CGFloat = 12
    private static let externalCardCollapseDragDistance: CGFloat = 24
    private static let externalCardCollapseDuration = 0.075
    private static let darkCardAtSourceColor = makeDarkCardAtSourceColor()

    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase

    var hideBezels = false
    var motionMode: InterfaceMotionMode = .standard
    var layoutVariant: InterfaceLayoutVariant = .original
    var items: [Item]
    var onBackFromFirstPage: () -> Void

    @State private var currentIndex = 0
    @State private var dragTranslation: CGFloat = 0
    @State private var swipeHapticTrigger = 0
    @State private var isDragGestureActive = false
    @State private var isMediaTransitionActive = false
    @State private var mediaTransitionToken = UUID()
    @State private var isExternalCardVisible = false
    @State private var isExternalCardStaged = false
    @State private var externalCardColorProgress = 0.0
    @State private var externalCardExitOpacity = 1.0
    @State private var manualCardCollapseProgress: CGFloat?
    @State private var isManualCardHidden = false

    var body: some View {
        GeometryReader { geometry in
            let bottomSafeArea = layoutVariant.usesFigmaGuide
                ? max(geometry.safeAreaInsets.bottom, 24)
                : max(geometry.safeAreaInsets.bottom, 34)
            let topSafeArea = layoutVariant.usesFigmaGuide
                ? onboardingAppBarTopInset(geometry.safeAreaInsets.top) - 8
                : onboardingAppBarTopInset(geometry.safeAreaInsets.top)
            let navigationHeight = topSafeArea + 44 + 10
            let bottomAreaHeight = interactiveBottomHeight(
                pageWidth: geometry.size.width,
                bottomSafeArea: bottomSafeArea
            )
            let pictureAreaHeight = max(
                layoutVariant.usesFigmaGuide
                    ? navigationHeight + 200
                    : layoutVariant.minimumPictureAreaHeight,
                geometry.size.height - bottomAreaHeight
            )

            ZStack(alignment: .top) {
                backgroundColor
                    .ignoresSafeArea()

                pictureAreaView(
                    pageWidth: geometry.size.width,
                    screenHeight: geometry.size.height,
                    navigationHeight: navigationHeight,
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
        let isGuide = layoutVariant.usesFigmaGuide
        let copyHeight = isGuide
            ? guideCopyHeight(for: items[currentIndex], pageWidth: pageWidth)
            : Self.maximumCopyHeight

        return ZStack(alignment: .top) {
            textContentView(pageWidth: pageWidth)
                .frame(height: copyHeight, alignment: .top)
                .padding(
                    .top,
                    isGuide ? guideCopyTopPadding(for: items[currentIndex]) : 32
                )
                .padding(.horizontal, isGuide ? 20 : 16)

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                indicatorView(pageWidth: pageWidth)
                    .padding(.bottom, isGuide ? 20 : 12)

                VStack(spacing: 0) {
                    continueButton

                    if let secondaryButtonTitle = items[currentIndex].secondaryButtonTitle {
                        secondaryButton(title: secondaryButtonTitle)
                            .padding(.top, isGuide ? 8 : Self.twoButtonSpacing)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(
                    .bottom,
                    items[currentIndex].secondaryButtonTitle == nil
                        ? 24 : (isGuide ? 16 : 20)
                )

                Color.clear
                    .frame(height: bottomSafeArea)
            }
        }
    }

    private func pictureAreaView(
        pageWidth: CGFloat,
        screenHeight: CGFloat,
        navigationHeight: CGFloat,
        size: CGSize
    ) -> some View {
        let phoneLayout = interactivePhoneLayout(
            pageWidth: pageWidth,
            pictureAreaHeight: size.height,
            screenHeight: screenHeight,
            navigationHeight: navigationHeight
        )
        let navbarFadeHeight = layoutVariant.usesFigmaGuide ? navigationHeight : 98

        return ZStack(alignment: .top) {
            FigmaPhoneMockupFrame(
                size: phoneLayout.size,
                hidesBezels: hideBezels,
                slotSize: phoneLayout.slotSize,
                outerCornerRadius: phoneLayout.outerCornerRadius,
                slotCornerRadius: phoneLayout.slotCornerRadius,
                slotBackground: layoutVariant.usesFigmaGuide
                    ? .black : Color(.systemBackground)
            ) { viewportSize in
                ZStack {
                    if layoutVariant.usesFigmaGuide {
                        Color.black
                    }

                    ForEach(items.indices, id: \.self) { index in
                        let item = items[index]
                        let restingPictureAreaHeight = max(
                            navigationHeight + 200,
                            screenHeight - bottomReferenceHeight(
                                for: item,
                                pageWidth: pageWidth
                            )
                        )
                        let pageCornerRadius = item.phonePresentation.figmaGuideLayout(
                            pictureAreaHeight: restingPictureAreaHeight,
                            screenWidth: pageWidth,
                            screenHeight: screenHeight,
                            navigationHeight: navigationHeight
                        ).slotCornerRadius

                        mediaPageView(
                            for: item,
                            index: index,
                            viewportSize: viewportSize,
                            slotCornerRadius: pageCornerRadius
                        )
                        .offset(
                            x: CGFloat(index - currentIndex)
                                * (viewportSize.width + 12)
                                + dragTranslation
                        )
                    }
                }
                .frame(width: viewportSize.width, height: viewportSize.height)
                .clipped()
            }
            .position(
                x: size.width / 2,
                y: phoneLayout.top + phoneLayout.size.height / 2
            )

            if let cardIndex = items.firstIndex(where: { $0.externalCardAssetName != nil }),
               let cardAssetName = items[cardIndex].externalCardAssetName {
                externalCardView(
                    assetName: cardAssetName,
                    phoneLayout: phoneLayout,
                    pageWidth: pageWidth
                )
                .offset(
                    x: CGFloat(cardIndex - currentIndex)
                        * ((hideBezels
                            ? phoneLayout.size.width
                            : phoneLayout.slotSize.width) + 12)
                        + dragTranslation
                )
            }

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
                .frame(height: navbarFadeHeight)

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
            .frame(height: navbarFadeHeight)
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

    private func externalCardView(
        assetName: String,
        phoneLayout: PhoneLayout,
        pageWidth: CGFloat
    ) -> some View {
        let screenshotSize = CGSize(width: 750, height: 1624)
        let cardImageSize = CGSize(width: 1233, height: 474)
        // Bounds of the first card inside the 750 × 1624 screenshot and of
        // its opaque body inside the transparent detached-card asset.
        let sourceCard = CGRect(x: 32, y: 330, width: 686, height: 180)
        let detachedCardBody = CGRect(x: 102, y: 84, width: 1029, height: 270)

        let screenshotScale = min(
            phoneLayout.slotSize.width / 750,
            phoneLayout.slotSize.height / 1624
        )
        let slotOrigin = CGPoint(
            x: (pageWidth - phoneLayout.slotSize.width) / 2,
            y: phoneLayout.top
                + (phoneLayout.size.height - phoneLayout.slotSize.height) / 2
        )
        let screenshotOrigin = CGPoint(
            x: slotOrigin.x
                + (phoneLayout.slotSize.width - screenshotSize.width * screenshotScale) / 2,
            y: slotOrigin.y
                + (phoneLayout.slotSize.height - screenshotSize.height * screenshotScale) / 2
        )

        // The vector mockup provides the Slot bounds. Map the card's source
        // coordinates through the fitted screenshot to the onboarding view.
        let sourceCardOrigin = CGPoint(
            x: screenshotOrigin.x + sourceCard.minX * screenshotScale,
            y: screenshotOrigin.y + sourceCard.minY * screenshotScale
        )
        let initialScale = sourceCard.width * screenshotScale / detachedCardBody.width
        let initialFrame = CGRect(
            x: sourceCardOrigin.x - detachedCardBody.minX * initialScale,
            y: sourceCardOrigin.y - detachedCardBody.minY * initialScale,
            width: cardImageSize.width * initialScale,
            height: cardImageSize.height * initialScale
        )

        let targetWidth = (cardImageSize.width * screenshotScale).rounded()
        let targetScale = targetWidth / cardImageSize.width
        let targetFrame = CGRect(
            x: (pageWidth - targetWidth) / 2,
            y: screenshotOrigin.y + 268 * screenshotScale + 10
                - detachedCardBody.minY * targetScale,
            width: targetWidth,
            height: cardImageSize.height * targetScale
        )
        let cardFrame: CGRect
        if let progress = manualCardCollapseProgress {
            cardFrame = CGRect(
                x: targetFrame.minX + (initialFrame.minX - targetFrame.minX) * progress,
                y: targetFrame.minY + (initialFrame.minY - targetFrame.minY) * progress,
                width: targetFrame.width + (initialFrame.width - targetFrame.width) * progress,
                height: targetFrame.height + (initialFrame.height - targetFrame.height) * progress
            )
        } else {
            cardFrame = isExternalCardVisible || usesReducedContentMotion
                ? targetFrame : initialFrame
        }
        let cardColorProgress = manualCardCollapseProgress.map { 1 - Double($0) }
            ?? externalCardColorProgress
        let cardOpacity = isExternalCardStaged && !isManualCardHidden
            ? externalCardExitOpacity : 0

        return ZStack {
            if colorScheme == .dark,
               let initialImage = Self.darkCardAtSourceColor {
                Image(uiImage: initialImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: cardFrame.width, height: cardFrame.height)

                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: cardFrame.width, height: cardFrame.height)
                    .opacity(cardColorProgress)
            } else {
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: cardFrame.width, height: cardFrame.height)
            }
        }
        .frame(width: cardFrame.width, height: cardFrame.height)
        .position(x: cardFrame.midX, y: cardFrame.midY)
        .opacity(cardOpacity)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private static func makeDarkCardAtSourceColor() -> UIImage? {
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        guard let original = UIImage(
            named: "InterfaceGuideDetachedCard",
            in: .main,
            compatibleWith: darkTraits
        ), let cgImage = original.cgImage else {
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        var pixels = [UInt8](repeating: 0, count: bytesPerRow * height)
        let recoloredImage = pixels.withUnsafeMutableBytes { rawPixels -> CGImage? in
            guard let context = CGContext(
                data: rawPixels.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: CGColorSpace(name: CGColorSpace.sRGB)
                    ?? CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue
                    | CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return nil
            }

            context.draw(
                cgImage,
                in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
            )
            // Replace only the neutral fill; keep lettering, graph and alpha.
            let rgba = rawPixels.bindMemory(to: UInt8.self)
            for pixel in stride(from: 0, to: rgba.count, by: 4) {
                let alpha = Int(rgba[pixel + 3])
                guard alpha > 0 else { continue }

                let red = Int(rgba[pixel]) * 255 / alpha
                let green = Int(rgba[pixel + 1]) * 255 / alpha
                let blue = Int(rgba[pixel + 2]) * 255 / alpha
                guard abs(red - 44) <= 4,
                      abs(green - 44) <= 4,
                      abs(blue - 46) <= 4 else {
                    continue
                }

                rgba[pixel] = UInt8((28 * alpha + 127) / 255)
                rgba[pixel + 1] = UInt8((28 * alpha + 127) / 255)
                rgba[pixel + 2] = UInt8((30 * alpha + 127) / 255)
            }

            return context.makeImage()
        }

        guard let recoloredImage else { return nil }
        return UIImage(
            cgImage: recoloredImage,
            scale: original.scale,
            orientation: original.imageOrientation
        )
    }

    @ViewBuilder
    private func mediaPageView(
        for item: Item,
        index: Int,
        viewportSize: CGSize,
        slotCornerRadius: CGFloat
    ) -> some View {
        let page = mediaView(
            for: item,
            isActive: currentIndex == index,
            isTransitioning: isMediaTransitionActive
        )
        .frame(width: viewportSize.width, height: viewportSize.height)
        // Keep the first two screens flush with the slot after fitting.
        .scaleEffect(
            x: layoutVariant.usesFigmaGuide && index < 2
                ? (viewportSize.width + 2) / max(1, viewportSize.width)
                : 1,
            y: 1
        )

        if layoutVariant.usesFigmaGuide {
            page
                .background(backgroundColor)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: slotCornerRadius,
                        style: .continuous
                    )
                )
        } else {
            page
        }
    }

    @ViewBuilder
    private func mediaView(
        for item: Item,
        isActive: Bool,
        isTransitioning: Bool
    ) -> some View {
        ZStack {
            if case let .assetImage(name) = item.media {
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: layoutVariant.usesFigmaGuide ? .fit : .fill)
            } else if let poster = item.media.poster {
                Image(uiImage: poster)
                    .resizable()
                    .aspectRatio(contentMode: layoutVariant.usesFigmaGuide ? .fit : .fill)
            } else {
                Rectangle()
                    .fill(.black)
            }

            if let resourceName = item.media.videoResourceName(for: colorScheme),
               Bundle.main.url(forResource: resourceName, withExtension: "mp4") != nil {
                OnboardingVideoView(
                    resourceName: resourceName,
                    isPlaying: isActive
                        && !isTransitioning
                        && scenePhase == .active,
                    isFrozen: isTransitioning,
                    fitsContent: layoutVariant.usesFigmaGuide,
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
                            .foregroundStyle(
                                layoutVariant.usesFigmaGuide
                                    ? secondaryTextColor : primaryTextColor
                            )
                    }
                    .frame(width: size.width)
                    .modifier(
                        InterfaceTextCompositingModifier(
                            isEnabled: !usesReducedContentMotion
                        )
                    )
                    .offset(x: relativePage * pageWidth)
                    .blur(radius: usesReducedContentMotion ? 0 : 20 * distance)
                    .opacity(usesReducedContentMotion ? 1 : 1 - distance)
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
            OnboardingPrimaryButtonTitle(
                title: items[currentIndex].buttonTitle,
                color: Color("TUITextPrimaryOnAccent1")
            )
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .contentShape(Rectangle())
                .modifier(InterfacePrimaryButtonSurfaceModifier())
        }
        .buttonStyle(InterfacePrimaryButtonStyle())
    }

    private func secondaryButton(title: String) -> some View {
        Button {
            transition(to: currentIndex - 1)
        } label: {
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color(red: 66 / 255, green: 139 / 255, blue: 249 / 255))
                .frame(maxWidth: .infinity)
                .frame(height: layoutVariant.usesFigmaGuide ? 56 : 48)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func backButton(topInset: CGFloat) -> some View {
        Group {
            if motionMode == .reducedMotion {
                backButtonContent
                    .background(
                        Circle()
                            .fill(legacyAppBarButtonBackground)
                    )
            } else {
                backButtonContent
                    .glassEffect(.regular, in: Circle())
            }
        }
        .foregroundStyle(primaryTextColor)
        .accessibilityLabel("Назад")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, 16)
        .padding(.top, topInset)
    }

    private var backButtonContent: some View {
        Button {
            guard currentIndex > 0 else {
                onBackFromFirstPage()
                return
            }

            transition(to: currentIndex - 1)
        } label: {
            Image(systemName: layoutVariant.usesFigmaGuide ? "xmark" : "chevron.left")
                .font(.system(size: 18, weight: .medium))
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var legacyAppBarButtonBackground: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255)
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
        pictureAreaHeight: CGFloat,
        screenHeight: CGFloat,
        navigationHeight: CGFloat
    ) -> PhoneLayout {
        let targetIndex = transitionTargetIndex()
        let progress = transitionProgress(pageWidth: pageWidth)
        let currentItem = items[currentIndex]
        let targetItem = items[targetIndex]
        let currentLayout = layoutVariant.usesFigmaGuide
            ? currentItem.phonePresentation.figmaGuideLayout(
                pictureAreaHeight: pictureAreaHeight,
                screenWidth: pageWidth,
                screenHeight: screenHeight,
                navigationHeight: navigationHeight
            )
            : currentItem.phonePresentation.layout(
                pictureAreaHeight: pictureAreaHeight,
                screenWidth: pageWidth,
                screenHeight: screenHeight
            )
        let targetLayout = layoutVariant.usesFigmaGuide
            ? targetItem.phonePresentation.figmaGuideLayout(
                pictureAreaHeight: pictureAreaHeight,
                screenWidth: pageWidth,
                screenHeight: screenHeight,
                navigationHeight: navigationHeight
            )
            : targetItem.phonePresentation.layout(
                pictureAreaHeight: pictureAreaHeight,
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
            slotSize: CGSize(
                width: currentLayout.slotSize.width
                    + (targetLayout.slotSize.width - currentLayout.slotSize.width) * progress,
                height: currentLayout.slotSize.height
                    + (targetLayout.slotSize.height - currentLayout.slotSize.height) * progress
            ),
            top: currentLayout.top + (targetLayout.top - currentLayout.top) * progress,
            outerCornerRadius: currentLayout.outerCornerRadius
                + (targetLayout.outerCornerRadius - currentLayout.outerCornerRadius) * progress,
            slotCornerRadius: currentLayout.slotCornerRadius
                + (targetLayout.slotCornerRadius - currentLayout.slotCornerRadius) * progress
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
        DragGesture(minimumDistance: Self.externalCardCollapseDragThreshold)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else {
                    dragTranslation = 0
                    return
                }

                if !isDragGestureActive {
                    isDragGestureActive = true
                    beginMediaTransition()
                    if items[currentIndex].externalCardAssetName != nil,
                       isExternalCardStaged, isExternalCardVisible {
                        manualCardCollapseProgress = 0
                        isManualCardHidden = false
                    }
                }

                let rawTranslation = value.translation.width
                let isAtFirstPage = currentIndex == 0 && rawTranslation > 0
                let isAtLastPage = currentIndex == items.count - 1 && rawTranslation < 0

                if manualCardCollapseProgress != nil,
                   !isAtFirstPage, !isAtLastPage {
                    // Spend the first part of the same gesture on the card.
                    // The phone starts moving only after the card is hidden.
                    let collapseDistance = Self.externalCardCollapseDragThreshold
                        + Self.externalCardCollapseDragDistance
                    let collapseTravel = max(
                        0, abs(rawTranslation) - Self.externalCardCollapseDragThreshold
                    )
                    let collapseProgress = min(
                        collapseTravel / Self.externalCardCollapseDragDistance, 1
                    )
                    manualCardCollapseProgress = collapseProgress
                    isManualCardHidden = collapseProgress >= 1
                    let pageTravel = min(max(abs(rawTranslation) - collapseDistance, 0), pageWidth)
                    dragTranslation = rawTranslation < 0 ? -pageTravel : pageTravel
                } else if isAtFirstPage || isAtLastPage {
                    dragTranslation = rawTranslation.sign == .minus
                        ? -min(abs(rawTranslation) * 0.24, 72)
                        : min(abs(rawTranslation) * 0.24, 72)
                } else {
                    dragTranslation = min(max(rawTranslation, -pageWidth), pageWidth)
                }
            }
            .onEnded { value in
                let wasDraggingHorizontally = isDragGestureActive
                isDragGestureActive = false
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

                let stayedOnPage = targetIndex == currentIndex
                let transitionToken = mediaTransitionToken
                if let cardProgress = manualCardCollapseProgress {
                    if stayedOnPage {
                        // A cancelled gesture reverses the card within the
                        // same stationary phone before restoring normal state.
                        withTransaction(Transaction(animation: nil)) {
                            isManualCardHidden = false
                        }
                        withAnimation(.timingCurve(
                            0.2, 0, 0.4, 0.9,
                            duration: max(0.001, 0.15 * Double(cardProgress))
                        ), completionCriteria: .logicallyComplete) {
                            manualCardCollapseProgress = 0
                        } completion: {
                            guard mediaTransitionToken == transitionToken else { return }
                            manualCardCollapseProgress = nil
                        }
                        withAnimation(animation, completionCriteria: .logicallyComplete) {
                            dragTranslation = 0
                        } completion: {
                            completeMediaTransition(token: transitionToken)
                        }
                    } else {
                        swipeHapticTrigger += 1
                        let remaining = 1 - cardProgress
                        if remaining > 0 {
                            withAnimation(.timingCurve(
                                0.2, 0, 1, 1,
                                duration: Self.externalCardCollapseDuration * Double(remaining)
                            ), completionCriteria: .logicallyComplete) {
                                manualCardCollapseProgress = 1
                            } completion: {
                                guard mediaTransitionToken == transitionToken else { return }
                                withTransaction(Transaction(animation: nil)) {
                                    isManualCardHidden = true
                                }
                                settleDrag(
                                    to: targetIndex,
                                    token: transitionToken,
                                    wasDraggingHorizontally: wasDraggingHorizontally
                                )
                            }
                        } else {
                            settleDrag(
                                to: targetIndex,
                                token: transitionToken,
                                wasDraggingHorizontally: wasDraggingHorizontally
                            )
                        }
                    }
                    return
                }

                if !stayedOnPage {
                    swipeHapticTrigger += 1
                    collapseExternalCard()
                } else if items[currentIndex].externalCardAssetName != nil {
                    restoreExternalCardAfterCancelledDrag()
                }

                settleDrag(
                    to: targetIndex,
                    token: transitionToken,
                    wasDraggingHorizontally: wasDraggingHorizontally
                )
            }
    }

    private func settleDrag(
        to targetIndex: Int,
        token: UUID,
        wasDraggingHorizontally: Bool
    ) {
        withAnimation(animation, completionCriteria: .logicallyComplete) {
            currentIndex = targetIndex
            dragTranslation = 0
        } completion: {
            guard mediaTransitionToken == token else { return }
            if wasDraggingHorizontally {
                completeMediaTransition(token: token)
            }
            manualCardCollapseProgress = nil
            isManualCardHidden = false
        }
    }

    private func interactiveBottomHeight(
        pageWidth: CGFloat,
        bottomSafeArea: CGFloat
    ) -> CGFloat {
        let currentHeight = bottomReferenceHeight(
            for: items[currentIndex], pageWidth: pageWidth
        )
        let targetHeight = bottomReferenceHeight(
            for: items[transitionTargetIndex()], pageWidth: pageWidth
        )
        let progress = transitionProgress(pageWidth: pageWidth)
        let safeAreaDelta = max(
            0,
            bottomSafeArea - (layoutVariant.usesFigmaGuide ? 24 : 34)
        )
        return currentHeight + (targetHeight - currentHeight) * progress + safeAreaDelta
    }

    private func bottomReferenceHeight(for item: Item, pageWidth: CGFloat) -> CGFloat {
        if layoutVariant.usesFigmaGuide {
            // The new Bottom hugs the measured copy; unused height fills Image-Area.
            // The second button adds one 56-point action and reduces bottom padding.
            let actionHeight: CGFloat
            if item.secondaryButtonTitle == nil {
                actionHeight = 80
            } else {
                actionHeight = 136
            }
            let copyHeight = guideCopyHeight(for: item, pageWidth: pageWidth)
            // 90 pt cover the copy-to-pager gap, pager, and safe area;
            // the media-to-copy inset depends on the phone presentation.
            let fixedHeight = 90 + guideCopyTopPadding(for: item)
            return fixedHeight + copyHeight + actionHeight
        }

        return item.secondaryButtonTitle == nil
            ? Self.oneButtonBottomReferenceHeight
            : Self.twoButtonBottomReferenceHeight
    }

    private func guideCopyHeight(for item: Item, pageWidth: CGFloat) -> CGFloat {
        let width = max(1, pageWidth - 40)
        let titleFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        let subtitleFont = UIFont.systemFont(ofSize: 17, weight: .regular)

        func measuredHeight(_ string: String, font: UIFont, tracking: CGFloat) -> CGFloat {
            let rect = (string as NSString).boundingRect(
                with: CGSize(width: width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: font, .kern: tracking],
                context: nil
            )
            return ceil(rect.height)
        }

        return measuredHeight(item.title, font: titleFont, tracking: 0.38)
            + Self.copySpacing
            + measuredHeight(item.subtitle, font: subtitleFont, tracking: -0.41)
    }

    private func guideCopyTopPadding(for item: Item) -> CGFloat {
        item.phonePresentation == .largeTop ? 32 : 8
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
        var externalCardAssetName: String? = nil
        var buttonTitle: String
        var secondaryButtonTitle: String? = nil
    }

    fileprivate struct PhoneLayout {
        let size: CGSize
        let slotSize: CGSize
        let top: CGFloat
        let outerCornerRadius: CGFloat
        let slotCornerRadius: CGFloat
    }

    // Mirrors the three iOS phone variants from the Figma component. The
    // default state always uses Picture Area/Full-center-min as its source;
    // device breakpoints are the only thing allowed to change its phone size.
    enum PhonePresentation: Equatable {
        private static let defaultBottomPadding: CGFloat = 16
        private static let largeTopPadding: CGFloat = 80
        private static let largeTopSlotPadding: CGFloat = 32
        private static let largeBottomPadding: CGFloat = 20
        private static let mediumBaseSize = CGSize(width: 174, height: 356)
        private static let mediumBaseSlotSize = CGSize(width: 155, height: 336)
        private static let largeBaseSlotSize = CGSize(width: 235, height: 508)
        private static let largePhoneScale: CGFloat = 1.5
        private static let mediumOuterCornerRadius: CGFloat = 32
        // Inner screen mask uses the continuous RoundedRectangle in
        // FigmaPhoneMockupFrame to approximate Figma's 60% corner smoothing.
        private static let mediumSlotCornerRadius: CGFloat = 28
        private static let largeOuterCornerRadius: CGFloat = 46
        private static let largeSlotCornerRadius: CGFloat = 38

        case `default`
        case largeTop
        case largeBottom

        // Figma's new flow: Full fills the free image slot below the 98-point
        // navigation area. Top and Bottom reuse the original integer L
        // breakpoint sizes; Bottom stays anchored above the copy.
        fileprivate func figmaGuideLayout(
            pictureAreaHeight: CGFloat,
            screenWidth: CGFloat,
            screenHeight: CGFloat,
            navigationHeight: CGFloat
        ) -> PhoneLayout {
            let scale = Self.breakpointScale(
                screenWidth: screenWidth,
                screenHeight: screenHeight
            )
            let largeSize = Self.largePhoneSize(
                screenWidth: screenWidth,
                screenHeight: screenHeight
            )
            let largeSlot = Self.scaledIntegerSize(
                Self.largeBaseSlotSize,
                scale: scale
            )
            let largeOuterRadius = (Self.largeOuterCornerRadius * scale).rounded()
            let largeSlotRadius = (Self.largeSlotCornerRadius * scale).rounded()

            switch self {
            case .default:
                let slotHeight = max(0, pictureAreaHeight - navigationHeight - 20)
                let phoneHeight = max(
                    1,
                    min(slotHeight, max(1, screenWidth - 32) * 426 / 207)
                ).rounded()
                let phoneWidth = (phoneHeight * 207 / 426).rounded()
                return PhoneLayout(
                    size: CGSize(width: phoneWidth, height: phoneHeight),
                    slotSize: CGSize(
                        width: (phoneWidth * 203.72 / 224.49).rounded(),
                        height: (phoneHeight * 441.61 / 462).rounded()
                    ),
                    top: navigationHeight + (slotHeight - phoneHeight) / 2,
                    outerCornerRadius: (phoneWidth * 40 / 224.49).rounded(),
                    slotCornerRadius: (phoneWidth * 32 / 224.49).rounded()
                )
            case .largeTop:
                return PhoneLayout(
                    size: largeSize,
                    slotSize: largeSlot,
                    top: navigationHeight + 8,
                    outerCornerRadius: largeOuterRadius,
                    slotCornerRadius: largeSlotRadius
                )
            case .largeBottom:
                return PhoneLayout(
                    size: largeSize,
                    slotSize: largeSlot,
                    top: pictureAreaHeight - 32 - largeSize.height,
                    outerCornerRadius: largeOuterRadius,
                    slotCornerRadius: largeSlotRadius
                )
            }
        }

        fileprivate func layout(
            pictureAreaHeight: CGFloat,
            screenWidth: CGFloat,
            screenHeight: CGFloat
        ) -> PhoneLayout {
            let breakpointScale = Self.breakpointScale(
                screenWidth: screenWidth,
                screenHeight: screenHeight
            )
            let outerCornerRadius: CGFloat
            let slotCornerRadius: CGFloat
            let slotSize: CGSize

            switch self {
            case .default:
                outerCornerRadius = (Self.mediumOuterCornerRadius * breakpointScale).rounded()
                slotCornerRadius = (Self.mediumSlotCornerRadius * breakpointScale).rounded()
                slotSize = Self.scaledIntegerSize(
                    Self.mediumBaseSlotSize,
                    scale: breakpointScale
                )
            case .largeTop, .largeBottom:
                outerCornerRadius = (Self.largeOuterCornerRadius * breakpointScale).rounded()
                slotCornerRadius = (Self.largeSlotCornerRadius * breakpointScale).rounded()
                slotSize = Self.scaledIntegerSize(
                    Self.largeBaseSlotSize,
                    scale: breakpointScale
                )
            }

            switch self {
            case .default:
                let size = Self.defaultPhoneSize(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )
                return PhoneLayout(
                    size: size,
                    slotSize: slotSize,
                    top: pictureAreaHeight
                        - Self.defaultBottomPadding
                        - size.height,
                    outerCornerRadius: outerCornerRadius,
                    slotCornerRadius: slotCornerRadius
                )
            case .largeTop:
                return PhoneLayout(
                    size: Self.largePhoneSize(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight
                    ),
                    slotSize: slotSize,
                    top: Self.largeTopPadding + Self.largeTopSlotPadding,
                    outerCornerRadius: outerCornerRadius,
                    slotCornerRadius: slotCornerRadius
                )
            case .largeBottom:
                let size = Self.largePhoneSize(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight
                )

                return PhoneLayout(
                    size: size,
                    slotSize: slotSize,
                    top: pictureAreaHeight - Self.largeBottomPadding - size.height,
                    outerCornerRadius: outerCornerRadius,
                    slotCornerRadius: slotCornerRadius
                )
            }
        }

        private static func largePhoneSize(
            screenWidth: CGFloat,
            screenHeight: CGFloat
        ) -> CGSize {
            let mediumSize = defaultPhoneSize(
                screenWidth: screenWidth,
                screenHeight: screenHeight
            )

            return CGSize(
                width: (mediumSize.width * largePhoneScale).rounded(),
                height: (mediumSize.height * largePhoneScale).rounded()
            )
        }

        private static func defaultPhoneSize(
            screenWidth: CGFloat,
            screenHeight: CGFloat
        ) -> CGSize {
            let scale = breakpointScale(
                screenWidth: screenWidth,
                screenHeight: screenHeight
            )

            // One shared 10% breakpoint grid keeps both M and L predictable.
            // Integer sizes keep the Figma frame crisp during interpolation.
            return CGSize(
                width: (mediumBaseSize.width * scale).rounded(),
                height: (mediumBaseSize.height * scale).rounded()
            )
        }

        private static func scaledIntegerSize(
            _ size: CGSize,
            scale: CGFloat
        ) -> CGSize {
            CGSize(
                width: (size.width * scale).rounded(),
                height: (size.height * scale).rounded()
            )
        }

        private static func breakpointScale(
            screenWidth: CGFloat,
            screenHeight: CGFloat
        ) -> CGFloat {
            if screenWidth >= 428, screenHeight >= 926 {
                1.30
            } else if screenWidth >= 402, screenHeight >= 874 {
                1.20
            } else if screenWidth >= 390, screenHeight >= 844 {
                1.10
            } else {
                1
            }
        }
    }

    private var animation: Animation {
        systemReduceMotion
            ? .easeInOut(duration: 0.2)
            : .interpolatingSpring(duration: 0.65, bounce: 0, initialVelocity: 0)
    }

    private var usesReducedContentMotion: Bool {
        systemReduceMotion || motionMode == .reducedMotion
    }

    private var externalCardAnimation: Animation {
        .timingCurve(0.2, 0, 0.4, 0.9, duration: 0.3)
    }

    private func collapseExternalCard() {
        guard items[currentIndex].externalCardAssetName != nil,
              isExternalCardStaged,
              isExternalCardVisible else { return }

        // Keep the overlay staged until the page settles, so a cancelled
        // swipe can reverse the current frame and opacity without a new show.
        withAnimation(.timingCurve(
            0.2, 0, 1, 1,
            duration: Self.externalCardCollapseDuration
        )) {
            isExternalCardVisible = false
            externalCardColorProgress = 0
            externalCardExitOpacity = 0
        }
    }

    private func restoreExternalCardAfterCancelledDrag() {
        guard isExternalCardStaged, !isExternalCardVisible else { return }
        withAnimation(.timingCurve(0.2, 0, 0.4, 0.9, duration: 0.15)) {
            isExternalCardVisible = true
            externalCardColorProgress = 1
            externalCardExitOpacity = 1
        }
    }

    private func beginMediaTransition() {
        mediaTransitionToken = UUID()
        if items[currentIndex].externalCardAssetName == nil {
            isExternalCardVisible = false
            isExternalCardStaged = false
            externalCardColorProgress = 0
            externalCardExitOpacity = 1
        }

        isMediaTransitionActive = true
    }

    private func completeMediaTransition(token: UUID) {
        guard mediaTransitionToken == token else { return }
        isMediaTransitionActive = false

        if items[currentIndex].externalCardAssetName != nil {
            guard !isExternalCardStaged else { return }
            externalCardExitOpacity = 1
            isExternalCardStaged = true

            // Let the source-sized card render once before growing it.
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(16)) {
                guard mediaTransitionToken == token,
                      items[currentIndex].externalCardAssetName != nil else { return }
                revealExternalCard()
            }
        } else {
            isExternalCardVisible = false
            isExternalCardStaged = false
            externalCardColorProgress = 0
            externalCardExitOpacity = 1
        }
    }

    private func revealExternalCard() {
        guard items.indices.contains(currentIndex),
              items[currentIndex].externalCardAssetName != nil else {
            return
        }

        withAnimation(externalCardAnimation) {
            isExternalCardVisible = true
            externalCardColorProgress = 1
        }
    }

    private func transition(to targetIndex: Int) {
        guard items.indices.contains(targetIndex), targetIndex != currentIndex else {
            return
        }

        beginMediaTransition()
        collapseExternalCard()
        let transitionToken = mediaTransitionToken

        withAnimation(animation, completionCriteria: .logicallyComplete) {
            currentIndex = targetIndex
            dragTranslation = 0
        } completion: {
            completeMediaTransition(token: transitionToken)
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
                    description: "Нажмите на кнопку “Счета и карт”\nвверху главного экрана",
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
                    title: "Зайти в настройки",
                    description: "Выберите компактный вид и нажмите\nгалочку в правом вверхнем угле",
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
            primaryActionTitle: "К настройкам",
            onPrimaryAction: { dismiss() }
        )
        .navigationTitle("Про редизайн")
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
    case assetImage(name: String)
    case video(
        poster: UIImage?,
        resourceName: String,
        darkResourceName: String? = nil
    )

    var poster: UIImage? {
        switch self {
        case let .image(poster), let .video(poster, _, _):
            poster
        case .assetImage:
            nil
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
    var isFrozen = false
    var fitsContent = false
    let posterDuration: TimeInterval

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> OnboardingPlayerView {
        let view = OnboardingPlayerView()
        view.playerLayer.videoGravity = fitsContent ? .resizeAspect : .resizeAspectFill
        context.coordinator.update(
            playerLayer: view.playerLayer,
            resourceName: resourceName,
            isPlaying: isPlaying,
            isFrozen: isFrozen,
            posterDuration: posterDuration
        )
        return view
    }

    func updateUIView(_ uiView: OnboardingPlayerView, context: Context) {
        uiView.playerLayer.videoGravity = fitsContent ? .resizeAspect : .resizeAspectFill
        context.coordinator.update(
            playerLayer: uiView.playerLayer,
            resourceName: resourceName,
            isPlaying: isPlaying,
            isFrozen: isFrozen,
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
        private var playbackState = PlaybackState.stopped
        private var playbackStarted = false
        private var pendingPlayback: DispatchWorkItem?
        private var pendingReveal: DispatchWorkItem?

        private enum PlaybackState: Equatable {
            case playing
            case frozen
            case stopped
        }

        func update(
            playerLayer: AVPlayerLayer,
            resourceName: String,
            isPlaying: Bool,
            isFrozen: Bool,
            posterDuration: TimeInterval
        ) {
            if loadedResourceName != resourceName {
                configure(playerLayer: playerLayer, resourceName: resourceName)
            }

            guard let player else {
                return
            }

            let newState: PlaybackState = if isPlaying {
                .playing
            } else if isFrozen {
                .frozen
            } else {
                .stopped
            }

            guard playbackState != newState else {
                return
            }

            playbackState = newState
            pendingPlayback?.cancel()
            pendingReveal?.cancel()

            switch newState {
            case .playing:
                if playerLayer.opacity > 0 {
                    playbackStarted = true
                    player.play()
                    revealVideoWhenReady(on: playerLayer)
                    return
                }

                let playback = DispatchWorkItem { [weak self] in
                    guard let self, self.playbackState == .playing else { return }
                    self.playbackStarted = true
                    self.player?.play()
                    self.revealVideoWhenReady(on: playerLayer)
                }
                pendingPlayback = playback
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + posterDuration,
                    execute: playback
                )

            case .frozen:
                playbackStarted = false
                player.pause()

            case .stopped:
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
            playbackState = .stopped
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
            guard playbackState == .playing, playbackStarted else {
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

private struct InterfaceTextCompositingModifier: ViewModifier {
    let isEnabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isEnabled {
            content.compositingGroup()
        } else {
            content
        }
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
