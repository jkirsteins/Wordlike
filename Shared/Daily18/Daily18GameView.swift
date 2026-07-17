import SwiftUI

/// The 18-tile progress grid (3 rows of 6).
struct Daily18ProgressGrid: View {
    let marks: [Daily18Mark]

    @Environment(\.palette) var palette: Palette

    func color(for mark: Daily18Mark) -> Color {
        switch mark {
        case .solved:
            return palette.rightPlaceFill
        case .failed:
            return palette.wrongLetterFill
        case .pending:
            return palette.wrongLetterFill.opacity(0.3)
        }
    }

    var body: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 6),
                count: 6
            ),
            spacing: 6
        ) {
            ForEach(Array(marks.enumerated()), id: \.offset) { _, mark in
                RoundedRectangle(cornerRadius: 6)
                    .fill(color(for: mark))
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }
}

/// Horizontal shake, driven by an increasing trigger value.
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size _: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: 8 * sin(animatableData * .pi * 4),
                y: 0
            )
        )
    }
}

struct Daily18GameView: View {
    @ObservedObject var engine: Daily18Engine

    @Environment(\.palette) var palette: Palette

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var slotLetters: [String?] {
        let scramble = engine.currentScramble
        return (0 ..< scramble.count).map { slot in
            slot < engine.placed.count ? scramble[engine.placed[slot]] : nil
        }
    }

    /// Circle rows split like the web original: ceil(n/2) then the rest.
    var circleRows: [[Int]] {
        let indices = Array(engine.currentScramble.indices)
        let firstRowCount = (indices.count + 1) / 2
        return [
            Array(indices.prefix(firstRowCount)),
            Array(indices.dropFirst(firstRowCount)),
        ]
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 20) {
                Daily18ProgressGrid(marks: engine.state.marks)
                    .frame(maxWidth: 280)

                Text(
                    String(
                        format: NSLocalizedString("Word %lld of 18", comment: ""),
                        engine.state.currentIndex + 1
                    )
                )
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)

                Text(verbatim: "\(max(0, engine.state.remainingSeconds))")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundColor(
                        engine.state.remainingSeconds <= 5 ? .red : .primary
                    )
                    .monospacedDigit()

                slotRow(width: proxy.size.width)
                    .modifier(
                        ShakeEffect(animatableData: CGFloat(engine.rejectionCount))
                    )
                    .animation(
                        .linear(duration: 0.4),
                        value: engine.rejectionCount
                    )

                circles(width: proxy.size.width)

                Button(action: { engine.removeLast() }) {
                    Image(systemName: "delete.left")
                        .font(.title2)
                }
                .disabled(engine.placed.isEmpty)
                .safeTint(.primary)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .onReceive(timer) { _ in
            engine.tick()
        }
        .onChange(of: engine.state.currentIndex) { _ in
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .onChange(of: engine.rejectionCount) { _ in
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    func slotRow(width: CGFloat) -> some View {
        let count = max(1, engine.currentScramble.count)
        let side = min(52, (width - CGFloat(count + 1) * 6) / CGFloat(count))

        return HStack(spacing: 6) {
            ForEach(Array(slotLetters.enumerated()), id: \.offset) { _, letter in
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(
                            letter == nil
                                ? Color.secondary.opacity(0.5)
                                : palette.rightPlaceStroke,
                            lineWidth: 1.5
                        )
                    if let letter = letter {
                        Text(verbatim: letter)
                            .font(.system(size: side * 0.5, weight: .bold))
                    }
                }
                .frame(width: side, height: side)
            }
        }
        .onTapGesture {
            engine.removeLast()
        }
    }

    func circles(width: CGFloat) -> some View {
        let maxPerRow = max(1, circleRows.map(\.count).max() ?? 1)
        let side = min(64, (width - CGFloat(maxPerRow + 1) * 10) / CGFloat(maxPerRow))

        return VStack(spacing: 10) {
            ForEach(Array(circleRows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { circleIndex in
                        circleButton(circleIndex: circleIndex, side: side)
                    }
                }
            }
        }
    }

    func circleButton(circleIndex: Int, side: CGFloat) -> some View {
        let isUsed = engine.placed.contains(circleIndex)

        return Button(action: {
            engine.placeLetter(circleIndex: circleIndex)
        }) {
            ZStack {
                Circle()
                    .fill(
                        isUsed
                            ? palette.rightPlaceFill
                            : palette.wrongLetterFill.opacity(0.3)
                    )
                Text(verbatim: engine.currentScramble[circleIndex])
                    .font(.system(size: side * 0.42, weight: .bold))
                    .foregroundColor(isUsed ? .white : .primary)
            }
            .frame(width: side, height: side)
        }
        .disabled(isUsed)
    }
}
