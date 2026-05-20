//
//  HomeView.swift
//  TestProject
//
//  Màn hình Trang Chủ — Demo các loại Button và điều hướng màn hình.
//
//  Các kiến thức trong file này:
//  1. NavigationStack — tạo ngăn xếp điều hướng (có nút Back)
//  2. NavigationLink — nút bấm chuyển sang màn hình mới (push)
//  3. .sheet() — mở màn hình modal từ dưới trượt lên
//  4. .fullScreenCover() — mở màn hình toàn màn hình
//  5. Alert — hộp thoại thông báo/xác nhận
//  6. @State — biến trạng thái, khi thay đổi UI tự cập nhật
//

import SwiftUI

struct HomeView: View {

    // MARK: - @State Variables (Biến trạng thái)
    // @State: khi biến này thay đổi, SwiftUI tự vẽ lại UI

    @State private var tapCount = 0           // Đếm số lần bấm nút
    @State private var showAlert = false       // Hiện/ẩn Alert
    @State private var showSheet = false       // Hiện/ẩn Sheet
    @State private var showFullScreen = false  // Hiện/ẩn FullScreenCover
    @State private var alertMessage = ""       // Nội dung thông báo

    var body: some View {
        // NavigationStack: tạo thanh điều hướng trên cùng và hỗ trợ push/pop
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // ── Phần 1: Đếm số lần bấm ──────────────────────────
                    GroupBox(label: Label("Nút Cơ Bản", systemImage: "hand.tap")) {
                        VStack(spacing: 12) {
                            Text("Bạn đã bấm: \(tapCount) lần")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.indigo)

                            // Button thông thường
                            Button {
                                // Hành động khi bấm nút
                                tapCount += 1
                            } label: {
                                Label("Bấm vào đây!", systemImage: "hand.point.up.left.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.indigo)

                            // Button reset
                            Button(role: .destructive) {
                                tapCount = 0
                            } label: {
                                Label("Reset về 0", systemImage: "arrow.counterclockwise")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.top, 8)
                    }

                    // ── Phần 2: Điều Hướng Push (NavigationLink) ─────────
                    GroupBox(label: Label("Chuyển Màn Hình (Push)", systemImage: "arrow.right.circle")) {
                        VStack(spacing: 12) {
                            Text("Bấm nút dưới đây để mở màn hình mới.\nBạn có thể bấm nút \"< Back\" để quay lại.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            // NavigationLink: chuyển sang màn hình DetailView
                            // Khi bấm, màn hình mới trượt vào từ bên phải
                            NavigationLink {
                                DetailView(title: "Chi Tiết Sản Phẩm", message: "Bạn đã điều hướng thành công! Bấm nút Back ở trên bên trái để quay lại.")
                            } label: {
                                Label("Mở màn hình Chi Tiết", systemImage: "arrow.forward")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)

                            // NavigationLink với dữ liệu khác nhau
                            NavigationLink {
                                DetailView(title: "Giới Thiệu", message: "Đây là màn hình Giới Thiệu. Mỗi NavigationLink có thể truyền dữ liệu khác nhau!")
                            } label: {
                                Label("Mở màn hình Giới Thiệu", systemImage: "info.circle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        }
                        .padding(.top, 8)
                    }

                    // ── Phần 3: Sheet (Modal từ dưới lên) ────────────────
                    GroupBox(label: Label("Sheet (Trượt từ dưới lên)", systemImage: "rectangle.bottomthird.inset.filled")) {
                        VStack(spacing: 12) {
                            Text("Sheet là màn hình phụ trượt từ dưới lên, không thay thế hoàn toàn màn hình hiện tại.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            Button {
                                showSheet = true  // Bật biến này để hiện Sheet
                            } label: {
                                Label("Mở Sheet", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.teal)
                        }
                        .padding(.top, 8)
                    }
                    // .sheet(): hiện khi showSheet = true
                    .sheet(isPresented: $showSheet) {
                        SheetView()
                    }

                    // ── Phần 4: FullScreenCover ───────────────────────────
                    GroupBox(label: Label("Full Screen Cover", systemImage: "rectangle.inset.filled")) {
                        VStack(spacing: 12) {
                            Text("FullScreenCover mở màn hình mới che toàn bộ màn hình, kể cả thanh tab ở dưới.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            Button {
                                showFullScreen = true
                            } label: {
                                Label("Mở Full Screen", systemImage: "arrow.up.left.and.arrow.down.right")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.purple)
                        }
                        .padding(.top, 8)
                    }
                    // .fullScreenCover(): hiện khi showFullScreen = true
                    .fullScreenCover(isPresented: $showFullScreen) {
                        FullScreenDemoView(isPresented: $showFullScreen)
                    }

                    // ── Phần 5: Alert (Hộp thoại) ────────────────────────
                    GroupBox(label: Label("Alert (Hộp Thoại)", systemImage: "bell")) {
                        VStack(spacing: 12) {
                            Text("Alert hiện hộp thoại thông báo hoặc yêu cầu xác nhận từ người dùng.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            // Alert thông báo đơn giản
                            Button {
                                alertMessage = "Xin chào! Đây là Alert thông báo."
                                showAlert = true
                            } label: {
                                Label("Alert thông báo", systemImage: "info.circle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.orange)

                            // Alert xác nhận (có 2 nút)
                            Button(role: .destructive) {
                                alertMessage = "Bạn có chắc muốn xoá không?"
                                showAlert = true
                            } label: {
                                Label("Alert xác nhận xoá", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                        .padding(.top, 8)
                    }
                    // .alert(): hiện khi showAlert = true
                    .alert("Thông Báo", isPresented: $showAlert) {
                        Button("OK") { } // Bấm OK đóng alert
                        Button("Huỷ", role: .cancel) { }
                    } message: {
                        Text(alertMessage)
                    }

                } // VStack
                .padding()
            } // ScrollView

            // Tiêu đề của NavigationStack
            .navigationTitle("🏠 Trang Chủ")
            .navigationBarTitleDisplayMode(.large)
        } // NavigationStack
    }
}

#Preview {
    HomeView()
}
