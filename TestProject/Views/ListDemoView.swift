//
//  ListDemoView.swift
//  TestProject
//
//  Màn hình Danh Sách — Demo List, ForEach, thêm/xóa item, NavigationLink.
//
//  Kiến thức:
//  1. List + ForEach — hiện danh sách cuộn được
//  2. .onDelete — vuốt trái để xóa item
//  3. NavigationLink trong List — bấm vào item để xem chi tiết
//  4. @State với mảng — quản lý danh sách items
//  5. Identifiable protocol — giúp SwiftUI nhận ra từng item
//

import SwiftUI

// ── Model: Cấu trúc dữ liệu một Item ───────────────────────────────────────
// Identifiable: mỗi item có id duy nhất để SwiftUI quản lý
struct TodoItem: Identifiable {
    let id = UUID()       // UUID tạo id ngẫu nhiên, duy nhất
    var title: String
    var isCompleted: Bool
    var emoji: String
}

// ── ListDemoView ────────────────────────────────────────────────────────────
struct ListDemoView: View {

    // @State với mảng: khi mảng thay đổi, List tự cập nhật
    @State private var items: [TodoItem] = [
        TodoItem(title: "Học SwiftUI", isCompleted: true, emoji: "📱"),
        TodoItem(title: "Tạo màn hình đầu tiên", isCompleted: true, emoji: "🖥️"),
        TodoItem(title: "Tìm hiểu NavigationStack", isCompleted: false, emoji: "🗺️"),
        TodoItem(title: "Dùng List và ForEach", isCompleted: false, emoji: "📋"),
        TodoItem(title: "Học @State và @Binding", isCompleted: false, emoji: "🔗"),
        TodoItem(title: "Tạo animation đầu tiên", isCompleted: false, emoji: "✨"),
        TodoItem(title: "Submit app lên App Store", isCompleted: false, emoji: "🚀"),
    ]

    @State private var showAddAlert = false
    @State private var newItemTitle = ""

    var body: some View {
        NavigationStack {
            List {
                // Section: Tổng quan
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tiến độ học tập")
                                .font(.headline)
                            Text("\(completedCount)/\(items.count) hoàn thành")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        // Biểu tượng tiến độ
                        ZStack {
                            Circle()
                                .stroke(Color.indigo.opacity(0.2), lineWidth: 8)
                                .frame(width: 60, height: 60)
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(Color.indigo, lineWidth: 8)
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut, value: progress)
                            Text("\(Int(progress * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Tổng Quan")
                }

                // Section: Danh sách items
                Section {
                    // ForEach lặp qua mảng items để tạo từng hàng
                    ForEach($items) { $item in
                        // NavigationLink: bấm vào hàng để xem chi tiết
                        NavigationLink {
                            ListDetailView(item: item)
                        } label: {
                            // Giao diện của mỗi hàng trong List
                            HStack(spacing: 12) {
                                Text(item.emoji)
                                    .font(.title2)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.body)
                                        // Gạch ngang nếu đã hoàn thành
                                        .strikethrough(item.isCompleted, color: .secondary)
                                        .foregroundStyle(item.isCompleted ? .secondary : .primary)
                                }

                                Spacer()

                                // Nút tick hoàn thành (không dùng NavigationLink)
                                Button {
                                    item.isCompleted.toggle()  // Đổi true ↔ false
                                } label: {
                                    Image(systemName: item.isCompleted
                                          ? "checkmark.circle.fill"
                                          : "circle")
                                    .foregroundStyle(item.isCompleted ? .green : .secondary)
                                    .font(.title3)
                                }
                                .buttonStyle(.plain)  // Không dùng style mặc định để tránh NavigationLink bị kích hoạt
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    // .onDelete: vuốt trái để xóa
                    .onDelete(perform: deleteItems)

                    // .onMove: kéo để di chuyển thứ tự (cần EditButton)
                    .onMove(perform: moveItems)

                } header: {
                    Text("Danh Sách Công Việc")
                } footer: {
                    Text("💡 Vuốt trái để xóa · Kéo ≡ để di chuyển thứ tự")
                }
            }
            .navigationTitle("📋 Danh Sách")
            .toolbar {
                // Nút Edit ở bên trái — bật chế độ chỉnh sửa
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()  // SwiftUI tự tạo nút Edit/Done
                }

                // Nút + ở bên phải — thêm item mới
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // Alert để nhập tên item mới
            .alert("Thêm Công Việc Mới", isPresented: $showAddAlert) {
                TextField("Tên công việc...", text: $newItemTitle)
                Button("Thêm") {
                    addNewItem()
                }
                Button("Huỷ", role: .cancel) {
                    newItemTitle = ""
                }
            }
        }
    }

    // ── Computed Properties ─────────────────────────────────────────────────
    // Tính số item đã hoàn thành
    private var completedCount: Int {
        items.filter { $0.isCompleted }.count
    }

    // Tính phần trăm tiến độ (0.0 → 1.0)
    private var progress: Double {
        guard !items.isEmpty else { return 0 }
        return Double(completedCount) / Double(items.count)
    }

    // ── Functions ───────────────────────────────────────────────────────────
    // Xóa item khi vuốt trái
    // IndexSet: tập hợp các chỉ số (index) của items cần xóa
    private func deleteItems(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    // Di chuyển item khi kéo
    private func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }

    // Thêm item mới
    private func addNewItem() {
        guard !newItemTitle.isEmpty else { return }
        let emojis = ["⭐", "🎯", "💡", "🔥", "🎨", "🛠️", "📌"]
        let newItem = TodoItem(
            title: newItemTitle,
            isCompleted: false,
            emoji: emojis.randomElement() ?? "📌"
        )
        // withAnimation: thêm item với hiệu ứng mượt
        withAnimation {
            items.append(newItem)
        }
        newItemTitle = ""
    }
}

#Preview {
    ListDemoView()
}
