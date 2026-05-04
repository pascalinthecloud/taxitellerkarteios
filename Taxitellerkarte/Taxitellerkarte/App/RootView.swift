import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            Tab("Karte", systemImage: "map.fill") {
                MapView()
            }
            Tab("Favoriten", systemImage: "heart.fill") {
                FavoritesPlaceholderView()
            }
            Tab("Profil", systemImage: "person.crop.circle.fill") {
                SignInView()
            }
        }
    }
}

#Preview {
    RootView()
}
