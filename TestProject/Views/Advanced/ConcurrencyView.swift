//
//  ConcurrencyView.swift
//  TestProject
//
//  Demo Swift Concurrency nâng cao.
//
//  Kiến thức:
//  1. async let — chạy nhiều task song song
//  2. withTaskGroup — nhóm nhiều task, thu thập kết quả
//  3. Actor — bảo vệ dữ liệu khỏi race condition (thread-safe)
//  4. Task.sleep — tạm dừng bất đồng bộ
//  5. Task.cancel / Task.isCancelled — huỷ task
//  6. @MainActor — đảm bảo code chạy trên Main Thread
//  7. So sánh tuần tự vs song song (hiệu năng)
//

import SwiftUI

// ── Actor: Bảo vệ dữ liệu khỏi race condition ───────────────────────────────
// Actor đảm bảo chỉ 1 task có thể truy cập dữ liệu tại một thời điểm
// Ngăn lỗi "race condition" khi nhiều thread cùng sửa 1 biến
actor SafeCounter {
    private var count: Int = 0
    private var history: [String] = []

    func increment(by amount: Int = 1) {
        count += amount
        history.append("Thêm \(amount) → \(count)")
    }

    func getValue() -> Int { count }
    func getHistory() -> [String] { history }
    func reset() { count = 0; history = [] }
}

// ── ConcurrencyView ──────────────────────────────────────────────────────────
struct ConcurrencyView: View {

    // Demo 1: async let
    @State private var task1Result = "Chờ..."
    @State private var task2Result = "Chờ..."
    @State private var task3Result = "Chờ..."
    @State private var parallelTime = ""
    @State private var sequentialTime = ""
    @State private var isRunningParallel = false
    @State private var isRunningSeq = false

    // Demo 2: TaskGroup
    @State private var taskGroupResults: [String] = []
    @State private var isRunningGroup = false

    // Demo 3: Actor
    private let counter = SafeCounter()
    @State private var counterValue = 0
    @State private var counterHistory: [String] = []
    @State private var isRunningActor = false

    // Demo 4: Cancellation
    @State private var cancelTask: Task<Void, Never>? = nil
    @State private var cancelProgress = 0
    @State private var cancelStatus = "Nhấn Bắt Đầu"
    @State private var isCancellable = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // ── Demo 1: async let ──────────────────────────────────
                GroupBox(label: Label("async let — Song Song vs Tuần Tự", systemImage: "arrow.triangle.branch")) {
                    VStack(spacing: 12) {
                        Text("async let chạy nhiều task cùng lúc, tiết kiệm thời gian.")
                            .font(.caption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Hiển thị kết quả 3 tasks
                        HStack(spacing: 8) {
                            taskResultBox("Task 1\n(2 giây)", result: task1Result, color: .blue)
                            taskResultBox("Task 2\n(1 giây)", result: task2Result, color: .green)
                            taskResultBox("Task 3\n(3 giây)", result: task3Result, color: .orange)
                        }

                        // So sánh thời gian
                        if !parallelTime.isEmpty {
                            HStack {
                                Label("Song song: \(parallelTime)", systemImage: "bolt.fill")
                                    .foregroundStyle(.green)
                                    .font(.caption).fontWeight(.semibold)
                                Spacer()
                                Label("Tuần tự: \(sequentialTime)", systemImage: "clock")
                                    .foregroundStyle(.red)
                                    .font(.caption).fontWeight(.semibold)
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        HStack(spacing: 8) {
                            Button {
                                Task { await runParallel() }
                            } label: {
                                HStack {
                                    if isRunningParallel { ProgressView().scaleEffect(0.7) }
                                    Text("Song Song")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent).tint(.green)
                            .disabled(isRunningParallel || isRunningSeq)

                            Button {
                                Task { await runSequential() }
                            } label: {
                                HStack {
                                    if isRunningSeq { ProgressView().scaleEffect(0.7) }
                                    Text("Tuần Tự")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent).tint(.red)
                            .disabled(isRunningParallel || isRunningSeq)
                        }

                        codeBlock("""
// async let: bắt đầu cả 3 ngay lập tức
async let r1 = fetchData(id: 1, delay: 2)
async let r2 = fetchData(id: 2, delay: 1)
async let r3 = fetchData(id: 3, delay: 3)
// Chờ tất cả hoàn thành (≈3 giây, không phải 6)
let (v1, v2, v3) = await (r1, r2, r3)
""")
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── Demo 2: TaskGroup ──────────────────────────────────
                GroupBox(label: Label("withTaskGroup — Nhóm Task", systemImage: "square.grid.2x2")) {
                    VStack(spacing: 12) {
                        Text("TaskGroup tạo nhóm task động, thu thập kết quả từng cái khi xong.")
                            .font(.caption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if !taskGroupResults.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(taskGroupResults, id: \.self) { result in
                                    Label(result, systemImage: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(Color.green.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        Button {
                            Task { await runTaskGroup() }
                        } label: {
                            HStack {
                                if isRunningGroup { ProgressView().scaleEffect(0.7) }
                                Text("Chạy 5 Task Cùng Lúc")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent).tint(.indigo)
                        .disabled(isRunningGroup)

                        codeBlock("""
await withTaskGroup(of: String.self) { group in
    for i in 1...5 {
        group.addTask {
            try? await Task.sleep(...)
            return "Task \\(i) xong!"
        }
    }
    for await result in group {
        results.append(result)  // Thu thập từng kết quả
    }
}
""")
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── Demo 3: Actor ──────────────────────────────────────
                GroupBox(label: Label("Actor — Thread-Safe Counter", systemImage: "lock.shield")) {
                    VStack(spacing: 12) {
                        Text("Actor ngăn race condition khi 100 task cùng tăng 1 biến.")
                            .font(.caption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("\(counterValue)")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundStyle(.purple)
                            .contentTransition(.numericText())

                        Text("(100 task × +1 = kỳ vọng: 100)")
                            .font(.caption2).foregroundStyle(.secondary)

                        if !counterHistory.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(counterHistory.suffix(5), id: \.self) { h in
                                        Text("• \(h)").font(.caption2).foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .frame(height: 70)
                            .padding(6)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        HStack(spacing: 8) {
                            Button {
                                Task { await runActorDemo() }
                            } label: {
                                HStack {
                                    if isRunningActor { ProgressView().scaleEffect(0.7) }
                                    Text("Chạy 100 Task")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent).tint(.purple)
                            .disabled(isRunningActor)

                            Button("Reset") {
                                Task {
                                    await counter.reset()
                                    counterValue = 0
                                    counterHistory = []
                                }
                            }
                            .buttonStyle(.bordered)
                        }

                        codeBlock("""
actor SafeCounter {
    private var count = 0
    func increment() { count += 1 }
    func getValue() -> Int { count }
}
// Nhiều task cùng increment → luôn đúng!
await counter.increment()
""")
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── Demo 4: Task Cancellation ──────────────────────────
                GroupBox(label: Label("Task Cancellation — Huỷ Task", systemImage: "xmark.circle")) {
                    VStack(spacing: 12) {
                        Text("Task có thể bị huỷ. Code nên kiểm tra Task.isCancelled để dừng.")
                            .font(.caption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ProgressView(value: Double(cancelProgress), total: 10)
                            .tint(isCancellable ? .blue : .red)
                            .scaleEffect(x: 1, y: 2)

                        Text(cancelStatus)
                            .font(.headline)
                            .foregroundStyle(isCancellable ? .blue : .secondary)

                        HStack(spacing: 8) {
                            Button("Bắt đầu") {
                                startCancellableTask()
                            }
                            .buttonStyle(.borderedProminent).tint(.blue)
                            .disabled(isCancellable)

                            Button("Huỷ") {
                                cancelTask?.cancel()
                                cancelStatus = "❌ Đã huỷ!"
                                isCancellable = false
                            }
                            .buttonStyle(.bordered).tint(.red)
                            .disabled(!isCancellable)
                        }

                        codeBlock("""
let task = Task {
    for i in 1...10 {
        // Kiểm tra đã bị huỷ chưa
        try Task.checkCancellation()
        await Task.sleep(...)
    }
}
task.cancel()  // Huỷ từ bên ngoài
""")
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("⚡ Concurrency")
        .navigationBarTitleDisplayMode(.inline)
    }

    // ── Async Functions ────────────────────────────────────────────────────

    // Giả lập fetch data với delay
    func fetchData(id: Int, delay: Double) async -> String {
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        return "✅ Task \(id) xong (\(Int(delay))s)"
    }

    // Song song: dùng async let
    func runParallel() async {
        isRunningParallel = true
        task1Result = "⏳"; task2Result = "⏳"; task3Result = "⏳"
        let start = Date()

        // async let: tất cả 3 task bắt đầu NGAY LẬP TỨC
        async let r1 = fetchData(id: 1, delay: 2)
        async let r2 = fetchData(id: 2, delay: 1)
        async let r3 = fetchData(id: 3, delay: 3)
        // Chờ tất cả (khoảng 3 giây, không phải 2+1+3=6 giây)
        let (v1, v2, v3) = await (r1, r2, r3)

        let elapsed = Date().timeIntervalSince(start)
        await MainActor.run {
            task1Result = v1; task2Result = v2; task3Result = v3
            parallelTime = String(format: "%.1fs", elapsed)
            isRunningParallel = false
        }
    }

    // Tuần tự: await từng cái một
    func runSequential() async {
        isRunningSeq = true
        task1Result = "⏳"; task2Result = "⏳"; task3Result = "⏳"
        let start = Date()

        // Chờ từng cái — tổng = 2+1+3 = 6 giây
        let v1 = await fetchData(id: 1, delay: 2)
        await MainActor.run { task1Result = v1 }
        let v2 = await fetchData(id: 2, delay: 1)
        await MainActor.run { task2Result = v2 }
        let v3 = await fetchData(id: 3, delay: 3)
        await MainActor.run { task3Result = v3 }

        let elapsed = Date().timeIntervalSince(start)
        await MainActor.run {
            sequentialTime = String(format: "%.1fs", elapsed)
            isRunningSeq = false
        }
    }

    // TaskGroup: nhiều task động
    func runTaskGroup() async {
        isRunningGroup = true
        await MainActor.run { taskGroupResults = [] }

        var results: [String] = []
        // withTaskGroup: tạo nhóm task trả về String
        await withTaskGroup(of: String.self) { group in
            for i in 1...5 {
                group.addTask {
                    let delay = Double.random(in: 0.5...2.0)
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    return "Task \(i) hoàn thành (\(String(format: "%.1f", delay))s)"
                }
            }
            // Thu thập kết quả khi từng task xong
            for await result in group {
                results.append(result)
                await MainActor.run { taskGroupResults = results }
            }
        }
        await MainActor.run { isRunningGroup = false }
    }

    // Actor demo: 100 task tăng counter
    func runActorDemo() async {
        isRunningActor = true
        await counter.reset()
        await MainActor.run { counterValue = 0; counterHistory = [] }

        // 100 task cùng increment — actor đảm bảo thread-safe
        await withTaskGroup(of: Void.self) { group in
            for _ in 1...100 {
                group.addTask {
                    await self.counter.increment()
                }
            }
        }

        let value = await counter.getValue()
        let history = await counter.getHistory()
        await MainActor.run {
            counterValue = value
            counterHistory = history
            isRunningActor = false
        }
    }

    // Cancellable task
    func startCancellableTask() {
        cancelProgress = 0
        isCancellable = true
        cancelStatus = "⏳ Đang chạy..."

        cancelTask = Task {
            do {
                for i in 1...10 {
                    // checkCancellation: ném lỗi nếu bị huỷ
                    try Task.checkCancellation()
                    try await Task.sleep(nanoseconds: 500_000_000)
                    await MainActor.run {
                        cancelProgress = i
                        cancelStatus = "⏳ Bước \(i)/10..."
                    }
                }
                await MainActor.run {
                    cancelStatus = "✅ Hoàn thành!"
                    isCancellable = false
                }
            } catch {
                // Task bị huỷ
                await MainActor.run {
                    cancelStatus = "❌ Đã huỷ ở bước \(cancelProgress)"
                    isCancellable = false
                }
            }
        }
    }

    // Component hiển thị code
    func codeBlock(_ code: String) -> some View {
        Text(code)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(.secondary)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    func taskResultBox(_ label: String, result: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text(result)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(result.contains("✅") ? color : .secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview { NavigationStack { ConcurrencyView() } }
