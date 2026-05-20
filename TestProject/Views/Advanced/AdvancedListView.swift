//
//  AdvancedListView.swift
//  TestProject
//
//  Demo các tính năng List nâng cao.
//
//  Kiến thức:
//  1. .searchable — thanh tìm kiếm tích hợp
//  2. .refreshable — kéo xuống để làm mới dữ liệu
//  3. .swipeActions — hành động vuốt trái/phải tùy chỉnh
//  4. .contextMenu — menu khi nhấn giữ
//  5. ScrollViewReader — cuộn đến vị trí cụ thể trong code
//  6. Section với header sticky
//  7. .badge — huy hiệu số
//  8. .listRowSeparator — ẩn/hiện đường kẻ
//

import SwiftUI

struct Contact: Identifiable {
    let id = UUID()
    var name: String
    var phone: String
    var isFavorite: Bool
    var category: String
    var avatar: String  // Emoji làm avatar
    var isOnline: Bool
    var unreadCount: Int
}

struct AdvancedListView: View {

    @State private var contacts: [Contact] = Contact.sampleData
    @State private var searchText = ""
    @State private var isRefreshing = false
    @State private var selectedContact: Contact? = nil
    @State private var showDeleteAlert = false
    @State private var contactToDelete: Contact? = nil
    @State private var sortBy: SortOption = .name

    enum SortOption: String, CaseIterable {
        case name = "Tên"
        case category = "Nhóm"
        case online = "Online trước"
    }

    // Lọc và sắp xếp
    var filteredContacts: [Contact] {
        var result = contacts
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.phone.contains(searchText)
            }
        }
        switch sortBy {
        case .name: return result.sorted { $0.name < $1.name }
        case .category: return result.sorted { $0.category < $1.category }
        case .online: return result.sorted { $0.isOnline && !$1.isOnline }
        }
    }

    // Nhóm theo category
    var groupedContacts: [String: [Contact]] {
        Dictionary(grouping: filteredContacts) { $0.category }
    }

    var sortedCategories: [String] {
        groupedContacts.keys.sorted()
    }

    var favoriteContacts: [Contact] {
        filteredContacts.filter { $0.isFavorite }
    }

    var body: some View {
        // ScrollViewReader: cho phép cuộn đến item theo id
        ScrollViewReader { scrollProxy in
            List {

                // ── Section: Yêu thích ─────────────────────────────────
                if !favoriteContacts.isEmpty && searchText.isEmpty {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(favoriteContacts) { contact in
                                    VStack(spacing: 6) {
                                        ZStack(alignment: .bottomTrailing) {
                                            Text(contact.avatar)
                                                .font(.system(size: 44))
                                                .frame(width: 60, height: 60)
                                                .background(Color(.systemGray6))
                                                .clipShape(Circle())
                                            // Online indicator
                                            if contact.isOnline {
                                                Circle()
                                                    .fill(.green)
                                                    .frame(width: 14, height: 14)
                                                    .overlay(Circle().stroke(.white, lineWidth: 2))
                                            }
                                        }
                                        Text(contact.name.components(separatedBy: " ").first ?? "")
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                    .frame(width: 60)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    } header: {
                        Label("Yêu Thích", systemImage: "star.fill")
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }

                // ── Sections theo nhóm ─────────────────────────────────
                ForEach(sortedCategories, id: \.self) { category in
                    Section {
                        ForEach(groupedContacts[category] ?? []) { contact in
                            contactRow(contact: contact, scrollProxy: scrollProxy)
                        }
                    } header: {
                        // Header sticky tự động khi dùng List
                        HStack {
                            Text(category)
                            Spacer()
                            Text("\(groupedContacts[category]?.count ?? 0) người")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Không có kết quả
                if filteredContacts.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            // ── .searchable: thanh tìm kiếm tích hợp ──────────────────
            .searchable(text: $searchText, prompt: "Tìm liên lạc, số điện thoại...")
            // ── .refreshable: kéo xuống để làm mới ───────────────────
            .refreshable {
                await simulateRefresh()
            }
            .navigationTitle("📞 List Nâng Cao")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sắp xếp", selection: $sortBy) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Label(option.rawValue, systemImage: "arrow.up.arrow.down")
                                    .tag(option)
                            }
                        }
                        Divider()
                        // Cuộn đến đầu danh sách
                        Button("Lên đầu") {
                            if let first = filteredContacts.first {
                                withAnimation { scrollProxy.scrollTo(first.id) }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        addRandomContact()
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            // Alert xoá
            .alert("Xóa liên lạc?", isPresented: $showDeleteAlert) {
                Button("Xóa", role: .destructive) {
                    if let c = contactToDelete { deleteContact(c) }
                }
                Button("Huỷ", role: .cancel) {}
            } message: {
                Text("Bạn có chắc muốn xóa \(contactToDelete?.name ?? "")?")
            }
        }
    }

    // ── Row liên lạc ──────────────────────────────────────────────────────
    func contactRow(contact: Contact, scrollProxy: ScrollViewProxy) -> some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Text(contact.avatar)
                    .font(.title2)
                    .frame(width: 46, height: 46)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
                if contact.isOnline {
                    Circle().fill(.green).frame(width: 12, height: 12)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(contact.name)
                        .fontWeight(.medium)
                    if contact.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }
                }
                Text(contact.phone)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if contact.unreadCount > 0 {
                // .badge trực tiếp
                Text("\(contact.unreadCount)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color.red)
                    .clipShape(Capsule())
            }
        }
        .id(contact.id)  // id để ScrollViewReader có thể scroll đến
        // ── .swipeActions: hành động vuốt ─────────────────────────────
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            // Hành động xoá (destructive = đỏ, full swipe = xoá ngay)
            Button(role: .destructive) {
                contactToDelete = contact
                showDeleteAlert = true
            } label: {
                Label("Xóa", systemImage: "trash.fill")
            }

            Button {
                // Gọi điện (mở link tel://)
            } label: {
                Label("Gọi", systemImage: "phone.fill")
            }
            .tint(.green)
        }
        .swipeActions(edge: .leading) {
            // Vuốt phải: yêu thích
            Button {
                toggleFavorite(contact)
            } label: {
                Label(contact.isFavorite ? "Bỏ yêu thích" : "Yêu thích",
                      systemImage: contact.isFavorite ? "star.slash" : "star.fill")
            }
            .tint(.yellow)
        }
        // ── .contextMenu: menu khi nhấn giữ ──────────────────────────
        .contextMenu {
            Button {
                toggleFavorite(contact)
            } label: {
                Label(contact.isFavorite ? "Bỏ yêu thích" : "Thêm yêu thích",
                      systemImage: contact.isFavorite ? "star.slash" : "star")
            }

            Button {
                // Copy số điện thoại
                UIPasteboard.general.string = contact.phone
            } label: {
                Label("Sao chép số điện thoại", systemImage: "doc.on.doc")
            }

            Divider()

            Button(role: .destructive) {
                contactToDelete = contact
                showDeleteAlert = true
            } label: {
                Label("Xóa liên lạc", systemImage: "trash")
            }
        }
        // Preview khi nhấn giữ
        .contextMenu(menuItems: { EmptyView() }, preview: {
            HStack(spacing: 16) {
                Text(contact.avatar).font(.system(size: 60))
                VStack(alignment: .leading) {
                    Text(contact.name).font(.title2).fontWeight(.bold)
                    Text(contact.phone).foregroundStyle(.secondary)
                    Text(contact.category).font(.caption).foregroundStyle(.blue)
                }
            }
            .padding()
        })
    }

    // ── Functions ─────────────────────────────────────────────────────────
    func toggleFavorite(_ contact: Contact) {
        if let idx = contacts.firstIndex(where: { $0.id == contact.id }) {
            withAnimation { contacts[idx].isFavorite.toggle() }
        }
    }

    func deleteContact(_ contact: Contact) {
        withAnimation {
            contacts.removeAll { $0.id == contact.id }
        }
    }

    func addRandomContact() {
        let names = ["Nguyễn An", "Trần Bình", "Lê Cường", "Phạm Dung", "Hoàng Em"]
        let phones = ["0901", "0912", "0923", "0934", "0945"]
        let emojis = ["😊", "👨", "👩", "🧑", "👦", "👧"]
        let categories = ["Gia Đình", "Bạn Bè", "Đồng Nghiệp"]
        withAnimation {
            contacts.append(Contact(
                name: names.randomElement()! + " \(Int.random(in: 1...99))",
                phone: phones.randomElement()! + "\(Int.random(in: 100000...999999))",
                isFavorite: false,
                category: categories.randomElement()!,
                avatar: emojis.randomElement()!,
                isOnline: Bool.random(),
                unreadCount: Int.random(in: 0...5)
            ))
        }
    }

    func simulateRefresh() async {
        try? await Task.sleep(nanoseconds: 1_500_000_000)  // 1.5 giây
        await MainActor.run {
            // Giả lập cập nhật dữ liệu
            contacts.indices.forEach { i in
                contacts[i].isOnline = Bool.random()
                contacts[i].unreadCount = Int.random(in: 0...3)
            }
        }
    }
}

// ── Dữ liệu mẫu ─────────────────────────────────────────────────────────────
extension Contact {
    static let sampleData: [Contact] = [
        Contact(name: "Mẹ", phone: "0901234567", isFavorite: true, category: "Gia Đình", avatar: "👩", isOnline: true, unreadCount: 2),
        Contact(name: "Ba", phone: "0901234568", isFavorite: true, category: "Gia Đình", avatar: "👨", isOnline: false, unreadCount: 0),
        Contact(name: "Anh Hai", phone: "0912345678", isFavorite: false, category: "Gia Đình", avatar: "🧑", isOnline: true, unreadCount: 1),
        Contact(name: "Minh Tuấn", phone: "0923456789", isFavorite: true, category: "Bạn Bè", avatar: "😎", isOnline: true, unreadCount: 5),
        Contact(name: "Hà Linh", phone: "0934567890", isFavorite: false, category: "Bạn Bè", avatar: "😊", isOnline: false, unreadCount: 0),
        Contact(name: "Quốc Hùng", phone: "0945678901", isFavorite: false, category: "Bạn Bè", avatar: "🤩", isOnline: true, unreadCount: 3),
        Contact(name: "Sếp Trực", phone: "0956789012", isFavorite: false, category: "Đồng Nghiệp", avatar: "👔", isOnline: false, unreadCount: 0),
        Contact(name: "Thu Hương", phone: "0967890123", isFavorite: false, category: "Đồng Nghiệp", avatar: "👩‍💼", isOnline: true, unreadCount: 1),
        Contact(name: "Văn Tài", phone: "0978901234", isFavorite: false, category: "Đồng Nghiệp", avatar: "👨‍💻", isOnline: true, unreadCount: 0),
    ]
}

#Preview { NavigationStack { AdvancedListView() } }
