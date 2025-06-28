//
//  AuthenticatedView.swift
//  DynamicSampleApp
//
//  Created by Moiz Ahmed on 2025-04-18.
//

import BigIntModule
import DynamicSwiftSDK
import Foundation
import SwiftUI

struct AuthenticatedView: View {
    let client: DynamicClient
    let onLogout: () -> Void
    
    @State private var tokenCopied = false
    @State private var showWalletView = false
    @State private var verifiedCredentials: [JwtVerifiedCredential] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerView
                tokenView
                verifiedCredentialsView
                createWalletButton
                logoutButton
            }
            .padding()
        }
        .task {
            // Initialize credentials when view loads
            updateCredentials()
        }
    }
    
    
    private func updateCredentials() {
        verifiedCredentials = client.user?.verifiedCredentials ?? []
    }
}

// MARK: - Subviews
extension AuthenticatedView {
    @ViewBuilder
    fileprivate var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("👋 Logged in as \(client.user?.email ?? client.user?.phoneNumber ?? "Unknown")")
                .font(.footnote)
                .foregroundColor(.secondary)
            Text("Project: \(client.projectSettings?.general.displayName ?? "None")")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    fileprivate var tokenView: some View {
        if let token = client.token {
            Button(action: {
                UIPasteboard.general.string = token
                tokenCopied = true
                
                // Reset the copied state after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    tokenCopied = false
                }
            }) {
                HStack {
                    Text(tokenCopied ? "Token Copied! ✓" : "Token: \(String(token.prefix(22)))...")
                        .font(.footnote)
                        .foregroundColor(tokenCopied ? .green : .secondary)
                    Spacer()
                    Image(systemName: "doc.on.clipboard")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                .padding(.horizontal)
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    fileprivate var verifiedCredentialsView: some View {
        if !verifiedCredentials.isEmpty {
            VerifiedCredentialsView(verifiedCredentials: verifiedCredentials, client: client)
        }
    }
    
    fileprivate var createWalletButton: some View {
        Button(action: {
            Task {
                if let _ = try? await createWalletAccount(client: client) {
                    // Ceremony is now complete, update credentials
                    await MainActor.run {
                        updateCredentials()
                    }
                }
            }
        }) {
            Text("Create Wallet")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    fileprivate var logoutButton: some View {
        Button(action: {
            Task {
                try? await logout(client: client)
                onLogout()
            }
        }) {
            Text("Logout")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}
