# Wallet Management Guide

## Overview

The Dynamic Swift SDK provides wallet management functionality for Ethereum-based wallets. This guide covers the core wallet operations demonstrated in the sample application: creating wallets, checking balances, signing messages, and sending transactions.

## Prerequisites

- Dynamic SDK initialized (see [Installation Guide](./installation_guide.md))
- User authenticated (see [Authentication Guide](./authentication.md))
- Dynamic Client instance created

## Wallet Creation

### Create New Wallet Account

To create a new wallet for an authenticated user, use the `createWalletAccount` function:

```swift
import DynamicSwiftSDK

let dynamicClient: DynamicClient

// Create a new wallet account
do {
    let accountAddress = try await createWalletAccount(client: dynamicClient)
    print("✅ Wallet created successfully!")
    print("Account Address: \(accountAddress)")
    
    // The wallet is automatically added to the user's verified credentials
} catch {
    print("❌ Failed to create wallet: \(error)")
}
```


## Wallet Initialization from Existing Address

### Initialize Ethereum Wallet from Address

Once a wallet exists (either created or already present), you can initialize an `EthereumWallet` instance:

```swift
import DynamicSwiftSDK

let dynamicClient: DynamicClient
let walletAddress = "0x1234567890abcdef1234567890abcdef12345678" // Existing wallet address

do {
    let ethereumWallet = try EthereumWallet(
        address: walletAddress,
        client: dynamicClient
    )
    
    print("Wallet initialized: \(ethereumWallet.address.asString())")
} catch {
    print("Failed to initialize wallet: \(error)")
}
```

### Get Wallet from Verified Credentials

```swift
import DynamicSwiftSDK

let dynamicClient: DynamicClient

// Get user's verified credentials and filter for blockchain wallets
if let verifiedCredentials = dynamicClient.user?.verifiedCredentials {
    for credential in verifiedCredentials {
        if credential.oauthProvider == .blockchain,
           let walletAddress = credential.publicIdentifier {
            do {
                let wallet = try EthereumWallet(address: walletAddress, client: dynamicClient)
                print("Wallet found: \(wallet.address.asString())")
                break
            } catch {
                print("Failed to initialize wallet: \(error)")
            }
        }
    }
}
```

## Wallet Information

### Get Wallet Address

```swift
let walletAddress = ethereumWallet.address.asString()
print("Wallet Address: \(walletAddress)")

// Get blockchain address for cross-chain compatibility
let blockchainAddress = ethereumWallet.accountAddress
print("Blockchain Address: \(blockchainAddress.asString())")
```

### Get Wallet Properties

```swift
// Wallet address (used in sample app UI)
let walletAddress = ethereumWallet.address.asString()
print("Wallet Address: \(walletAddress)")

// Account address for cross-chain compatibility
let accountAddress = ethereumWallet.accountAddress.asString()
print("Account Address: \(accountAddress)")
```

## Balance Management

### Get Wallet Balance

```swift
import BigIntModule

// Get latest balance
do {
    let balanceWei = try await ethereumWallet.getBalance(.Latest)
    
    // Convert Wei to Ether
    let etherValue = Double(String(balanceWei)) ?? 0.0
    let balanceEth = etherValue / pow(10.0, 18.0)
    
    print("Balance: \(String(format: "%.6f", balanceEth)) ETH")
} catch {
    print("Failed to get balance: \(error)")
}
```

### Switch to Sepolia Network

```swift
// Switch to Sepolia testnet (as used in sample app)
let sepoliaNetwork = SupportedEthereumNetwork.sepoliaTestnet.chainConfig

do {
    try await ethereumWallet.switchNetwork(to: sepoliaNetwork)
    let balance = try await ethereumWallet.getBalance(.Latest)
    
    // Convert Wei to ETH (sample app pattern)
    let etherValue = Double(String(balance)) ?? 0.0
    let balanceEth = etherValue / pow(10.0, 18.0)
    let formattedBalance = String(format: "%.6f", balanceEth)
    
    print("Sepolia Balance: \(formattedBalance) ETH")
} catch {
    print("Failed to switch network or get balance: \(error)")
}
```

## Message Signing

### Sign a Message

```swift
let message = "Hello There!" // Message used in sample app

do {
    let signature = try await ethereumWallet.signMessage(message)
    print("✅ Message signed successfully!")
    print("📝 Message: \(message)")
    print("🔏 Signature: \(signature)")
    print("🔏 Address: \(ethereumWallet.accountAddress.asString())")
} catch {
    print("❌ Failed to sign message: \(error)")
}
```

### Verify Signature

```swift
import DynamicSwiftSDK

let message = "Hello There!"
let signature = "0x..." // Signature from signing step
let walletAddress = ethereumWallet.accountAddress.asString()

do {
    let verificationResult = try verifySignature(
        message: message,
        signature: signature,
        walletAddress: walletAddress
    )
    
    print("Verification Result: \(verificationResult)")
} catch {
    print("Failed to verify signature: \(error)")
}
```

## Transaction Management

### Send ETH Transaction

```swift
import BigIntModule

// Transaction parameters (as used in sample app)
let amount = BigUInt(10000000000000000) // 0.01 ETH in wei
let recipient = EthereumAddress("0xd4f748199B91c22095150d2d4Cca3Fe6175B0CbA") 
let chainId = SupportedEthereumNetwork.sepoliaTestnet.chainConfig.chainId

do {
    // Get network client for Sepolia
    let networkClient = try await ethereumWallet.getNetworkClient(for: chainId)
    
    // Get current gas price and set gas limit
    let gasPrice = try await networkClient.eth_gasPriceBigInt()
    let gasLimit = BigUInt(21_000) // Standard ETH transfer
    
    print("🌐 Network: Ethereum Sepolia (Chain ID: \(chainId))")
    print("💰 Amount: 0.01 ETH")
    print("📍 From: \(ethereumWallet.address.asString())")
    print("📍 To: \(recipient.asString())")
    print("⛽ Gas Price: \(gasPrice) wei")
    print("⛽ Gas Limit: \(gasLimit)")
    
    // Create transaction
    let transaction = EthereumTransaction(
        from: ethereumWallet.address,
        to: recipient,
        value: amount,
        data: Data(),
        nonce: nil,
        gasPrice: gasPrice,
        gasLimit: gasLimit,
        chainId: chainId
    )
    
    print("📝 Transaction created successfully")
    
    // Send transaction
    let txHash = try await ethereumWallet.sendTransaction(transaction)
    
    print("✅ Transaction sent!")
    print("🔗 Transaction Hash: \(txHash)")
    
    // Get network details for block explorer URL
    if let supportedNetwork = SupportedEthereumNetwork.fromChainId(chainId) {
        let networkConfig = supportedNetwork.chainConfig
        if let explorerUrl = networkConfig.blockExplorerUrls.first {
            print("🔍 View on \(networkConfig.name): \(explorerUrl)/tx/\(txHash)")
        }
    }
} catch {
    print("❌ Transaction failed: \(error)")
}
```

## Key Shares Management

### Check Key Shares Availability

```swift
func checkKeySharesAvailability(client: DynamicClient, walletAddress: String) -> Bool {
    let keyShares = loadKeyShares(client: client, accountAddress: walletAddress)
    return keyShares != nil
}

// Usage
let hasKeyShares = checkKeySharesAvailability(
    client: dynamicClient,
    walletAddress: ethereumWallet.address.asString()
)

print("Key shares available: \(hasKeyShares)")
```

## Network Management

### Sepolia Testnet

```swift
// Sepolia testnet configuration (used in sample app)
let sepoliaNetwork = SupportedEthereumNetwork.sepoliaTestnet.chainConfig
print("Sepolia Chain ID: \(sepoliaNetwork.chainId)") // 11155111

// Switch to Sepolia (sample app pattern)
do {
    try await ethereumWallet.switchNetwork(to: sepoliaNetwork)
    print("🌐 Switched to Ethereum Sepolia")
} catch {
    print("❌ Failed to switch to Sepolia: \(error)")
}
```

## Error Handling

### Common Wallet Errors

```swift
do {
    let wallet = try EthereumWallet(address: "invalid_address", client: dynamicClient)
} catch {
    if let nsError = error as NSError? {
        switch nsError.code {
        case 1003:
            print("Could not determine wallet ID from address")
        default:
            print("Wallet creation error: \(error)")
        }
    }
}
```

## Best Practices

### 1. Network Switching
Always switch to Sepolia before performing operations:

```swift
// Switch to Sepolia first
let sepoliaNetwork = SupportedEthereumNetwork.sepoliaTestnet.chainConfig
try await wallet.switchNetwork(to: sepoliaNetwork)

// Then perform operations
let balance = try await wallet.getBalance(.Latest)
```

### 2. Gas Price Fetching
Get current gas prices for transactions:

```swift
let networkClient = try await wallet.getNetworkClient(for: chainId)
let gasPrice = try await networkClient.eth_gasPriceBigInt()
```

## Next Steps

- [Ethereum Integration](./ethereum_integration.md) - Advanced Ethereum features