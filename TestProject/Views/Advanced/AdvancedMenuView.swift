//
//  AdvancedMenuView.swift
//  TestProject
//
//  Menu chính của tab Nâng Cao — danh sách các chủ đề nâng cao.
//

import SwiftUI

struct AdvancedMenuView: View {

    @Environment(AppState.self) private var appState

    struct AdvancedTopic: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let color: Color
        let badge: String?

        init(_ title: String, _ subtitle: String, _ icon: String, _ color: Color, badge: String? = nil) {
            self.title = title; self.subtitle = subtitle
            self.icon = icon; self.color = color; self.badge = badge
        }
    }

    let section1Topics: [AdvancedTopic] = [
        AdvancedTopic("Networking & API",   "async/await, URLSession, JSON",      "network",                      .blue),
        AdvancedTopic("Swift Charts",       "Biểu đồ cột, đường, tròn",           "chart.bar.fill",               .green),
        AdvancedTopic("Chọn Ảnh",          "PhotosPicker, Core Image filters",    "photo.fill",                   .orange),
        AdvancedTopic("Haptic Feedback",    "Rung phản hồi cảm ứng",              "iphone.radiowaves.left.and.right", .purple),
        AdvancedTopic("Custom Shape",       "Path, Canvas, ViewModifier",          "paintbrush.fill",              .pink),
        AdvancedTopic("State Management",   "@Observable, @Binding, @Environment","arrow.triangle.2.circlepath",  .indigo),
    ]

    let section2Topics: [AdvancedTopic] = [
        AdvancedTopic("SwiftData",          "Database cục bộ, CRUD, @Query",       "cylinder.fill",                .cyan,      badge: "NEW"),
        AdvancedTopic("MapKit",             "Bản đồ VN, Marker, Camera",           "map.fill",                     .green,     badge: "NEW"),
        AdvancedTopic("Face ID / Touch ID", "LocalAuthentication, sinh trắc học",  "faceid",                       .indigo,    badge: "NEW"),
        AdvancedTopic("Local Notifications","Lên lịch thông báo đẩy cục bộ",       "bell.badge.fill",              .red,       badge: "NEW"),
        AdvancedTopic("Grid Layout",        "LazyVGrid, LazyHGrid, GridItem",       "grid",                         .orange,    badge: "NEW"),
        AdvancedTopic("List Nâng Cao",      "Search, Refresh, SwipeActions, Menu", "list.star",                    .teal,      badge: "NEW"),
        AdvancedTopic("Concurrency",        "async let, TaskGroup, Actor",          "bolt.horizontal.fill",         .yellow,    badge: "NEW"),
        AdvancedTopic("Navigation Nâng Cao","NavigationPath, Deep Link",            "map.and.location.north",       .purple,    badge: "NEW"),
    ]

    var body: some View {
        NavigationStack {
            List {
                // ── Banner AppState ────────────────────────────────────
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(appState.favoriteColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Xin chào, \(appState.currentUser)!")
                                .font(.headline)
                            Text("Tổng \(section1Topics.count + section2Topics.count) chủ đề · SwiftUI iOS 17+")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if appState.notificationCount > 0 {
                            Text("\(appState.notificationCount)")
                                .font(.caption).fontWeight(.bold).foregroundStyle(.white)
                                .padding(6).background(Color.red).clipShape(Circle())
                        }
                    }
                    .padding(.vertical, 4)
                } header: { Text("Trạng Thái App") }

                // ── Section 1: Chủ đề cơ bản nâng cao ────────────────
                Section {
                    ForEach(section1Topics) { topic in
                        NavigationLink { destinationView(for: topic.title) } label: {
                            topicRow(topic)
                        }
                    }
                } header: { Label("Chủ Đề Nâng Cao", systemImage: "star") }

                // ── Section 2: Chủ đề mới (NEW) ───────────────────────
                Section {
                    ForEach(section2Topics) { topic in
                        NavigationLink { destinationView(for: topic.title) } label: {
                            topicRow(topic)
                        }
                    }
                } header: { Label("Thêm Mới 🔥", systemImage: "sparkles") }
                  footer: {
                    Text("Tổng cộng \(section1Topics.count + section2Topics.count) chủ đề iOS nâng cao với chú thích tiếng Việt.")
                }
            }
            .navigationTitle("🔬 Nâng Cao")
        }
    }

    func topicRow(_ topic: AdvancedTopic) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 10)
                .fill(topic.color.gradient)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: topic.icon)
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                }
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(topic.title).font(.body).fontWeight(.medium)
                    if let badge = topic.badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(topic.color)
                            .clipShape(Capsule())
                    }
                }
                Text(topic.subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    func destinationView(for title: String) -> some View {
        switch title {
        case "Networking & API":    return AnyView(NetworkingView())
        case "Swift Charts":        return AnyView(ChartsView())
        case "Chọn Ảnh":           return AnyView(PhotoPickerView())
        case "Haptic Feedback":     return AnyView(HapticView())
        case "Custom Shape":        return AnyView(CustomShapeView())
        case "State Management":    return AnyView(StateManagementView())
        case "SwiftData":           return AnyView(SwiftDataView())
        case "MapKit":              return AnyView(MapKitView())
        case "Face ID / Touch ID":  return AnyView(BiometricView())
        case "Local Notifications": return AnyView(LocalNotificationsView())
        case "Grid Layout":         return AnyView(GridLayoutView())
        case "List Nâng Cao":      return AnyView(AdvancedListView())
        case "Concurrency":         return AnyView(ConcurrencyView())
        case "Navigation Nâng Cao": return AnyView(NavigationAdvancedView())
        default:                    return AnyView(Text("Coming soon...").padding())
        }
    }
}

#Preview {
    AdvancedMenuView().environment(AppState())
}
