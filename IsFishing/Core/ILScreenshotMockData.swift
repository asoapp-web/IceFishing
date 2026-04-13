import Foundation

// MARK: - App Store screenshots — plan (4–6 shots)
//
// Включение: в схеме Xcode → Run → Arguments → добавьте **-ILScreenshotMocks**
// (или запуск из терминала с тем же аргументом). Сплэш и онбординг пропускаются.
//
// Рекомендуемые кадры (переключайте табы вручную):
// 1. **Map (таб 2)** — точки на карте, зимняя рыбалка как главная фича.
// 2. **Species (таб 1)** — сетка рыб, визуал каталога.
// 3. **Sessions (таб 3)** — список выездов и уловы.
// 4. **Guide (таб 0)** — статьи / советы по льду.
// 5. **Games (таб 4)** — мини-игры и трофеи (опционально).
// 6. **Profile (таб 5)** — имя, тема наград, активность (опционально).
//
// После съёмки: удалить этот файл и вызовы `applyScreenshotMocksIfNeeded` / логику в `ILRootContainerView`
// (поиск по строке **ILScreenshotMock** во всём проекте).

enum ILScreenshotMockData {
    /// Launch argument включает моки и короткий путь в главный shell.
    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-ILScreenshotMocks")
    }

    // MARK: Profile & meta

    static let displayName = "Jordan K."

    /// Trophy / tier / themes (Games hub + Profile)
    static let trophyPointsTotal = 1840
    static var trophyTierRaw: String {
        ILTrophyTier.tier(forPoints: trophyPointsTotal).rawValue
    }

    static let pullHighScore = 1240
    static let pullGamesPlayed = 38
    static let pullTotalPoints = 9100

    static let markedHighScore = 2150
    static let markedGamesPlayed = 31
    static let markedTotalPoints = 7800
    static let markedBestStreak = 14

    /// Тема с акцентом (разблокирована при ≥500 pts)
    static let rewardThemeRaw = ILAppRewardTheme.ember.rawValue

    // MARK: Map

    /// Регион: крупное озеро (Северная Америка), несколько пинов в кадре
    static let mapRegion = ILMapStoredRegion(
        centerLatitude: 46.8421,
        centerLongitude: -91.9936,
        spanLatitudeDelta: 0.35,
        spanLongitudeDelta: 0.35
    )

    static var spots: [ILSpot] {
        let t = ILDateFormatting.string(from: Date())
        return [
            ILSpot(
                id: "mock-spot-north",
                name: "North Basin — 24 ft",
                latitude: 46.88,
                longitude: -92.05,
                date: t,
                notes: "Walleye at dawn. Safe ice ~12\".",
                speciesId: "walleye",
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
            ILSpot(
                id: "mock-spot-ridge",
                name: "Pressure Ridge (marked)",
                latitude: 46.81,
                longitude: -91.92,
                date: t,
                notes: "Avoid crossing — use shore trail.",
                speciesId: nil,
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
            ILSpot(
                id: "mock-spot-community",
                name: "Community Hole",
                latitude: 46.79,
                longitude: -92.02,
                date: t,
                notes: "Perch bite on waxies.",
                speciesId: "yellow_perch",
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
        ]
    }

    // MARK: Sessions

    static var sessions: [ILSession] {
        let t = ILDateFormatting.string(from: Date())
        let d1 = "2026-01-18T14:30:00Z"
        let d2 = "2026-01-11T09:15:00Z"
        let d3 = "2026-01-04T16:00:00Z"
        return [
            ILSession(
                id: "mock-sess-1",
                date: d1,
                durationMinutes: 240,
                comment: "Cold but steady perch under the humps.",
                spotId: "mock-spot-community",
                catchEntries: [
                    ILCatchEntry(id: "c1", speciesId: "yellow_perch", customSpeciesName: nil, quantity: 12, sizeEstimate: "9–11\"", note: nil),
                    ILCatchEntry(id: "c2", speciesId: "walleye", customSpeciesName: nil, quantity: 2, sizeEstimate: "18–20\"", note: "Both on jigging rap"),
                ],
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
            ILSession(
                id: "mock-sess-2",
                date: d2,
                durationMinutes: 180,
                comment: "First pike of the season on tip-up.",
                spotId: "mock-spot-north",
                catchEntries: [
                    ILCatchEntry(id: "c3", speciesId: "northern_pike", customSpeciesName: nil, quantity: 1, sizeEstimate: "28\"", note: nil),
                ],
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
            ILSession(
                id: "mock-sess-3",
                date: d3,
                durationMinutes: 90,
                comment: "Scouting only — marked unsafe ice south bay.",
                spotId: "mock-spot-ridge",
                catchEntries: [],
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
        ]
    }

    // MARK: Notes

    static var notes: [ILNote] {
        let t = ILDateFormatting.string(from: Date())
        return [
            ILNote(
                id: "mock-note-1",
                text: "Bring spud bar — ice was noisy near the point. Vexilar battery backup in dry box.",
                photoId: nil,
                createdAt: t,
                updatedAt: t
            ),
            ILNote(
                id: "mock-note-2",
                text: "DNR: walleye slot 15–20\" on this lake. Check signs at landing.",
                photoId: nil,
                createdAt: t,
                updatedAt: t
            ),
        ]
    }

    /// Для экрана Statistics / «изучено» — пару видов
    static let exploredSpeciesIds: Set<String> = ["walleye", "yellow_perch", "northern_pike"]

    /// Прочитанные статьи (если где-то отображается прогресс)
    static let readArticleIds: Set<String> = ["species_guide_001"]
}
