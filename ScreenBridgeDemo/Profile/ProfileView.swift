import SwiftUI
import ScreenBridge

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var displayName = "Alex Example"
    @Published var notificationsOn = true
    @Published var theme = 0

    init() {
        ScreenBridge.register(ProfileViewModel.self, role: "viewModel")
    }
}

/// SwiftUI screen hosted in UIKit. Source anchors come from `.screenBridgeSource`.
struct ProfileView: View {
    @StateObject private var model = ProfileViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading) {
                            Text(model.displayName).font(.title3.weight(.semibold))
                            Text("Demo profile").foregroundStyle(.secondary)
                        }
                    }
                    .screenBridgeSource("ProfileHeader", related: [.type(ProfileViewModel.self, role: "viewModel")])
                }
                Section("Preferences") {
                    Toggle("Notifications", isOn: $model.notificationsOn)
                        .screenBridgeSource("NotificationsToggle")
                    Picker("Theme", selection: $model.theme) {
                        Text("System").tag(0)
                        Text("Light").tag(1)
                        Text("Dark").tag(2)
                    }
                    .screenBridgeSource("ThemePicker")
                }
                Section {
                    Button("Sign out (demo)", role: .destructive) {
                        ScreenBridge.log("Sign-out tapped token=abc123secret", category: "profile")
                    }
                    .screenBridgeSource("SignOutButton")
                }
            }
            .navigationTitle("Profile")
            .screenBridgeSource("ProfileView", role: "screen", related: [.type(ProfileViewModel.self, role: "viewModel")])
        }
    }
}

final class ProfileHostingController: UIHostingController<ProfileView> {
    init() {
        super.init(rootView: ProfileView())
        screenBridgeSource("ProfileHostingController")
    }

    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) { fatalError() }
}
