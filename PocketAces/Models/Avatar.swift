import Foundation

enum Avatar {
    static let all: [String] = (1...10).map { String(format: "avatar_%02d", $0) }
}
