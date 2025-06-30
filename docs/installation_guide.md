# Installation Guide

## Prerequisites

- iOS 13.0+
- Swift 5.9+
- Xcode 15.0+
- **Dynamic account and environment ID**: Set up your project and get an environment ID from https://app.dynamic.xyz/dashboard/overview

## Swift Package Manager

### Option 1: Package.swift

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/dynamic-labs/sdk-swift.git", from: "0.0.4")
]
```

### Option 2: Xcode

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/dynamic-labs/sdk-swift.git`
3. Select version `0.0.4` or `from: 0.0.4`
4. Add to your target

## Setup in App

### 1. Configure Environment Variables

Add the following environment variables to your app scheme:

1. In Xcode, go to Product → Scheme → Edit Scheme
2. Select "Run" from the left sidebar
3. Go to the "Arguments" tab
4. Under "Environment Variables", add:

```
DYNAMIC_BASE_URL = https://app.dynamicauth.com/api/v0
DYNAMIC_RELAY_HOST = relay.dynamicauth.com
DYNAMIC_ENVIRONMENT_ID = <your_environment_id>
```

Use the environment ID from your Dynamic dashboard (see Prerequisites above).

### 2. Initialize the SDK

Import and configure the SDK in your Swift files:

```swift
import DynamicSwiftSDK

let config = DynamicClientConfig(
    environmentId: ProcessInfo.processInfo.environment["DYNAMIC_ENVIRONMENT_ID"] ?? "<your env value>"
)
let newClient = createDynamicClient(config: config)
```

### Support

For additional help, visit [Dynamic's documentation](https://docs.dynamic.xyz) or contact hello@dynamic.xyz.
