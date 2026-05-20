//
//  SettingsView.swift
//  TestProject
//
//  Màn hình Cài Đặt — Demo màn hình Settings kiểu iOS.
//
//  Kiến thức:
//  1. Form + Section — tổ chức cài đặt như iOS Settings
//  2. NavigationLink trong Form — điều hướng tới màn hình cài đặt con
//  3. @AppStorage — lưu dữ liệu vào UserDefaults (nhớ qua lần mở app)
//  4. ColorScheme — chuyển dark/light mode
//  5. Alert xác nhận khi thực hiện hành động quan trọng
//

import SwiftUI

struct SettingsView: View {

    // @AppStorage: lưu vào UserDefaults — nhớ sau khi tắt app!
    // "notifications_enabled" là key để lưu/đọc giá trị
    @AppStorage("notifications_enabled") private var notificationsEnabled = true
    @AppStorage("sound_enabled") private var soundEnabled = true
    @AppStorage("username") private var username = "Người Dùng"

    @State private var showLogoutAlert = false
    @State private var showResetAlert = false
    @State private var appVersion = "1.0.0"

    var body: some View {
        NavigationStack {
            Form {

                // ── Section 1: Hồ Sơ ──────────────────────────────────
                Section {
                    // NavigationLink → màn hình chỉnh sửa hồ sơ
                    NavigationLink {
                        ProfileEditView(username: $username)
                    } label: {
                        HStack(spacing: 16) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [.indigo, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 60, height: 60)
                                Text(String(username.prefix(1)).uppercased())
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(username)
                                    .font(.headline)
                                Text("Bấm để chỉnh sửa hồ sơ")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Hồ Sơ")
                }

                // ── Section 2: Thông Báo ───────────────────────────────
                Section {
                    // Toggle lưu vào @AppStorage
                    Toggle("Thông báo", isOn: $notificationsEnabled)
                    Toggle("Âm thanh", isOn: $soundEnabled)

                    // NavigationLink → màn hình cài đặt thông báo
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Cài đặt thông báo chi tiết", systemImage: "bell.badge")
                    }

                } header: {
                    Label("Thông Báo", systemImage: "bell")
                }

                // ── Section 3: Giao Diện ───────────────────────────────
                Section {
                    NavigationLink {
                        AppearanceView()
                    } label: {
                        Label("Giao diện & Chủ đề", systemImage: "paintpalette")
                    }

                } header: {
                    Label("Giao Diện", systemImage: "display")
                }

                // ── Section 4: Thông tin App ───────────────────────────
                Section {
                    // Hàng thông tin (không tương tác)
                    HStack {
                        Label("Phiên bản", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }

                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("Giới thiệu về App", systemImage: "questionmark.circle")
                    }

                    // Nút mở URL (ví dụ: App Store, website)
                    Link(destination: URL(string: "https://www.apple.com/swift/")!) {
                        Label("Học SwiftUI tại Apple", systemImage: "safari")
                    }

                } header: {
                    Label("Thông Tin", systemImage: "info.circle")
                }

                // ── Section 5: Hành động nguy hiểm ───────────────────
                Section {
                    // Xoá tất cả dữ liệu
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Xoá tất cả dữ liệu", systemImage: "trash")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }

                    // Đăng xuất
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        Label("Đăng Xuất", systemImage: "rectangle.portrait.and.arrow.right")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }

            } // Form
            .navigationTitle("⚙️ Cài Đặt")

            // Alert xác nhận đăng xuất
            .alert("Đăng Xuất?", isPresented: $showLogoutAlert) {
                Button("Đăng xuất", role: .destructive) {
                    // Thực hiện đăng xuất ở đây
                    username = "Người Dùng"
                }
                Button("Huỷ", role: .cancel) { }
            } message: {
                Text("Bạn có chắc muốn đăng xuất khỏi tài khoản?")
            }

            // Alert xác nhận xoá dữ liệu
            .alert("Xoá Tất Cả Dữ Liệu?", isPresented: $showResetAlert) {
                Button("Xoá", role: .destructive) {
                    resetAllData()
                }
                Button("Huỷ", role: .cancel) { }
            } message: {
                Text("Hành động này không thể hoàn tác. Tất cả dữ liệu của bạn sẽ bị xoá vĩnh viễn.")
            }
        }
    }

    private func resetAllData() {
        notificationsEnabled = true
        soundEnabled = true
        username = "Người Dùng"
    }
}

// ── ProfileEditView ─────────────────────────────────────────────────────────
struct ProfileEditView: View {
    @Binding var username: String
    @State private var tempName: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                TextField("Tên hiển thị", text: $tempName)
                    .textContentType(.name)
            } header: {
                Text("Tên Hiển Thị")
            } footer: {
                Text("Tên này sẽ hiển thị trong hồ sơ của bạn.")
            }
        }
        .navigationTitle("Chỉnh Sửa Hồ Sơ")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            tempName = username
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Lưu") {
                    if !tempName.isEmpty {
                        username = tempName
                    }
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }
}

// ── NotificationSettingsView ────────────────────────────────────────────────
struct NotificationSettingsView: View {
    @State private var alertsEnabled = true
    @State private var badgesEnabled = true
    @State private var soundsEnabled = true

    var body: some View {
        Form {
            Section {
                Toggle("Cảnh báo", isOn: $alertsEnabled)
                Toggle("Huy hiệu (Badge)", isOn: $badgesEnabled)
                Toggle("Âm thanh", isOn: $soundsEnabled)
            } header: {
                Text("Loại Thông Báo")
            }
        }
        .navigationTitle("Thông Báo")
    }
}

// ── AppearanceView ──────────────────────────────────────────────────────────
struct AppearanceView: View {
    @AppStorage("accent_color") private var accentColorIndex = 0
    let accentColors: [(name: String, color: Color)] = [
        ("Indigo", .indigo), ("Xanh dương", .blue), ("Xanh lá", .green),
        ("Cam", .orange), ("Đỏ", .red), ("Hồng", .pink), ("Tím", .purple)
    ]

    var body: some View {
        Form {
            Section {
                ForEach(accentColors.indices, id: \.self) { index in
                    HStack {
                        Circle()
                            .fill(accentColors[index].color)
                            .frame(width: 24, height: 24)
                        Text(accentColors[index].name)
                        Spacer()
                        if accentColorIndex == index {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.indigo)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        accentColorIndex = index
                    }
                }
            } header: {
                Text("Màu Chủ Đạo")
            }
        }
        .navigationTitle("Giao Diện")
    }
}

// ── AboutView ───────────────────────────────────────────────────────────────
struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "swift")
                .font(.system(size: 80))
                .foregroundStyle(.orange)

            VStack(spacing: 8) {
                Text("TestProject")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Ứng dụng học SwiftUI")
                    .foregroundStyle(.secondary)
                Text("Phiên bản 1.0.0")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Được tạo bằng:")
                        .fontWeight(.semibold)
                    Label("Swift 5.9", systemImage: "swift")
                    Label("SwiftUI Framework", systemImage: "square.3.layers.3d")
                    Label("Xcode 15+", systemImage: "hammer")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Giới Thiệu")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}
