import PhotosUI
import SwiftUI

struct ILProfileScreen: View {
    @Binding var toast: String?
    @EnvironmentObject private var router: ILAppRouter
    @EnvironmentObject private var store: ILPersistenceStore
    @Environment(\.ilRewardAccent) private var accent
    @State private var showNameEditor  = false
    @State private var nameDraft       = ""
    @State private var showAvatarSheet = false
    @State private var showAvatarCamera = false
    @State private var showEmojiPicker  = false
    @State private var showSymbolPicker = false
    @State private var pickedAvatar: PhotosPickerItem?

    private let emojiChoices = ["🎣","🐟","🐻‍❄️","🐧","❄️","⛰️","🧊","🌨️","🏔️","🦭","🛷","🧣","🧤","☃️","🌊","🪵","🔥","✨","🌙","⭐","🧭","🗺️","🛶","🦆","🪶","🪝","⚓️","🎒","🥾"]
    private let symbolChoices = ["fish.fill","snowflake","mountain.2.fill","drop.fill","cloud.snow.fill","water.waves","binoculars.fill","map.fill","location.north.circle.fill","moon.stars.fill","sun.horizon.fill","leaf.fill","hare.fill","bird.fill","backpack.fill","flame.fill","bolt.fill"]

    var body: some View {
        NavigationStack {
            ZStack {
                ILAtmosphereBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        profileHero
                            .ilStaggeredAppear(index: 0, baseDelay: 0.05)
                        rewardThemeStrip
                            .ilStaggeredAppear(index: 1, baseDelay: 0.05)
                        activitySection
                            .ilStaggeredAppear(index: 2, baseDelay: 0.05)
                        settingsRow
                            .ilStaggeredAppear(index: 3, baseDelay: 0.05)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
            }
        }
        .sheet(isPresented: $showNameEditor) { nameEditor }
        .sheet(isPresented: $showAvatarCamera) {
            ILImagePicker(sourceType: .camera) { img in
                if let img, let id = try? ILImageStorageService.saveJPEG(img, subfolder: "avatar") {
                    store.setAvatar(type: .photo, value: id)
                }
                showAvatarCamera = false
            }
        }
        .sheet(isPresented: $showAvatarSheet) { avatarSheetContent }
        .sheet(isPresented: $showEmojiPicker) { emojiSheet }
        .sheet(isPresented: $showSymbolPicker) { symbolSheet }
        .onChange(of: pickedAvatar) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let ui = UIImage(data: data),
                   let id = try? ILImageStorageService.saveJPEG(ui, subfolder: "avatar") {
                    await MainActor.run {
                        store.setAvatar(type: .photo, value: id)
                        pickedAvatar = nil
                        showAvatarSheet = false
                    }
                }
            }
        }
    }

    

    private var profileHero: some View {
        HStack(spacing: 18) {
            
            ZStack(alignment: .bottomTrailing) {
                ILAvatarAuroraRing(diameter: 98)
                ZStack {
                    Circle()
                        .fill(ILTheme.backgroundTertiary)
                        .frame(width: 88, height: 88)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(colors: [accent.light.opacity(0.6), accent.mid.opacity(0.2)], startPoint: .top, endPoint: .bottom),
                                    lineWidth: 2
                                )
                        )
                        .shadow(color: accent.mid.opacity(0.25), radius: 10)
                    avatarView
                        .frame(width: 84, height: 84)
                        .clipShape(Circle())
                }
                Button { showAvatarSheet = true } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 22))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, accent.mid)
                        .background(Circle().fill(ILTheme.background))
                }
                .accessibilityLabel("Edit avatar")
                .offset(x: 2, y: 2)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(store.displayName)
                        .font(.ilDisplay(22))
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                        .lineLimit(1)
                    Button {
                        nameDraft = store.displayName
                        showNameEditor = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(ILTheme.textMutedOnDark)
                    }
                    .accessibilityLabel("Edit name")
                }
                HStack(spacing: 6) {
                    Image(systemName: store.currentTrophyTier.symbolName)
                    Text(store.currentTrophyTier.displayName)
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ILTheme.amber)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(ILTheme.amber.opacity(0.15)))
                .overlay(Capsule().stroke(ILTheme.amber.opacity(0.35), lineWidth: 1))

                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(ILTheme.amber)
                    Text("\(store.trophyPointsTotal) pts")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                }
            }
            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.06),
                            ILTheme.backgroundSecondary,
                            ILTheme.backgroundTertiary.opacity(0.95),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            accent.light.opacity(0.42),
                            ILTheme.outlineCyan.opacity(0.55),
                            ILTheme.divider,
                        ],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: .black.opacity(0.38), radius: 16, y: 6)
        .shadow(color: accent.mid.opacity(0.1), radius: 22, y: 10)
    }

    @ViewBuilder
    private var avatarView: some View {
        switch store.avatarType {
        case .photo:
            if let ui = ILImageStorageService.loadImage(id: store.avatarValue, subfolder: "avatar") {
                Image(uiImage: ui).resizable().scaledToFill()
            } else { defaultAvatar }
        case .emoji:
            ZStack {
                Circle().fill(accent.light.opacity(0.15))
                Text(store.avatarValue).font(.system(size: 44))
            }
        case .symbol:
            ZStack {
                Circle().fill(accent.light.opacity(0.15))
                Image(systemName: store.avatarValue.isEmpty ? "person.crop.circle.fill" : store.avatarValue)
                    .font(.system(size: 40))
                    .foregroundStyle(accent.light)
            }
        case .default: defaultAvatar
        }
    }

    private var defaultAvatar: some View {
        ZStack {
            Circle().fill(ILTheme.backgroundTertiary)
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(ILTheme.textMutedOnDark)
        }
    }

    

    private var activitySection: some View {
        VStack(spacing: 0) {
            profileNavRow(icon: "chart.bar.fill", iconColor: accent.light, title: "Statistics") {
                ILStatisticsScreen(toast: $toast)
            }
            profileDivider
            NavigationLink {
                ILNotesScreen(toast: $toast)
            } label: {
                profileRowLabel(icon: "note.text", iconColor: ILTheme.amber, title: "Notes") {
                    HStack(spacing: 4) {
                        Text("\(store.notes.count)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(ILTheme.textMutedOnDark)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(ILTheme.textMutedOnDark)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .background(ILTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ILTheme.divider, lineWidth: 1)
        )
    }

    

    private var rewardThemeStrip: some View {
        NavigationLink {
            ILRewardThemesScreen(toast: $toast)
                .environmentObject(store)
                .environmentObject(router)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [accent.light.opacity(0.22), ILTheme.amber.opacity(0.12)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(accent.light)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Reward theme")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(ILTheme.textMutedOnDark)
                    Text(store.activeRewardTheme.displayName)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(ILTheme.textPrimaryOnDark)
                    Text("Unlock palettes with trophy points · opens theme picker")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(ILTheme.textSecondaryOnDark)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ILTheme.textMutedOnDark)
            }
            .padding(14)
            .background(ILTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [accent.light.opacity(0.35), ILTheme.divider],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    

    private var settingsRow: some View {
        profileNavRow(icon: "gearshape.fill", iconColor: ILTheme.textSecondaryOnDark, title: "Settings") {
            ILSettingsScreen(toast: $toast)
        }
        .background(ILTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(ILTheme.divider, lineWidth: 1)
        )
    }

    

    private func profileNavRow<Destination: View>(icon: String, iconColor: Color, title: String, @ViewBuilder dest: () -> Destination) -> some View {
        NavigationLink(destination: dest) {
            profileRowLabel(icon: icon, iconColor: iconColor, title: title) {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(ILTheme.textMutedOnDark)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func profileRowLabel<Trailing: View>(icon: String, iconColor: Color, title: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            Text(title)
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(ILTheme.textPrimaryOnDark)
            Spacer()
            trailing()
        }
        .padding(14)
    }

    private var profileDivider: some View {
        Divider()
            .background(ILTheme.divider)
            .padding(.leading, 62)
    }

    

    private var avatarSheetContent: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Button {
                    showAvatarSheet = false
                    showAvatarCamera = true
                } label: {
                    sheetRow(icon: "camera.fill", text: "Take Photo")
                }
                .buttonStyle(.plain)
                Divider().background(ILTheme.divider)
                PhotosPicker(selection: $pickedAvatar, matching: .images) {
                    sheetRow(icon: "photo.fill", text: "Choose from Gallery")
                }
                .buttonStyle(.plain)
                Divider().background(ILTheme.divider)
                Button { showEmojiPicker = true } label: {
                    sheetRow(icon: "face.smiling.inverse", text: "Choose Emoji")
                }
                .buttonStyle(.plain)
                Divider().background(ILTheme.divider)
                Button { showSymbolPicker = true } label: {
                    sheetRow(icon: "star.circle.fill", text: "Choose Symbol")
                }
                .buttonStyle(.plain)
                if store.avatarType != .default {
                    Divider().background(ILTheme.divider)
                    Button {
                        store.setAvatar(type: .default, value: "")
                        showAvatarSheet = false
                    } label: {
                        sheetRow(icon: "trash.fill", text: "Remove Avatar", destructive: true)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(ILTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(20)
            .navigationTitle("Edit Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAvatarSheet = false }
                        .foregroundStyle(accent.light)
                }
            }
            .background(ILTheme.background.ignoresSafeArea())
        }
        .presentationDetents([.medium])
    }

    private func sheetRow(icon: String, text: String, destructive: Bool = false) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(destructive ? ILTheme.tertiaryRed : accent.light)
                .frame(width: 28)
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(destructive ? ILTheme.tertiaryRed : ILTheme.textPrimaryOnDark)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var emojiSheet: some View {
        NavigationStack {
            ZStack {
                ILTheme.background.ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 52))], spacing: 8) {
                        ForEach(emojiChoices, id: \.self) { e in
                            Button(e) {
                                store.setAvatar(type: .emoji, value: e)
                                showEmojiPicker = false
                            }
                            .font(.largeTitle)
                            .frame(width: 52, height: 52)
                            .background(ILTheme.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Choose Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { showEmojiPicker = false }.foregroundStyle(accent.light) } }
        }
    }

    private var symbolSheet: some View {
        NavigationStack {
            ZStack {
                ILTheme.background.ignoresSafeArea()
                List(symbolChoices, id: \.self) { sym in
                    Button {
                        store.setAvatar(type: .symbol, value: sym)
                        showSymbolPicker = false
                    } label: {
                        Label(sym, systemImage: sym)
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                    }
                    .listRowBackground(ILTheme.backgroundSecondary)
                }
                .listStyle(.plain)
                .ilScrollSurface()
            }
            .navigationTitle("Choose Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { showSymbolPicker = false }.foregroundStyle(accent.light) } }
        }
    }

    private var nameEditor: some View {
        NavigationStack {
            ZStack {
                ILTheme.background.ignoresSafeArea()
                Form {
                    Section {
                        TextField("Display name", text: $nameDraft)
                            .foregroundStyle(ILTheme.textPrimaryOnDark)
                    }
                    .listRowBackground(ILTheme.backgroundSecondary)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showNameEditor = false }.foregroundStyle(ILTheme.textSecondaryOnDark)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let t = nameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !t.isEmpty { store.setDisplayName(t) }
                        showNameEditor = false
                    }
                    .foregroundStyle(accent.light)
                }
            }
        }
    }
}
