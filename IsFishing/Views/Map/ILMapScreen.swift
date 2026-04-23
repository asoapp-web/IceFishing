import MapKit
import SwiftUI

struct ILMapScreen: View {
    @Binding var toast: String?
    @EnvironmentObject private var router: ILAppRouter
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45, longitude: -95),
        span: MKCoordinateSpan(latitudeDelta: 35, longitudeDelta: 45)
    )
    @State private var mapType: MKMapType = .standard
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var showSearchPanel = false
    @State private var showSearchFailure = false
    @State private var spotDraft: ILSpotEditorDraft?
    @State private var spotForDetail: ILSpot?
    @State private var selectedSpotId: String?
    @FocusState private var searchFocused: Bool

    private let content = ILBundleContentService.shared

    var body: some View {
        ZStack(alignment: .top) {
            mapLayer
            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                searchDropdown
            }
            floatingControls
            if store.spots.isEmpty {
                emptyHint
            }
        }
        .onAppear { restoreRegion() }
        .onChange(of: region.center.latitude)    { _, _ in persistRegion() }
        .onChange(of: region.span.latitudeDelta) { _, _ in persistRegion() }
        .sheet(item: $spotDraft) { draft in
            ILSpotEditorView(draft: draft, toast: $toast)
                .environmentObject(store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $spotForDetail, onDismiss: {
            selectedSpotId = nil
            updateMapChrome()
        }) { sp in
            ILSpotDetailSheet(
                spot: sp,
                onEdit: {
                    spotForDetail = nil
                    spotDraft = .edit(sp)
                },
                onDismiss: {
                    spotForDetail = nil
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: selectedSpotId) { _, sid in
            if let sid, let sp = store.spots.first(where: { $0.id == sid }) {
                spotForDetail = sp
            } else {
                spotForDetail = nil
            }
        }
        .onChange(of: spotDraft != nil) { _, vis in
            updateMapChrome()
            if vis { selectedSpotId = nil }
        }
        .onChange(of: spotForDetail != nil) { _, _ in
            updateMapChrome()
        }
        .alert("Search Unavailable", isPresented: $showSearchFailure) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Search requires an internet connection. You can still place spots by long-pressing the map.")
        }
    }

    private func updateMapChrome() {
        router.tabBarHidden = spotDraft != nil || spotForDetail != nil
    }

    

    private var mapLayer: some View {
        ILMapViewRepresentable(
            region: $region,
            selectedSpotId: $selectedSpotId,
            mapType: mapType,
            showUserLocation: false,
            spots: store.spots,
            speciesName: { id in content.species(by: id)?.commonName },
            onLongPress: { coord in
                selectedSpotId = nil
                spotDraft = .new(lat: coord.latitude, lon: coord.longitude)
            }
        )
        .ignoresSafeArea()
    }

    

    private var topBar: some View {
        HStack(spacing: 10) {
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(searchFocused ? accent.light : ILTheme.textMutedOnDark)

                TextField("", text: $searchText, prompt: Text("Search places…").foregroundStyle(ILTheme.iceLight.opacity(0.72)))
                    .textFieldStyle(.plain)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(ILTheme.textPrimaryOnDark)
                    .tint(accent.light)
                    .focused($searchFocused)
                    .onSubmit { runSearch() }
                    .onChange(of: searchText) { _, v in
                        if v.isEmpty { searchResults = [] }
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchResults = []
                        searchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(ILTheme.textMutedOnDark)
                    }
                    .buttonStyle(.plain)
                }

                if isSearching {
                    ProgressView()
                        .scaleEffect(0.75)
                        .tint(accent.light)
                }
            }
            .ilFrostSearchFieldChrome(focused: searchFocused)

            
            if !searchFocused {
                HStack(spacing: 5) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12, weight: .semibold))
                    Text("\(store.spots.count)")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                }
                .foregroundStyle(accent.light)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(ILTheme.backgroundElevated.opacity(0.94))
                        .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(ILTheme.divider, lineWidth: 1)
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: searchFocused)
    }

    

    @ViewBuilder
    private var searchDropdown: some View {
        if !searchResults.isEmpty {
            VStack(spacing: 0) {
                ForEach(Array(searchResults.prefix(6).enumerated()), id: \.offset) { idx, item in
                    Button {
                        ILHaptics.light()
                        selectSearch(item)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(accent.light)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name ?? "Place")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(Color.white)
                                    .lineLimit(1)
                                if let addr = item.placemark.title, addr != item.name {
                                    Text(addr)
                                        .font(.caption)
                                        .foregroundStyle(ILTheme.tabBarLabelInactive)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(ILTheme.textMutedOnDark)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                    }
                    .buttonStyle(ILPressScaleButtonStyle(scale: 0.99))
                    .ilStaggeredAppear(index: idx, baseDelay: 0.03)
                    if idx < min(searchResults.count, 6) - 1 {
                        Divider()
                            .background(ILTheme.divider)
                            .padding(.leading, 44)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(ILTheme.backgroundElevated.opacity(0.96))
                    .shadow(color: .black.opacity(0.40), radius: 14, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(ILTheme.divider, lineWidth: 1)
            )
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeOut(duration: 0.2), value: searchResults.count)
        }
    }

    

    private var floatingControls: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    
                    mapActionButton(icon: "plus") { zoom(factor: 0.5) }
                    
                    mapActionButton(icon: "minus") { zoom(factor: 2.0) }
                    
                    mapActionButton(icon: mapType == .standard ? "globe.europe.africa" : "map") {
                        withAnimation { mapType = mapType == .standard ? .hybrid : .standard }
                    }
                }
                .padding(.trailing, 14)
                .padding(.bottom, ILLayout.tabBarClearance + 8)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .padding(.top, 130)
    }

    private func mapActionButton(icon: String, active: Bool = false, action: @escaping () -> Void) -> some View {
        Button {
            ILHaptics.light()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(
                    Circle()
                        .fill(ILTheme.backgroundElevated.opacity(0.92))
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    active ? accent.light.opacity(0.85) : Color.white.opacity(0.35),
                                    lineWidth: active ? 2 : 1.25
                                )
                        )
                )
                .shadow(color: .black.opacity(0.45), radius: 8, y: 3)
        }
        .ilPressScaleButton(0.93)
    }

    

    private var emptyHint: some View {
        VStack {
            Spacer()
            ILMapLongPressHint()
                .padding(.bottom, ILLayout.tabBarClearance + 24)
        }
        .allowsHitTesting(false)
    }

    

    private func zoom(factor: Double) {
        var s = region.span
        s.latitudeDelta  = min(max(s.latitudeDelta  * factor, 0.005), 60)
        s.longitudeDelta = min(max(s.longitudeDelta * factor, 0.005), 60)
        region = MKCoordinateRegion(center: region.center, span: s)
    }

    private func runSearch() {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { searchResults = []; return }
        isSearching = true
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = q
        req.region = region
        MKLocalSearch(request: req).start { resp, err in
            isSearching = false
            if err != nil { showSearchFailure = true; return }
            withAnimation { searchResults = resp?.mapItems ?? [] }
        }
    }

    private func selectSearch(_ item: MKMapItem) {
        let c = item.placemark.coordinate
        withAnimation {
            region = MKCoordinateRegion(
                center: c,
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
        }
        searchResults = []
        searchText = ""
        searchFocused = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            spotDraft = .new(lat: c.latitude, lon: c.longitude)
        }
    }

    private func restoreRegion() {
        if let r = store.mapRegion {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: r.centerLatitude, longitude: r.centerLongitude),
                span: MKCoordinateSpan(latitudeDelta: r.spanLatitudeDelta, longitudeDelta: r.spanLongitudeDelta)
            )
        }
    }

    private func persistRegion() {
        let r = ILMapStoredRegion(
            centerLatitude: region.center.latitude,
            centerLongitude: region.center.longitude,
            spanLatitudeDelta: region.span.latitudeDelta,
            spanLongitudeDelta: region.span.longitudeDelta
        )
        store.saveMapRegion(r)
    }
}



struct ILSpotEditorDraft: Identifiable {
    let id = UUID()
    var existing: ILSpot?
    var latitude: Double
    var longitude: Double

    static func new(lat: Double, lon: Double) -> ILSpotEditorDraft {
        ILSpotEditorDraft(existing: nil, latitude: lat, longitude: lon)
    }

    static func edit(_ sp: ILSpot) -> ILSpotEditorDraft {
        ILSpotEditorDraft(existing: sp, latitude: sp.latitude, longitude: sp.longitude)
    }
}
