//
//  HapticView.swift
//  TestProject
//
//  Demo Haptic Feedback — Rung phản hồi cảm ứng (chỉ hoạt động trên thiết bị thật).
//
//  Kiến thức:
//  1. UIImpactFeedbackGenerator — rung tác động (nhẹ/vừa/mạnh)
//  2. UINotificationFeedbackGenerator — rung thông báo (thành công/cảnh báo/lỗi)
//  3. UISelectionFeedbackGenerator — rung khi chọn item
//  4. sensoryFeedback(..) modifier — SwiftUI native (iOS 17+)
//

import SwiftUI

struct HapticView: View {

    @State private var impactCount = 0
    @State private var lastFeedback = "Chưa có"
    @State private var sliderValue: Double = 50
    @State private var selectedOption = 0

    // Tạo các generator — khởi tạo sẵn để giảm độ trễ
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let notificationGen = UINotificationFeedbackGenerator()
    private let selectionGen = UISelectionFeedbackGenerator()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Banner thông báo
                GroupBox {
                    Label("Haptic chỉ hoạt động trên thiết bị thật (iPhone). Simulator không có rung.", systemImage: "iphone")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal)

                // Hiển thị feedback cuối
                GroupBox {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Feedback vừa thực hiện:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(lastFeedback)
                                .font(.headline)
                                .foregroundStyle(.indigo)
                        }
                        Spacer()
                        Image(systemName: "waveform")
                            .font(.largeTitle)
                            .foregroundStyle(.indigo.opacity(0.5))
                    }
                }
                .padding(.horizontal)

                // ── Impact Feedback ────────────────────────────────────
                GroupBox(label: Label("Impact Feedback (Tác Động)", systemImage: "hand.tap")) {
                    VStack(spacing: 10) {
                        Text("Dùng khi người dùng chạm vào nút, kéo thả, v.v.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 8) {
                            hapticButton("Nhẹ", color: .blue) {
                                lightImpact.impactOccurred()
                                lastFeedback = "Impact - Light (Nhẹ)"
                            }
                            hapticButton("Vừa", color: .indigo) {
                                mediumImpact.impactOccurred()
                                lastFeedback = "Impact - Medium (Vừa)"
                            }
                            hapticButton("Mạnh", color: .purple) {
                                heavyImpact.impactOccurred()
                                lastFeedback = "Impact - Heavy (Mạnh)"
                            }
                        }
                        HStack(spacing: 8) {
                            hapticButton("Cứng", color: .gray) {
                                rigidImpact.impactOccurred()
                                lastFeedback = "Impact - Rigid (Cứng)"
                            }
                            hapticButton("Mềm", color: .teal) {
                                softImpact.impactOccurred()
                                lastFeedback = "Impact - Soft (Mềm)"
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── Notification Feedback ──────────────────────────────
                GroupBox(label: Label("Notification Feedback (Thông Báo)", systemImage: "bell")) {
                    VStack(spacing: 10) {
                        Text("Dùng khi thao tác hoàn thành, có lỗi hoặc cảnh báo.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 8) {
                            hapticButton("✅ Thành công", color: .green) {
                                notificationGen.notificationOccurred(.success)
                                lastFeedback = "Notification - Success ✅"
                            }
                            hapticButton("⚠️ Cảnh báo", color: .orange) {
                                notificationGen.notificationOccurred(.warning)
                                lastFeedback = "Notification - Warning ⚠️"
                            }
                            hapticButton("❌ Lỗi", color: .red) {
                                notificationGen.notificationOccurred(.error)
                                lastFeedback = "Notification - Error ❌"
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── Selection Feedback ─────────────────────────────────
                GroupBox(label: Label("Selection Feedback (Chọn Lựa)", systemImage: "checkmark.circle")) {
                    VStack(spacing: 12) {
                        Text("Dùng khi người dùng di chuyển qua các item (Picker, Slider...).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Picker với haptic khi chọn
                        Picker("Chọn", selection: $selectedOption) {
                            Text("Option 1").tag(0)
                            Text("Option 2").tag(1)
                            Text("Option 3").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: selectedOption) { _, _ in
                            selectionGen.selectionChanged()
                            lastFeedback = "Selection - Option \(selectedOption + 1)"
                        }

                        Text("Kéo slider:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Slider với haptic tại các điểm tròn
                        Slider(value: $sliderValue, in: 0...100, step: 10) {
                            Text("Giá trị")
                        } minimumValueLabel: {
                            Text("0")
                        } maximumValueLabel: {
                            Text("100")
                        }
                        .onChange(of: sliderValue) { _, _ in
                            selectionGen.selectionChanged()
                            lastFeedback = "Selection - Slider: \(Int(sliderValue))"
                        }
                        .tint(.indigo)

                        Text("Giá trị: \(Int(sliderValue))")
                            .fontWeight(.semibold)
                            .foregroundStyle(.indigo)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                // ── SwiftUI Native (iOS 17+) ───────────────────────────
                GroupBox(label: Label("SwiftUI Native .sensoryFeedback (iOS 17+)", systemImage: "sparkles")) {
                    VStack(spacing: 10) {
                        Text("iOS 17 thêm modifier .sensoryFeedback — dễ dùng hơn!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button {
                            impactCount += 1
                            lastFeedback = "sensoryFeedback - impact"
                        } label: {
                            Label("Bấm (iOS 17+ haptic)", systemImage: "bolt.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.purple)
                        // .sensoryFeedback: SwiftUI tự trigger khi impactCount thay đổi
                        .sensoryFeedback(.impact(weight: .medium), trigger: impactCount)

                        Text("Đã bấm: \(impactCount) lần")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("📳 Haptic Feedback")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Component nút haptic tái sử dụng
    func hapticButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(color.opacity(0.15))
                .foregroundStyle(color)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HapticView()
    }
}
