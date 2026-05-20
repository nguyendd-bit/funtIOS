//
//  LocalNotificationsView.swift
//  TestProject
//
//  Demo Local Notifications — Thông báo đẩy cục bộ.
//
//  Kiến thức:
//  1. UNUserNotificationCenter — trung tâm quản lý notification
//  2. requestAuthorization — xin quyền gửi thông báo
//  3. UNNotificationRequest — tạo một thông báo
//  4. UNMutableNotificationContent — nội dung thông báo
//  5. UNTimeIntervalNotificationTrigger — kích hoạt sau X giây
//  6. UNCalendarNotificationTrigger — kích hoạt vào giờ cụ thể
//  7. Xem danh sách thông báo đang chờ
//

import SwiftUI
import UserNotifications

// ── NotificationManager ──────────────────────────────────────────────────────
@Observable
class NotificationManager {

    var permissionStatus: UNAuthorizationStatus = .notDetermined
    var pendingNotifications: [UNNotificationRequest] = []
    var deliveredNotifications: [UNNotification] = []

    init() {
        Task { await checkPermission() }
    }

    // Kiểm tra quyền hiện tại
    func checkPermission() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            permissionStatus = settings.authorizationStatus
        }
    }

    // Xin quyền gửi thông báo
    func requestPermission() async {
        do {
            // options: loại thông báo được phép
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            await MainActor.run {
                permissionStatus = granted ? .authorized : .denied
            }
        } catch {
            print("Lỗi xin quyền: \(error)")
        }
    }

    // Lên lịch thông báo sau X giây
    func scheduleNotification(title: String, body: String, delaySeconds: Double,
                               badge: Int = 1, sound: Bool = true) async {
        // Bước 1: Nội dung thông báo
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.badge = NSNumber(value: badge)
        if sound { content.sound = .default }
        content.userInfo = ["custom_key": "custom_value"]  // Dữ liệu tùy chỉnh

        // Bước 2: Trigger — kích hoạt sau bao nhiêu giây
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: delaySeconds,
            repeats: false  // false = chỉ gửi 1 lần
        )

        // Bước 3: Request — kết hợp content + trigger + id
        let id = UUID().uuidString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        // Bước 4: Thêm vào notification center
        do {
            try await UNUserNotificationCenter.current().add(request)
            await refreshPending()
        } catch {
            print("Lỗi lên lịch thông báo: \(error)")
        }
    }

    // Lên lịch thông báo hàng ngày theo giờ
    func scheduleDaily(title: String, body: String, hour: Int, minute: Int) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        // UNCalendarNotificationTrigger: kích hoạt theo lịch
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true  // true = lặp lại mỗi ngày
        )

        let request = UNNotificationRequest(identifier: "daily_\(hour)_\(minute)",
                                             content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
        await refreshPending()
    }

    // Lấy danh sách thông báo đang chờ
    func refreshPending() async {
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let delivered = await UNUserNotificationCenter.current().deliveredNotifications()
        await MainActor.run {
            pendingNotifications = pending
            deliveredNotifications = delivered
        }
    }

    // Xóa tất cả thông báo
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        pendingNotifications = []
        deliveredNotifications = []
    }

    // Xóa theo ID
    func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        Task { await refreshPending() }
    }

    var permissionText: String {
        switch permissionStatus {
        case .authorized: return "✅ Đã được phép"
        case .denied: return "❌ Bị từ chối"
        case .notDetermined: return "❓ Chưa xác định"
        case .provisional: return "⚠️ Tạm thời"
        default: return "Không rõ"
        }
    }

    var permissionColor: Color {
        switch permissionStatus {
        case .authorized: return .green
        case .denied: return .red
        default: return .orange
        }
    }
}

// ── LocalNotificationsView ───────────────────────────────────────────────────
struct LocalNotificationsView: View {

    @State private var manager = NotificationManager()
    @State private var customTitle = "Nhắc nhở học tập"
    @State private var customBody = "Đã đến giờ học SwiftUI rồi! 📱"
    @State private var delaySeconds = 5.0
    @State private var showCustomForm = false

    var body: some View {
        List {

            // ── Section: Quyền ────────────────────────────────────────
            Section {
                HStack {
                    Label("Trạng thái quyền", systemImage: "bell.badge")
                    Spacer()
                    Text(manager.permissionText)
                        .foregroundStyle(manager.permissionColor)
                        .fontWeight(.semibold)
                }

                if manager.permissionStatus != .authorized {
                    Button {
                        Task { await manager.requestPermission() }
                    } label: {
                        Label("Xin Quyền Gửi Thông Báo", systemImage: "bell.badge.fill")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                    .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            } header: {
                Text("Quyền Thông Báo")
            } footer: {
                Text("App phải được cấp quyền mới có thể gửi thông báo.")
            }

            // ── Section: Gửi nhanh ────────────────────────────────────
            if manager.permissionStatus == .authorized {
                Section {
                    quickNotifButton(
                        title: "⏰ Sau 5 giây",
                        subtitle: "Test thông báo ngay",
                        color: .blue
                    ) {
                        Task {
                            await manager.scheduleNotification(
                                title: "👋 Xin chào!",
                                body: "Đây là thông báo sau 5 giây.",
                                delaySeconds: 5
                            )
                        }
                    }

                    quickNotifButton(
                        title: "📚 Nhắc học (30 giây)",
                        subtitle: "Nhắc nhở học tập",
                        color: .green
                    ) {
                        Task {
                            await manager.scheduleNotification(
                                title: "📱 Đến giờ học SwiftUI!",
                                body: "Bạn đã ngồi học chưa? Hãy mở Xcode lên nào! 💪",
                                delaySeconds: 30
                            )
                        }
                    }

                    quickNotifButton(
                        title: "💧 Nhắc uống nước (1 phút)",
                        subtitle: "Thông báo nhắc uống nước",
                        color: .teal
                    ) {
                        Task {
                            await manager.scheduleNotification(
                                title: "💧 Uống nước đi!",
                                body: "Đã 1 tiếng rồi, uống 1 ly nước nhé 🥤",
                                delaySeconds: 60
                            )
                        }
                    }

                } header: {
                    Text("Gửi Thông Báo Nhanh")
                } footer: {
                    Text("💡 Thoát app để thấy thông báo xuất hiện trên màn hình khoá.")
                }

                // ── Section: Thông báo tùy chỉnh ─────────────────────
                Section {
                    TextField("Tiêu đề", text: $customTitle)
                    TextField("Nội dung", text: $customBody, axis: .vertical)
                        .lineLimit(2...3)

                    HStack {
                        Text("Sau: \(Int(delaySeconds)) giây")
                        Slider(value: $delaySeconds, in: 3...120, step: 1)
                            .tint(.indigo)
                    }

                    Button {
                        Task {
                            await manager.scheduleNotification(
                                title: customTitle,
                                body: customBody,
                                delaySeconds: delaySeconds
                            )
                        }
                    } label: {
                        Label("Lên Lịch Thông Báo", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                    .disabled(customTitle.isEmpty || customBody.isEmpty)

                } header: {
                    Text("Thông Báo Tùy Chỉnh")
                }

                // ── Section: Đang chờ ─────────────────────────────────
                Section {
                    if manager.pendingNotifications.isEmpty {
                        Label("Không có thông báo nào đang chờ", systemImage: "bell.slash")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(manager.pendingNotifications, id: \.identifier) { request in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(request.content.title)
                                        .fontWeight(.medium)
                                    Text(request.content.body)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                    if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                                        Text("Còn: \(Int(trigger.timeInterval)) giây")
                                            .font(.caption2)
                                            .foregroundStyle(.orange)
                                    }
                                }
                                Spacer()
                                Button {
                                    manager.cancel(id: request.identifier)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Đang Chờ (\(manager.pendingNotifications.count))")
                        Spacer()
                        Button("Làm mới") { Task { await manager.refreshPending() } }
                            .font(.caption)
                    }
                }

                // ── Xóa tất cả ────────────────────────────────────────
                Section {
                    Button(role: .destructive) {
                        manager.cancelAll()
                    } label: {
                        Label("Xóa tất cả thông báo", systemImage: "trash")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
        .navigationTitle("🔔 Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { Task { await manager.refreshPending() } }
    }

    func quickNotifButton(title: String, subtitle: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).fontWeight(.medium).foregroundStyle(.primary)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "bell.fill").foregroundStyle(color)
            }
        }
    }
}

#Preview { NavigationStack { LocalNotificationsView() } }
