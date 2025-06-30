
import SwiftUI
import DynamicSwiftSDK

public enum SocialAuthMode {
    case enabledOnly
    case allProviders
}

struct SocialAuthPicker: View {
    @State private var isExpanded = false
    @State private var enabledProviders: [(provider: ProviderType, displayName: String, imageName: String)] = []
    @State private var displayedProviders: [(provider: ProviderType, displayName: String, imageName: String)] = []
    
    let client: DynamicClient
    let mode: SocialAuthMode
    let onProviderSelected: (ProviderType) -> Void
    
    private let providerMapping: [(provider: ProviderType, displayName: String, imageName: String)] = [
        (.apple, "Apple", "apple-logo"),
        (.google, "Google", "google-logo"),
        (.twitter, "X", "x-logo"),
        (.discord, "Discord", "discord-logo"),
        (.github, "GitHub", "github-logo"),
        (.twitch, "Twitch", "twitch-logo"),
    ]

    var visibleProviders: [(provider: ProviderType, displayName: String, imageName: String)] {
        isExpanded ? displayedProviders : Array(displayedProviders.prefix(8))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if displayedProviders.isEmpty && enabledProviders.isEmpty {
                Text("No social auth providers available.")
                    .foregroundColor(.gray)
                    .padding()
            } else if displayedProviders.isEmpty {
                ProgressView()
                    .padding()
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                    ForEach(visibleProviders, id: \.provider) { item in
                        Button(action: {
                            onProviderSelected(item.provider)
                        }) {
                            if item.imageName == "questionmark.circle" {
                                Image(systemName: item.imageName)
                                    .font(.system(size: 24))
                                    .frame(width: 48, height: 48)
                            } else {
                                Image(item.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 48, height: 48)
                            }
                        }
                        .buttonStyle(SocialButtonStyle())
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
                
                if displayedProviders.count > 8 {
                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(isExpanded ? "Show less" : "More")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(24)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(20)
        .task {
            await loadProviders()
        }
    }
    
    @MainActor
    private func loadProviders() async {
        switch mode {
        case .enabledOnly:
            await loadEnabledProviders()
        case .allProviders:
            await loadAllProviders()
        }
    }
    
    @MainActor
    private func loadEnabledProviders() async {
        do {
            let providers = try await getEnabledSocialProviders(client: client)
            
            let mapped = providers.compactMap { provider -> (provider: ProviderType, displayName: String, imageName: String)? in
                if let mappingInfo = providerMapping.first(where: { $0.provider == provider.provider }) {
                    return mappingInfo
                } else {
                    let displayName = String(describing: provider.provider).capitalized
                    return (provider: provider.provider, displayName: displayName, imageName: "questionmark.circle")
                }
            }
            
            self.enabledProviders = mapped
            self.displayedProviders = mapped
        } catch {
            print("Failed to load enabled providers: \(error)")
            self.enabledProviders = []
            self.displayedProviders = []
        }
    }
    
    @MainActor
    private func loadAllProviders() async {
        self.displayedProviders = providerMapping
        
        do {
            let providers = try await getEnabledSocialProviders(client: client)
            let mapped = providers.compactMap { provider -> (provider: ProviderType, displayName: String, imageName: String)? in
                if let mappingInfo = providerMapping.first(where: { $0.provider == provider.provider }) {
                    return mappingInfo
                } else {
                    let displayName = String(describing: provider.provider).capitalized
                    return (provider: provider.provider, displayName: displayName, imageName: "questionmark.circle")
                }
            }
            self.enabledProviders = mapped
        } catch {
            print("Failed to load enabled providers: \(error)")
        }
    }
}

struct SocialButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
