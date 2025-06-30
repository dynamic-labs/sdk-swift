//
//  VerifiedCredentialsView.swift
//  DynamicSampleApp
//
//  Created by DS on 2025-06-27.
//

import DynamicSwiftSDK
import SwiftUI

struct VerifiedCredentialsView: View {
    let verifiedCredentials: [JwtVerifiedCredential]
    let client: DynamicClient?
    
    init(verifiedCredentials: [JwtVerifiedCredential], client: DynamicClient? = nil) {
        self.verifiedCredentials = verifiedCredentials
        self.client = client
    }
    
    var body: some View {
        if !verifiedCredentials.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Verified Credentials")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(Array(verifiedCredentials.enumerated()), id: \.offset) { index, credential in
                    VerifiedCredentialCard(credential: credential, client: client)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct VerifiedCredentialCard: View {
    let credential: JwtVerifiedCredential
    let client: DynamicClient?
    @State private var navigateToManagement = false
    @State private var navigationPath = NavigationPath()
    
    init(credential: JwtVerifiedCredential, client: DynamicClient? = nil) {
        self.credential = credential
        self.client = client
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            credentialHeader
            credentialDetails
            if isBlockchainWalletProvider {
                manageButton
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var credentialHeader: some View {
        HStack {
            Text("ID: \(credential.id)")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    @ViewBuilder
    private var credentialDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            let format = credential.format
            credentialRow(title: "Format", value: format.rawValue)
            
            if let oauthProvider = credential.oauthProvider {
                credentialRow(title: "Oauth Provider", value: oauthProvider.rawValue)
            }
            
            if let walletProvider = credential.walletProvider {
                credentialRow(title: "Wallet Provider", value: walletProvider.rawValue)
            }
            
            if let walletName = credential.walletName {
                credentialRow(title: "Wallet Name", value: walletName)
            }
            
            if let chain = credential.chain {
                credentialRow(title: "Chain", value: chain)
            }
            
            if let publicIdentifier = credential.publicIdentifier {
                credentialRow(title: "Public Id", value: publicIdentifier)
            }
            
        }
    }
    
    @ViewBuilder
    private func credentialRow(title: String, value: String) -> some View {
        HStack {
            Text("\(title): \(value)")
                .font(.caption)
            Spacer()
        }
    }
    
    private var isBlockchainWalletProvider: Bool {
        credential.format == .blockchain && credential.walletProvider != nil
    }
    
    @ViewBuilder
    private var manageButton: some View {
        if let client = client {
            NavigationLink(destination: WalletManagementView(credential: credential, client: client)) {
                Text("Manage")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(6)
            }
        } else {
            Text("No client available")
                .font(.caption)
                .foregroundColor(.red)
        }
    }
}

#Preview {
    VerifiedCredentialsView(verifiedCredentials: [])
}
