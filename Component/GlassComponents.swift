import SwiftUI

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
            }
    }
}

// MARK: - Glass Button
struct GlassButton: View {
    let title: String
    let icon: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(isLoading ? "Processing..." : title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1, green: 0.2, blue: 0.2).opacity(0.85),
                                Color(red: 0.8, green: 0.1, blue: 0.3).opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                    }
                    .shadow(color: Color(red: 1, green: 0.2, blue: 0.2).opacity(0.4), radius: 12, y: 4)
            }
        }
        .disabled(isLoading)
        .buttonStyle(.plain)
    }
}

// MARK: - Segment Picker (Glass style)
struct GlassSegmentPicker<T: Hashable & CaseIterable & Identifiable>: View where T.AllCases: RandomAccessCollection {
    let options: T.Type
    @Binding var selection: T
    let labelForOption: (T) -> String
    let iconForOption: (T) -> String

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(T.allCases)) { option in
                let isSelected = selection as AnyHashable == option as AnyHashable
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = option
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: iconForOption(option))
                            .font(.system(size: 13, weight: .medium))
                        Text(labelForOption(option))
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.white.opacity(0.15))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                                }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.07))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Floating Orbs Background
struct FloatingOrbsBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .ignoresSafeArea()

            // Red orb top
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 1, green: 0.15, blue: 0.15).opacity(0.35), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: animate ? -60 : -80, y: animate ? -180 : -160)
                .blur(radius: 30)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)

            // Purple orb bottom
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0.5, green: 0.1, blue: 1).opacity(0.25), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: animate ? 80 : 100, y: animate ? 300 : 280)
                .blur(radius: 30)
                .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear { animate = true }
    }
}
