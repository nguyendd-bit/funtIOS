//
//  StateManagementView.swift
//  TestProject
//
//  Demo State Management — Các cách quản lý trạng thái trong SwiftUI.
//
//  Kiến thức:
//  1. @State — trạng thái cục bộ trong 1 View
//  2. @Binding — chia sẻ trạng thái xuống View con
//  3. @Observable / @Environment — chia sẻ trạng thái toàn app
//  4. @StateObject / @ObservedObject (iOS 16 pattern cũ, vẫn dùng nhiều)
//  5. So sánh khi nào dùng loại nào
//

import SwiftUI
import Observation

// ── Demo @Observable (iOS 17+ recommended) ───────────────────────────────────
// @Observable thay thế ObservableObject — đơn giản hơn, ít boilerplate hơn
@Observable
class CounterModel {
    var count: Int = 0
    var history: [String] = []

    func increment() {
        count += 1
        history.append("+ 1 → \(count)")
        if history.count > 5 { history.removeFirst() }
    }

    func decrement() {
        count -= 1
        history.append("- 1 → \(count)")
        if history.count > 5 { history.removeFirst() }
    }

    func reset() {
        history.append("Reset → 0")
        count = 0
        if history.count > 5 { history.removeFirst() }
    }
}

// ── Demo ObservableObject (iOS 14+ pattern cũ, vẫn phổ biến) ────────────────
// ObservableObject: cách cũ trước @Observable
// @Published: đánh dấu property sẽ phát thông báo khi thay đổi
class TimerModel: ObservableObject {
    @Published var seconds: Int = 0
    @Published var isRunning: Bool = false

    private var timer: Timer?

    func startStop() {
        if isRunning {
            timer?.invalidate()
            timer = nil
            isRunning = false
        } else {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                // @MainActor: đảm bảo cập nhật UI trên main thread
                DispatchQueue.main.async {
                    self.seconds += 1
                }
            }
        }
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        seconds = 0
    }

    // Dừng timer khi model bị giải phóng
    deinit { timer?.invalidate() }
}

// ── StateManagementView ──────────────────────────────────────────────────────
struct StateManagementView: View {

    // @State: trạng thái cục bộ — chỉ dùng trong View này
    @State private var localCount = 0

    // @State với object @Observable
    // counterModel được tạo và quản lý bởi View này
    @State private var counterModel = CounterModel()

    // @StateObject: tạo và quản lý ObservableObject
    // Dùng với class ObservableObject cũ
    @StateObject private var timerModel = TimerModel()

    // Lấy AppState từ Environment (được inject từ App entry point)
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // ── 1. @State Cục Bộ ──────────────────────────────────
                GroupBox(label: Label("@State — Trạng Thái Cục Bộ", systemImage: "1.circle.fill")) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("💡 Chỉ dùng trong 1 View. Đơn giản nhất.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }

                        HStack(spacing: 20) {
                            Button("-") { localCount -= 1 }
                                .font(.title)
                                .buttonStyle(.bordered)

                            Text("\(localCount)")
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .frame(minWidth: 80)
                                .foregroundStyle(.indigo)
                                .contentTransition(.numericText())

                            Button("+") { localCount += 1 }
                                .font(.title)
                                .buttonStyle(.bordered)
                        }

                        Text("@State private var localCount = \(localCount)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── 2. @Binding ────────────────────────────────────────
                GroupBox(label: Label("@Binding — Chia Sẻ Xuống View Con", systemImage: "2.circle.fill")) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("💡 View cha truyền @State xuống View con qua @Binding.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }

                        Text("Giá trị: \(localCount)")
                            .font(.headline)

                        // Truyền $localCount (Binding) vào View con
                        // View con có thể thay đổi biến của View cha!
                        BindingChildView(count: $localCount)

                        Text("View con đang điều khiển biến của View cha ↑")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── 3. @Observable ─────────────────────────────────────
                GroupBox(label: Label("@Observable — Object Có Thể Quan Sát (iOS 17+)", systemImage: "3.circle.fill")) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("💡 Dùng cho logic phức tạp. CounterModel chứa cả data lẫn hành động.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }

                        Text("\(counterModel.count)")
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundStyle(.teal)
                            .contentTransition(.numericText())

                        HStack(spacing: 12) {
                            Button("− 1") { counterModel.decrement() }
                                .buttonStyle(.bordered).tint(.red)
                            Button("Reset") { counterModel.reset() }
                                .buttonStyle(.bordered).tint(.gray)
                            Button("+ 1") { counterModel.increment() }
                                .buttonStyle(.bordered).tint(.green)
                        }

                        // Hiển thị lịch sử
                        if !counterModel.history.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Lịch sử (5 gần nhất):")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                ForEach(Array(counterModel.history.enumerated().reversed()), id: \.offset) { _, entry in
                                    Text("• \(entry)")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundStyle(.teal)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(Color.teal.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── 4. @StateObject (ObservableObject cũ) ─────────────
                GroupBox(label: Label("@StateObject — Timer Đồng Hồ", systemImage: "4.circle.fill")) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("💡 @StateObject dùng với class ObservableObject (iOS 14+).")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }

                        // Hiển thị thời gian dạng đẹp
                        let hours = timerModel.seconds / 3600
                        let minutes = (timerModel.seconds % 3600) / 60
                        let secs = timerModel.seconds % 60

                        Text(String(format: "%02d:%02d:%02d", hours, minutes, secs))
                            .font(.system(size: 46, weight: .bold, design: .monospaced))
                            .foregroundStyle(timerModel.isRunning ? .green : .primary)
                            .contentTransition(.numericText())

                        HStack(spacing: 12) {
                            Button(timerModel.isRunning ? "⏸ Dừng" : "▶ Bắt đầu") {
                                timerModel.startStop()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(timerModel.isRunning ? .orange : .green)

                            Button("↺ Reset") {
                                timerModel.reset()
                            }
                            .buttonStyle(.bordered)
                        }

                        // Indicator đang chạy
                        if timerModel.isRunning {
                            Label("Đang đếm...", systemImage: "circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                                .symbolEffect(.pulse, isActive: timerModel.isRunning)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── 5. @Environment (AppState toàn app) ───────────────
                GroupBox(label: Label("@Environment — Trạng Thái Toàn App", systemImage: "5.circle.fill")) {
                    VStack(spacing: 10) {
                        HStack {
                            Text("💡 AppState được inject 1 lần, dùng ở mọi màn hình qua @Environment.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }

                        // Hiển thị giá trị từ AppState
                        HStack {
                            Label("Người dùng:", systemImage: "person")
                            Spacer()
                            Text(appState.currentUser)
                                .fontWeight(.semibold)
                                .foregroundStyle(.purple)
                        }
                        HStack {
                            Label("Thông báo:", systemImage: "bell")
                            Spacer()
                            Text("\(appState.notificationCount)")
                                .fontWeight(.semibold)
                                .foregroundStyle(.red)
                        }

                        Button {
                            appState.addNotification()  // Thay đổi AppState
                        } label: {
                            Label("Thêm thông báo (+1)", systemImage: "bell.badge")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)

                        Text("→ Mở tab Nâng Cao để thấy badge cập nhật!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── Bảng so sánh ───────────────────────────────────────
                GroupBox(label: Label("📊 Bảng So Sánh", systemImage: "tablecells")) {
                    VStack(alignment: .leading, spacing: 8) {
                        comparisonRow("@State", "Trạng thái đơn giản, cục bộ 1 View", .blue)
                        comparisonRow("@Binding", "Chia sẻ @State từ cha xuống con", .teal)
                        comparisonRow("@Observable", "Object phức tạp, iOS 17+", .green)
                        comparisonRow("@StateObject", "Object ObservableObject, iOS 14+", .orange)
                        comparisonRow("@Environment", "Chia sẻ toàn app, không cần truyền tay", .purple)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("🔄 State Management")
        .navigationBarTitleDisplayMode(.inline)
    }

    func comparisonRow(_ type: String, _ description: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(type)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.bold)
                .foregroundStyle(color)
                .frame(width: 110, alignment: .leading)
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// ── View Con dùng @Binding ────────────────────────────────────────────────────
struct BindingChildView: View {
    // @Binding: nhận binding từ View cha
    // Khi thay đổi count, View cha sẽ thấy ngay
    @Binding var count: Int

    var body: some View {
        HStack(spacing: 12) {
            Button("View con: −10") { count -= 10 }
                .buttonStyle(.bordered).tint(.red)
            Button("View con: +10") { count += 10 }
                .buttonStyle(.bordered).tint(.green)
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        StateManagementView()
    }
    .environment(AppState())
}
