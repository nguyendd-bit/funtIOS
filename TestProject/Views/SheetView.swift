//
//  SheetView.swift
//  TestProject
//
//  Màn hình Sheet — hiện từ dưới trượt lên khi bấm nút trong HomeView.
//
//  Kiến thức:
//  1. @Environment(\.dismiss) — đóng sheet
//  2. Sheet có thể kéo xuống để đóng (swipe to dismiss)
//  3. presentationDetents — kiểm soát chiều cao của sheet
//

import SwiftUI

struct SheetView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // NavigationStack trong Sheet để có tiêu đề và nút đóng
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "rectangle.bottomthird.inset.filled")
                    .font(.system(size: 70))
                    .foregroundStyle(.teal)

                VStack(spacing: 8) {
                    Text("Đây là Sheet!")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Sheet trượt từ dưới lên.\nBạn có thể kéo xuống để đóng,\nhoặc bấm nút \"Đóng\" bên trên.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Mô phỏng nội dung sheet
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Sheet thường dùng để:", systemImage: "lightbulb")
                            .fontWeight(.semibold)
                        Text("• Hiện thông tin bổ sung")
                        Text("• Form nhập liệu nhanh")
                        Text("• Xác nhận hành động")
                        Text("• Menu tuỳ chọn")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }
                .padding(.horizontal)

                Spacer()

                // Nút đóng sheet
                Button {
                    dismiss()  // Đóng sheet, trở về HomeView
                } label: {
                    Label("Đóng Sheet", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.teal)
                .padding(.horizontal)
                .padding(.bottom)
            }

            .navigationTitle("Sheet Demo")
            .navigationBarTitleDisplayMode(.inline)
            // Nút X ở góc trên phải để đóng
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        // presentationDetents: kiểm soát chiều cao của sheet
        // .medium = nửa màn hình, .large = toàn màn hình
        // Bỏ comment dòng dưới để thử:
        // .presentationDetents([.medium, .large])
    }
}

// ── FullScreenDemoView ──────────────────────────────────────────────────────
// Màn hình toàn màn hình (FullScreenCover)

struct FullScreenDemoView: View {
    // Binding: kết nối với biến showFullScreen trong HomeView
    // Khi ta đặt isPresented = false, màn hình sẽ đóng
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Nền gradient
            LinearGradient(
                colors: [.purple, .indigo, .blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    Text("Full Screen Cover!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("Màn hình này che toàn bộ app.\nKể cả tab bar ở dưới cũng bị ẩn!")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("FullScreenCover dùng khi:", systemImage: "lightbulb")
                            .fontWeight(.semibold)
                        Text("• Màn hình đăng nhập/đăng ký")
                        Text("• Onboarding (hướng dẫn ban đầu)")
                        Text("• Xem ảnh/video toàn màn hình")
                        Text("• Game hoặc trải nghiệm nhập vai")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }
                .padding(.horizontal)

                // Nút đóng FullScreenCover
                Button {
                    isPresented = false  // Đặt về false để đóng màn hình
                } label: {
                    Label("Đóng Full Screen", systemImage: "arrow.down.right.and.arrow.up.left")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(.purple)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    SheetView()
}
