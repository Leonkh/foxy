//
//  CGSize+Extension.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 02.01.2022.
//

import Foundation
import CoreGraphics

extension CGSize {
    
    init(square size: CGFloat) {
        self.init(width: size, height: size)
    }
}
