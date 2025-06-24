# Authentication Guide

## Overview

The Dynamic Swift SDK provides multiple authentication methods including Email OTP, SMS OTP, and Social Login. This guide covers how to implement each authentication method in your iOS application.

## Prerequisites

- Dynamic SDK initialized (see [Installation Guide](./installation_guide.md))
- Dynamic Client instance created
- Valid environment ID configured

## Email OTP Authentication

Email OTP (One-Time Password) authentication allows users to sign in using their email address.

### 1. Send OTP to Email

```swift
import DynamicSwiftSDK

let dynamicClient: DynamicClient
let userEmail: String = "user@example.com"

let otpVerification: OTPVerification = try await sendEmailOtp(
    client: dynamicClient,
    email: userEmail
)

var currentOtpVerification: OTPVerification?
currentOtpVerification = otpVerification
```

### 2. Verify Email OTP

```swift
let otpCode: String = "123456" // The OTP code entered by user

guard let otpVerification = currentOtpVerification else {
    print("No OTP verification in progress")
    return
}

do {
    let authenticatedUser: SdkUser = try await verifyOtp(
        otpVerification: otpVerification,
        verificationToken: otpCode
    )
    
    print("Welcome \(authenticatedUser.email ?? "")")
} catch {
    print("Invalid OTP: \(error)")
}
```

## SMS OTP Authentication

SMS OTP authentication allows users to sign in using their phone number.

### 1. Send OTP via SMS

```swift
import DynamicSwiftSDK

let dynamicClient: DynamicClient
let phoneNumber: String = "1234567890"
let phoneCountryCode: String = "+1" 
let isoCountryCode: String = "US"

let otpVerification: OTPVerification = try await sendSmsOtp(
    client: dynamicClient,
    phoneNumber: phoneNumber,
    phoneCountryCode: phoneCountryCode,
    isoCountryCode: isoCountryCode
)

var currentOtpVerification: OTPVerification?
currentOtpVerification = otpVerification
```

### 2. Verify SMS OTP

```swift
let otpCode: String = "123456" // The OTP code entered by user

guard let otpVerification = currentOtpVerification else {
    print("No OTP verification in progress")
    return
}

do {
    let authenticatedUser: SdkUser = try await verifySmsOtp(
        otpVerification: otpVerification,
        verificationToken: otpCode
    )
    
    print("Welcome user with phone: \(authenticatedUser.phoneNumber ?? "")")
} catch {
    print("Invalid OTP: \(error)")
}
```

## Social Authentication

Social authentication allows users to sign in using their existing social media accounts including Apple, Google, Twitter, Discord, GitHub, and Twitch.

For detailed setup instructions, provider configuration, and implementation examples, see the [Social Authentication Guide](./social_authentication.md).


## Authentication State Management

The SDK automatically manages authentication state. After successful authentication:

1. JWT tokens are stored securely
2. User information is available through the SDK
3. Authenticated requests can be made to Dynamic APIs

### Check Authentication Status

```swift
// Get current authenticated user
if let currentUser = dynamicClient.authenticatedUser {
    print("User is authenticated: \(currentUser.id)")
} else {
    print("User is not authenticated")
}
```

### Logout

```swift
// Clear authentication state
dynamicClient.logout()
```

## Key Data Types

### OTPVerification
The `OTPVerification` object is returned when sending an OTP and must be stored to verify the OTP later:

```swift
public struct OTPVerification {
    public let email: String?           // Email address (for email OTP)
    public let phoneNumber: String?     // Phone number (for SMS OTP)
    public let phoneCountryCode: String? // Country code (for SMS OTP)
    public let isoCountryCode: String?  // ISO country code (for SMS OTP)
    public let verificationUUID: String // Unique ID for this verification
}
```

### SdkUser
The `SdkUser` object represents an authenticated user:

```swift
public struct SdkUser {
    public let id: String              // User's unique ID
    public let email: String?          // User's email
    public let phoneNumber: String?    // User's phone number
    // ... other user properties
}
```

## Next Steps

- [Social Authentication](./social_authentication.md) - Set up social login providers
- [Wallet Management](./wallets.md) - Create and manage wallets for authenticated users
- [Transaction Signing](./transactions.md) - Sign and send blockchain transactions
