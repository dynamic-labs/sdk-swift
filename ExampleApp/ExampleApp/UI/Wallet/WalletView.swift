//
//  WalletView.swift
//  DynamicSampleApp
//
//  Created by DS on 2025-06-27.
//

import DynamicSwiftSDK
import SwiftUI

struct WalletView: View {
    let client: DynamicClient
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let verifiedCredentials = client.user?.verifiedCredentials {
                    VerifiedCredentialsView(verifiedCredentials: verifiedCredentials, client: client)
                } else {
                    Text("No verified credentials found")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
}
