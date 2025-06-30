//
//  UnauthenticatedView.swift
//  DynamicSampleApp
//
//  Created by Moiz Ahmed on 2025-04-18.
//

import Foundation
import SwiftUI
import DynamicSwiftSDK

enum AuthMode {
    case email
    case phone
}

struct UnauthenticatedView: View {
    let client: DynamicClient
    
    @Binding var message: String

    @State private var selectedCountryCode = "1"
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var phoneCountryCode: String = ""
    @State private var verificationCode: String = ""
    @State private var otpVerification: OTPVerification?
    @State private var mode: AuthMode = .phone
    
    
    public init(client: DynamicClient, message: Binding<String>) {
        self.client = client
        self._message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Log in or sign up")
                .font(.headline)

            Group {
                switch mode {
                case .email:
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                case .phone:
                    HStack {
                        Menu {
                            // You can later expand this with more codes
                            Button("+1 (US)", action: { selectedCountryCode = "1" })
                        } label: {
                            HStack {
                                Text(selectedCountryCode)
                                    .padding(.leading, 12)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }

                        TextField("Phone number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .padding(.leading, 8)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }

            Button(action: {
                Task {
                    do {
                        switch mode {
                        case .email:
                            otpVerification = try await sendEmailOtp(client: client, email: email)
                            message = "OTP sent to \(email)"
                        case .phone:
                            otpVerification = try await sendSmsOtp(
                                client: client,
                                phoneNumber: phoneNumber,
                                phoneCountryCode: selectedCountryCode,
                                isoCountryCode: "CA"
                            )
                            message = "OTP sent to \(phoneNumber)"
                        }
                    } catch {
                        message = "❌ Failed to send OTP: \(error.localizedDescription)"
                    }
                }
            }) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)                         



            Button {
                mode = mode == .email ? .phone : .email
            } label: {
                Text(mode == .email ? "Use phone instead" : "Use email instead")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }

            if otpVerification != nil {
                TextField("Enter OTP", text: $verificationCode)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .padding(.horizontal)

                Button(action: {
                    guard let otpVerification else {
                        message = "Missing verification data."
                        return
                    }

                    Task {
                        do {
                            switch mode {
                            case .email:
                                _ = try await verifyOtp(
                                    otpVerification: otpVerification,
                                    verificationToken: verificationCode
                                )
                            case .phone:
                                _ = try await verifySmsOtp(
                                    otpVerification: otpVerification,
                                    verificationToken: verificationCode
                                )
                            }
                            message = "✅ Verified!"
                        } catch {
                            message = "❌ Verification failed: \(error.localizedDescription)"
                        }
                    }
                }) {
                    Text("Verify OTP")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
            
            SocialAuthPicker(client: client, mode: .enabledOnly) { providerType in
                Task {
                    await self.handleSocialAuth(provider: providerType)
                }
            }
        }
        .padding(.vertical, 32)
    }
    
    private func handleSocialAuth(provider: ProviderType) async {
        message = "Preparing authentication..."
        
        do {
            let user = try await socialLogin(
                client: client,
                with: provider,
                deepLinkUrl: "dynamicsample://"
            )
            self.message = "✅ Successfully logged in: \(user.email ?? "Unknown")"
            
        } catch {
            self.message = "❌ Social auth failed: \(error.localizedDescription)"
        }
    }

}
