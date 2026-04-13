import MapKit
import PhotosUI
import SwiftUI

struct ILSpotEditorView: View {
    let draft: ILSpotEditorDraft
    @Binding var toast: String?
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var date = Date()
    @State private var notes: String = ""
    @State private var speciesId: String?
    @State private var photoIds: [String] = []
    @State private var lat: Double = 0
    @State private var lon: Double = 0
    @State private var showDeleteConfirm = false
    @State private var showDiscardConfirm = false
    @State private var pickedItems: [PhotosPickerItem] = []
    @State private var showCamera = false
    @State private var baseline: Snapshot?

    private let content = ILBundleContentService.shared

    private struct Snapshot: Equatable {
        let name: String
        let notes: String
        let speciesId: String?
        let photoIds: [String]
        let date: Date
        let lat: Double
        let lon: Double
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Spot") {
                    TextField("Spot name", text: $name)
                        .textInputAutocapitalization(.words)
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                    Text("Latitude \(lat, format: .number.precision(.fractionLength(5)))")
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                    Text("Longitude \(lon, format: .number.precision(.fractionLength(5)))")
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section("Notes") {
                    TextField("Add notes about this spot…", text: $notes, axis: .vertical)
                        .lineLimit(3...8)
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                }
                Section("Species") {
                    Picker("Linked species", selection: Binding(
                        get: { speciesId ?? "" },
                        set: { speciesId = $0.isEmpty ? nil : $0 }
                    )) {
                        Text("None").tag("" as String)
                        ForEach(content.species.sorted { $0.commonName < $1.commonName }) { sp in
                            Text(sp.commonName).tag(sp.id)
                        }
                    }
                }
                Section("Photos") {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(photoIds, id: \.self) { pid in
                                if let ui = ILImageStorageService.loadImage(id: pid, subfolder: "spots") {
                                    Image(uiImage: ui)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 72, height: 72)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    ILPhotoSourceRow(
                        showCamera: $showCamera,
                        pickedItems: $pickedItems,
                        maxGalleryItems: max(0, 5 - photoIds.count)
                    )
                    if photoIds.isEmpty {
                        Text("No photos attached. Add one from your camera or gallery.")
                            .font(.caption)
                            .foregroundStyle(ILTheme.textMutedOnDark)
                    }
                }
                if draft.existing != nil {
                    Section {
                        Button("Delete Spot", role: .destructive) {
                            showDeleteConfirm = true
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(ILTheme.background.ignoresSafeArea())
            .navigationTitle(draft.existing == nil ? "New Spot" : "Edit Spot")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("✕") {
                        if hasChanges { showDiscardConfirm = true } else { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Spot") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let e = draft.existing {
                    name = e.name
                    notes = e.notes ?? ""
                    speciesId = e.speciesId
                    photoIds = e.photoIds
                    lat = e.latitude
                    lon = e.longitude
                    if let d = ILDateFormatting.date(from: e.date) { date = d }
                } else {
                    lat = draft.latitude
                    lon = draft.longitude
                }
                baseline = Snapshot(
                    name: name,
                    notes: notes,
                    speciesId: speciesId,
                    photoIds: photoIds,
                    date: date,
                    lat: lat,
                    lon: lon
                )
            }
            .interactiveDismissDisabled(hasChanges)
            .onChange(of: pickedItems) { _, items in
                Task { await loadPicked(items) }
            }
            .sheet(isPresented: $showCamera) {
                ILImagePicker(sourceType: .camera) { img in
                    if let img { addPhoto(img, data: nil) }
                }
            }
            .overlay {
                if showDeleteConfirm {
                    ILConfirmationDialog(
                        title: "Delete this spot?",
                        message: "This action cannot be undone.",
                        confirmTitle: "Delete",
                        onConfirm: {
                            showDeleteConfirm = false
                            deleteSpot()
                        },
                        onCancel: { showDeleteConfirm = false }
                    )
                }
                if showDiscardConfirm {
                    ILConfirmationDialog(
                        title: "Discard changes?",
                        message: "Your edits will be lost.",
                        confirmTitle: "Discard",
                        cancelTitle: "Keep Editing",
                        onConfirm: {
                            showDiscardConfirm = false
                            dismiss()
                        },
                        onCancel: { showDiscardConfirm = false }
                    )
                }
            }
        }
    }

    private var hasChanges: Bool {
        guard let b = baseline else { return false }
        return Snapshot(
            name: name,
            notes: notes,
            speciesId: speciesId,
            photoIds: photoIds,
            date: date,
            lat: lat,
            lon: lon
        ) != b
    }

    private func loadPicked(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                if let ui = UIImage(data: data) {
                    await MainActor.run {
                        addPhoto(ui, data: data)
                    }
                }
            }
        }
        await MainActor.run { pickedItems.removeAll() }
    }

    private func addPhoto(_ image: UIImage, data: Data?) {
        guard photoIds.count < 5 else { return }
        do {
            let id = try ILImageStorageService.saveJPEG(image, subfolder: "spots")
            photoIds.append(id)
        } catch {}
    }

    private func save() {
        let now = ILDateFormatting.string(from: Date())
        let dateStr = ILDateFormatting.string(from: date)
        if var e = draft.existing {
            e.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            e.latitude = lat
            e.longitude = lon
            e.date = dateStr
            e.notes = notes.isEmpty ? nil : notes
            e.speciesId = speciesId
            e.photoIds = photoIds
            e.updatedAt = now
            var list = store.spots
            if let idx = list.firstIndex(where: { $0.id == e.id }) {
                list[idx] = e
                store.saveSpots(list)
            }
        } else {
            let sp = ILSpot(
                id: UUID().uuidString,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                latitude: lat,
                longitude: lon,
                date: dateStr,
                notes: notes.isEmpty ? nil : notes,
                speciesId: speciesId,
                photoIds: photoIds,
                createdAt: now,
                updatedAt: now
            )
            var list = store.spots
            list.append(sp)
            store.saveSpots(list)
        }
        toast = "Spot saved"
        ILHaptics.success()
        dismiss()
    }

    private func deleteSpot() {
        guard let e = draft.existing else { return }
        for pid in e.photoIds {
            ILImageStorageService.removeFile(id: pid, subfolder: "spots")
        }
        store.saveSpots(store.spots.filter { $0.id != e.id })
        toast = "Spot deleted"
        dismiss()
    }
}
