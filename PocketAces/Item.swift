//
//  Item.swift
//  PocketAces
//
//  Created by Rishi Murumkar on 3/11/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
