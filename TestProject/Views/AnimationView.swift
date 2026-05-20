//
//  AnimationView.swift
//  TestProject
//
//  Màn hình Animation & Gesture — Demo hiệu ứng và cử chỉ chạm.
//
//  Kiến thức:
//  1. withAnimation — thêm hiệu ứng cho thay đổi UI
//  2. .animation(.spring()) — animation mùa xuân (bật nảy)
//  3. .rotationEffect — xoay view
//  4. .scaleEffect — phóng to/thu nhỏ
//  5. .offset — di chuyển view
//  6. Gesture: TapGesture, LongPressGesture, DragGesture
//  7. ProgressView — thanh tiến trình
//

import SwiftUI

struct AnimationView: View {

    // MARK: - Animation States

    // Demo 1: Scale và màu sắc
    @State private var isScaled = false
    @State private var buttonColor: Color = .indigo

    // Demo 2: Xoay
    @State private var rotationAngle: Double = 0

    // Demo 3: Ẩn/hiện
    @State private var isVisible = true

    // Demo 4: Progress
    @State private var progress: Double = 0.3

    // Demo 5: Drag gesture
    @State private var dragOffset = CGSize.zero

    // Demo 6: Long press
    @State private var isLongPressed = false

    // Demo 7: Bounce
    @State private var bounceCount = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // ── Demo 1: Scale và Màu Sắc ─────────────────────────
                    GroupBox(label: Label("Scale & Màu Sắc", systemImage: "arrow.up.and.down.and.arrow.left.and.right")) {
                        VStack(spacing: 12) {
                            // View được áp dụng animation
                            RoundedRectangle(cornerRadius: 16)
                                .fill(buttonColor)
                                .frame(width: isScaled ? 200 : 100, height: isScaled ? 100 : 60)
                                // .animation: tự động animate khi isScaled thay đổi
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isScaled)
                                .animation(.easeInOut, value: buttonColor)
                                .overlay {
                                    Text(isScaled ? "To!" : "Nhỏ!")
                                        .foregroundStyle(.white)
                                        .fontWeight(.bold)
                                }

                            HStack(spacing: 12) {
                                Button("Phóng To/Thu Nhỏ") {
                                    isScaled.toggle()
                                }
                                .buttonStyle(.bordered)

                                Button("Đổi Màu") {
                                    // withAnimation: bao quanh thay đổi bằng animation
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        let colors: [Color] = [.indigo, .red, .orange, .green, .purple, .pink]
                                        buttonColor = colors.randomElement() ?? .indigo
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(.orange)
                            }
                        }
                        .padding(.top, 8)
                    }

                    // ── Demo 2: Rotation (Xoay) ───────────────────────────
                    GroupBox(label: Label("Xoay (Rotation)", systemImage: "arrow.clockwise")) {
                        VStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.yellow)
                                // .rotationEffect: xoay theo góc độ
                                .rotationEffect(.degrees(rotationAngle))
                                .animation(.easeInOut(duration: 0.6), value: rotationAngle)

                            HStack(spacing: 12) {
                                Button("Xoay 90°") {
                                    rotationAngle += 90
                                }
                                .buttonStyle(.bordered)

                                Button("Xoay 360°") {
                                    withAnimation(.linear(duration: 1)) {
                                        rotationAngle += 360
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.yellow)

                                Button("Reset") {
                                    withAnimation {
                                        rotationAngle = 0
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            }
                        }
                        .padding(.top, 8)
                    }

                    // ── Demo 3: Hiện/Ẩn View ─────────────────────────────
                    GroupBox(label: Label("Hiện/Ẩn (Transition)", systemImage: "eye")) {
                        VStack(spacing: 12) {
                            // .transition: hiệu ứng khi view xuất hiện/biến mất
                            if isVisible {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LinearGradient(
                                        colors: [.teal, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(height: 60)
                                    .overlay {
                                        Text("Tôi đang hiển thị! 👋")
                                            .foregroundStyle(.white)
                                            .fontWeight(.semibold)
                                    }
                                    // Hiệu ứng khi xuất hiện/biến mất
                                    .transition(.asymmetric(
                                        insertion: .slide,    // Xuất hiện: trượt vào
                                        removal: .opacity     // Biến mất: mờ dần
                                    ))
                            }

                            Button(isVisible ? "Ẩn đi" : "Hiện ra") {
                                // withAnimation: bọc toggle để có hiệu ứng
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    isVisible.toggle()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.teal)
                        }
                        .padding(.top, 8)
                    }

                    // ── Demo 4: Progress Bar ───────────────────────────────
                    GroupBox(label: Label("Thanh Tiến Trình", systemImage: "chart.bar")) {
                        VStack(spacing: 12) {
                            // ProgressView dạng thanh ngang
                            ProgressView(value: progress)
                                .tint(.indigo)
                                .scaleEffect(x: 1, y: 2) // Dày hơn

                            Text("\(Int(progress * 100))% hoàn thành")
                                .font(.headline)

                            HStack(spacing: 12) {
                                Button("-10%") {
                                    withAnimation {
                                        progress = max(0, progress - 0.1)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)

                                Button("+10%") {
                                    withAnimation {
                                        progress = min(1.0, progress + 0.1)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .tint(.green)

                                // ProgressView dạng vòng tròn loading
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .padding(.leading, 8)
                            }
                        }
                        .padding(.top, 8)
                    }

                    // ── Demo 5: Drag Gesture (Kéo) ────────────────────────
                    GroupBox(label: Label("Kéo Thả (Drag Gesture)", systemImage: "hand.draw")) {
                        VStack(spacing: 12) {
                            Text("Kéo quả bóng dưới đây:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Circle()
                                .fill(LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 70, height: 70)
                                .shadow(radius: 8)
                                // Dịch chuyển theo ngón tay kéo
                                .offset(dragOffset)
                                // DragGesture: nhận diện cử chỉ kéo
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            // Cập nhật vị trí theo ngón tay
                                            dragOffset = value.translation
                                        }
                                        .onEnded { _ in
                                            // Khi nhả tay: quay về vị trí gốc
                                            withAnimation(.spring()) {
                                                dragOffset = .zero
                                            }
                                        }
                                )
                        }
                        .frame(height: 150)
                        .padding(.top, 8)
                    }

                    // ── Demo 6: Long Press & Tap ───────────────────────────
                    GroupBox(label: Label("Long Press & Tap", systemImage: "hand.tap")) {
                        VStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isLongPressed ? Color.green : Color.gray.opacity(0.2))
                                .frame(height: 80)
                                .overlay {
                                    Text(isLongPressed
                                         ? "✅ Đã giữ lâu!"
                                         : "Giữ lâu vào đây...")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(isLongPressed ? .white : .primary)
                                }
                                .animation(.easeInOut(duration: 0.3), value: isLongPressed)
                                // LongPressGesture: nhận diện khi giữ lâu
                                .onLongPressGesture(minimumDuration: 0.8) {
                                    withAnimation {
                                        isLongPressed.toggle()
                                    }
                                }

                            Text("Giữ ngón tay 0.8 giây để kích hoạt")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 8)
                    }

                    // ── Demo 7: Symbol Effect ─────────────────────────────
                    GroupBox(label: Label("Symbol Animation", systemImage: "sparkles")) {
                        VStack(spacing: 12) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.red)
                                // symbolEffect: animation cho SF Symbols (iOS 17+)
                                .symbolEffect(.bounce, value: bounceCount)

                            Button("Bấm để tim đập! ❤️") {
                                bounceCount += 1
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                        .padding(.top, 8)
                    }

                } // VStack
                .padding()
            } // ScrollView
            .navigationTitle("✨ Animation")
        }
    }
}

#Preview {
    AnimationView()
}
