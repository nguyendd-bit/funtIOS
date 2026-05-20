//
//  DetailView.swift
//  TestProject
//
//  Màn hình Chi Tiết — được mở từ HomeView qua NavigationLink.
//
//  Kiến thức trong file này:
//  1. Nhận dữ liệu từ màn hình trước qua thuộc tính (property)
//  2. @Environment(\.dismiss) — đóng màn hình hiện tại theo cách lập trình
//  3. navigationTitle — tiêu đề trên thanh điều hướng
//  4. toolbar — thêm nút vào thanh điều hướng
//

import SwiftUI

struct DetailView: View {

    // Nhận dữ liệu được truyền từ màn hình trước
    let title: String
    let message: String

    // @Environment(\.dismiss): dùng để đóng màn hình hiện tại
    // Khi màn hình được push (NavigationLink), dismiss sẽ pop về màn hình trước
    @Environment(\.dismiss) private var dismiss

    @State private var likeCount = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // Icon lớn ở giữa
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.indigo)
                    .padding(.top, 20)

                // Tiêu đề và nội dung
                VStack(spacing: 12) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Divider()

                // Demo: nút Like
                VStack(spacing: 8) {
                    Text("Demo tương tác:")
                        .font(.headline)
                    Text("❤️ \(likeCount) lượt thích")
                        .font(.title3)
                    Button {
                        likeCount += 1
                    } label: {
                        Label("Thích", systemImage: "heart.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }

                Divider()

                // Nút đóng màn hình theo cách lập trình (không dùng Back)
                VStack(spacing: 12) {
                    Text("Bạn có thể đóng màn hình bằng:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Cách 1: Dùng nút Back trên thanh điều hướng (tự động có)
                    Text("① Nút \"< Back\" ở góc trên trái")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // Cách 2: Gọi dismiss() trong code
                    Button {
                        dismiss() // Đóng màn hình, quay về màn hình trước
                    } label: {
                        Label("② Bấm nút này để quay lại", systemImage: "arrow.backward")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }

            } // VStack
            .padding()
        } // ScrollView

        // Đặt tiêu đề cho màn hình này
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)

        // Thêm nút vào thanh điều hướng phía trên bên phải
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    likeCount += 1
                } label: {
                    Image(systemName: "heart")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(
            title: "Chi Tiết Sản Phẩm",
            message: "Đây là màn hình chi tiết demo."
        )
    }
}
