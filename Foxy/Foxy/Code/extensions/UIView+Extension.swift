//
//  UIView+Extension.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 31.12.2021.
//

import Foundation
import UIKit

/// :nodoc:
extension UIView {
    
    /// create view.
    /// - Parameter apply: code for apply some parametrs to view.
    /// - Returns: created view with applyed parametrs.
     static func create<T: UIView>(_ apply: (T) -> Void) -> T {
        let view = T()
        apply(view)
        return view
    }
    
    /// add array of view to subviews
    /// - Parameter subviews: array of subviews
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { addSubview($0) }
    }
}
