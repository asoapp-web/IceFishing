import PhotosUI
import SwiftUI
import UIKit

struct ILNotesScreen: View {
    @Binding var toast: String?
    @EnvironmentObject private var router: ILAppRouter
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent
    @State private var editorNote: ILNote?
    @State private var creating = false

    private var sorted: [ILNote] {
        store.notes.sorted { a, b in
            (ILDateFormatting.date(from: a.createdAt) ?? .distantPast) > (ILDateFormatting.date(from: b.createdAt) ?? .distantPast)
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ILAtmosphereBackground()
            if sorted.isEmpty {
                ILEmptyState(icon: "note.text.badge.plus", message: "No notes yet. Tap + to jot down your first thought.", onDark: true)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sorted) { n in
                            Button {
                                editorNote = n
                            } label: {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(n.text)
                                            .font(.body)
                                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                                            .lineLimit(2)
                                        Text(ILDateFormatting.displayDate(fromISO: n.createdAt))
                                            .font(.caption)
                                            .foregroundStyle(ILTheme.textSecondaryOnDark)
                                    }
                                    Spacer()
                                    if let pid = n.photoId, let ui = ILImageStorageService.loadImage(id: pid, subfolder: "notes") {
                                        Image(uiImage: ui)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 56, height: 56)
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .strokeBorder(accent.light.opacity(0.35), lineWidth: 1)
                                            )
                                    }
                                }
                                .padding(14)
                            }
                            .buttonStyle(.plain)
                            .ilCard()
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 80)
                }
            }
            Button {
                creating = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 54, height: 54)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [accent.light, accent.mid],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: accent.mid.opacity(0.42), radius: 14, y: 6)
            }
            .padding()
        }
        .navigationTitle("Notes")
        .sheet(isPresented: $creating) {
            ILNoteEditorView(mode: .create, toast: $toast)
                .environmentObject(store)
        }
        .sheet(item: $editorNote) { n in
            ILNoteEditorView(mode: .edit(n), toast: $toast)
                .environmentObject(store)
        }
        .ilTracksProfileNavigationDepth(router)
    }
}

enum ILNoteEditorMode: Identifiable {
    case create
    case edit(ILNote)
    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let n): return n.id
        }
    }
}

struct ILNoteEditorView: View {
    let mode: ILNoteEditorMode
    @Binding var toast: String?
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var photoId: String?
    @State private var picked: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showDelete = false
    @State private var showDiscard = false
    @State private var baselineText = ""
    @State private var baselinePhoto: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Write your note…", text: $text, axis: .vertical)
                        .lineLimit(5...12)
                }
                Section {
                    if let pid = photoId, let ui = ILImageStorageService.loadImage(id: pid, subfolder: "notes") {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                    ILPhotoSinglePickerRow(showCamera: $showCamera, picked: $picked)
                    if photoId == nil {
                        Text("No photos attached. Add one from your camera or gallery.")
                            .font(.caption)
                            .foregroundStyle(ILTheme.textMutedOnDark)
                    }
                }
                if case .edit = mode {
                    Section {
                        Button("Delete Note", role: .destructive) { showDelete = true }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(ILTheme.background.ignoresSafeArea())
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("✕") {
                        if hasChanges { showDiscard = true } else { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Note") { save() }
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if case .edit(let n) = mode {
                    text = n.text
                    photoId = n.photoId
                }
                baselineText = text
                baselinePhoto = photoId
            }
            .interactiveDismissDisabled(hasChanges)
            .sheet(isPresented: $showCamera) {
                ILImagePicker(sourceType: .camera) { img in
                    if let img, let id = try? ILImageStorageService.saveJPEG(img, subfolder: "notes") {
                        if let old = photoId { ILImageStorageService.removeFile(id: old, subfolder: "notes") }
                        photoId = id
                    }
                }
            }
            .onChange(of: picked) { _, item in
                Task {
                    if let data = try? await item?.loadTransferable(type: Data.self), let ui = UIImage(data: data),
                       let id = try? ILImageStorageService.saveJPEG(ui, subfolder: "notes") {
                        await MainActor.run {
                            if let old = photoId { ILImageStorageService.removeFile(id: old, subfolder: "notes") }
                            photoId = id
                            picked = nil
                        }
                    }
                }
            }
            .overlay {
                if showDelete {
                    ILConfirmationDialog(
                        title: "Delete this note?",
                        message: "This action cannot be undone.",
                        confirmTitle: "Delete",
                        onConfirm: { showDelete = false; deleteNote() },
                        onCancel: { showDelete = false }
                    )
                }
                if showDiscard {
                    ILConfirmationDialog(
                        title: "Discard changes?",
                        message: "Your edits will be lost.",
                        confirmTitle: "Discard",
                        cancelTitle: "Keep Editing",
                        isDestructive: false,
                        onConfirm: { showDiscard = false; dismiss() },
                        onCancel: { showDiscard = false }
                    )
                }
            }
        }
    }

    private var title: String {
        switch mode {
        case .create: return "New Note"
        case .edit: return "Edit Note"
        }
    }

    private var hasChanges: Bool {
        text != baselineText || photoId != baselinePhoto
    }

    private func save() {
        let now = ILDateFormatting.string(from: Date())
        let body = text.trimmingCharacters(in: .whitespacesAndNewlines)
        switch mode {
        case .create:
            let n = ILNote(id: UUID().uuidString, text: body, photoId: photoId, createdAt: now, updatedAt: now)
            var list = store.notes
            list.append(n)
            store.saveNotes(list)
        case .edit(let n):
            var updated = n
            updated.text = body
            updated.photoId = photoId
            updated.updatedAt = now
            var list = store.notes
            if let i = list.firstIndex(where: { $0.id == updated.id }) {
                list[i] = updated
                store.saveNotes(list)
            }
        }
        toast = "Note saved"
        dismiss()
    }

    private func deleteNote() {
        if case .edit(let n) = mode {
            if let p = n.photoId { ILImageStorageService.removeFile(id: p, subfolder: "notes") }
            store.saveNotes(store.notes.filter { $0.id != n.id })
        }
        dismiss()
    }
}
