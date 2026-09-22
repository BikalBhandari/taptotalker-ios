import SwiftUI

struct PINEntryView: View {
    let title: String
    let message: String
    let expectedPIN: String?
    let onSuccess: () -> Void
    let onCancel: () -> Void

    @State private var pin: String = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("PIN", text: $pin)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .font(.title2)
                        .accessibilityLabel("Caregiver PIN")

                    if let error {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.callout)
                            .accessibilityLabel(error)
                    }
                } footer: {
                    Text(message)
                }

                Section {
                    Button("Continue") {
                        let trimmed = pin.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else {
                            error = "Enter the caregiver PIN."
                            return
                        }
                        if let expectedPIN, trimmed != expectedPIN {
                            error = "Incorrect PIN. Try again."
                            pin = ""
                            return
                        }
                        onSuccess()
                    }
                    .font(.headline)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}
