import Foundation













enum ILScreenshotMockData {
    
    
    
    /// 🔴 УСТАНОВИТЕ В FALSE ПЕРЕД ОТПРАВКОЙ В APP STORE
    static let mocksEnabled: Bool = false
    
    /// Launch argument включает моки и короткий путь в главный shell.
    /// Работает только если `mocksEnabled = true` выше.
    static var isEnabled: Bool {
        guard mocksEnabled else { return false }
        return ProcessInfo.processInfo.arguments.contains("-ILScreenshotMocks")
    }

    

    static let displayName = "Alex Fisher"

    /// Trophy / tier / themes (Games hub + Profile)
    static let trophyPointsTotal = 2450
    static var trophyTierRaw: String {
        ILTrophyTier.tier(forPoints: trophyPointsTotal).rawValue
    }

    static let pullHighScore = 2840
    static let pullGamesPlayed = 67
    static let pullTotalPoints = 12400

    static let markedHighScore = 3420
    static let markedGamesPlayed = 54
    static let markedTotalPoints = 15600
    static let markedBestStreak = 23

    /// Тема: arctic = стандартная голубая тема (cyan/ice)
    static let rewardThemeRaw = ILAppRewardTheme.arctic.rawValue

    

    /// Регион: Lake Superior region — красивый зимний вид
    static let mapRegion = ILMapStoredRegion(
        centerLatitude: 46.8421,
        centerLongitude: -91.9936,
        spanLatitudeDelta: 0.28,
        spanLongitudeDelta: 0.32
    )

    static var spots: [ILSpot] {
        let baseDate = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        let t = ILDateFormatting.string(from: baseDate)
        let oldDate = ILDateFormatting.string(from: Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date())
        
        return [
            ILSpot(
                id: "mock-spot-north",
                name: "North Basin — 24 ft",
                latitude: 46.88,
                longitude: -92.05,
                date: t,
                notes: "Walleye at dawn. Safe ice ~12\". Best bite 6-8am.",
                speciesId: "walleye",
                photoIds: [],
                createdAt: oldDate,
                updatedAt: t
            ),
            ILSpot(
                id: "mock-spot-ridge",
                name: "Pressure Ridge ⚠️",
                latitude: 46.81,
                longitude: -91.92,
                date: t,
                notes: "Dangerous ice. Avoid crossing — use shore trail marked with orange flags.",
                speciesId: nil,
                photoIds: [],
                createdAt: oldDate,
                updatedAt: t
            ),
            ILSpot(
                id: "mock-spot-community",
                name: "Community Hole (Hot!)",
                latitude: 46.79,
                longitude: -92.02,
                date: t,
                notes: "Perch bite on waxies and minnows. Limit: 25/day. Crowded weekends.",
                speciesId: "yellow_perch",
                photoIds: [],
                createdAt: oldDate,
                updatedAt: t
            ),
            ILSpot(
                id: "mock-spot-weedline",
                name: "Weedline Shelf",
                latitude: 46.85,
                longitude: -91.98,
                date: t,
                notes: "Pike territory. Tip-ups with suckers. 15-18ft depth.",
                speciesId: "northern_pike",
                photoIds: [],
                createdAt: oldDate,
                updatedAt: t
            ),
            ILSpot(
                id: "mock-spot-crib",
                name: "Old Crib Structure",
                latitude: 46.825,
                longitude: -92.01,
                date: t,
                notes: "Crappie suspending. Electronics required. 28ft.",
                speciesId: "black_crappie",
                photoIds: [],
                createdAt: oldDate,
                updatedAt: t
            ),
            ILSpot(
                id: "mock-spot-inlet",
                name: "Creek Inlet",
                latitude: 46.87,
                longitude: -91.97,
                date: t,
                notes: "Rainbow trout stocked last week. Light line only.",
                speciesId: "rainbow_trout",
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
        ]
    }

    

    static var sessions: [ILSession] {
        let t = ILDateFormatting.string(from: Date())
        let formatter = ISO8601DateFormatter()
        
        
        let dates = [
            "2026-04-15T07:30:00Z",  
            "2026-04-12T14:00:00Z",  
            "2026-04-08T06:15:00Z",  
            "2026-03-28T11:30:00Z",  
            "2026-03-15T09:00:00Z",  
            "2026-02-22T15:45:00Z",  
            "2026-02-08T08:00:00Z",  
            "2026-01-20T13:20:00Z",  
        ]
        
        return [
            
            ILSession(
                id: "mock-sess-1",
                date: dates[0],
                durationMinutes: 300,
                comment: "Epic perch bite! Limit by 9am. Wax worms outperformed minnows 3:1. Ice thickness steady at 14\".",
                spotId: "mock-spot-community",
                catchEntries: [
                    ILCatchEntry(id: "c1", speciesId: "yellow_perch", customSpeciesName: nil, quantity: 25, sizeEstimate: "10–12\"", note: "Limit reached!"),
                    ILCatchEntry(id: "c2", speciesId: "yellow_perch", customSpeciesName: nil, quantity: 8, sizeEstimate: "13–15\"", note: "Jumbo perch - released"),
                    ILCatchEntry(id: "c3", speciesId: "walleye", customSpeciesName: nil, quantity: 2, sizeEstimate: "17–19\"", note: "Slot fish, released"),
                ],
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
            
            
            ILSession(
                id: "mock-sess-2",
                date: dates[1],
                durationMinutes: 240,
                comment: "Afternoon bite picked up after 2pm. Mixed bag at weedline. Wind was brutal.",
                spotId: "mock-spot-weedline",
                catchEntries: [
                    ILCatchEntry(id: "c4", speciesId: "northern_pike", customSpeciesName: nil, quantity: 1, sizeEstimate: "32\"", note: "Tip-up with sucker"),
                    ILCatchEntry(id: "c5", speciesId: "yellow_perch", customSpeciesName: nil, quantity: 6, sizeEstimate: "9–11\"", note: nil),
                    ILCatchEntry(id: "c6", speciesId: "walleye", customSpeciesName: nil, quantity: 1, sizeEstimate: "16\"", note: "Underslot, released"),
                ],
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
            
            
            ILSession(
                id: "mock-sess-3",
                date: dates[2],
                durationMinutes: 180,
                comment: "Beautiful sunrise. Trout were cruising shallow. 4lb test line, tiny jigs.",
                spotId: "mock-spot-inlet",
                catchEntries: [
                    ILCatchEntry(id: "c7", speciesId: "rainbow_trout", customSpeciesName: nil, quantity: 3, sizeEstimate: "16–20\"", note: "All released"),
                    ILCatchEntry(id: "c8", speciesId: "brook_trout", customSpeciesName: nil, quantity: 1, sizeEstimate: "14\"", note: "Beautiful colors"),
                ],
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
            
            
            ILSession(
                id: "mock-sess-4",
                date: dates[3],
                durationMinutes: 360,
                comment: "All day on the crib. Crappie were stacked 5ft off bottom. 28ft depth. Used Marcum.",
                spotId: "mock-spot-crib",
                catchEntries: [
                    ILCatchEntry(id: "c9", speciesId: "black_crappie", customSpeciesName: nil, quantity: 18, sizeEstimate: "11–13\"", note: "Kept 12"),
                    ILCatchEntry(id: "c10", speciesId: "bluegill", customSpeciesName: nil, quantity: 8, sizeEstimate: "8–9\"", note: "Bonus"),
                    ILCatchEntry(id: "c11", speciesId: "yellow_perch", customSpeciesName: nil, quantity: 4, sizeEstimate: "10\"", note: nil),
                ],
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
            
            
            ILSession(
                id: "mock-sess-5",
                date: dates[4],
                durationMinutes: 90,
                comment: "Scouting only — marked unsafe ice near pressure ridge. Shore trail recommended.",
                spotId: "mock-spot-ridge",
                catchEntries: [],
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
            
            
            ILSession(
                id: "mock-sess-6",
                date: dates[5],
                durationMinutes: 270,
                comment: "Prime time bite 5:30-7:00pm. Jigging raps in 24ft. Slow but quality fish.",
                spotId: "mock-spot-north",
                catchEntries: [
                    ILCatchEntry(id: "c12", speciesId: "walleye", customSpeciesName: nil, quantity: 4, sizeEstimate: "18–21\"", note: "2 keepers, 2 released"),
                    ILCatchEntry(id: "c13", speciesId: "burbot", customSpeciesName: nil, quantity: 1, sizeEstimate: "24\"", note: "After sunset"),
                ],
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
            
            
            ILSession(
                id: "mock-sess-7",
                date: dates[6],
                durationMinutes: 210,
                comment: "Kids day out. Non-stop bluegill action in 12ft. Tungsten jigs with plastics.",
                spotId: "mock-spot-community",
                catchEntries: [
                    ILCatchEntry(id: "c14", speciesId: "bluegill", customSpeciesName: nil, quantity: 45, sizeEstimate: "7–9\"", note: "Non-stop action!"),
                    ILCatchEntry(id: "c15", speciesId: "pumpkinseed", customSpeciesName: nil, quantity: 6, sizeEstimate: "8\"", note: "Pretty colors"),
                ],
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
            
            
            ILSession(
                id: "mock-sess-8",
                date: dates[7],
                durationMinutes: 480,
                comment: "Trophy hunt all day. Finally connected at 3pm. Big fish!",
                spotId: "mock-spot-weedline",
                catchEntries: [
                    ILCatchEntry(id: "c16", speciesId: "northern_pike", customSpeciesName: nil, quantity: 1, sizeEstimate: "38\"", note: "Trophy! Released"),
                    ILCatchEntry(id: "c17", speciesId: "northern_pike", customSpeciesName: nil, quantity: 2, sizeEstimate: "28–30\"", note: "Smaller ones"),
                ],
                photoIds: [],
                createdAt: t,
                updatedAt: t
            ),
        ]
    }

    

    static var notes: [ILNote] {
        let t = ILDateFormatting.string(from: Date())
        let oldDate = ILDateFormatting.string(from: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date())
        
        return [
            ILNote(
                id: "mock-note-1",
                text: "🎣 Gear checklist:\n• Spud bar (ice was noisy near point)\n• Vexilar FLX-28 + backup battery\n• 4lb fluoro for trout\n• Tip-ups with quick-strike rigs\n• Suckers (3-4 inch)",
                photoId: nil,
                createdAt: oldDate,
                updatedAt: t
            ),
            ILNote(
                id: "mock-note-2",
                text: "📏 DNR Regulations 2026:\n• Walleye slot: 15–20\" protected\n• Perch limit: 25/day\n• Pike: 2/day, no size limit\n• Check signs at landing for updates",
                photoId: nil,
                createdAt: oldDate,
                updatedAt: t
            ),
            ILNote(
                id: "mock-note-3",
                text: "🔥 Hot spots this week:\n1. Community hole - perch on waxies\n2. Weedline - pike cruising\n3. Crib - crappie suspended 5ft off bottom\n4. Inlet - stocked trout active",
                photoId: nil,
                createdAt: t,
                updatedAt: t
            ),
            ILNote(
                id: "mock-note-4",
                text: "💡 Tactics that worked:\n• Tungsten jigs outfished lead 2:1\n• Deadstick rod caught 40% of fish\n• Glow lures after 4pm\n• Stay mobile - drill 3-4 holes before committing",
                photoId: nil,
                createdAt: t,
                updatedAt: t
            ),
            ILNote(
                id: "mock-note-5",
                text: "⚠️ Safety reminders:\n• Always fish with buddy\n• 4\" minimum ice for walking\n• Check ice thickness every 150ft\n• Carry ice picks & throw rope",
                photoId: nil,
                createdAt: oldDate,
                updatedAt: t
            ),
        ]
    }

    /// Изученные виды рыб для экрана Statistics
    static let exploredSpeciesIds: Set<String> = [
        "walleye",           
        "yellow_perch",      
        "northern_pike",     
        "black_crappie",     
        "bluegill",          
        "rainbow_trout",     
        "brook_trout",       
        "burbot",            
        "pumpkinseed",       
        "lake_sturgeon",     
        "lake_trout",        
        "muskellunge",       
        "whitefish",         
        "cisco",             
        "rock_bass",         
    ]

    /// Прочитанные статьи гида
    static let readArticleIds: Set<String> = [
        "species_guide_001",
        "safety_checklist",
        "gear_ice_augurs",
        "electronics_flashers",
        "tactics_jigging",
        "tactics_deadsticking",
        "tactics_tipups",
        "species_identification",
        "regulations_summary",
    ]
}
