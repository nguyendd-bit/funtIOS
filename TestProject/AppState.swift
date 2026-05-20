//
//  AppState.swift
//  TestProject
//
//  AppState — Quản lý trạng thái toàn cục của App (State Management).
//
//  Kiến thức:
//  1. @Observable (iOS 17+) — thay thế ObservableObject, đơn giản hơn nhiều
//  2. @State + @Bindable — dùng @Observable với SwiftUI
//  3. Singleton pattern — một instance duy nhất toàn app
//  4. @Environment — truyền object qua nhiều màn hình mà không cần Binding
//

import SwiftUI
import Observation

// @Observable: đánh dấu class này có thể quan sát được bởi SwiftUI
// Khi bất kỳ property nào thay đổi, các View đang dùng nó sẽ tự cập nhật
@Observable
class AppState {

    // Biến dùng chung toàn app
    var currentUser: String = "Người Dùng"
    var isDarkMode: Bool = false
    var notificationCount: Int = 0
    var favoriteColor: Color = .indigo
    var isLoggedIn: Bool = false
		
    // Hàm thêm thông báo
    func addNotification() {
        notificationCount += 1
    }

    // Hàm đăng nhập
    func login(name: String) {
        currentUser = name
        isLoggedIn = true
    }

    // Hàm đăng xuất
    func logout() {
        currentUser = "Người Dùng"
        isLoggedIn = false
        notificationCount = 0
    }
}
