import Combine
import PhotosUI
import SwiftUI

enum ILSessionEditorMode: Identifiable {
    case create
    case edit(ILSession)

    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let s): return s.id
        }
    }
}

struct ILSessionEditorView: View {
    let mode: ILSessionEditorMode
    @Binding var toast: String?
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var durationMinutes: Int?
    @State private var durationMode: DurationMode = .manual
    @State private var manualHours = 0
    @State private var manualMins = 0
    @State private var timerRunning = false
    @State private var timerStart: Date?
    @State private var timerAccumulated: TimeInterval = 0
    @State private var timerTicker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var comment = ""
    @State private var spotId: String?
    @State private var catches: [ILCatchEntry] = []
    @State private var photoIds: [String] = []
    @State private var pickedItems: [PhotosPickerItem] = []
    @State private var showCamera = false
    @State private var showSpotPicker = false
    @State private var showTimerSwitchConfirm = false
    @State private var showDelete = false
    @State private var showDiscard = false
    @State private var showDateSheet = false
    @State private var baseline: Data?

    private let content = ILBundleContentService.shared

    private enum DurationMode: String, CaseIterable {
        case timer = "Timer"
        case manual = "Manual"
    }

    private static let sizeOptions: [(id: String, label: String)] = [
        ("small", "Small"), ("medium", "Medium"), ("large", "Large"), ("trophy", "Trophy"),
    ]

    var body: some View {
        ZStack {
            ILTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                chromeHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        basicCard
                        spotCard
                        catchLogCard
                        photosCard
                        if case .edit = mode {
                            deleteBlock
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 36)
                }
            }

            overlayDialogs
        }
        .navigationBarHidden(true)
        .onAppear(perform: load)
        .interactiveDismissDisabled(hasChanges)
        .onReceive(timerTicker) { _ in
            _ = currentTimerSeconds
        }
        .onChange(of: pickedItems) { _, items in
            Task { await loadPhotos(items) }
        }
        .sheet(isPresented: $showCamera) {
            ILImagePicker(sourceType: .camera) { img in
                if let img { addPhoto(img) }
            }
        }
        .sheet(isPresented: $showSpotPicker) {
            ILSpotPickerSheet(selectedSpotId: $spotId)
                .environmentObject(store)
        }
        .sheet(isPresented: $showDateSheet) {
            datePickSheet
        }
    }

    private var chromeHeader: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                Button {
                    if hasChanges { showDiscard = true } else { dismiss() }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                        .frame(width: 40, height: 40)
                        .background(ILTheme.backgroundTertiary)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(ILTheme.divider, lineWidth: 1))
                }
                .buttonStyle(.plain)

                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(ILTheme.textPrimaryOnDark)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)

                Button(action: save) {
                    Text("Save")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(ILGradient.accentPrimary(accent))
                        .clipShape(Capsule())
                        .shadow(color: accent.mid.opacity(0.35), radius: 8, y: 3)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)

            Rectangle()
                .fill(ILTheme.divider.opacity(0.85))
                .frame(height: 1)
        }
        .background(ILTheme.background.opacity(0.98))
    }

    private var basicCard: some View {
        editorCard(title: "Trip", icon: "calendar") {
            Button {
                showDateSheet = true
            } label: {
                HStack {
                    Text("Date")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                    Spacer()
                    Text(ILDateFormatting.displayDate(fromISO: ILDateFormatting.string(from: date)))
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(accent.light)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(ILTheme.textMutedOnDark)
                }
                .padding(14)
                .background(ILTheme.backgroundTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            Text("Duration")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(ILTheme.textMutedOnDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)

            durationModePicker
                .onChange(of: durationMode) { _, new in
                    if new == .manual && (timerRunning || timerAccumulated > 0 || timerStart != nil) {
                        showTimerSwitchConfirm = true
                    }
                }

            if durationMode == .timer {
                timerBlock
            } else {
                manualDurationBlock
            }

            Text("Notes")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(ILTheme.textMutedOnDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 6)

            TextField("", text: $comment, axis: .vertical)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
                .lineLimit(3...10)
                .padding(14)
                .background(ILTheme.backgroundTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if comment.isEmpty {
                        Text("How was the trip?")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(ILTheme.textMutedOnDark)
                            .padding(14)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    private var durationModePicker: some View {
        HStack(spacing: 4) {
            ForEach(DurationMode.allCases, id: \.self) { m in
                Button {
                    durationMode = m
                } label: {
                    Text(m.rawValue)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(durationMode == m ? ILTheme.textPrimaryOnDark : ILTheme.textSecondaryOnDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(
                            Group {
                                if durationMode == m {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(ILTheme.backgroundElevated)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(accent.light.opacity(0.45), lineWidth: 1)
                                        )
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(ILTheme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var timerBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Button(action: toggleTimer) {
                    Label(timerRunning ? "Pause" : "Start", systemImage: timerRunning ? "pause.fill" : "play.fill")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(accent.light)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ILTheme.backgroundTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(accent.mid.opacity(0.35), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Button(action: stopTimer) {
                    Text("Stop")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ILTheme.backgroundTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(ILTheme.divider, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!timerRunning && timerAccumulated == 0 && timerStart == nil)
                .opacity((!timerRunning && timerAccumulated == 0 && timerStart == nil) ? 0.45 : 1)
            }

            HStack(spacing: 8) {
                Image(systemName: "stopwatch")
                    .foregroundStyle(ILTheme.amber)
                Text("Elapsed \(Int(currentTimerSeconds / 60)) min")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(ILTheme.textSecondaryOnDark)
            }
            .padding(.horizontal, 4)
        }
        .padding(.top, 4)
    }

    private var manualDurationBlock: some View {
        HStack(spacing: 12) {
            durationStepperCard(title: "Hours", value: $manualHours, range: 0 ..< 24)
            durationStepperCard(title: "Minutes", value: $manualMins, range: 0 ..< 60)
        }
        .padding(.top, 4)
    }

    private func durationStepperCard(title: String, value: Binding<Int>, range: Range<Int>) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(ILTheme.textMutedOnDark)
            HStack(spacing: 0) {
                Button {
                    if value.wrappedValue > range.lowerBound { value.wrappedValue -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(accent.light)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .disabled(value.wrappedValue <= range.lowerBound)
                .opacity(value.wrappedValue <= range.lowerBound ? 0.35 : 1)

                Text("\(value.wrappedValue)")
                    .font(.system(.title2, design: .rounded, weight: .bold).monospacedDigit())
                    .foregroundStyle(ILTheme.textPrimaryOnDark)
                    .frame(minWidth: 44)

                Button {
                    if value.wrappedValue < range.upperBound - 1 { value.wrappedValue += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(accent.light)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .disabled(value.wrappedValue >= range.upperBound - 1)
                .opacity(value.wrappedValue >= range.upperBound - 1 ? 0.35 : 1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(ILTheme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(ILTheme.divider, lineWidth: 1)
        )
    }

    private var spotCard: some View {
        editorCard(title: "Spot", icon: "mappin.and.ellipse") {
            if let sid = spotId, let sp = store.spots.first(where: { $0.id == sid }) {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(accent.dark.opacity(0.35))
                            .frame(width: 44, height: 44)
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(accent.light)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Linked")
                            .font(.system(.caption2, design: .rounded, weight: .semibold))
                            .foregroundStyle(ILTheme.textMutedOnDark)
                        Text(sp.name)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 8)
                    Button("Unlink") { spotId = nil }
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(ILTheme.amber)
                        .buttonStyle(.plain)
                }
                .padding(14)
                .background(ILTheme.backgroundTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                Button {
                    showSpotPicker = true
                } label: {
                    HStack {
                        Image(systemName: "link.circle.fill")
                            .font(.title3)
                            .foregroundStyle(accent.light)
                        Text("Link a spot from your map")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(ILTheme.textMutedOnDark)
                    }
                    .padding(14)
                    .background(ILTheme.backgroundTertiary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(accent.light.opacity(0.25), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var catchLogCard: some View {
        editorCard(title: "Catch log", icon: "fish.fill") {
            if catches.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "fish")
                        .font(.system(size: 28))
                        .foregroundStyle(ILTheme.textMutedOnDark)
                    Text("No entries yet")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(ILTheme.backgroundTertiary.opacity(0.65))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            ForEach($catches) { $entry in
                catchEntryBlock($entry)
            }

            Button(action: addCatch) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(accent.light)
                    Text("Add catch")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(accent.light)
                    Spacer()
                }
                .padding(14)
                .background(ILTheme.backgroundTertiary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(accent.light.opacity(0.35), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func catchEntryBlock(_ binding: Binding<ILCatchEntry>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Species")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(ILTheme.textMutedOnDark)
                Spacer()
                Menu {
                    Button("Custom name") {
                        binding.wrappedValue.speciesId = nil
                    }
                    Divider()
                    ForEach(content.species.sorted { $0.commonName < $1.commonName }) { sp in
                        Button(sp.commonName) {
                            binding.wrappedValue.speciesId = sp.id
                            binding.wrappedValue.customSpeciesName = nil
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(speciesLabel(for: binding.wrappedValue))
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(accent.light)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(ILTheme.textMutedOnDark)
                    }
                }
            }

            if binding.wrappedValue.speciesId == nil {
                TextField("Custom species", text: Binding(
                    get: { binding.wrappedValue.customSpeciesName ?? "" },
                    set: { binding.wrappedValue.customSpeciesName = $0.isEmpty ? nil : $0 }
                ))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
                .padding(12)
                .background(ILTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(ILTheme.divider, lineWidth: 1)
                )
            }

            HStack {
                Text("Quantity")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(ILTheme.textMutedOnDark)
                Spacer()
                HStack(spacing: 0) {
                    Button {
                        if binding.wrappedValue.quantity > 1 { binding.wrappedValue.quantity -= 1 }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(accent.light)
                            .frame(width: 36, height: 36)
                            .background(ILTheme.background)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(binding.wrappedValue.quantity <= 1)

                    Text("\(binding.wrappedValue.quantity)")
                        .font(.system(.headline, design: .rounded, weight: .bold).monospacedDigit())
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                        .frame(minWidth: 40)

                    Button {
                        if binding.wrappedValue.quantity < 99 { binding.wrappedValue.quantity += 1 }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(accent.light)
                            .frame(width: 36, height: 36)
                            .background(ILTheme.background)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(binding.wrappedValue.quantity >= 99)
                }
                .padding(4)
                .background(ILTheme.backgroundTertiary)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(ILTheme.divider, lineWidth: 1))
            }

            HStack {
                Text("Size")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(ILTheme.textMutedOnDark)
                Spacer()
                Menu {
                    Button("Clear") {
                        binding.wrappedValue.sizeEstimate = nil
                    }
                    Divider()
                    ForEach(Self.sizeOptions, id: \.id) { opt in
                        Button(opt.label) {
                            binding.wrappedValue.sizeEstimate = opt.id
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(sizeLabel(binding.wrappedValue.sizeEstimate))
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(ILTheme.textMutedOnDark)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Note")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(ILTheme.textMutedOnDark)
                TextField("", text: Binding(
                    get: { binding.wrappedValue.note ?? "" },
                    set: { binding.wrappedValue.note = $0.isEmpty ? nil : $0 }
                ))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
                .padding(12)
                .background(ILTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(ILTheme.divider, lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if (binding.wrappedValue.note ?? "").isEmpty {
                        Text("Optional")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(ILTheme.textMutedOnDark)
                            .padding(12)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
        .padding(14)
        .background(ILTheme.backgroundElevated.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [accent.light.opacity(0.22), ILTheme.divider],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private func speciesLabel(for e: ILCatchEntry) -> String {
        if let sid = e.speciesId, let sp = content.species.first(where: { $0.id == sid }) {
            return sp.commonName
        }
        if let c = e.customSpeciesName, !c.isEmpty { return c }
        return "Choose species"
    }

    private func sizeLabel(_ raw: String?) -> String {
        guard let raw else { return "Optional" }
        return Self.sizeOptions.first { $0.id == raw }?.label ?? raw.capitalized
    }

    private var photosCard: some View {
        editorCard(title: "Photos", icon: "photo.on.rectangle.angled") {
            if !photoIds.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(photoIds, id: \.self) { pid in
                            if let ui = ILImageStorageService.loadImage(id: pid, subfolder: "sessions") {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 76, height: 76)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(accent.light.opacity(0.25), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
            }
            ILPhotoSourceRow(
                showCamera: $showCamera,
                pickedItems: $pickedItems,
                maxGalleryItems: max(0, 10 - photoIds.count)
            )
        }
    }

    private var deleteBlock: some View {
        Button(role: .destructive) {
            showDelete = true
        } label: {
            Text("Delete session")
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(ILTheme.tertiaryRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(ILTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(ILTheme.tertiaryRed.opacity(0.35), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var datePickSheet: some View {
        NavigationStack {
            ZStack {
                ILTheme.background.ignoresSafeArea()
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(accent.light)
                    .padding()
                    .foregroundStyle(ILTheme.textPrimaryOnDark)
            }
            .navigationTitle("Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showDateSheet = false }
                        .fontWeight(.semibold)
                        .foregroundStyle(accent.light)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func editorCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(accent.light)
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(ILTheme.textPrimaryOnDark)
                Spacer()
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ILTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [accent.light.opacity(0.18), ILTheme.divider],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    @ViewBuilder
    private var overlayDialogs: some View {
        if showDelete {
            ILConfirmationDialog(
                title: "Delete this session and all its data?",
                message: "This cannot be undone.",
                confirmTitle: "Delete",
                onConfirm: { showDelete = false; deleteSession() },
                onCancel: { showDelete = false }
            )
        }
        if showDiscard {
            ILConfirmationDialog(
                title: "Discard changes?",
                message: "Your edits will be lost.",
                confirmTitle: "Discard",
                cancelTitle: "Keep Editing",
                onConfirm: { showDiscard = false; dismiss() },
                onCancel: { showDiscard = false }
            )
        }
        if showTimerSwitchConfirm {
            ILConfirmationDialog(
                title: "Stop timer?",
                message: "Stop timer and switch to manual input?",
                confirmTitle: "Stop",
                cancelTitle: "Cancel",
                onConfirm: {
                    showTimerSwitchConfirm = false
                    stopTimer()
                    durationMode = .manual
                },
                onCancel: {
                    showTimerSwitchConfirm = false
                    if durationMode == .manual { durationMode = .timer }
                }
            )
        }
    }

    private var title: String {
        switch mode {
        case .create: return "New Session"
        case .edit: return "Edit Session"
        }
    }

    private var currentTimerSeconds: TimeInterval {
        var t = timerAccumulated
        if timerRunning, let s = timerStart {
            t += Date().timeIntervalSince(s)
        }
        return t
    }

    private func toggleTimer() {
        if timerRunning {
            if let s = timerStart {
                timerAccumulated += Date().timeIntervalSince(s)
            }
            timerStart = nil
            timerRunning = false
        } else {
            timerStart = Date()
            timerRunning = true
        }
    }

    private func stopTimer() {
        if timerRunning, let s = timerStart {
            timerAccumulated += Date().timeIntervalSince(s)
        }
        timerStart = nil
        timerRunning = false
        durationMinutes = max(1, Int(timerAccumulated / 60))
    }

    private func load() {
        if case .edit(let s) = mode {
            if let d = ILDateFormatting.date(from: s.date) { date = d }
            durationMinutes = s.durationMinutes
            if let m = s.durationMinutes {
                manualHours = m / 60
                manualMins = m % 60
            }
            comment = s.comment ?? ""
            spotId = s.spotId
            catches = s.catchEntries
            photoIds = s.photoIds
        }
        baseline = snapshotData()
    }

    private func snapshotData() -> Data? {
        try? JSONEncoder().encode(
            ILSession(
                id: "snap",
                date: ILDateFormatting.string(from: date),
                durationMinutes: resolvedDuration(),
                comment: comment.isEmpty ? nil : comment,
                spotId: spotId,
                catchEntries: catches,
                photoIds: photoIds,
                createdAt: "",
                updatedAt: ""
            )
        )
    }

    private var hasChanges: Bool {
        guard let baseline else { return false }
        return snapshotData() != baseline
    }

    private func resolvedDuration() -> Int? {
        if durationMode == .manual {
            let m = manualHours * 60 + manualMins
            return m > 0 ? m : nil
        }
        let sec = currentTimerSeconds
        return sec > 0 ? max(1, Int(sec / 60)) : durationMinutes
    }

    private func addCatch() {
        catches.append(ILCatchEntry(
            id: UUID().uuidString,
            speciesId: nil,
            customSpeciesName: nil,
            quantity: 1,
            sizeEstimate: nil,
            note: nil
        ))
    }

    private func loadPhotos(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self), let ui = UIImage(data: data) {
                await MainActor.run { addPhoto(ui) }
            }
        }
        await MainActor.run { pickedItems.removeAll() }
    }

    private func addPhoto(_ image: UIImage) {
        guard photoIds.count < 10 else { return }
        if let id = try? ILImageStorageService.saveJPEG(image, subfolder: "sessions") {
            photoIds.append(id)
        }
    }

    private func save() {
        let now = ILDateFormatting.string(from: Date())
        let dateStr = ILDateFormatting.string(from: date)
        let dur = resolvedDuration()
        switch mode {
        case .create:
            let s = ILSession(
                id: UUID().uuidString,
                date: dateStr,
                durationMinutes: dur,
                comment: comment.isEmpty ? nil : comment,
                spotId: spotId,
                catchEntries: catches,
                photoIds: photoIds,
                createdAt: now,
                updatedAt: now
            )
            var list = store.sessions
            list.append(s)
            store.saveSessions(list)
        case .edit(var s):
            s.date = dateStr
            s.durationMinutes = dur
            s.comment = comment.isEmpty ? nil : comment
            s.spotId = spotId
            s.catchEntries = catches
            s.photoIds = photoIds
            s.updatedAt = now
            var list = store.sessions
            if let i = list.firstIndex(where: { $0.id == s.id }) {
                list[i] = s
                store.saveSessions(list)
            }
        }
        toast = "Session saved"
        ILHaptics.success()
        dismiss()
    }

    private func deleteSession() {
        if case .edit(let s) = mode {
            for p in s.photoIds { ILImageStorageService.removeFile(id: p, subfolder: "sessions") }
            store.saveSessions(store.sessions.filter { $0.id != s.id })
        }
        dismiss()
    }
}

struct ILSpotPickerSheet: View {
    @Binding var selectedSpotId: String?
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    var body: some View {
        NavigationStack {
            ZStack {
                ILTheme.background.ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(store.spots.filter { s in
                            search.isEmpty || s.name.localizedCaseInsensitiveContains(search)
                        }) { sp in
                            Button {
                                selectedSpotId = sp.id
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundStyle(accent.light)
                                    Text(sp.name)
                                        .font(.system(.body, design: .rounded, weight: .medium))
                                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(ILTheme.textMutedOnDark)
                                }
                                .padding(14)
                                .background(ILTheme.backgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(ILTheme.divider, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Spots")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $search, prompt: "Search")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(accent.light)
                }
            }
        }
    }
}
