import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var app
    @State private var session = CommunicationSession()
    @State private var showSettings = false
    @State private var showPINGate = false
    @State private var editingCard: AACCard?

    var body: some View {
        ZStack {
            if app.needsOnboarding {
                OnboardingView()
            } else {
                mainBoard
            }
        }
        .onAppear {
            LandscapeLaunch.enforce(reason: "RootView.onAppear")
        }
        .animation(.easeInOut(duration: 0.25), value: app.needsOnboarding)
    }

    private var mainBoard: some View {
        NavigationStack {
            BoardView(session: session, onEditCard: { editingCard = $0 })
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Settings", systemImage: "gearshape.fill") {
                            if app.hasPIN {
                                showPINGate = true
                            } else {
                                showSettings = true
                            }
                        }
                        .accessibilityLabel("Caregiver settings")
                    }
                }
                .toolbarBackground(AACTheme.boardBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        }
        .background(AACTheme.boardBackground.ignoresSafeArea())
        .persistentSystemOverlays(.hidden)
        .statusBarHidden(true)
        .sheet(isPresented: $showSettings) {
            CaregiverSettingsView()
        }
        .sheet(isPresented: $showPINGate) {
            PINEntryView(
                title: "Enter PIN",
                message: "Enter the caregiver PIN to open settings.",
                expectedPIN: app.settings.caregiverPIN,
                onSuccess: {
                    showPINGate = false
                    showSettings = true
                },
                onCancel: { showPINGate = false }
            )
        }
        .sheet(item: $editingCard) { card in
            CardEditorView(card: card)
        }
        .onChange(of: app.vocabularyMode) { _, _ in
            session.reset()
        }
    }
}
