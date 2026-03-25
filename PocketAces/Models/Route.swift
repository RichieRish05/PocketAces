import FirebaseFirestore

enum Route: Hashable {
    case gameDetail(gameId: String)
    case gameSummary(game: Game)
    case pastGames
}


enum ProfileDestination: Hashable {
    case avatarPicker
}
