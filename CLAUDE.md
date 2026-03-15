# PocketAces

Home game poker management iOS app. Create a game, share a join code, track buy-ins/cash-outs in real time, and review stats after.

## Tech Stack

- **UI:** SwiftUI (iOS 26.2+)
- **Local persistence:** SwiftData
- **Auth:** Firebase Anonymous Auth (zero-friction, no sign-up)
- **Real-time backend:** Cloud Firestore (snapshot listeners)
- **Charts:** Swift Charts
- **Dependencies:** Firebase iOS SDK (`FirebaseAuth`, `FirebaseFirestore`) via SPM

## Architecture

MVVM with a Services layer:

```
View → ViewModel → Service → Firestore / SwiftData
```

- **Views** — SwiftUI views, no business logic
- **ViewModels** — `@Observable` classes, one per screen, own the state
- **Services** — stateless singletons that talk to Firebase or SwiftData (`AuthService`, `GameService`, `StatsService`)
- **Models** — plain data types

## Folder Structure

```
PocketAces/
├── App/                  # App entry point, Firebase setup
├── Models/               # Firestore Codable structs (Game, Player)
├── LocalModels/          # SwiftData @Model classes (LocalSession)
├── Views/                # SwiftUI views, organized by feature
│   ├── Home/
│   ├── Game/
│   ├── Stats/
│   └── Components/       # Reusable view components
├── ViewModels/           # @Observable view models
├── Services/             # AuthService, GameService, StatsService
└── Utilities/            # Extensions, helpers, constants
```

## Data Layer

### Firestore — `games` collection

Each document represents one game session. Players are an embedded array (no sub-collections).

```
games/{gameId}
  name: String
  hostId: String
  joinCode: String            // unique 6-char alphanumeric
  buyIn: Double
  chipDenominations: [Double]
  status: "waiting" | "active" | "ended"
  createdAt: Timestamp
  endedAt: Timestamp?
  players: [
    {
      id: String              // Firebase anonymous UID
      displayName: String
      buyIns: Int
      cashOut: Double?
      joinedAt: Timestamp
    }
  ]
```

### SwiftData — `LocalSession`

Stored on-device for offline history and stats. Synced from Firestore when a game ends.

```swift
@Model class LocalSession {
    var gameId: String
    var gameName: String
    var date: Date
    var buyIn: Double
    var totalBuyIns: Int
    var cashOut: Double
    var netResult: Double      // cashOut - (buyIn * totalBuyIns)
    var playerCount: Int
    var duration: TimeInterval
}
```

### Data conventions

- Firestore models: plain `Codable` structs in `Models/`
- SwiftData models: `@Model` classes in `LocalModels/`
- Never import SwiftData in Firestore model files or vice versa

## Key Features

### Authentication
- Firebase Anonymous Auth — user gets a UID on first launch, no credentials required
- UID persists across sessions until app uninstall

### Game Creation
- Host sets: game name, buy-in amount, chip denominations
- System generates a unique 6-character alphanumeric join code
- Game starts in `"waiting"` status

### Joining a Game
- **Primary:** Universal Links (Associated Domains) — `applinks:` only
- **No** custom URL scheme fallback — Universal Links are the sole deep link mechanism
- **Manual:** Enter 6-char join code directly

### Real-Time Lobby
- Firestore snapshot listener on the game document
- All players see live updates: joins, buy-ins, cash-outs
- Host sees admin controls

### Player Actions
- Cash out (enter chip count → converted to dollar amount)
- Re-buy (increments buy-in count)

### Host Powers
- End game (sets status to `"ended"`, computes final results)
- Force cash-out a player

### Game History
- Card-based UI showing past sessions
- Data sourced from `LocalSession` (SwiftData)

### Statistics Dashboard
- 15 metrics including: total games, win rate, biggest win/loss, average net, ROI, streak tracking
- Swift Charts visualizations: net results over time, session distribution

## Build Settings

- **Deployment target:** iOS 26.2
- **Swift version:** 5
- **Default actor isolation:** `MainActor` (set in build settings)
- **Xcode groups:** Filesystem-synced (not virtual references)
- **Minimum Xcode:** 26.2+
- **Build command:** `xcodebuild -scheme PocketAces -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`

## Conventions

### Naming
- Types: `PascalCase` — `GameViewModel`, `LocalSession`
- Properties/functions: `camelCase`
- Constants: `camelCase` (not `SCREAMING_SNAKE`)
- Files: match their primary type name — `GameViewModel.swift`

### SwiftUI
- Extract reusable pieces into `Components/`
- Use `@Observable` (not `ObservableObject`) for view models
- Inject services via the SwiftUI environment when practical

### Error Handling
- Services throw; ViewModels catch and surface errors as user-facing alert state
- No silent `try?` — always handle or propagate errors

### Testing
- Unit tests for ViewModels and Services
- Use Swift Testing framework (`@Test`, `#expect`) not XCTest
- Test file naming: `GameViewModelTests.swift`

### Git
- Conventional-style commit messages: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`
- One logical change per commit
