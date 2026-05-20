//
//  BiometricView.swift
//  TestProject
//
//  Demo Face ID / Touch ID — Xác thực sinh trắc học.
//
//  Kiến thức:
//  1. LAContext — context xác thực cục bộ
//  2. evaluatePolicy — yêu cầu xác thực (FaceID/TouchID)
//  3. LAPolicy — loại xác thực (biometric / passcode)
//  4. LAError — xử lý các loại lỗi xác thực
//  5. canEvaluatePolicy — kiểm tra thiết bị hỗ trợ không
//
//  ⚠️ Cần thêm NSFaceIDUsageDescription vào Info.plist để dùng Face ID.
//  Simulator: dùng Features > Face ID > Enrolled để bật Face ID.
//

import SwiftUI
import LocalAuthentication

// ── BiometricViewModel ───────────────────────────────────────────────────────
@Observable
class BiometricViewModel {
    
    var authState: AuthState = .idle
    var isAuthenticated = false
    var biometricType: LABiometryType = .none
    var errorMessage = ""
    var attemptCount = 0
    
    enum AuthState {
        case idle
        case authenticating
        case success
        case failure(String)
    }
    
    // Kiểm tra loại biometric thiết bị hỗ trợ
    init() {
        checkBiometricType()
    }
    
    func checkBiometricType() {
        let context = LAContext()
        var error: NSError?
        // canEvaluatePolicy: kiểm tra thiết bị có hỗ trợ không
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType  // .faceID hoặc .touchID
        } else {
            biometricType = .none
        }
    }
    
    // Xác thực bằng Biometric (FaceID/TouchID)
    func authenticateWithBiometric() async {
        authState = .authenticating
        let context = LAContext()
        context.localizedCancelTitle = "Dùng mật khẩu"
        
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            let capturedError = error!
            await MainActor.run {
                let errMsg = LAError(LAError.Code(rawValue: capturedError.code)!).localizedDescription
                authState = .failure(errMsg)
                errorMessage = errMsg
            }
            return
        }
        
        do {
            // evaluatePolicy: yêu cầu xác thực
            // reason: hiện trong dialog FaceID/TouchID
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Xác thực để truy cập nội dung bảo mật"
            )
            
            await MainActor.run {
                if success {
                    isAuthenticated = true
                    authState = .success
                    attemptCount += 1
                }
            }
        } catch let error as LAError {
            await MainActor.run {
                let message = laErrorMessage(error)
                authState = .failure(message)
                errorMessage = message
                isAuthenticated = false
            }
        } catch {
            await MainActor.run {
                authState = .failure(error.localizedDescription)
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // Xác thực bằng mật khẩu thiết bị (bao gồm biometric + passcode)
    func authenticateWithPasscode() async {
        authState = .authenticating
        let context = LAContext()
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthentication,  // = biometric + passcode fallback
                localizedReason: "Xác thực để truy cập"
            )
            await MainActor.run {
                if success {
                    isAuthenticated = true
                    authState = .success
                    attemptCount += 1
                }
            }
        } catch let error as LAError {
            await MainActor.run {
                authState = .failure(laErrorMessage(error))
                isAuthenticated = false
            }
        } catch {
            await MainActor.run {
                authState = .failure(error.localizedDescription)
                isAuthenticated = false
            }
        }
    }
    
    func lockScreen() {
        isAuthenticated = false
        authState = .idle
    }
    
    // Chuyển LAError → thông báo tiếng Việt
    func laErrorMessage(_ error: LAError) -> String {
        switch error.code {
        case .authenticationFailed:
            return "Xác thực thất bại. Vui lòng thử lại."
        case .userCancel:
            return "Người dùng đã huỷ xác thực."
        case .userFallback:
            return "Người dùng chọn nhập mật khẩu."
        case .biometryNotAvailable:
            return "Thiết bị không hỗ trợ biometric."
        case .biometryNotEnrolled:
            return "Chưa thiết lập Face ID / Touch ID."
        case .biometryLockout:
            return "Đã thử quá nhiều lần. Vui lòng dùng mật khẩu."
        default:
            return error.localizedDescription
        }
    }
    
    var biometricIcon: String {
        switch biometricType {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        default:       return "lock.fill"
        }
    }
    
    var biometricName: String {
        switch biometricType {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        default:       return "Mật Khẩu"
        }
    }
}

// ── BiometricView ────────────────────────────────────────────────────────────
struct BiometricView: View {
    
    @State private var viewModel = BiometricViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // ── Trạng thái xác thực ────────────────────────────────
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(authBackground)
                        .frame(height: 220)
                    
                    VStack(spacing: 16) {
                        Image(systemName: viewModel.isAuthenticated
                              ? "lock.open.fill" : viewModel.biometricIcon)
                        .font(.system(size: 70))
                        .foregroundStyle(viewModel.isAuthenticated ? .green : .primary)
                        .symbolEffect(.bounce, value: viewModel.isAuthenticated)
                        
                        Text(viewModel.isAuthenticated
                             ? "✅ Đã xác thực thành công!"
                             : "🔒 Nội dung được bảo vệ")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(viewModel.isAuthenticated ? .green : .primary)
                        
                        if case .failure(let msg) = viewModel.authState {
                            Label(msg, systemImage: "exclamationmark.circle")
                                .font(.caption)
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.horizontal)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isAuthenticated)
                
                // ── Nội dung bí mật (chỉ hiện sau khi xác thực) ───────
                if viewModel.isAuthenticated {
                    GroupBox(label: Label("🔐 Nội Dung Bí Mật", systemImage: "key.fill")) {
                        VStack(alignment: .leading, spacing: 10) {
                            SecretRow(label: "Số thẻ tín dụng", value: "4532 •••• •••• 9821")
                            SecretRow(label: "Mã PIN", value: "1234")
                            SecretRow(label: "Mật khẩu Wi-Fi", value: "mySecretWifi123")
                            SecretRow(label: "Mã OTP", value: "847 291")
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal)
                    .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                            removal: .opacity))
                }
                
                // ── Nút xác thực ───────────────────────────────────────
                VStack(spacing: 12) {
                    if !viewModel.isAuthenticated {
                        // Xác thực bằng Biometric
                        Button {
                            Task { await viewModel.authenticateWithBiometric() }
                        } label: {
                            HStack {
                                Image(systemName: viewModel.biometricIcon)
                                    .font(.title3)
                                Text("Xác thực bằng \(viewModel.biometricName)")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.indigo)
                        
                        // Xác thực bằng passcode
                        Button {
                            Task { await viewModel.authenticateWithPasscode() }
                        } label: {
                            Label("Dùng mật khẩu thiết bị", systemImage: "lock.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                    } else {
                        Button {
                            withAnimation { viewModel.lockScreen() }
                        } label: {
                            Label("Khoá màn hình", systemImage: "lock.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .padding(.horizontal)
                .animation(.easeInOut, value: viewModel.isAuthenticated)
                
                // ── Thông tin thiết bị ─────────────────────────────────
                GroupBox(label: Label("Thông Tin Thiết Bị", systemImage: "iphone")) {
                    VStack(spacing: 8) {
                        infoRow("Loại xác thực",
                                value: viewModel.biometricName,
                                icon: viewModel.biometricIcon)
                        infoRow("Số lần xác thực",
                                value: "\(viewModel.attemptCount)",
                                icon: "number")
                        infoRow("Trạng thái",
                                value: viewModel.isAuthenticated ? "Đã xác thực" : "Chưa xác thực",
                                icon: viewModel.isAuthenticated ? "checkmark.shield" : "xmark.shield")
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)
                
                // ── Ghi chú cách dùng ──────────────────────────────────
                GroupBox(label: Label("Cách Dùng Thực Tế", systemImage: "lightbulb")) {
                    VStack(alignment: .leading, spacing: 8) {
                        usageNote("Bảo vệ màn hình tài khoản ngân hàng")
                        usageNote("Unlock nội dung premium")
                        usageNote("Xác nhận giao dịch thanh toán")
                        usageNote("Đăng nhập thay cho mật khẩu")
                        usageNote("Bảo vệ ghi chú/ảnh nhạy cảm")
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("🔐 Face ID / Touch ID")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var authBackground: some ShapeStyle {
        if viewModel.isAuthenticated {
            return AnyShapeStyle(LinearGradient(colors: [.green.opacity(0.15), .teal.opacity(0.1)],
                                                startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        return AnyShapeStyle(LinearGradient(colors: [Color(.systemGray6), Color(.systemGray5)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    
    func infoRow(_ label: String, value: String, icon: String) -> some View {
        HStack {
            Label(label, systemImage: icon).font(.subheadline)
            Spacer()
            Text(value).foregroundStyle(.secondary).font(.subheadline)
        }
    }
    
    func usageNote(_ text: String) -> some View {
        Label(text, systemImage: "checkmark.circle.fill")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

struct SecretRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.system(.subheadline, design: .monospaced)).fontWeight(.semibold)
        }
    }
}

#Preview { NavigationStack { BiometricView() } }
