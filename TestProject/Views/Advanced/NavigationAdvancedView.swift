//
//  NavigationAdvancedView.swift
//  TestProject
//
//  Demo Navigation nâng cao — Điều hướng lập trình (Programmatic Navigation).
//
//  Kiến thức:
//  1. NavigationPath — ngăn xếp điều hướng có thể điều khiển từ code
//  2. .navigationDestination(for:) — đăng ký màn hình theo kiểu dữ liệu
//  3. Programmatic push — điều hướng mà không cần người dùng bấm
//  4. Quay về màn hình bất kỳ — popToRoot, pop n màn hình
//  5. Deep link navigation — mở màn hình cụ thể từ notification/URL
//  6. .navigationDestination với enum — điều hướng type-safe
//

import SwiftUI

// ── Enum định nghĩa tất cả màn hình có thể điều hướng ───────────────────────
// Hashable: cần để dùng với NavigationPath
// Codable: cần để lưu/phục hồi navigation state
enum AppRoute: Hashable, Codable {
    case productList
    case productDetail(id: Int, name: String)
    case cart(itemCount: Int)
    case checkout
    case orderConfirmation(orderId: String)
    case userProfile(username: String)
    case settings
}

// ── NavigationAdvancedView ────────────────────────────────────────────────────
struct NavigationAdvancedView: View {

    // NavigationPath: ngăn xếp điều hướng — ta có thể thêm/xóa màn hình
    @State private var path = NavigationPath()
    @State private var deepLinkRoute: String = "Chưa có"

    var body: some View {
        // NavigationStack nhận path để điều khiển ngăn xếp
        NavigationStack(path: $path) {
            List {

                // ── Section 1: Điều hướng cơ bản ──────────────────────
                Section {
                    // Cách 1: NavigationLink thông thường (khai báo)
                    NavigationLink(value: AppRoute.productList) {
                        Label("Danh sách sản phẩm", systemImage: "list.bullet")
                    }

                    NavigationLink(value: AppRoute.userProfile(username: "NguyenVanA")) {
                        Label("Hồ sơ người dùng", systemImage: "person.crop.circle")
                    }

                } header: {
                    Text("NavigationLink (Khai Báo)")
                }

                // ── Section 2: Điều hướng lập trình ──────────────────
                Section {
                    Text("Điều hướng từ code, không cần Link")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // Cách 2: Thêm vào path từ Button
                    Button {
                        // Thêm route vào ngăn xếp → push màn hình mới
                        path.append(AppRoute.productDetail(id: 42, name: "iPhone 16 Pro"))
                    } label: {
                        Label("Push: Chi tiết iPhone", systemImage: "arrow.right.circle")
                    }

                    Button {
                        path.append(AppRoute.cart(itemCount: 3))
                    } label: {
                        Label("Push: Giỏ hàng (3 sản phẩm)", systemImage: "cart")
                    }

                    // Đẩy nhiều màn hình cùng lúc (deep link)
                    Button {
                        // Mở luôn màn hình Order Confirmation (3 cấp sâu)
                        path.append(AppRoute.productDetail(id: 1, name: "MacBook Pro"))
                        path.append(AppRoute.cart(itemCount: 1))
                        path.append(AppRoute.checkout)
                        path.append(AppRoute.orderConfirmation(orderId: "ORD-\(Int.random(in: 10000...99999))"))
                    } label: {
                        Label("Deep Link: Xác nhận đơn hàng (4 cấp)", systemImage: "bolt.fill")
                    }
                    .foregroundStyle(.orange)

                } header: {
                    Text("Programmatic Navigation (Code)")
                }

                // ── Section 3: Điều khiển ngăn xếp ───────────────────
                Section {
                    HStack {
                        Text("Màn hình đang có:")
                            .font(.subheadline)
                        Spacer()
                        Text("\(path.count) màn hình")
                            .fontWeight(.bold)
                            .foregroundStyle(.indigo)
                    }

                    // Xóa n màn hình khỏi ngăn xếp
                    Button {
                        if path.count > 0 {
                            path.removeLast()  // Pop 1 màn hình
                        }
                    } label: {
                        Label("Pop 1 màn hình", systemImage: "arrow.left")
                    }
                    .disabled(path.isEmpty)

                    Button {
                        path = NavigationPath()  // Xóa tất cả → về root
                    } label: {
                        Label("Về màn hình gốc (Pop to Root)", systemImage: "arrow.uturn.left")
                    }
                    .foregroundStyle(.red)
                    .disabled(path.isEmpty)

                } header: {
                    Text("Điều Khiển Ngăn Xếp")
                }

                // ── Section 4: Deep Link Simulator ────────────────────
                Section {
                    Text("Giả lập mở app từ thông báo/URL scheme với màn hình cụ thể:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    deepLinkButton("myapp://product/123", icon: "link") {
                        path = NavigationPath()
                        path.append(AppRoute.productDetail(id: 123, name: "Sản Phẩm #123"))
                        deepLinkRoute = "myapp://product/123"
                    }

                    deepLinkButton("myapp://order/confirmed", icon: "checkmark.circle") {
                        path = NavigationPath()
                        path.append(AppRoute.productList)
                        path.append(AppRoute.cart(itemCount: 2))
                        path.append(AppRoute.checkout)
                        path.append(AppRoute.orderConfirmation(orderId: "ORD-98765"))
                        deepLinkRoute = "myapp://order/confirmed"
                    }

                    deepLinkButton("myapp://profile/settings", icon: "gearshape") {
                        path = NavigationPath()
                        path.append(AppRoute.userProfile(username: "TôiLàUser"))
                        path.append(AppRoute.settings)
                        deepLinkRoute = "myapp://profile/settings"
                    }

                    if deepLinkRoute != "Chưa có" {
                        Label("Last deep link: \(deepLinkRoute)", systemImage: "link.badge.plus")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                } header: {
                    Text("Deep Link Simulator")
                }
            }
            .navigationTitle("🧭 Navigation Nâng Cao")
            .navigationBarTitleDisplayMode(.inline)

            // ── .navigationDestination ─────────────────────────────────
            // Đăng ký màn hình cho từng loại AppRoute
            // Khi path.append(AppRoute.xxx) → SwiftUI tự mở màn hình tương ứng
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .productList:
                    ProductListDemoView(path: $path)

                case .productDetail(let id, let name):
                    ProductDetailDemoView(id: id, name: name, path: $path)

                case .cart(let itemCount):
                    CartDemoView(itemCount: itemCount, path: $path)

                case .checkout:
                    CheckoutDemoView(path: $path)

                case .orderConfirmation(let orderId):
                    OrderConfirmationView(orderId: orderId, path: $path)

                case .userProfile(let username):
                    UserProfileDemoView(username: username, path: $path)

                case .settings:
                    SettingsSubView(path: $path)
                }
            }
        }
    }

    func deepLinkButton(_ url: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).foregroundStyle(.blue)
                Text(url)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.blue)
            }
        }
    }
}

// ── Sub-Views ────────────────────────────────────────────────────────────────

struct ProductListDemoView: View {
    @Binding var path: NavigationPath
    let products = [("iPhone 16 Pro", 29990000, "📱"), ("MacBook Pro", 59990000, "💻"),
                    ("AirPods Pro", 6990000, "🎧"), ("Apple Watch", 12990000, "⌚")]
    var body: some View {
        List(products, id: \.0) { product in
            Button {
                path.append(AppRoute.productDetail(id: Int.random(in: 1...100), name: product.0))
            } label: {
                HStack {
                    Text(product.2).font(.title2)
                    VStack(alignment: .leading) {
                        Text(product.0).fontWeight(.medium).foregroundStyle(.primary)
                        Text("\(product.1.formatted()) ₫").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("🛍️ Sản Phẩm")
    }
}

struct ProductDetailDemoView: View {
    let id: Int; let name: String
    @Binding var path: NavigationPath
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("📦").font(.system(size: 80))
            Text(name).font(.largeTitle).fontWeight(.bold)
            Text("ID: #\(id)").foregroundStyle(.secondary)
            Text("29,990,000 ₫").font(.title2).fontWeight(.semibold).foregroundStyle(.green)
            Button {
                path.append(AppRoute.cart(itemCount: 1))
            } label: {
                Label("Thêm vào giỏ hàng", systemImage: "cart.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).padding(.horizontal)
            Spacer()
        }
        .navigationTitle("Chi Tiết")
    }
}

struct CartDemoView: View {
    let itemCount: Int
    @Binding var path: NavigationPath
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("🛒").font(.system(size: 80))
            Text("Giỏ Hàng").font(.largeTitle).fontWeight(.bold)
            Text("\(itemCount) sản phẩm").foregroundStyle(.secondary)
            Text("Tổng: \(itemCount * 29990000, format: .number) ₫")
                .font(.title3).fontWeight(.semibold)
            Button {
                path.append(AppRoute.checkout)
            } label: {
                Label("Tiến hành thanh toán", systemImage: "creditcard")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).tint(.green).padding(.horizontal)
            Spacer()
        }
        .navigationTitle("Giỏ Hàng")
    }
}

struct CheckoutDemoView: View {
    @Binding var path: NavigationPath
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("💳").font(.system(size: 80))
            Text("Thanh Toán").font(.largeTitle).fontWeight(.bold)
            Group {
                infoRow("Phương thức", value: "Apple Pay")
                infoRow("Địa chỉ", value: "123 Nguyễn Huệ, Q1")
                infoRow("Phí ship", value: "Miễn phí")
            }
            Button {
                path.append(AppRoute.orderConfirmation(orderId: "ORD-\(Int.random(in: 10000...99999))"))
            } label: {
                Label("Đặt hàng ngay", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).tint(.orange).padding(.horizontal)
            Spacer()
        }
        .navigationTitle("Thanh Toán")
    }
    func infoRow(_ label: String, value: String) -> some View {
        HStack { Text(label).foregroundStyle(.secondary); Spacer(); Text(value).fontWeight(.medium) }
            .padding(.horizontal)
    }
}

struct OrderConfirmationView: View {
    let orderId: String
    @Binding var path: NavigationPath
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80)).foregroundStyle(.green)
                .symbolEffect(.bounce)
            Text("Đặt Hàng Thành Công!").font(.largeTitle).fontWeight(.bold)
            Text("Mã đơn: \(orderId)").foregroundStyle(.secondary)
            Text("Dự kiến giao: 2-3 ngày").foregroundStyle(.secondary)
            Button {
                path = NavigationPath()  // Về trang chủ
            } label: {
                Label("Về Trang Chủ", systemImage: "house")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent).padding(.horizontal)
            Spacer()
        }
        .navigationTitle("Xác Nhận")
        .navigationBarBackButtonHidden(true)  // Ẩn nút back sau khi đặt hàng
    }
}

struct UserProfileDemoView: View {
    let username: String
    @Binding var path: NavigationPath
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 50)).foregroundStyle(.indigo)
                    VStack(alignment: .leading) {
                        Text(username).font(.title2).fontWeight(.bold)
                        Text("iOS Developer").foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
            Section {
                NavigationLink(value: AppRoute.settings) {
                    Label("Cài đặt tài khoản", systemImage: "gearshape")
                }
            }
        }
        .navigationTitle("Hồ Sơ")
    }
}

struct SettingsSubView: View {
    @Binding var path: NavigationPath
    var body: some View {
        Form {
            Section("Tài khoản") {
                Label("Email", systemImage: "envelope")
                Label("Mật khẩu", systemImage: "lock")
            }
            Section {
                Button("Về trang gốc") { path = NavigationPath() }
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Cài Đặt Tài Khoản")
    }
}

#Preview { NavigationAdvancedView() }
