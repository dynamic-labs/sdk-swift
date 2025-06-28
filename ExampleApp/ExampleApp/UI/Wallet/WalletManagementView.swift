//
//  WalletManagementView.swift
//  DynamicSampleApp
//
//  Created by DS on 2025-06-27.
//

import BigIntModule
import DynamicSwiftSDK
import Foundation
import SwiftUI

struct WalletManagementView: View {
    let credential: JwtVerifiedCredential
    let client: DynamicClient
    
    @State private var primaryWallet: EthereumWallet?
    @State private var signature: String?
    @State private var transactionHash: String?
    @State private var addressCopied = false
    @State private var balance: String?
    @State private var keySharesAvailable: Bool?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                walletInfoSection
                if let primaryWallet = primaryWallet {
                    walletDetailsSection(for: primaryWallet)
                    signatureSection
                } else {
                    Text("Initializing wallet...")
                        .foregroundColor(.secondary)
                        .padding()
                }
                walletActionsSection
            }
            .padding()
        }
        .task {
            await initializeWallet()
            await checkKeySharesAvailability()
        }
    }
    
    @ViewBuilder
    private var walletInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wallet Information")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                if let walletName = credential.walletName {
                    infoRow(title: "Wallet Name", value: walletName)
                }
                
                if let walletProvider = credential.walletProvider {
                    infoRow(title: "Provider", value: walletProvider.rawValue)
                }
                
                if let chain = credential.chain {
                    infoRow(title: "Chain", value: chain)
                }
                
                if let publicIdentifier = credential.publicIdentifier {
                    infoRow(title: "Address", value: publicIdentifier)
                }
                
                keySharesStatusRow
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private func walletDetailsSection(for primaryWallet: EthereumWallet) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wallet Details")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Button(action: {
                    UIPasteboard.general.string = primaryWallet.address.asString()
                    addressCopied = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        addressCopied = false
                    }
                }) {
                    HStack {
                        Text(
                            addressCopied
                            ? "Address Copied! ✓"
                            : "Address: \(primaryWallet.address.asString())"
                        )
                        .foregroundColor(addressCopied ? .green : .primary)
                        .font(.caption)
                        Spacer()
                        Image(systemName: "doc.on.clipboard")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)
                
                if let balance = balance {
                    infoRow(title: "Balance", value: "\(balance) ETH")
                } else {
                    HStack {
                        Text("Balance:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private var signatureSection: some View {
        if let signature = signature {
            VStack(alignment: .leading, spacing: 8) {
                Text("Last Signature")
                    .font(.headline)
                Text(signature)
                    .font(.caption)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
    
    @ViewBuilder
    private var walletActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Wallet Actions")
                .font(.headline)
            
            VStack(spacing: 12) {
                if let primaryWallet = primaryWallet {
                    walletActionButton(title: "Sign Message", systemImage: "signature") {
                        signMessage(for: primaryWallet)
                    }
                    
                    walletActionButton(title: "Send Transaction", systemImage: "paperplane") {
                        sendTransaction(for: primaryWallet)
                    }
                    
                    walletActionButton(title: "Refresh Balance", systemImage: "dollarsign.circle") {
                        print("🔄 Refresh Balance button clicked")
                        Task {
                            print("🔄 Starting balance refresh...")
                            await fetchBalance(for: primaryWallet)
                            print("🔄 Balance refresh completed")
                        }
                    }
                    
                } else {
                    Text("Loading wallet...")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
    
    @ViewBuilder
    private func walletActionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                Text(title)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var keySharesStatusRow: some View {
        HStack {
            Text("Key Shares:")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            if let available = keySharesAvailable {
                Text(available ? "Available" : "Not Found")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(available ? .green : .red)
            } else {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
    }
    
    // MARK: - Wallet Operations
    private func initializeWallet() async {
        guard let address = credential.publicIdentifier else { return }
        do {
            primaryWallet = try EthereumWallet(address: address, client: client)
            if let wallet = primaryWallet {
                await fetchBalance(for: wallet)
            }
        } catch {
            print("Failed to initialize wallet: \(error)")
        }
    }
    
    private func fetchBalance(for wallet: EthereumWallet) async {
        do {
            print("🔍 Fetching balance from Ethereum Sepolia...")
            
            // Switch to Ethereum Sepolia network first
            let sepoliaNetwork = SupportedEthereumNetwork.sepoliaTestnet.chainConfig
            try await wallet.switchNetwork(to: sepoliaNetwork)
            
//            // Now get balance using the public method (this will use the current network)
            let balanceWei = try await wallet.getBalanceString()
            
            print("💰 Balance in Wei: \(balanceWei)")
            
            // Convert Wei (BigUInt) to Ether (Double)
            guard let etherValue = Double(String(balanceWei)) else {
                print("❌ Failed to convert balance to double")
                await MainActor.run {
                    balance = "Error"
                }
                return
            }
            let etherInDecimals = etherValue / pow(10.0, 18.0)
            let balanceEth = String(format: "%.6f", etherInDecimals)
            
            print("💰 Balance in ETH: \(balanceEth)")
            
            await MainActor.run {
                balance = balanceEth
            }
        } catch {
            print("❌ Failed to fetch balance: \(error)")
            await MainActor.run {
                balance = "Error"
            }
        }
    }
    
    private func signMessage(for wallet: EthereumWallet) {
        Task {
            let message = "Hello There!"
            
            do {
                let sig = try await wallet.signMessage(message)
                signature = sig
                print("✅ Message signed successfully!")
                print("📝 Message: \(message)")
                print("🔏 Signature: \(sig)")
                print("🔏 Address: \(wallet.accountAddress)")
            } catch {
                print("❌ Failed to sign message: \(error)")
                signature = nil
            }
            
            let verificationResult = try verifySignature(message: message, signature: signature!, walletAddress: wallet.accountAddress.asString())
            print("Verification Result: \(verificationResult)")
            
        }
    }
    
    private func sendTransaction(for wallet: EthereumWallet) {
        Task { () async throws -> Void in
            let amount = BigUInt(10000000000000000) // 0.01 ETH in wei
            let chainId = SupportedEthereumNetwork.sepoliaTestnet.chainConfig.chainId
            let recipient = EthereumAddress(
                "0xd4f748199B91c22095150d2d4Cca3Fe6175B0CbA") // Example recipient
            
            do {
                let networkClient: BaseEthereumClient = try await wallet.getNetworkClient(for: chainId)
                
                let gasPrice = try await networkClient.eth_gasPriceString()
                let gasLimit = BigUInt(21_000) // Standard ETH transfer
                
                print("🌐 Network: Ethereum Sepolia (Chain ID: \(chainId))")
                print("💰 Amount: 0.01 ETH")
                print("📍 From: \(wallet.address.asString())")
                print("📍 To: \(recipient.asString())")
                print("⛽ Gas Price: \(gasPrice) wei")
                print("⛽ Gas Limit: \(gasLimit)")
                
                let transaction = EthereumTransaction(
                    from: wallet.address,
                    to: recipient,
                    value: amount,
                    data: Data(),
                    nonce: nil,
                    gasPrice: BigUInt(gasPrice),
                    gasLimit: gasLimit,
                    chainId: chainId
                )
                
                print("📝 Transaction created successfully")
                
                let txHash = try await wallet.sendTransaction(transaction)
                
                print("✅ Transaction sent!")
                print("🔗 Transaction Hash: \(txHash)")
                
                // Get network details for block explorer URL
                if let supportedNetwork = SupportedEthereumNetwork.fromChainId(chainId) {
                    let networkConfig = supportedNetwork.chainConfig
                    if let explorerUrl = networkConfig.blockExplorerUrls.first {
                        print("🔍 View on \(networkConfig.name): \(explorerUrl)/tx/\(txHash)")
                    }
                }
                
                await MainActor.run {
                    transactionHash = txHash
                }
            } catch {
                print("❌ Transaction failed: \(error)")
            }
        }
    }
    
    private func checkKeySharesAvailability() async {
        guard let address = credential.publicIdentifier else {
            await MainActor.run {
                keySharesAvailable = false
            }
            return
        }
        
        let keyShares = loadKeyShares(client: client, accountAddress: address)
        await MainActor.run {
            keySharesAvailable = keyShares != nil
        }
    }
}
