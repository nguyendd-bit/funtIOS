//
//  CustomShapeView.swift
//  TestProject
//
//  Demo Custom Shape & Canvas — Vẽ hình tùy chỉnh với Path và Canvas.
//
//  Kiến thức:
//  1. Shape protocol + Path — vẽ hình tùy chỉnh (tam giác, ngôi sao, v.v.)
//  2. Canvas — vẽ 2D tùy ý, hiệu suất cao
//  3. ViewModifier — tạo modifier tái sử dụng
//  4. TimelineView — cập nhật UI theo thời gian thực (animation timer)
//

import SwiftUI

// ── Custom Shapes ────────────────────────────────────────────────────────────

// Shape 1: Tam Giác
// Tuân thủ giao thức Shape → cần cài đặt hàm path(in:)
struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Di chuyển đến điểm đầu (đỉnh tam giác)
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        // Vẽ đường đến góc dưới phải
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Vẽ đường đến góc dưới trái
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Đóng hình (nối về điểm đầu)
        path.closeSubpath()
        return path
    }
}

// Shape 2: Ngôi Sao
struct StarShape: Shape {
    var points: Int = 5       // Số cánh sao
    var innerRatio: Double = 0.4  // Tỉ lệ bán kính trong/ngoài

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRatio

        var path = Path()
        let totalPoints = points * 2  // Mỗi cánh sao có 2 điểm (ngoài + trong)

        for i in 0..<totalPoints {
            let angle = (Double(i) * .pi / Double(points)) - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

// Shape 3: Hình Bong Bóng Chat (Bubble)
struct BubbleShape: Shape {
    var cornerRadius: CGFloat = 16
    var tailSize: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        let adjustedRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: rect.height - tailSize
        )
        var path = Path(roundedRect: adjustedRect, cornerRadius: cornerRadius)

        // Thêm đuôi bong bóng
        let tailStart = CGPoint(x: adjustedRect.minX + 20, y: adjustedRect.maxY)
        let tailTip = CGPoint(x: adjustedRect.minX + 5, y: rect.maxY)
        let tailEnd = CGPoint(x: adjustedRect.minX + 35, y: adjustedRect.maxY)

        path.move(to: tailStart)
        path.addLine(to: tailTip)
        path.addLine(to: tailEnd)
        path.closeSubpath()

        return path
    }
}

// ── ViewModifier: Tạo hiệu ứng tái sử dụng ──────────────────────────────────
// ViewModifier: đóng gói một nhóm modifier thành 1 modifier duy nhất
struct GlowEffect: ViewModifier {
    var color: Color
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.8), radius: radius / 2)
            .shadow(color: color.opacity(0.5), radius: radius)
            .shadow(color: color.opacity(0.3), radius: radius * 1.5)
    }
}

// Extension để dùng modifier dễ dàng hơn
extension View {
    func glowEffect(color: Color = .blue, radius: CGFloat = 10) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// ── CustomShapeView ──────────────────────────────────────────────────────────
struct CustomShapeView: View {

    @State private var starPoints = 5.0
    @State private var innerRatio = 0.4
    @State private var starColor: Color = .yellow
    @State private var showGlow = true
    @State private var animationAngle = 0.0

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // ── Hình Tùy Chỉnh ─────────────────────────────────────
                GroupBox(label: Label("Custom Shapes (Hình Tùy Chỉnh)", systemImage: "pentagon")) {
                    HStack(spacing: 20) {
                        // Tam giác
                        VStack(spacing: 6) {
                            TriangleShape()
                                .fill(Color.red.gradient)
                                .frame(width: 80, height: 70)
                            Text("Tam Giác")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Ngôi sao
                        VStack(spacing: 6) {
                            StarShape(points: 5)
                                .fill(Color.yellow.gradient)
                                .frame(width: 80, height: 80)
                                .glowEffect(color: .yellow, radius: 8)
                            Text("Ngôi Sao")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        // Bong bóng chat
                        VStack(spacing: 6) {
                            BubbleShape()
                                .fill(Color.blue.gradient)
                                .frame(width: 80, height: 70)
                            Text("Chat Bubble")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)

                // ── Ngôi Sao Tùy Chỉnh ─────────────────────────────────
                GroupBox(label: Label("Tuỳ Chỉnh Ngôi Sao Real-time", systemImage: "star")) {
                    VStack(spacing: 16) {
                        // Ngôi sao với tham số thay đổi được
                        StarShape(
                            points: Int(starPoints),
                            innerRatio: innerRatio
                        )
                        .fill(starColor.gradient)
                        .frame(width: 150, height: 150)
                        .glowEffect(color: showGlow ? starColor : .clear, radius: 15)
                        .rotationEffect(.degrees(animationAngle))
                        .animation(.spring(), value: starPoints)
                        .animation(.spring(), value: innerRatio)

                        // Controls
                        HStack {
                            Text("Số cánh: \(Int(starPoints))")
                                .font(.caption)
                            Spacer()
                        }
                        Slider(value: $starPoints, in: 3...12, step: 1)
                            .tint(starColor)

                        HStack {
                            Text("Tỉ lệ: \(innerRatio, specifier: "%.1f")")
                                .font(.caption)
                            Spacer()
                        }
                        Slider(value: $innerRatio, in: 0.1...0.9)
                            .tint(starColor)

                        HStack(spacing: 12) {
                            ColorPicker("Màu sắc", selection: $starColor)
                            Toggle("Glow", isOn: $showGlow)
                            Button("Xoay") {
                                withAnimation(.linear(duration: 1)) {
                                    animationAngle += 360
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── Canvas: Vẽ tùy ý ───────────────────────────────────
                GroupBox(label: Label("Canvas (Vẽ Tùy Ý)", systemImage: "paintbrush")) {
                    VStack(spacing: 8) {
                        Text("Canvas vẽ hình theo lập trình, hiệu suất cao cho đồ họa phức tạp.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        // Canvas: nhận closure (context, size) để vẽ
                        Canvas { context, size in
                            let center = CGPoint(x: size.width / 2, y: size.height / 2)

                            // Vẽ 8 vòng tròn đồng tâm với màu gradient
                            for i in stride(from: 8, through: 1, by: -1) {
                                let radius = CGFloat(i) * 18
                                let hue = Double(i) / 8.0
                                var ellipsePath = Path()
                                ellipsePath.addEllipse(in: CGRect(
                                    x: center.x - radius,
                                    y: center.y - radius,
                                    width: radius * 2,
                                    height: radius * 2
                                ))
                                context.fill(ellipsePath,
                                            with: .color(Color(hue: hue, saturation: 0.8, brightness: 0.9)))
                            }

                            // Vẽ ngôi sao ở giữa
                            let starPath = StarShape(points: 6, innerRatio: 0.4)
                                .path(in: CGRect(x: center.x - 30, y: center.y - 30,
                                                width: 60, height: 60))
                            context.fill(starPath, with: .color(.white))

                            // Vẽ text
                            var text = AttributedString("Canvas!")
                            text.font = .boldSystemFont(ofSize: 14)
                            text.foregroundColor = .white
                            context.draw(Text(text), at: CGPoint(x: center.x, y: size.height - 16))

                            // Vẽ đường thẳng chéo
                            var linePath = Path()
                            linePath.move(to: CGPoint(x: 10, y: 10))
                            linePath.addLine(to: CGPoint(x: size.width - 10, y: size.height - 10))
                            context.stroke(linePath,
                                          with: .color(.white.opacity(0.3)),
                                          lineWidth: 1)
                        }
                        .frame(height: 180)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── ViewModifier Demo ──────────────────────────────────
                GroupBox(label: Label("Custom ViewModifier", systemImage: "wand.and.stars")) {
                    VStack(spacing: 12) {
                        Text("ViewModifier giúp đóng gói và tái sử dụng style:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Dùng .glowEffect() custom modifier
                        HStack(spacing: 16) {
                            Text("Glow Đỏ")
                                .fontWeight(.bold)
                                .foregroundStyle(.red)
                                .glowEffect(color: .red, radius: 8)

                            Text("Glow Xanh")
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                                .glowEffect(color: .blue, radius: 8)

                            Text("Glow Vàng")
                                .fontWeight(.bold)
                                .foregroundStyle(.yellow)
                                .glowEffect(color: .yellow, radius: 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Dùng .cardStyle() custom modifier
                        HStack {
                            Image(systemName: "star.fill").foregroundStyle(.yellow)
                            Text("Card với .cardStyle() modifier")
                                .font(.subheadline)
                            Spacer()
                        }
                        .cardStyle()
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("🎨 Shapes & Canvas")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CustomShapeView()
    }
}
