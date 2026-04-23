import Combine
import Foundation
import SwiftUI

@MainActor
final class ILPersistenceStore: ObservableObject {
    static let shared = ILPersistenceStore()

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published private(set) var spots: [ILSpot] = []
    @Published private(set) var sessions: [ILSession] = []
    @Published private(set) var notes: [ILNote] = []
    @Published private(set) var readArticleIds: Set<String> = []
    @Published private(set) var exploredSpeciesIds: Set<String> = []
    @Published var displayName: String = "Angler"
    @Published var avatarType: ILAvatarType = .default
    @Published var avatarValue: String = ""
    @Published var mapRegion: ILMapStoredRegion?

    @Published private(set) var trophyPointsTotal: Int = 0
    @Published private(set) var trophyTierRaw: String = ILTrophyTier.novice.rawValue
    @Published private(set) var pullHighScore: Int = 0
    @Published private(set) var pullGamesPlayed: Int = 0
    @Published private(set) var pullTotalPoints: Int = 0
    @Published private(set) var markedHighScore: Int = 0
    @Published private(set) var markedGamesPlayed: Int = 0
    @Published private(set) var markedTotalPoints: Int = 0
    @Published private(set) var markedBestStreak: Int = 0
    @Published private(set) var onboardingCompletedFlag: Bool = false
    @Published private(set) var rewardThemeRaw: String = ILAppRewardTheme.arctic.rawValue

    var currentTrophyTier: ILTrophyTier {
        ILTrophyTier(rawValue: trophyTierRaw) ?? .novice
    }

    private init() {
        ILImageStorageService.ensureDirectories()
        reloadFromDefaults()
    }

    func reloadFromDefaults() {
        spots = decodeArray(ILUserDefaultsKeys.spotsData) ?? []
        sessions = decodeArray(ILUserDefaultsKeys.sessionsData) ?? []
        notes = decodeArray(ILUserDefaultsKeys.notesData) ?? []
        readArticleIds = Set(decodeArray(ILUserDefaultsKeys.statsReadArticles) ?? [String]())
        exploredSpeciesIds = Set(decodeArray(ILUserDefaultsKeys.statsExploredSpecies) ?? [String]())
        displayName = defaults.string(forKey: ILUserDefaultsKeys.profileDisplayName) ?? "Angler"
        if let raw = defaults.string(forKey: ILUserDefaultsKeys.profileAvatarType),
           let t = ILAvatarType(rawValue: raw) {
            avatarType = t
        } else {
            avatarType = .default
        }
        avatarValue = defaults.string(forKey: ILUserDefaultsKeys.profileAvatarValue) ?? ""
        if let data = defaults.data(forKey: ILUserDefaultsKeys.mapLastRegion),
           let region = try? decoder.decode(ILMapStoredRegion.self, from: data) {
            mapRegion = region
        } else {
            mapRegion = nil
        }
        trophyPointsTotal = defaults.integer(forKey: ILUserDefaultsKeys.gamesTrophyPointsTotal)
        trophyTierRaw = defaults.string(forKey: ILUserDefaultsKeys.gamesCurrentTier) ?? ILTrophyTier.novice.rawValue
        pullHighScore = defaults.integer(forKey: ILUserDefaultsKeys.gamesPullHighScore)
        pullGamesPlayed = defaults.integer(forKey: ILUserDefaultsKeys.gamesPullGamesPlayed)
        pullTotalPoints = defaults.integer(forKey: ILUserDefaultsKeys.gamesPullTotalPoints)
        markedHighScore = defaults.integer(forKey: ILUserDefaultsKeys.gamesMarkedHighScore)
        markedGamesPlayed = defaults.integer(forKey: ILUserDefaultsKeys.gamesMarkedGamesPlayed)
        markedTotalPoints = defaults.integer(forKey: ILUserDefaultsKeys.gamesMarkedTotalPoints)
        markedBestStreak = defaults.integer(forKey: ILUserDefaultsKeys.gamesMarkedBestStreak)
        onboardingCompletedFlag = defaults.bool(forKey: ILUserDefaultsKeys.onboardingCompleted)
        rewardThemeRaw = defaults.string(forKey: ILUserDefaultsKeys.appRewardTheme) ?? ILAppRewardTheme.arctic.rawValue
        applyScreenshotMocksIfNeeded()
    }

    /// App Store screenshots: enabled with launch argument `-ILScreenshotMocks`. Does not write UserDefaults.
    private func applyScreenshotMocksIfNeeded() {
        guard ILScreenshotMockData.isEnabled else { return }
        spots = ILScreenshotMockData.spots
        sessions = ILScreenshotMockData.sessions
        notes = ILScreenshotMockData.notes
        displayName = ILScreenshotMockData.displayName
        avatarType = .default
        avatarValue = ""
        mapRegion = ILScreenshotMockData.mapRegion
        trophyPointsTotal = ILScreenshotMockData.trophyPointsTotal
        trophyTierRaw = ILScreenshotMockData.trophyTierRaw
        pullHighScore = ILScreenshotMockData.pullHighScore
        pullGamesPlayed = ILScreenshotMockData.pullGamesPlayed
        pullTotalPoints = ILScreenshotMockData.pullTotalPoints
        markedHighScore = ILScreenshotMockData.markedHighScore
        markedGamesPlayed = ILScreenshotMockData.markedGamesPlayed
        markedTotalPoints = ILScreenshotMockData.markedTotalPoints
        markedBestStreak = ILScreenshotMockData.markedBestStreak
        readArticleIds = ILScreenshotMockData.readArticleIds
        exploredSpeciesIds = ILScreenshotMockData.exploredSpeciesIds
        rewardThemeRaw = ILScreenshotMockData.rewardThemeRaw
        onboardingCompletedFlag = true
        objectWillChange.send()
    }

    var activeRewardTheme: ILAppRewardTheme {
        let chosen = ILAppRewardTheme(rawValue: rewardThemeRaw) ?? .arctic
        if chosen.isUnlocked(trophyPoints: trophyPointsTotal) { return chosen }
        return .arctic
    }

    func setRewardTheme(_ theme: ILAppRewardTheme) {
        guard theme.isUnlocked(trophyPoints: trophyPointsTotal) else { return }
        rewardThemeRaw = theme.rawValue
        defaults.set(theme.rawValue, forKey: ILUserDefaultsKeys.appRewardTheme)
        objectWillChange.send()
    }

    private static func todayKey() -> String {
        let cal = Calendar.current
        let c = cal.dateComponents([.year, .month, .day], from: Date())
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }

    /// Call when user selects a main tab (0…5). Tracks daily “visit all tabs” nudge + small trophy bonus.
    func registerMainTabVisit(_ tabIndex: Int) {
        guard tabIndex >= 0, tabIndex < 6 else { return }
        let day = Self.todayKey()
        if defaults.string(forKey: ILUserDefaultsKeys.dailyTabVisitDay) != day {
            defaults.set(day, forKey: ILUserDefaultsKeys.dailyTabVisitDay)
            defaults.set(0, forKey: ILUserDefaultsKeys.dailyTabVisitMask)
        }
        var mask = defaults.integer(forKey: ILUserDefaultsKeys.dailyTabVisitMask)
        mask |= (1 << tabIndex)
        defaults.set(mask, forKey: ILUserDefaultsKeys.dailyTabVisitMask)

        let fullMask = (1 << 6) - 1
        if mask == fullMask, defaults.string(forKey: ILUserDefaultsKeys.dailyExplorerBonusDay) != day {
            defaults.set(day, forKey: ILUserDefaultsKeys.dailyExplorerBonusDay)
            addTrophyPointsBonus(12)
        }
        objectWillChange.send()
    }

    func dailyTabNudgeActive(for tabIndex: Int) -> Bool {
        guard tabIndex >= 0, tabIndex < 6 else { return false }
        let day = Self.todayKey()
        if defaults.string(forKey: ILUserDefaultsKeys.dailyTabVisitDay) != day { return true }
        let mask = defaults.integer(forKey: ILUserDefaultsKeys.dailyTabVisitMask)
        return (mask & (1 << tabIndex)) == 0
    }

    private func addTrophyPointsBonus(_ n: Int) {
        trophyPointsTotal += n
        let tier = ILTrophyTier.tier(forPoints: trophyPointsTotal)
        trophyTierRaw = tier.rawValue
        defaults.set(trophyPointsTotal, forKey: ILUserDefaultsKeys.gamesTrophyPointsTotal)
        defaults.set(trophyTierRaw, forKey: ILUserDefaultsKeys.gamesCurrentTier)
        objectWillChange.send()
    }

    func setOnboardingCompleted(_ value: Bool) {
        defaults.set(value, forKey: ILUserDefaultsKeys.onboardingCompleted)
        onboardingCompletedFlag = value
    }

    func markArticleRead(_ id: String) {
        readArticleIds.insert(id)
        saveStringSet(readArticleIds, key: ILUserDefaultsKeys.statsReadArticles)
    }

    func markSpeciesExplored(_ id: String) {
        exploredSpeciesIds.insert(id)
        saveStringSet(exploredSpeciesIds, key: ILUserDefaultsKeys.statsExploredSpecies)
    }

    func saveSpots(_ list: [ILSpot]) {
        spots = list
        encodeArray(list, key: ILUserDefaultsKeys.spotsData)
    }

    func saveMapRegion(_ region: ILMapStoredRegion?) {
        mapRegion = region
        if let region, let data = try? encoder.encode(region) {
            defaults.set(data, forKey: ILUserDefaultsKeys.mapLastRegion)
        } else {
            defaults.removeObject(forKey: ILUserDefaultsKeys.mapLastRegion)
        }
    }

    func saveSessions(_ list: [ILSession]) {
        sessions = list
        encodeArray(list, key: ILUserDefaultsKeys.sessionsData)
    }

    func saveNotes(_ list: [ILNote]) {
        notes = list
        encodeArray(list, key: ILUserDefaultsKeys.notesData)
    }

    func setDisplayName(_ name: String) {
        displayName = name
        defaults.set(name, forKey: ILUserDefaultsKeys.profileDisplayName)
    }

    func setAvatar(type: ILAvatarType, value: String) {
        avatarType = type
        avatarValue = value
        defaults.set(type.rawValue, forKey: ILUserDefaultsKeys.profileAvatarType)
        defaults.set(value, forKey: ILUserDefaultsKeys.profileAvatarValue)
    }

    func applyPullRound(score: Int) {
        trophyPointsTotal += score
        pullTotalPoints += score
        pullGamesPlayed += 1
        pullHighScore = max(pullHighScore, score)
        let tier = ILTrophyTier.tier(forPoints: trophyPointsTotal)
        trophyTierRaw = tier.rawValue
        defaults.set(trophyPointsTotal, forKey: ILUserDefaultsKeys.gamesTrophyPointsTotal)
        defaults.set(trophyTierRaw, forKey: ILUserDefaultsKeys.gamesCurrentTier)
        defaults.set(pullHighScore, forKey: ILUserDefaultsKeys.gamesPullHighScore)
        defaults.set(pullGamesPlayed, forKey: ILUserDefaultsKeys.gamesPullGamesPlayed)
        defaults.set(pullTotalPoints, forKey: ILUserDefaultsKeys.gamesPullTotalPoints)
        objectWillChange.send()
    }

    func applyMarkedRound(score: Int, bestStreak: Int) {
        trophyPointsTotal += score
        markedTotalPoints += score
        markedGamesPlayed += 1
        markedHighScore = max(markedHighScore, score)
        markedBestStreak = max(markedBestStreak, bestStreak)
        let tier = ILTrophyTier.tier(forPoints: trophyPointsTotal)
        trophyTierRaw = tier.rawValue
        defaults.set(trophyPointsTotal, forKey: ILUserDefaultsKeys.gamesTrophyPointsTotal)
        defaults.set(trophyTierRaw, forKey: ILUserDefaultsKeys.gamesCurrentTier)
        defaults.set(markedHighScore, forKey: ILUserDefaultsKeys.gamesMarkedHighScore)
        defaults.set(markedGamesPlayed, forKey: ILUserDefaultsKeys.gamesMarkedGamesPlayed)
        defaults.set(markedTotalPoints, forKey: ILUserDefaultsKeys.gamesMarkedTotalPoints)
        defaults.set(markedBestStreak, forKey: ILUserDefaultsKeys.gamesMarkedBestStreak)
        objectWillChange.send()
    }

    func resetStatisticsTracking() {
        readArticleIds = []
        exploredSpeciesIds = []
        saveStringSet([], key: ILUserDefaultsKeys.statsReadArticles)
        saveStringSet([], key: ILUserDefaultsKeys.statsExploredSpecies)
    }

    func resetNotes() {
        notes = []
        defaults.removeObject(forKey: ILUserDefaultsKeys.notesData)
        ILImageStorageService.removeAll(in: "notes")
    }

    func resetSessions() {
        sessions = []
        defaults.removeObject(forKey: ILUserDefaultsKeys.sessionsData)
        ILImageStorageService.removeAll(in: "sessions")
    }

    func resetMapSpots() {
        spots = []
        defaults.removeObject(forKey: ILUserDefaultsKeys.spotsData)
        defaults.removeObject(forKey: ILUserDefaultsKeys.mapLastRegion)
        mapRegion = nil
        ILImageStorageService.removeAll(in: "spots")
        var updated = sessions
        for i in updated.indices {
            updated[i].spotId = nil
        }
        saveSessions(updated)
    }

    func resetGameProgress() {
        trophyPointsTotal = 0
        trophyTierRaw = ILTrophyTier.novice.rawValue
        pullHighScore = 0
        pullGamesPlayed = 0
        pullTotalPoints = 0
        markedHighScore = 0
        markedGamesPlayed = 0
        markedTotalPoints = 0
        markedBestStreak = 0
        defaults.set(0, forKey: ILUserDefaultsKeys.gamesTrophyPointsTotal)
        defaults.set(ILTrophyTier.novice.rawValue, forKey: ILUserDefaultsKeys.gamesCurrentTier)
        defaults.set(0, forKey: ILUserDefaultsKeys.gamesPullHighScore)
        defaults.set(0, forKey: ILUserDefaultsKeys.gamesPullGamesPlayed)
        defaults.set(0, forKey: ILUserDefaultsKeys.gamesPullTotalPoints)
        defaults.set(0, forKey: ILUserDefaultsKeys.gamesMarkedHighScore)
        defaults.set(0, forKey: ILUserDefaultsKeys.gamesMarkedGamesPlayed)
        defaults.set(0, forKey: ILUserDefaultsKeys.gamesMarkedTotalPoints)
        defaults.set(0, forKey: ILUserDefaultsKeys.gamesMarkedBestStreak)
        objectWillChange.send()
    }

    func resetAllUserData() {
        resetStatisticsTracking()
        resetNotes()
        resetSessions()
        resetMapSpots()
        resetGameProgress()
        setDisplayName("Angler")
        setAvatar(type: .default, value: "")
        rewardThemeRaw = ILAppRewardTheme.arctic.rawValue
        defaults.set(ILAppRewardTheme.arctic.rawValue, forKey: ILUserDefaultsKeys.appRewardTheme)
        defaults.removeObject(forKey: ILUserDefaultsKeys.dailyTabVisitDay)
        defaults.removeObject(forKey: ILUserDefaultsKeys.dailyTabVisitMask)
        defaults.removeObject(forKey: ILUserDefaultsKeys.dailyExplorerBonusDay)
        ILImageStorageService.removeAll(in: "avatar")
        setOnboardingCompleted(false)
        objectWillChange.send()
    }

    private func decodeArray<T: Decodable>(_ key: String) -> [T]? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode([T].self, from: data)
    }

    private func encodeArray<T: Encodable>(_ value: [T], key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func saveStringSet(_ set: Set<String>, key: String) {
        encodeArray(Array(set).sorted(), key: key)
    }
}
