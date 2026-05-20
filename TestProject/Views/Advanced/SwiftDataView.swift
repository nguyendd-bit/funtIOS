//
//  SwiftDataView.swift
//  TestProject
//
//  Demo SwiftData — Cơ sở dữ liệu cục bộ hiện đại của Apple (iOS 17+).
//
//  Kiến thức:
//  1. @Model — đánh dấu class là model trong database
//  2. @Query — tự động lấy và cập nhật dữ liệu từ database
//  3. ModelContext — thực hiện CRUD (Create, Read, Update, Delete)
//  4. .modelContainer — cung cấp database cho View
//  5. Predicate & SortDescriptor — lọc và sắp xếp dữ liệu
//

import SwiftUI
import SwiftData

// ── @Model: Định nghĩa cấu trúc dữ liệu trong database ──────────────────────
// @Model: SwiftData tự tạo bảng và cột cho class này
@Model
final class Note {
    var title: String
    var content: String
    var createdAt: Date
    var isPinned: Bool
    var colorName: String  // Lưu tên màu (không lưu trực tiếp Color)
    var category: String

    init(title: String, content: String, colorName: String = "blue", category: String = "Chung") {
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.isPinned = false
        self.colorName = colorName
        self.category = category
    }

    // Computed property: chuyển tên màu → Color
    var color: Color {
        switch colorName {
        case "red":    return .red
        case "green":  return .green
        case "orange": return .orange
        case "purple": return .purple
        case "teal":   return .teal
        default:       return .blue
        }
    }
}

// ── SwiftDataView: Wrapper setup container ───────────────────────────────────
// Tách riêng để có thể inject modelContainer trước khi @Query chạy
struct SwiftDataView: View {
    var body: some View {
        SwiftDataContentView()
            // .modelContainer: tạo/kết nối SQLite database cho Note model
            // isAutosaveEnabled: true = tự động lưu khi có thay đổi
            .modelContainer(for: Note.self)
    }
}

// ── SwiftDataContentView: View chính ─────────────────────────────────────────
struct SwiftDataContentView: View {

    // @Environment(\.modelContext): context để thao tác với database
    @Environment(\.modelContext) private var modelContext

    // @Query: tự động fetch và observe Note từ database
    // Khi database thay đổi, @Query tự cập nhật → View tự render lại
    @Query(sort: \Note.createdAt, order: .reverse)
    private var notes: [Note]

    // @Query với filter (chỉ lấy note đã pin)
    @Query(
        filter: #Predicate<Note> { $0.isPinned == true },
        sort: \Note.createdAt, order: .reverse
    )
    private var pinnedNotes: [Note]

    @State private var showAddSheet = false
    @State private var searchText = ""
    @State private var editingNote: Note? = nil

    // Lọc notes theo searchText
    var filteredNotes: [Note] {
        if searchText.isEmpty { return notes }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle("📦 SwiftData")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { showAddSheet = true } label: {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        if !notes.isEmpty {
                            Button("Xóa tất cả", role: .destructive) { deleteAll() }
                                .font(.caption)
                        }
                    }
                }
                .sheet(isPresented: $showAddSheet) {
                    NoteEditorSheet(note: nil, onSave: addNote)
                }
                .sheet(item: $editingNote) { note in
                    NoteEditorSheet(note: note, onSave: { _, _, _, _ in })
                }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if notes.isEmpty {
            ContentUnavailableView {
                Label("Chưa có ghi chú", systemImage: "note.text")
            } description: {
                Text("Bấm + để tạo ghi chú đầu tiên")
            } actions: {
                Button("Tạo ghi chú mẫu") { addSampleNotes() }
                    .buttonStyle(.borderedProminent)
            }
        } else {
            notesList
        }
    }

    private var notesList: some View {
        List {
            if !pinnedNotes.isEmpty {
                Section {
                    ForEach(pinnedNotes) { note in
                        NoteRow(note: note)
                            .swipeActions(edge: .leading) {
                                Button {
                                    note.isPinned = false
                                } label: {
                                    Label("Bỏ ghim", systemImage: "pin.slash")
                                }
                                .tint(.orange)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) { delete(note) } label: {
                                    Label("Xóa", systemImage: "trash")
                                }
                            }
                            .onTapGesture { editingNote = note }
                    }
                } header: {
                    Label("Đã Ghim", systemImage: "pin.fill")
                }
            }

            Section {
                ForEach(filteredNotes.filter { !$0.isPinned }) { note in
                    NoteRow(note: note)
                        .swipeActions(edge: .leading) {
                            Button {
                                note.isPinned = true
                            } label: {
                                Label("Ghim", systemImage: "pin.fill")
                            }
                            .tint(.yellow)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) { delete(note) } label: {
                                Label("Xóa", systemImage: "trash")
                            }
                        }
                        .onTapGesture { editingNote = note }
                }
                .onDelete { offsets in
                    let unpinned = filteredNotes.filter { !$0.isPinned }
                    offsets.forEach { delete(unpinned[$0]) }
                }
            } header: {
                Text("Tất Cả (\(notes.count) ghi chú)")
            }

            Section {
                HStack {
                    Label("Tổng ghi chú", systemImage: "note.text")
                    Spacer()
                    Text("\(notes.count)").foregroundStyle(.secondary)
                }
                HStack {
                    Label("Đã ghim", systemImage: "pin")
                    Spacer()
                    Text("\(pinnedNotes.count)").foregroundStyle(.secondary)
                }
            } header: {
                Text("Thống Kê Database")
            }
        }
        .searchable(text: $searchText, prompt: "Tìm ghi chú...")
    }

    // ── CRUD Functions ──────────────────────────────────────────────────────

    // CREATE: Thêm ghi chú mới
    func addNote(title: String, content: String, colorName: String, category: String) {
        let note = Note(title: title, content: content, colorName: colorName, category: category)
        modelContext.insert(note)   // Thêm vào database
        // modelContext.save() — không cần gọi thủ công nếu autosave = true
    }

    // DELETE: Xóa ghi chú
    func delete(_ note: Note) {
        modelContext.delete(note)   // Xóa khỏi database
    }

    // DELETE ALL
    func deleteAll() {
        notes.forEach { modelContext.delete($0) }
    }

    // Thêm dữ liệu mẫu
    func addSampleNotes() {
        let samples = [
            ("🛒 Danh sách mua sắm", "Táo, Chuối, Sữa, Bánh mì", "orange", "Cá Nhân"),
            ("📚 Học SwiftUI", "Xem tutorial, làm project, ôn lại", "blue", "Học Tập"),
            ("💡 Ý tưởng app", "App quản lý chi tiêu, app học tiếng Anh", "purple", "Công Việc"),
            ("🏃 Lịch tập gym", "T2/T4/T6 sáng 6h, cardio + weights", "green", "Sức Khỏe"),
        ]
        samples.forEach { addNote(title: $0.0, content: $0.1, colorName: $0.2, category: $0.3) }
    }
}

// ── NoteRow: Component hiển thị 1 ghi chú ───────────────────────────────────
struct NoteRow: View {
    let note: Note
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(note.color.gradient)
                .frame(width: 6, height: 50)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(note.title)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }
                Text(note.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                HStack {
                    Text(note.category)
                        .font(.caption2)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(note.color.opacity(0.15))
                        .foregroundStyle(note.color)
                        .clipShape(Capsule())
                    Spacer()
                    Text(note.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

// ── NoteEditorSheet: Form thêm/sửa ghi chú ──────────────────────────────────
struct NoteEditorSheet: View {
    let note: Note?
    let onSave: (String, String, String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var content = ""
    @State private var colorName = "blue"
    @State private var category = "Chung"

    let colors = ["blue", "red", "green", "orange", "purple", "teal"]
    let categories = ["Chung", "Công Việc", "Học Tập", "Cá Nhân", "Sức Khỏe"]

    var isEditing: Bool { note != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Nội dung") {
                    TextField("Tiêu đề", text: $title)
                    TextField("Nội dung...", text: $content, axis: .vertical)
                        .lineLimit(3...6)
                }
                Section("Phân loại") {
                    Picker("Danh mục", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    // Chọn màu
                    HStack {
                        Text("Màu sắc")
                        Spacer()
                        ForEach(colors, id: \.self) { c in
                            Circle()
                                .fill(noteColor(c))
                                .frame(width: 26, height: 26)
                                .overlay(colorName == c ? Image(systemName: "checkmark").foregroundStyle(.white).font(.caption) : nil)
                                .onTapGesture { colorName = c }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Sửa Ghi Chú" : "Ghi Chú Mới")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let note {
                    title = note.title
                    content = note.content
                    colorName = note.colorName
                    category = note.category
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Huỷ") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        if isEditing {
                            // UPDATE: Sửa trực tiếp trên note object
                            note?.title = title
                            note?.content = content
                            note?.colorName = colorName
                            note?.category = category
                        } else {
                            onSave(title, content, colorName, category)
                        }
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    func noteColor(_ name: String) -> Color {
        switch name {
        case "red": return .red
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "teal": return .teal
        default: return .blue
        }
    }
}

#Preview {
    SwiftDataView()
}
