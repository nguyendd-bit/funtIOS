//
//  ChartsView.swift
//  TestProject
//
//  Demo Swift Charts — Vẽ biểu đồ đẹp với framework Swift Charts (iOS 16+).
//
//  Kiến thức:
//  1. Chart { } — container chứa biểu đồ
//  2. BarMark — biểu đồ thanh (cột)
//  3. LineMark + AreaMark — biểu đồ đường
//  4. PointMark — biểu đồ điểm (scatter)
//  5. .chartXAxis / .chartYAxis — tuỳ chỉnh trục
//  6. .foregroundStyle(by:) — tô màu theo nhóm
//

import SwiftUI
import Charts

// ── Dữ liệu mẫu ─────────────────────────────────────────────────────────────
struct SalesData: Identifiable {
    let id = UUID()
    let month: String
    let sales: Double
    let category: String
}

struct WeeklyStep: Identifiable {
    let id = UUID()
    let day: String
    let steps: Int
}

struct AppUsage: Identifiable {
    let id = UUID()
    let app: String
    let hours: Double
    let color: Color
}

// ── ChartsView ───────────────────────────────────────────────────────────────
struct ChartsView: View {

    // Dữ liệu doanh thu theo tháng (2 dòng: App A & App B)
    let salesData: [SalesData] = [
        SalesData(month: "T1", sales: 12, category: "App A"),
        SalesData(month: "T2", sales: 18, category: "App A"),
        SalesData(month: "T3", sales: 15, category: "App A"),
        SalesData(month: "T4", sales: 25, category: "App A"),
        SalesData(month: "T5", sales: 30, category: "App A"),
        SalesData(month: "T6", sales: 28, category: "App A"),
        SalesData(month: "T1", sales: 8, category: "App B"),
        SalesData(month: "T2", sales: 14, category: "App B"),
        SalesData(month: "T3", sales: 20, category: "App B"),
        SalesData(month: "T4", sales: 16, category: "App B"),
        SalesData(month: "T5", sales: 22, category: "App B"),
        SalesData(month: "T6", sales: 35, category: "App B"),
    ]

    // Dữ liệu bước chân mỗi ngày trong tuần
    let weeklySteps: [WeeklyStep] = [
        WeeklyStep(day: "T2", steps: 8420),
        WeeklyStep(day: "T3", steps: 6200),
        WeeklyStep(day: "T4", steps: 11500),
        WeeklyStep(day: "T5", steps: 9800),
        WeeklyStep(day: "T6", steps: 7300),
        WeeklyStep(day: "T7", steps: 13200),
        WeeklyStep(day: "CN", steps: 5100),
    ]

    // Dữ liệu sử dụng app (dạng tròn)
    let appUsage: [AppUsage] = [
        AppUsage(app: "Mạng XH", hours: 3.5, color: .blue),
        AppUsage(app: "Trò chơi", hours: 2.0, color: .green),
        AppUsage(app: "Học tập", hours: 1.5, color: .orange),
        AppUsage(app: "Đọc sách", hours: 1.0, color: .purple),
        AppUsage(app: "Khác", hours: 0.8, color: .gray),
    ]

    @State private var selectedTab = 0
    @State private var animateChart = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Chọn loại biểu đồ
                Picker("Loại biểu đồ", selection: $selectedTab) {
                    Text("📊 Cột").tag(0)
                    Text("📈 Đường").tag(1)
                    Text("🔵 Tròn").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch selectedTab {
                case 0: barChartSection
                case 1: lineChartSection
                case 2: pieChartSection
                default: EmptyView()
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("📊 Swift Charts")
        .navigationBarTitleDisplayMode(.inline)
    }

    // ── Biểu đồ Cột (Bar Chart) ───────────────────────────────────────────
    var barChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            GroupBox(label: Label("Doanh Thu Theo Tháng", systemImage: "chart.bar.fill")) {
                // Chart: container biểu đồ
                Chart {
                    // ForEach trong Chart để tạo từng thanh
                    ForEach(salesData) { data in
                        // BarMark: một thanh trong biểu đồ cột
                        BarMark(
                            x: .value("Tháng", data.month),    // Trục X = tháng
                            y: .value("Doanh thu", data.sales)  // Trục Y = doanh thu
                        )
                        // .foregroundStyle(by:): tô màu theo category
                        .foregroundStyle(by: .value("Loại", data.category))
                        .cornerRadius(4)
                    }
                }
                .frame(height: 220)
                // Tuỳ chỉnh chú thích biểu đồ
                .chartLegend(position: .bottom, alignment: .center)
                // Màu sắc custom
                .chartForegroundStyleScale([
                    "App A": Color.indigo,
                    "App B": Color.teal
                ])
                .padding(.top, 8)

                Text("Biểu đồ nhóm (Grouped Bar Chart) — So sánh 2 loại cùng lúc")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .padding(.horizontal)

            // Biểu đồ cột nằm ngang (Horizontal Bar)
            GroupBox(label: Label("Bước Chân Trong Tuần", systemImage: "figure.walk")) {
                Chart {
                    ForEach(weeklySteps) { step in
                        BarMark(
                            x: .value("Bước chân", step.steps),  // Nằm ngang: X = giá trị
                            y: .value("Ngày", step.day)            // Y = nhãn
                        )
                        // Annotation: thêm nhãn trên thanh
                        .annotation(position: .trailing) {
                            Text("\(step.steps / 1000)K")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        // Tô màu dựa vào điều kiện
                        .foregroundStyle(step.steps >= 10000 ? Color.green : Color.blue)
                        .cornerRadius(4)
                    }

                    // RuleMark: đường ngang mục tiêu
                    RuleMark(x: .value("Mục tiêu", 10000))
                        .foregroundStyle(.red.opacity(0.7))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Mục tiêu 10K")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                }
                .frame(height: 200)
                .padding(.top, 8)

                Text("Xanh lá = đạt mục tiêu 10,000 bước · Đường đỏ = mục tiêu")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .padding(.horizontal)
        }
    }

    // ── Biểu đồ Đường (Line Chart) ────────────────────────────────────────
    var lineChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            GroupBox(label: Label("Xu Hướng Doanh Thu", systemImage: "chart.line.uptrend.xyaxis")) {
                Chart {
                    ForEach(salesData) { data in
                        // LineMark: điểm trên đường
                        LineMark(
                            x: .value("Tháng", data.month),
                            y: .value("Doanh thu", data.sales)
                        )
                        .foregroundStyle(by: .value("Loại", data.category))
                        // PointMark: chấm tròn tại mỗi điểm dữ liệu
                        .symbol(by: .value("Loại", data.category))

                        // AreaMark: tô vùng dưới đường (area chart)
                        AreaMark(
                            x: .value("Tháng", data.month),
                            y: .value("Doanh thu", data.sales)
                        )
                        .foregroundStyle(by: .value("Loại", data.category))
                        .opacity(0.1) // Trong suốt
                    }
                }
                .frame(height: 220)
                .chartForegroundStyleScale([
                    "App A": Color.indigo,
                    "App B": Color.teal
                ])
                .chartLegend(position: .bottom)
                .chartYAxis {
                    // Tuỳ chỉnh trục Y
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text("\(Int(v))M")
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)

            // Thống kê nhanh
            GroupBox(label: Label("Thống Kê Nhanh", systemImage: "number")) {
                HStack(spacing: 0) {
                    statItem(title: "Cao nhất", value: "35M", icon: "arrow.up", color: .green)
                    Divider()
                    statItem(title: "Thấp nhất", value: "8M", icon: "arrow.down", color: .red)
                    Divider()
                    statItem(title: "Trung bình", value: "19M", icon: "equal", color: .blue)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)
        }
    }

    // ── Biểu đồ Tròn (Pie / Donut Chart) ─────────────────────────────────
    var pieChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            GroupBox(label: Label("Thời Gian Dùng App Hôm Nay", systemImage: "clock.fill")) {
                // SectorMark = biểu đồ tròn (iOS 17+)
                Chart {
                    ForEach(appUsage) { usage in
                        SectorMark(
                            angle: .value("Giờ", usage.hours),
                            innerRadius: .ratio(0.6),  // 0.6 = donut, 0 = pie đặc
                            angularInset: 2            // Khoảng cách giữa các mảnh
                        )
                        .cornerRadius(4)
                        .foregroundStyle(by: .value("App", usage.app))
                    }
                }
                .frame(height: 250)
                .chartLegend(position: .bottom, alignment: .center, spacing: 8)
                .chartForegroundStyleScale(
                    domain: appUsage.map { $0.app },
                    range: appUsage.map { $0.color }
                )
                .overlay {
                    // Nhãn ở giữa donut
                    VStack(spacing: 2) {
                        Text("\(appUsage.reduce(0) { $0 + $1.hours }, specifier: "%.1f")")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("giờ")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)

            // Bảng chi tiết
            GroupBox(label: Label("Chi Tiết", systemImage: "list.bullet")) {
                VStack(spacing: 8) {
                    ForEach(appUsage) { usage in
                        HStack {
                            Circle()
                                .fill(usage.color)
                                .frame(width: 12, height: 12)
                            Text(usage.app)
                            Spacer()
                            Text("\(usage.hours, specifier: "%.1f") giờ")
                                .foregroundStyle(.secondary)
                            Text("(\(Int(usage.hours / 8.8 * 100))%)")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal)
        }
    }

    // Component thống kê nhỏ
    func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationStack {
        ChartsView()
    }
}
