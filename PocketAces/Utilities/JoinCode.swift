import Foundation

/// Shared 6-char alphanumeric join code generator.
/// Omits visually ambiguous characters (I, O, 0, 1).
enum JoinCode {
    static let charset = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
    static let length = 6

    static func generate() -> String {
        String((0..<length).map { _ in charset.randomElement()! })
    }
}

