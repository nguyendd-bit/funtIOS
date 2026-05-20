//
//  NetworkingView.swift
//  TestProject
//
//  Demo Networking — Gọi API thực tế, xử lý JSON, async/await.
//
//  Kiến thức:
//  1. async/await — lập trình bất đồng bộ hiện đại (thay thế callback/Closure)
//  2. URLSession — gửi HTTP request
//  3. Codable / Decodable — tự động giải mã JSON thành Swift struct
//  4. @State với enum LoadingState — quản lý trạng thái loading/success/error
//  5. Task { } — chạy code async trong SwiftUI
//  6. .task { } modifier — tự động fetch khi view xuất hiện
//

import SwiftUI

// ── Model: Cấu trúc dữ liệu khớp với JSON từ API ───────────────────────────
// Decodable: Swift tự động giải mã JSON → struct này
// API endpoint: https://jsonplaceholder.typicode.com/posts
struct Post: Decodable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

// Thông tin Bitcoin từ CoinDesk API
struct BitcoinPrice: Decodable {
    let bpi: BPI

    struct BPI: Decodable {
        let USD: Currency
    }
    struct Currency: Decodable {
        let rate: String
        let description: String
    }
}

// ── LoadingState: Enum quản lý trạng thái tải dữ liệu ──────────────────────
// Đây là pattern rất phổ biến trong iOS development
enum LoadingState<T> {
    case idle       // Chưa làm gì
    case loading    // Đang tải
    case success(T) // Tải thành công, có dữ liệu
    case failure(String) // Tải thất bại, có thông báo lỗi
}

// ── NetworkingView ───────────────────────────────────────────────────────────
struct NetworkingView: View {

    // LoadingState với kiểu dữ liệu là mảng Post
    @State private var postsState: LoadingState<[Post]> = .idle
    @State private var btcState: LoadingState<BitcoinPrice> = .idle
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                // Picker chọn loại API demo
                Picker("API Demo", selection: $selectedTab) {
                    Text("📰 Bài Viết").tag(0)
                    Text("₿ Bitcoin").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedTab == 0 {
                    postsSection
                } else {
                    bitcoinSection
                }
            }
        }
        .navigationTitle("🌐 Networking & API")
        .navigationBarTitleDisplayMode(.inline)
    }

    // ── Section 1: Danh sách bài viết ─────────────────────────────────────
    var postsSection: some View {
        VStack(spacing: 16) {

            // Giải thích code pattern
            GroupBox {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Cách hoạt động:", systemImage: "lightbulb")
                        .fontWeight(.semibold)
                    Text("1. App gọi API → https://jsonplaceholder.typicode.com")
                    Text("2. Nhận JSON response từ server")
                    Text("3. Giải mã JSON → Swift struct (Decodable)")
                    Text("4. Hiển thị dữ liệu lên màn hình")
                }
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)

            // Nút gọi API
            Button {
                // Task { }: chạy code async từ context đồng bộ
                Task {
                    await fetchPosts()
                }
            } label: {
                Label("Tải bài viết từ API", systemImage: "arrow.down.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(.horizontal)

            // Hiển thị theo trạng thái
            switch postsState {
            case .idle:
                ContentUnavailableView(
                    "Chưa tải dữ liệu",
                    systemImage: "network",
                    description: Text("Bấm nút trên để gọi API")
                )
                .padding(.top, 40)

            case .loading:
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Đang gọi API...")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)

            case .success(let posts):
                LazyVStack(spacing: 0) {
                    ForEach(posts) { post in
                        PostRow(post: post)
                        Divider()
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

            case .failure(let error):
                ContentUnavailableView(
                    "Lỗi kết nối",
                    systemImage: "wifi.exclamationmark",
                    description: Text(error)
                )
                .padding(.top, 40)
            }

            Spacer(minLength: 40)
        }
        .padding(.top, 8)
    }

    // ── Section 2: Bitcoin Price ───────────────────────────────────────────
    var bitcoinSection: some View {
        VStack(spacing: 20) {
            GroupBox {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Dữ liệu thực tế:", systemImage: "bolt")
                        .fontWeight(.semibold)
                    Text("Gọi API CoinDesk để lấy giá Bitcoin hiện tại theo USD.")
                }
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)

            Button {
                Task { await fetchBitcoinPrice() }
            } label: {
                Label("Lấy giá Bitcoin", systemImage: "bitcoinsign.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding(.horizontal)

            switch btcState {
            case .idle:
                ContentUnavailableView("Chưa tải", systemImage: "bitcoinsign.circle")
                    .padding(.top, 40)

            case .loading:
                VStack(spacing: 12) {
                    ProgressView().scaleEffect(1.5)
                    Text("Đang lấy giá Bitcoin...").foregroundStyle(.secondary)
                }
                .padding(.top, 60)

            case .success(let btc):
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(
                                colors: [.orange, .yellow],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        VStack(spacing: 8) {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.white)
                            Text("Bitcoin (BTC/USD)")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.8))
                            Text("$\(btc.bpi.USD.rate)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        .padding(30)
                    }
                    .padding(.horizontal)
                }

            case .failure(let error):
                ContentUnavailableView("Lỗi", systemImage: "wifi.exclamationmark",
                                       description: Text(error))
                    .padding(.top, 40)
            }

            Spacer(minLength: 40)
        }
        .padding(.top, 8)
    }

    // ── Async Functions (Hàm bất đồng bộ) ─────────────────────────────────

    // async func: hàm bất đồng bộ — phải dùng await khi gọi
    // throws: hàm có thể ném ra lỗi
    func fetchPosts() async {
        // Bước 1: Đổi trạng thái sang loading
        postsState = .loading

        // do-catch: xử lý lỗi trong Swift
        do {
            // Bước 2: Tạo URL
            let url = URL(string: "https://jsonplaceholder.typicode.com/posts?_limit=15")!

            // Bước 3: Gọi API — await dừng tại đây cho đến khi có kết quả
            // URLSession.shared.data(from:) trả về (Data, URLResponse)
            let (data, _) = try await URLSession.shared.data(from: url)

            // Bước 4: Giải mã JSON → [Post]
            // JSONDecoder tự khớp key JSON với property của struct
            let posts = try JSONDecoder().decode([Post].self, from: data)

            // Bước 5: Cập nhật UI (phải chạy trên Main Thread)
            await MainActor.run {
                postsState = .success(posts)
            }

        } catch {
            // Xảy ra lỗi: cập nhật trạng thái lỗi
            await MainActor.run {
                postsState = .failure("Không thể kết nối: \(error.localizedDescription)")
            }
        }
    }

    func fetchBitcoinPrice() async {
        btcState = .loading
        do {
            let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let price = try JSONDecoder().decode(BitcoinPrice.self, from: data)
            await MainActor.run { btcState = .success(price) }
        } catch {
            await MainActor.run { btcState = .failure(error.localizedDescription) }
        }
    }
}

// ── PostRow: Component hiển thị một bài viết ──────────────────────────────
struct PostRow: View {
    let post: Post

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar số thứ tự
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 40, height: 40)
                Text("#\(post.id)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(post.title.capitalized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                Text(post.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        NetworkingView()
    }
}
