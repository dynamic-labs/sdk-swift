# Ethereum Integration Guide

## Prerequisites

- Dynamic SDK initialized (see [Installation Guide](./installation_guide.md))
- User authenticated (see [Authentication Guide](./authentication.md))
- Wallet created (see [Wallet Management](./wallet_management.md))

## Network Configuration

### Supported Networks

```swift
import DynamicSwiftSDK

// Ethereum Sepolia Testnet (primary network in sample app)
let sepolia = SupportedEthereumNetwork.sepoliaTestnet.chainConfig
print("Sepolia Chain ID: \(sepolia.chainId)") // 11155111
```

### Get Network Client

```swift
let dynamicClient: DynamicClient
let ethereumWallet: EthereumWallet
let chainId = SupportedEthereumNetwork.sepoliaTestnet.chainConfig.chainId

do {
    let networkClient = try await ethereumWallet.getNetworkClient(for: chainId)
    print("Connected to Sepolia network: \(chainId)")
    
    // Get gas price for transactions
    let gasPrice = try await networkClient.eth_gasPriceBigInt()
    print("Current gas price: \(gasPrice) wei")
} catch {
    print("Failed to get network client: \(error)")
}
```

### Switch Network

```swift
// Switch to Sepolia testnet (sample app usage)
let sepoliaConfig = SupportedEthereumNetwork.sepoliaTestnet.chainConfig

do {
    try await ethereumWallet.switchNetwork(to: sepoliaConfig)
    print("🌐 Switched to Sepolia testnet")
} catch {
    print("❌ Failed to switch to Sepolia: \(error)")
}
```

## Ethereum Address Handling

### Address Creation and Validation

```swift
// Create Ethereum address
let address = EthereumAddress("0x1234567890abcdef1234567890abcdef12345678")

// Get string representation
let addressString = address.asString()
print("Address: \(addressString)")
```

### Blockchain Address

```swift
// Get blockchain address for cross-chain compatibility (used in sample app)
let ethereumWallet: EthereumWallet
let blockchainAddress = ethereumWallet.accountAddress
print("Blockchain Address: \(blockchainAddress.asString())")
```

## Gas Management

### Get Current Gas Price

```swift
let networkClient = try await ethereumWallet.getNetworkClient(for: chainId)

do {
    let gasPrice = try await networkClient.eth_gasPriceBigInt()
    print("Current gas price: \(gasPrice) wei")
} catch {
    print("Failed to get gas price: \(error)")
}
```

### Gas Limit for ETH Transfers

```swift

// Standard gas limit for ETH transfers (used in sample app)
let gasLimit = BigUInt(21_000) // Standard ETH transfer
print("ETH Transfer Gas Limit: \(gasLimit)")
```

## Transaction Operations

### Create Transaction

```swift

let fromAddress = ethereumWallet.address
let toAddress = EthereumAddress("0xRecipientAddress")
let amount = BigUInt(1000000000000000000) // 1 ETH in wei
let gasPrice = try await networkClient.eth_gasPriceBigInt()
let gasLimit = BigUInt(21_000)
let chainId = SupportedEthereumNetwork.sepoliaTestnet.chainConfig.chainId

let transaction = EthereumTransaction(
    from: fromAddress,
    to: toAddress,
    value: amount,
    data: Data(),
    nonce: nil,
    gasPrice: gasPrice,
    gasLimit: gasLimit,
    chainId: chainId
)
```

### Send Transaction

```swift
do {
    let txHash = try await ethereumWallet.sendTransaction(transaction)
    print("Transaction Hash: \(txHash)")
    
    // Get network details for block explorer URL
    if let supportedNetwork = SupportedEthereumNetwork.fromChainId(chainId) {
        let networkConfig = supportedNetwork.chainConfig
        if let explorerUrl = networkConfig.blockExplorerUrls.first {
            print("🔍 View on \(networkConfig.name): \(explorerUrl)/tx/\(txHash)")
        }
    }
} catch {
    print("Transaction failed: \(error)")
}
```

### Sign Transaction

```swift
do {
    let signedTransaction = try await ethereumWallet.sign(transaction: transaction)
    print("Transaction signed successfully")
    print("Signature: \(signedTransaction)")
} catch {
    print("Failed to sign transaction: \(error)")
}
```


## Balance Operations

### Get Latest Balance and Convert to ETH

```swift

// Get latest balance (sample app usage)
do {
    let balanceWei = try await ethereumWallet.getBalance(.Latest)
    print("💰 Balance in Wei: \(balanceWei)")
    
    // Convert Wei to Ether (sample app conversion pattern)
    guard let etherValue = Double(String(balanceWei)) else {
        print("❌ Failed to convert balance to double")
        return
    }
    let etherInDecimals = etherValue / pow(10.0, 18.0)
    let balanceEth = String(format: "%.6f", etherInDecimals)
    
    print("💰 Balance in ETH: \(balanceEth)")
} catch {
    print("❌ Failed to fetch balance: \(error)")
}
```

## Best Practices

### 1. Network Switching
Example of how to switch networks:

```swift
// Switch to desired network before operations
let targetNetwork = SupportedEthereumNetwork.sepoliaTestnet.chainConfig
try await ethereumWallet.switchNetwork(to: targetNetwork)

// Then perform operations
let balance = try await ethereumWallet.getBalance(.Latest)
```

### 2. Explorer URL Generation
Generate dynamic block explorer URLs for transaction tracking:

```swift
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
```

