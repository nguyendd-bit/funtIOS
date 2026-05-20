//
//  FormDemoView.swift
//  TestProject
//
//  Màn hình Form — Demo các loại input phổ biến trong iOS.
//
//  Kiến thức:
//  1. TextField — ô nhập văn bản
//  2. SecureField — ô nhập mật khẩu (ẩn ký tự)
//  3. Toggle — công tắc bật/tắt
//  4. Stepper — tăng/giảm số
//  5. DatePicker — chọn ngày giờ
//  6. Picker — chọn từ danh sách
//  7. Form + Section — tổ chức giao diện nhập liệu
//  8. Validation — kiểm tra dữ liệu trước khi submit
//

import SwiftUI

struct FormDemoView: View {

    // MARK: - Biến trạng thái cho từng loại input

    // TextField
    @State private var fullName = ""
    @State private var email = ""

    // SecureField
    @State private var password = ""

    // Toggle
    @State private var receiveNotifications = true
    @State private var darkModeEnabled = false

    // Stepper
    @State private var age = 18

    // DatePicker
    @State private var birthday = Date()

    // Picker
    @State private var selectedCity = "Hà Nội"
    @State private var selectedGender = "Nam"
    let cities = ["Hà Nội", "Hồ Chí Minh", "Đà Nẵng", "Huế", "Cần Thơ"]
    let genders = ["Nam", "Nữ", "Khác"]

    // Submit
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            // Form: container đặc biệt cho màn hình nhập liệu
            // Tự động có style giống màn hình Settings của iOS
            Form {

                // ── Section 1: Thông tin cá nhân ──────────────────────
                Section {
                    // TextField: ô nhập văn bản
                    // "Họ và tên" là placeholder (gợi ý)
                    // $fullName: binding — kết nối với biến @State
                    TextField("Họ và tên", text: $fullName)
                        .textContentType(.name)       // Gợi ý AutoFill
                        .autocorrectionDisabled()

                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)  // Hiện bàn phím email
                        .autocapitalization(.none)    // Không tự viết hoa

                    // SecureField: ô nhập mật khẩu (ẩn ký tự thành ●●●)
                    SecureField("Mật khẩu", text: $password)
                        .textContentType(.password)

                } header: {
                    Label("Thông Tin Tài Khoản", systemImage: "person.circle")
                } footer: {
                    Text("Mật khẩu tối thiểu 6 ký tự.")
                }

                // ── Section 2: Thông tin cá nhân ──────────────────────
                Section {
                    // Stepper: tăng/giảm giá trị trong khoảng cho phép
                    // in: 1...100 — giới hạn từ 1 đến 100
                    Stepper("Tuổi: \(age)", value: $age, in: 1...100)

                    // DatePicker: chọn ngày sinh
                    // displayedComponents: .date — chỉ hiện ngày (không giờ)
                    DatePicker(
                        "Ngày sinh",
                        selection: $birthday,
                        in: ...Date(),            // Chỉ chọn đến ngày hôm nay
                        displayedComponents: .date
                    )

                    // Picker dạng menu (dropdown)
                    Picker("Giới tính", selection: $selectedGender) {
                        ForEach(genders, id: \.self) { gender in
                            Text(gender)
                        }
                    }

                } header: {
                    Label("Thông Tin Cá Nhân", systemImage: "person.text.rectangle")
                }

                // ── Section 3: Địa điểm ───────────────────────────────
                Section {
                    // Picker dạng wheel (cuộn)
                    Picker("Thành phố", selection: $selectedCity) {
                        ForEach(cities, id: \.self) { city in
                            Text(city).tag(city)
                        }
                    }
                    .pickerStyle(.wheel)           // Kiểu cuộn như đồng hồ
                    .frame(height: 120)

                } header: {
                    Label("Địa Điểm", systemImage: "mappin.circle")
                }

                // ── Section 4: Tuỳ chọn ───────────────────────────────
                Section {
                    // Toggle: công tắc bật/tắt
                    Toggle("Nhận thông báo", isOn: $receiveNotifications)

                    Toggle("Chế độ tối", isOn: $darkModeEnabled)

                } header: {
                    Label("Tuỳ Chọn", systemImage: "slider.horizontal.3")
                }

                // ── Section 5: Nút Submit ──────────────────────────────
                Section {
                    // Nút Submit — kiểm tra dữ liệu rồi gửi
                    Button {
                        submitForm()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Đăng Ký", systemImage: "checkmark.circle.fill")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.indigo)
                    .foregroundStyle(.white)

                    // Nút Reset
                    Button(role: .destructive) {
                        resetForm()
                    } label: {
                        HStack {
                            Spacer()
                            Label("Xoá tất cả", systemImage: "trash")
                            Spacer()
                        }
                    }
                }
            }

            .navigationTitle("📝 Form")
            // Alert thành công
            .alert("Đăng ký thành công! 🎉", isPresented: $showSuccessAlert) {
                Button("OK") { }
            } message: {
                Text("Xin chào \(fullName)!\nTài khoản của bạn đã được tạo.")
            }
            // Alert lỗi validation
            .alert("Vui lòng kiểm tra lại", isPresented: $showErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // ── Hàm kiểm tra và submit form ───────────────────────────────────────
    private func submitForm() {
        // Validation: kiểm tra dữ liệu trước khi gửi
        if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Vui lòng nhập họ và tên."
            showErrorAlert = true
            return
        }
        if !email.contains("@") || !email.contains(".") {
            errorMessage = "Email không hợp lệ.\nVí dụ: ten@email.com"
            showErrorAlert = true
            return
        }
        if password.count < 6 {
            errorMessage = "Mật khẩu phải có ít nhất 6 ký tự."
            showErrorAlert = true
            return
        }
        // Tất cả hợp lệ — hiện thông báo thành công
        showSuccessAlert = true
    }

    private func resetForm() {
        fullName = ""
        email = ""
        password = ""
        age = 18
        birthday = Date()
        selectedCity = "Hà Nội"
        selectedGender = "Nam"
        receiveNotifications = true
        darkModeEnabled = false
    }
}

#Preview {
    FormDemoView()
}
