import Foundation

extension Double {
    /// Format as USD currency.
    /// - Parameters:
    ///   - decimals: fraction digits (default 0) — "$1,235" or "$1,234.56"
    ///   - showSign: prefix +/- for net results — "+$50" / "-$20"
    func formattedCurrency(decimals: Int = 2, showSign: Bool = false) -> String {
        let formatted = self.formatted(
            .currency(code: "USD")
            .precision(.fractionLength(decimals))
        )
        if showSign && self >= 0 {
            return "+" + formatted
        }
        return formatted
    }

    /// Compact display: "$1.5k" for >= 1000, "$500" otherwise.
    func formattedCompact() -> String {
        if self >= 1000 {
            let k = self / 1000
            return k.truncatingRemainder(dividingBy: 1) == 0
                ? "$\(Int(k))k"
                : String(format: "$%.1fk", k)
        }
        
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            return self.formatted(
                .currency(code: "USD")
                .precision(.fractionLength(0))
            )
        }
        return self.formatted(
            .currency(code: "USD")
            .precision(.fractionLength(2))
        )
    }
}
