import Foundation

enum Avatar {
    static let all: [String] = (1...6).map { String(format: "avatar_%02d", $0) }
}
