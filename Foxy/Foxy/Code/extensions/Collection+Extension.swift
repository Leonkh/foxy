//
//  Collection+Extension.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 19.01.2022.
//

import Foundation

public extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
