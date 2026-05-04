import SwiftUI

struct SignInView: View {
    @Environment(AuthStore.self) private var auth

    var body: some View {
        NavigationStack {
            Group {
                switch auth.state {
                case .signedIn:
                    SignedInPanel()
                default:
                    SignedOutPanel()
                }
            }
            .navigationTitle("Profil")
        }
    }
}

private struct SignedOutPanel: View {
    @Environment(AuthStore.self) private var auth

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.crop.circle")
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(Brand.accent)

            VStack(spacing: 8) {
                Text("Anmelden")
                    .font(.ttDisplayLarge)
                Text("Mit deinem Account kannst du Spots hinzufügen, abstimmen und Kommentare schreiben.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            if case .error(let message) = auth.state {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                Task { await auth.signIn() }
            } label: {
                HStack(spacing: 8) {
                    if auth.state == .authenticating {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    }
                    Text("Mit Keycloak anmelden")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Brand.accent)
            .disabled(auth.state == .authenticating)
            .padding(.horizontal, 32)

            Spacer()
        }
    }
}

private struct SignedInPanel: View {
    @Environment(AuthStore.self) private var auth

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(Brand.Status.verified)

            Text("Du bist angemeldet")
                .font(.ttDisplayLarge)

            Text("Du kannst jetzt Spots hinzufügen, abstimmen und Kommentare schreiben.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            Button(role: .destructive) {
                auth.signOut()
            } label: {
                Text("Abmelden")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
        }
    }
}
