//
//  MapKitView.swift
//  TestProject
//
//  Demo MapKit — Bản đồ, Marker, điều hướng (iOS 17+).
//
//  Kiến thức:
//  1. Map { } — hiển thị bản đồ
//  2. MapCameraPosition — điều khiển góc nhìn camera bản đồ
//  3. Marker — ghim địa điểm trên bản đồ
//  4. Annotation — ghim tùy chỉnh (giao diện tự thiết kế)
//  5. .mapStyle — đổi kiểu bản đồ (standard/imagery/hybrid)
//  6. MapReader — đọc thông tin từ bản đồ
//  7. MKLocalSearch — tìm kiếm địa điểm
//

import SwiftUI
import MapKit

// ── Model địa điểm ───────────────────────────────────────────────────────────
struct Landmark: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let emoji: String
    let type: LandmarkType

    enum LandmarkType: Hashable {
        case city, attraction, nature
    }

    static func == (lhs: Landmark, rhs: Landmark) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// ── MapKitView ───────────────────────────────────────────────────────────────
struct MapKitView: View {

    // MapCameraPosition: điều khiển camera bản đồ
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 16.0, longitude: 108.0), // Trung Việt Nam
            span: MKCoordinateSpan(latitudeDelta: 14, longitudeDelta: 8)      // Zoom level
        )
    )

    @State private var selectedLandmark: Landmark? = nil
    @State private var mapStyleIndex = 0
    @State private var showCities = true
    @State private var showAttractions = true
    @State private var showRoute = false

    // Danh sách địa điểm Việt Nam
    let landmarks: [Landmark] = [
        Landmark(name: "Hà Nội", description: "Thủ đô Việt Nam, trung tâm chính trị văn hóa.",
                 coordinate: .init(latitude: 21.0285, longitude: 105.8542), emoji: "🏛️", type: .city),
        Landmark(name: "TP. Hồ Chí Minh", description: "Thành phố lớn nhất VN, trung tâm kinh tế.",
                 coordinate: .init(latitude: 10.7769, longitude: 106.7009), emoji: "🌆", type: .city),
        Landmark(name: "Đà Nẵng", description: "Thành phố đáng sống nhất Việt Nam.",
                 coordinate: .init(latitude: 16.0544, longitude: 108.2022), emoji: "🌉", type: .city),
        Landmark(name: "Cần Thơ", description: "Thủ phủ miền Tây sông nước.",
                 coordinate: .init(latitude: 10.0452, longitude: 105.7469), emoji: "🛶", type: .city),
        Landmark(name: "Vịnh Hạ Long", description: "Di sản thiên nhiên thế giới UNESCO.",
                 coordinate: .init(latitude: 20.9101, longitude: 107.1839), emoji: "⛵", type: .nature),
        Landmark(name: "Phố Cổ Hội An", description: "Di sản văn hóa thế giới UNESCO.",
                 coordinate: .init(latitude: 15.8801, longitude: 108.3380), emoji: "🏮", type: .attraction),
        Landmark(name: "Sapa", description: "Thiên đường mây mù và ruộng bậc thang.",
                 coordinate: .init(latitude: 22.3364, longitude: 103.8438), emoji: "⛰️", type: .nature),
        Landmark(name: "Phú Quốc", description: "Hòn đảo thiên đường biển xanh.",
                 coordinate: .init(latitude: 10.2899, longitude: 103.9840), emoji: "🏝️", type: .nature),
        Landmark(name: "Mũi Né", description: "Thiên đường dù lượn và bãi biển.",
                 coordinate: .init(latitude: 10.9330, longitude: 108.2874), emoji: "🏄", type: .attraction),
        Landmark(name: "Đà Lạt", description: "Thành phố ngàn hoa, khí hậu mát mẻ.",
                 coordinate: .init(latitude: 11.9404, longitude: 108.4583), emoji: "🌸", type: .city),
    ]

    // Lọc theo loại
    var visibleLandmarks: [Landmark] {
        landmarks.filter { landmark in
            switch landmark.type {
            case .city: return showCities
            case .attraction, .nature: return showAttractions
            }
        }
    }

    // Kiểu bản đồ theo index
    var currentMapStyle: MapStyle {
        switch mapStyleIndex {
        case 1: return .imagery(elevation: .realistic)
        case 2: return .hybrid(elevation: .realistic)
        default: return .standard(elevation: .realistic)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            mapLayer
            bottomPanel
        }
        .navigationTitle("🗺️ MapKit")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var mapLayer: some View {
        // ── Bản đồ chính ───────────────────────────────────────────
        Map(position: $cameraPosition, selection: $selectedLandmark) {
            ForEach(visibleLandmarks) { landmark in
                // Annotation: ghim tùy chỉnh với giao diện riêng
                Annotation(landmark.name, coordinate: landmark.coordinate) {
                    ZStack {
                        Circle()
                            .fill(annotationColor(for: landmark.type))
                            .frame(width: 40, height: 40)
                            .shadow(radius: 4)
                        Text(landmark.emoji)
                            .font(.title3)
                    }
                    .scaleEffect(selectedLandmark?.id == landmark.id ? 1.3 : 1.0)
                    .animation(.spring(), value: selectedLandmark?.id)
                }
                .tag(landmark)
            }

            // UserAnnotation: vị trí người dùng (cần quyền location)
            UserAnnotation()
        }
        .mapStyle(currentMapStyle)
        // Controls trên bản đồ
        .mapControls {
            MapScaleView()          // Thước đo khoảng cách
            MapCompass()            // La bàn
            MapPitchToggle()        // Chuyển 2D/3D
            MapUserLocationButton() // Nút đến vị trí người dùng
        }
        .frame(maxHeight: .infinity)
    }

    @ViewBuilder
    private var bottomPanel: some View {
        // ── Panel dưới ────────────────────────────────────────────
        VStack(spacing: 0) {
            // Thông tin địa điểm được chọn
            if let selected = selectedLandmark {
                HStack(spacing: 12) {
                    Text(selected.emoji)
                        .font(.largeTitle)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selected.name)
                            .fontWeight(.bold)
                        Text(selected.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    Button {
                        // Di chuyển camera đến địa điểm
                        withAnimation {
                            cameraPosition = .region(MKCoordinateRegion(
                                center: selected.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                            ))
                        }
                    } label: {
                        Image(systemName: "location.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                Divider()
            }

            // Controls
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {

                    // Bộ lọc loại địa điểm
                    FilterChip("🏙️ Thành phố", isOn: $showCities, color: .blue)
                    FilterChip("🌿 Thắng cảnh", isOn: $showAttractions, color: .green)

                    Divider().frame(height: 30)

                    // Chọn kiểu bản đồ
                    ForEach(["Bình thường", "Vệ tinh", "Hybrid"].indices, id: \.self) { i in
                        Button(["Bình thường", "Vệ tinh", "Hybrid"][i]) {
                            mapStyleIndex = i
                        }
                        .buttonStyle(.bordered)
                        .tint(mapStyleIndex == i ? .indigo : .secondary)
                        .font(.caption)
                    }

                    Divider().frame(height: 30)

                    // Nút zoom về toàn VN
                    Button {
                        withAnimation {
                            cameraPosition = .region(MKCoordinateRegion(
                                center: .init(latitude: 16.0, longitude: 108.0),
                                span: .init(latitudeDelta: 14, longitudeDelta: 8)
                            ))
                            selectedLandmark = nil
                        }
                    } label: {
                        Label("Toàn VN", systemImage: "map")
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .background(Color(.systemBackground))
        }
    }

    func annotationColor(for type: Landmark.LandmarkType) -> Color {
        switch type {
        case .city: return .blue
        case .attraction: return .orange
        case .nature: return .green
        }
    }
}

// ── FilterChip: Toggle chip nhỏ ─────────────────────────────────────────────
struct FilterChip: View {
    let title: String
    @Binding var isOn: Bool
    let color: Color

    init(_ title: String, isOn: Binding<Bool>, color: Color) {
        self.title = title
        self._isOn = isOn
        self.color = color
    }

    var body: some View {
        Button { isOn.toggle() } label: {
            Text(title)
                .font(.caption)
                .fontWeight(isOn ? .semibold : .regular)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(isOn ? color.opacity(0.15) : Color(.systemGray5))
                .foregroundStyle(isOn ? color : .secondary)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isOn ? color : Color.clear, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { MapKitView() }
}
