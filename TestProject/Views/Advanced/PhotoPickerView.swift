//
//  PhotoPickerView.swift
//  TestProject
//
//  Demo PhotosPicker — Chọn ảnh từ thư viện, xử lý hình ảnh.
//
//  Kiến thức:
//  1. PhotosPicker — picker tích hợp sẵn, không cần xin quyền (iOS 16+)
//  2. PhotosPickerItem — đại diện cho ảnh được chọn
//  3. .loadTransferable(type:) — tải dữ liệu ảnh bất đồng bộ
//  4. Image — hiển thị ảnh từ Data/UIImage
//  5. Xử lý ảnh cơ bản với UIImage
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {

    // PhotosPickerItem: item ảnh được chọn từ picker
    @State private var selectedItem: PhotosPickerItem? = nil

    // UIImage: ảnh đã được tải về
    @State private var selectedImage: UIImage? = nil

    // Trạng thái tải ảnh
    @State private var isLoading = false

    // Thông số ảnh
    @State private var imageInfo: String = ""

    // Bộ lọc áp dụng
    @State private var selectedFilter = 0
    let filters = ["Gốc", "Xám", "Đảo màu", "Sáng hơn"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // ── Khu hiển thị ảnh ──────────────────────────────────
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                        .frame(height: 300)

                    if isLoading {
                        VStack(spacing: 12) {
                            ProgressView().scaleEffect(1.5)
                            Text("Đang tải ảnh...").foregroundStyle(.secondary)
                        }

                    } else if let image = processedImage {
                        // Hiển thị ảnh đã được xử lý
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .transition(.opacity.combined(with: .scale))

                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 50))
                                .foregroundStyle(.secondary)
                            Text("Chọn ảnh từ thư viện")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .animation(.easeInOut, value: selectedImage)
                .padding(.horizontal)

                // ── Nút chọn ảnh (PhotosPicker) ───────────────────────
                // PhotosPicker: không cần xin quyền! iOS tự xử lý
                PhotosPicker(
                    selection: $selectedItem,         // Binding đến item được chọn
                    matching: .images,                // Chỉ cho chọn ảnh
                    photoLibrary: .shared()           // Dùng thư viện ảnh chung
                ) {
                    Label("Chọn Ảnh Từ Thư Viện", systemImage: "photo.on.rectangle.angled")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.horizontal)
                // Khi selectedItem thay đổi → tải ảnh
                .onChange(of: selectedItem) { _, newItem in
                    Task { await loadImage(from: newItem) }
                }

                // ── Bộ lọc màu ────────────────────────────────────────
                if selectedImage != nil {
                    GroupBox(label: Label("Bộ Lọc Màu (Filter)", systemImage: "camera.filters")) {
                        Picker("Bộ lọc", selection: $selectedFilter) {
                            ForEach(filters.indices, id: \.self) { i in
                                Text(filters[i]).tag(i)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.top, 4)

                        Text("Xử lý ảnh bằng Core Image / UIKit")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal)

                    // ── Thông tin ảnh ──────────────────────────────────
                    if !imageInfo.isEmpty {
                        GroupBox(label: Label("Thông Tin Ảnh", systemImage: "info.circle")) {
                            Text(imageInfo)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4)
                        }
                        .padding(.horizontal)
                    }

                    // Nút xoá ảnh
                    Button(role: .destructive) {
                        withAnimation {
                            selectedImage = nil
                            selectedItem = nil
                            imageInfo = ""
                        }
                    } label: {
                        Label("Xoá ảnh", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }

                // ── Giải thích code ────────────────────────────────────
                GroupBox(label: Label("Cách hoạt động", systemImage: "lightbulb")) {
                    VStack(alignment: .leading, spacing: 6) {
                        codeStep("1", "PhotosPicker hiện UI chọn ảnh (iOS quản lý quyền)")
                        codeStep("2", "selectedItem nhận PhotosPickerItem")
                        codeStep("3", "loadTransferable tải Data bất đồng bộ")
                        codeStep("4", "Chuyển Data → UIImage để xử lý")
                        codeStep("5", "Áp dụng filter với Core Image")
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)

                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .navigationTitle("📸 Chọn Ảnh")
        .navigationBarTitleDisplayMode(.inline)
    }

    // ── Computed: ảnh đã qua xử lý filter ────────────────────────────────
    var processedImage: UIImage? {
        guard let image = selectedImage else { return nil }
        switch selectedFilter {
        case 1: return image.applyGrayscale()
        case 2: return image.applyInvert()
        case 3: return image.applyBrighten()
        default: return image
        }
    }

    // ── Hàm tải ảnh bất đồng bộ ─────────────────────────────────────────
    func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        isLoading = true

        do {
            // loadTransferable: tải dữ liệu ảnh dưới dạng Data
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    withAnimation {
                        selectedImage = uiImage
                    }
                    // Thu thập thông tin ảnh
                    let size = uiImage.size
                    let bytes = data.count
                    imageInfo = """
                    Kích thước: \(Int(size.width)) × \(Int(size.height)) px
                    Dung lượng: \(bytes / 1024) KB
                    Scale: \(uiImage.scale)x
                    """
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
    }

    // Component nhỏ
    func codeStep(_ number: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(Color.orange)
                .clipShape(Circle())
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// ── UIImage Extension: Xử lý ảnh cơ bản ────────────────────────────────────
// Extension: thêm function vào kiểu dữ liệu có sẵn
extension UIImage {

    // Chuyển sang ảnh xám (Grayscale)
    func applyGrayscale() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        let context = CIContext()
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(CIImage(cgImage: cgImage), forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey)  // Saturation = 0 → xám
        guard let output = filter.outputImage,
              let result = context.createCGImage(output, from: output.extent)
        else { return self }
        return UIImage(cgImage: result)
    }

    // Đảo màu (Invert)
    func applyInvert() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        let context = CIContext()
        let filter = CIFilter(name: "CIColorInvert")!
        filter.setValue(CIImage(cgImage: cgImage), forKey: kCIInputImageKey)
        guard let output = filter.outputImage,
              let result = context.createCGImage(output, from: output.extent)
        else { return self }
        return UIImage(cgImage: result)
    }

    // Tăng độ sáng
    func applyBrighten() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        let context = CIContext()
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(CIImage(cgImage: cgImage), forKey: kCIInputImageKey)
        filter.setValue(0.3, forKey: kCIInputBrightnessKey)
        guard let output = filter.outputImage,
              let result = context.createCGImage(output, from: output.extent)
        else { return self }
        return UIImage(cgImage: result)
    }
}

#Preview {
    NavigationStack {
        PhotoPickerView()
    }
}
