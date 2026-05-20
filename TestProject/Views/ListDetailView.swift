//
//  ListDetailView.swift
//  TestProject
//
//  Màn hình chi tiết của một item trong Danh Sách.
//
//  Kiến thức:
//  1. Nhận struct (TodoItem) từ màn hình trước
//  2. @Environment(\.dismiss) — đóng màn hình
//

import SwiftUI

struct ListDetailView: View {
    // Nhận item được chọn từ ListDemoView
    let item: TodoItem

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // Emoji lớn ở giữa
            Text(item.emoji)
                .font(.system(size: 100))

            VStack(spacing: 8) {
                Text(item.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                // Trạng thái hoàn thành
                Label(
                    item.isCompleted ? "Đã hoàn thành ✓" : "Chưa hoàn thành",
                    systemImage: item.isCompleted ? "checkmark.circle.fill" : "circle"
                )
                .foregroundStyle(item.isCompleted ? .green : .orange)
                .font(.headline)
            }

            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Thông tin", systemImage: "info.circle")
                        .fontWeight(.semibold)
                    Divider()
                    HStack {
                        Text("ID:")
                            .foregroundStyle(.secondary)
                        Text(item.id.uuidString.prefix(8) + "...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Trạng thái:")
                            .foregroundStyle(.secondary)
                        Text(item.isCompleted ? "Hoàn thành" : "Đang làm")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Chi Tiết")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ListDetailView(item: TodoItem(
            title: "Học SwiftUI",
            isCompleted: true,
            emoji: "📱"
        ))
    }
}
