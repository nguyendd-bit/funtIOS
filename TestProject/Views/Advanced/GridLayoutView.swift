//
//  GridLayoutView.swift
//  TestProject
//
//  Demo Grid Layout — LazyVGrid, LazyHGrid, GridItem.
//
//  Kiến thức:
//  1. LazyVGrid — lưới dọc (hàng cột)
//  2. LazyHGrid — lưới ngang (cuộn ngang)
//  3. GridItem(.flexible()) — cột co giãn đều nhau
//  4. GridItem(.fixed(width)) — cột cố định kích thước
//  5. GridItem(.adaptive(minimum:)) — tự động tính số cột
//  6. Section trong Grid — nhóm items
//  7. Animated layout change — đổi số cột có animation
//

import SwiftUI

struct GridLayoutView: View {

    @State private var columnCount = 3
    @State private var selectedTab = 0
    @State private var selectedItem: String? = nil

    struct ColorItem: Identifiable {
        let name: String
        let color: Color
        let emoji: String
        var id: String { name }
    }

    struct AppIcon: Identifiable {
        let name: String
        let icon: String
        let color: Color
        var id: String { name }
    }

    // Dữ liệu màu sắc cho grid
    let colorItems: [ColorItem] = [
        ColorItem(name: "Đỏ", color: .red, emoji: "🔴"),
        ColorItem(name: "Cam", color: .orange, emoji: "🟠"),
        ColorItem(name: "Vàng", color: .yellow, emoji: "🟡"),
        ColorItem(name: "Xanh lá", color: .green, emoji: "🟢"),
        ColorItem(name: "Xanh dương", color: .blue, emoji: "🔵"),
        ColorItem(name: "Tím", color: .purple, emoji: "🟣"),
        ColorItem(name: "Hồng", color: .pink, emoji: "🩷"),
        ColorItem(name: "Nâu", color: .brown, emoji: "🟤"),
        ColorItem(name: "Đen", color: .black, emoji: "⚫"),
        ColorItem(name: "Xám", color: .gray, emoji: "⬜"),
        ColorItem(name: "Ngọc", color: .teal, emoji: "🩵"),
        ColorItem(name: "Chàm", color: .indigo, emoji: "💜"),
        ColorItem(name: "Vàng kim", color: Color(hue: 0.13, saturation: 0.9, brightness: 0.9), emoji: "🥇"),
        ColorItem(name: "San hô", color: Color(hue: 0.05, saturation: 0.8, brightness: 0.95), emoji: "🪸"),
        ColorItem(name: "Bạc hà", color: Color(hue: 0.46, saturation: 0.6, brightness: 0.9), emoji: "🌿"),
        ColorItem(name: "Tím lavender", color: Color(hue: 0.75, saturation: 0.4, brightness: 0.9), emoji: "💐"),
    ]

    // Dữ liệu app icons cho demo
    let appIcons: [AppIcon] = [
        AppIcon(name: "Safari", icon: "safari.fill", color: .blue),
        AppIcon(name: "Mail", icon: "envelope.fill", color: .blue),
        AppIcon(name: "Tin nhắn", icon: "message.fill", color: .green),
        AppIcon(name: "Ảnh", icon: "photo.fill", color: .orange),
        AppIcon(name: "Camera", icon: "camera.fill", color: .gray),
        AppIcon(name: "Maps", icon: "map.fill", color: .green),
        AppIcon(name: "Cài đặt", icon: "gearshape.fill", color: .gray),
        AppIcon(name: "App Store", icon: "app.badge.fill", color: .blue),
        AppIcon(name: "Nhắc nhở", icon: "checklist", color: .red),
        AppIcon(name: "Ghi chú", icon: "note.text", color: .yellow),
        AppIcon(name: "Lịch", icon: "calendar", color: .red),
        AppIcon(name: "Đồng hồ", icon: "clock.fill", color: .black),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Chọn loại grid
                Picker("", selection: $selectedTab) {
                    Text("🎨 Màu sắc").tag(0)
                    Text("📱 App Icons").tag(1)
                    Text("↔️ Nằm ngang").tag(2)
                    Text("📐 Loại cột").tag(3)
                }
                .pickerStyle(.segmented)
                .padding()

                gridContent
            }
        }
        .navigationTitle("⬛ Grid Layout")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var gridContent: some View {
        switch selectedTab {
        case 0: colorGridSection
        case 1: appIconGridSection
        case 2: horizontalGridSection
        case 3: gridTypesSection
        default: EmptyView()
        }
    }

    // ── 1. Grid màu sắc — đổi số cột ─────────────────────────────────────
    var colorGridSection: some View {
        VStack(spacing: 12) {
            // Controls đổi số cột
            HStack {
                Text("Số cột: \(columnCount)")
                    .fontWeight(.semibold)
                Spacer()
                Stepper("", value: $columnCount, in: 1...6)
            }
            .padding(.horizontal)

            // LazyVGrid: chỉ render item khi hiển thị → tiết kiệm bộ nhớ
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount), spacing: 8) {
                ForEach(colorItems) { item in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(item.color.gradient)
                        VStack(spacing: 4) {
                            Text(item.emoji)
                                .font(columnCount <= 2 ? .largeTitle : .title2)
                            if columnCount <= 3 {
                                Text(item.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(8)
                    }
                    .aspectRatio(1, contentMode: .fit) // Tỉ lệ 1:1 (hình vuông)
                    .shadow(color: item.color.opacity(0.3), radius: 4, y: 2)
                    // Nhấn để chọn
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedItem = item.name
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedItem == item.name ? .white : .clear, lineWidth: 3)
                    )
                }
            }
            // animation: khi columnCount thay đổi, grid tự sắp xếp lại có animation
            .animation(.spring(response: 0.4), value: columnCount)
            .padding(.horizontal)

            if let selected = selectedItem {
                Text("Đã chọn: \(selected)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical)
    }

    // ── 2. App Icons Grid ─────────────────────────────────────────────────
    var appIconGridSection: some View {
        // GridItem(.adaptive(minimum: 70)): tự tính số cột sao cho mỗi cột >= 70pt
        let columns = [GridItem(.adaptive(minimum: 70, maximum: 120))]

        return LazyVGrid(columns: columns, spacing: 20) {
            ForEach(appIcons) { app in
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(app.color.gradient)
                            .frame(width: 70, height: 70)
                        Image(systemName: app.icon)
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: app.color.opacity(0.4), radius: 6, y: 3)

                    Text(app.name)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(width: 80)
            }
        }
        .padding()
    }

    var horizontalGridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("LazyHGrid — cuộn ngang")
                .font(.headline)
                .padding(.horizontal)

            horizontalColorGrid

            Text("ScrollView ngang + 3 hàng (Fixed)")
                .font(.headline)
                .padding(.horizontal)

            horizontalAppGrid
        }
        .padding(.vertical)
    }

    private var horizontalColorGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            // LazyHGrid: lưới ngang, rows = số hàng
            LazyHGrid(rows: [GridItem(.fixed(100)), GridItem(.fixed(100))], spacing: 12) {
                ForEach(colorItems) { item in
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(item.color.gradient)
                            .frame(width: 100, height: 100)
                        VStack(spacing: 4) {
                            Text(item.emoji).font(.title)
                            Text(item.name)
                                .font(.caption2)
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                        }
                    }
                    .shadow(color: item.color.opacity(0.3), radius: 4, y: 2)
                }
            }
            .padding(.horizontal)
        }
    }

    private var horizontalAppGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: Array(repeating: GridItem(.fixed(70)), count: 3), spacing: 8) {
                ForEach(appIcons) { app in
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(app.color.gradient)
                            .frame(width: 70, height: 70)
                        Image(systemName: app.icon)
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // ── 4. Các loại GridItem ──────────────────────────────────────────────
    var gridTypesSection: some View {
        VStack(spacing: 20) {

            gridTypeDemo(
                title: ".flexible() — Co giãn đều nhau",
                subtitle: "Chia đều không gian còn lại",
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                color: .blue
            )

            gridTypeDemo(
                title: ".fixed(80) — Cố định kích thước",
                subtitle: "Mỗi cột luôn đúng 80pt",
                columns: [GridItem(.fixed(80)), GridItem(.fixed(80)), GridItem(.fixed(80))],
                color: .orange
            )

            gridTypeDemo(
                title: ".adaptive(minimum: 80) — Tự động",
                subtitle: "Tự tính số cột (>=80pt mỗi cột)",
                columns: [GridItem(.adaptive(minimum: 80))],
                color: .green
            )

            gridTypeDemo(
                title: "Kết hợp nhiều loại",
                subtitle: "fixed(60) + flexible() + fixed(60)",
                columns: [GridItem(.fixed(60)), GridItem(.flexible()), GridItem(.fixed(60))],
                color: .purple
            )
        }
        .padding()
    }

    func gridTypeDemo(title: String, subtitle: String,
                      columns: [GridItem], color: Color) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(.subheadline).fontWeight(.semibold).foregroundStyle(color)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)

                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(0..<6, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color.opacity(0.15 + Double(i) * 0.1))
                            .overlay(
                                Text("\(i+1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(color)
                            )
                            .frame(height: 50)
                    }
                }
            }
        }
    }
}

#Preview { NavigationStack { GridLayoutView() } }
