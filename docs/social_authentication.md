# Social Authentication Guide

## Overview

Social authentication allows users to sign in to your app using their existing social media accounts. The Dynamic Swift SDK supports multiple providers including Apple, Google, Twitter, Discord, GitHub, and Twitch.

## Prerequisites

### 1. Dynamic Dashboard Configuration

Before implementing social authentication, you must enable and configure the desired providers in your Dynamic dashboard:

1. Log in to [Dynamic Dashboard](https://app.dynamic.xyz/dashboard)
2. Navigate to **Log in and User Profile** → **Social**
3. Enable the providers you want to support
4. Configure OAuth settings for each provider

### 2. Configure Deep Link URL

Register your app's redirect URL in the Dynamic dashboard:

1. Go to [Dynamic Dashboard](https://app.dynamic.xyz/dashboard/security)
2. Navigate to **Security** → **Whitelist Mobile Deeplink**
3. Add your app's deep link URL (e.g., `myapp://auth/callback`)
4. Save the configuration

### 3. Info.plist Configuration

Add the following to your `Info.plist` to ensure Safari authentication works properly:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>https</string>
    <string>http</string>
</array>
```

## Implementation

### Get Available Providers

First, fetch the list of enabled providers for your environment:

```swift
import DynamicSwiftSDK

let dynamicClient: DynamicClient

// Fetch enabled providers
let providers: [ProviderInfo] = try await getEnabledSocialProviders(client: dynamicClient)

// Check available providers
for provider in providers {
    print("Available: \(provider.provider)")
}
```

### Implement Social Login

```swift
import DynamicSwiftSDK

let dynamicClient: DynamicClient
let provider: ProviderType = .google // or any supported provider
let deepLinkUrl = "myapp://auth/callback" // Your app's deep link URL (must be whitelisted in Dynamic dashboard)

do {
    let authenticatedUser: SdkUser = try await socialLogin(
        client: dynamicClient,
        with: provider,
        deepLinkUrl: deepLinkUrl
    )
    
    print("Welcome \(authenticatedUser.email ?? "")")
    print("User ID: \(authenticatedUser.id)")
    
    // User is now authenticated
    // Navigate to your app's main screen
} catch {
    print("Social login failed: \(error)")
    // Handle error appropriately
}
```
### Provider Types

```swift
public enum ProviderType: String {
    case apple = "apple"
    case google = "google" 
    case twitter = "twitter"
    case discord = "discord"
    case github = "github"
    case twitch = "twitch"
}
```

## Troubleshooting

### Callback Not Working
- Verify your app's URL scheme is configured correctly in Dynamic dashboard
- Check that redirect URLs match in provider and Dynamic settings

### Provider Not Showing
- Confirm provider is enabled in Dynamic dashboard
- Check that `fetchSocialProviders` is called successfully
