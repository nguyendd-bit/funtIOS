//
//  ContentView.swift
//  TestProject
//
//  ContentView là màn hình gốc của app.
//  Chúng ta dùng TabView để tạo thanh tab ở dưới cùng,
//  giúp người dùng chuyển giữa các màn hình chính.
//

import SwiftUI

struct ContentView: View {

    // Lấy AppState từ Environment (được inject bởi TestProjectApp)
    @Environment(AppState.self) private var appState

    var body: some View {
        // TabView tạo thanh điều hướng dưới cùng (Tab Bar)
        TabView {
            // Tab 1: Trang Chủ
            HomeView()
                .tabItem {
                    Label("Trang Chủ", systemImage: "house.fill")
                }

            // Tab 2: Danh Sách
            ListDemoView()
                .tabItem {
                    Label("Danh Sách", systemImage: "list.bullet")
                }

            // Tab 3: Form Nhập Liệu
            FormDemoView()
                .tabItem {
                    Label("Form", systemImage: "square.and.pencil")
                }

            // Tab 4: Animation & Gesture
            AnimationView()
                .tabItem {
                    Label("Animation", systemImage: "sparkles")
                }

            // Tab 5: Cài Đặt
            SettingsView()
                .tabItem {
                    Label("Cài Đặt", systemImage: "gearshape.fill")
                }

            // Tab 6: Nâng Cao (mới thêm)
            AdvancedMenuView()
                .tabItem {
                    Label("Nâng Cao", systemImage: "flask.fill")
                }
                // Badge thông báo từ AppState
                .badge(appState.notificationCount > 0 ? appState.notificationCount : 0)
        }
        // Màu sắc của tab bar
        .tint(.indigo)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
