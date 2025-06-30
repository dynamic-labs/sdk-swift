import DynamicSwiftSDK
import SwiftUI

struct ContentView: View {
    @State private var client: DynamicClient?

    //This should be placed in the file where client is created, and should control which view
    @StateObject private var sessionState = DynamicSessionState()

    @State private var message: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Dynamic Swift Sample App")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)

                if !sessionState.isInitialized {
                    ProgressView("Initializing SDK...")
                } else if let client {
                    if sessionState.isLoggedIn {
                        AuthenticatedView(
                            client: client,
                            onLogout: {
                                message = "👋 Logged out"
                            }
                        )
                    } else {
                        UnauthenticatedView(
                            client: client,
                            message: $message
                        )
                    }

                    Text(message)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)

                    Spacer()
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
        .task {
            await initialize()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task {
                await refreshSettingsIfNeeded()
            }
        }
    }

    private func initialize() async {
        print("🔥 Starting SDK initialization")

        let config = DynamicClientConfig(
            environmentId:
                ProcessInfo.processInfo.environment["DYNAMIC_ENVIRONMENT_ID"]
                ?? "6fc9ab72-60f4-4f8c-bcd0-5e2bc5c09105"
        )
        let newClient = createDynamicClient(config: config)
        
        client = newClient
        bindSessionState(sessionState, to: newClient)

        do {
            try await addEthereumConnector(
                to: newClient,
                networkConfigProvider: GenericNetworkConfigurationProvider(),
                initialChainId: 84532  // Base Testnet
            )
        } catch {
            print("Error adding Ethereum connector: \(error)")
        }

        message = "✅ SDK Initialized"
    }
    
    private func refreshSettingsIfNeeded() async {
        guard let existingClient = client else { return }
        print("🔄 Refreshing project settings on app activation")
        do {
            try await initializeClient(client: existingClient)
            print("✅ Settings refresh completed")
        } catch {
            print("❌ Failed to refresh settings: \(error)")
        }
    }
}
