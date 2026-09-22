import SwiftUI

/// Brief branded splash after the system launch screen, then hands off to onboarding or the board.
struct SplashView: View {
    var onFinished: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            AACTheme.boardBackground
                .ignoresSafeArea()

            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 520)
                .padding(.horizontal, 40)
                .scaleEffect(showContent ? 1 : 0.92)
                .opacity(showContent ? 1 : 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("TapToTalker")
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                showContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                onFinished()
            }
        }
    }
}
