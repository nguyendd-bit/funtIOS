//
//  TestProjectApp.swift
//  TestProject
//
//  Điểm khởi đầu của App.
//
//  Kiến thức:
//  @main — đánh dấu đây là nơi app bắt đầu chạy
//  .environment() — inject AppState vào toàn bộ view hierarchy
//  Bất kỳ View nào cũng có thể đọc AppState qua @Environment(AppState.self)
//

import SwiftUI

@main
struct TestProjectApp: App {

    // @State với @Observable object: tạo một instance AppState duy nhất cho toàn app
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // .environment(): truyền appState vào toàn bộ view hierarchy
                // Bất kỳ View con nào cũng có thể dùng @Environment(AppState.self)
                .environment(appState)
        }
    }
}
