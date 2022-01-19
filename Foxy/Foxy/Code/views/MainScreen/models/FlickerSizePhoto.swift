//
//  FlickerSizePhoto.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 31.12.2021.
//

import Foundation

enum FlickerSizePhoto {
    // 75 px cropped square
    case s
    
    // 150 px cropped square
    case q
    
    // 100 px
    case t
    
    // 240 px
    case m
    
    // 320 px
    case n
    
    // 400 px
    case w
    
    // 500 px
    case none
    
    // 640 px
    case z
    
    // 800 px
    case c
    
    // 1024 px
    case b
    
    // 1600 px has a unique secret; photo owner can restrict
    case h
    
    // 2048 px has a unique secret; photo owner can restrict
    case k
    
    // 3072 px has a unique secret; photo owner can restrict
    case k3
    
    // 4096 px has a unique secret; photo owner can restrict
    case k4
    
    // 4096 px has a unique secret; photo owner can restrict; only exists for 2:1 aspect ratio photos
    case f
    
    // 5120 px has a unique secret; photo owner can restrict
    case k5
    
    // 6144 px has a unique secret; photo owner can restrict
    case k6
    
    // arbitrary, has a unique secret; photo owner can restrict; files have full EXIF data; files might not be rotated; files can use an arbitrary file extension
    case o
}

extension FlickerSizePhoto {
    var stringValue: String {
        switch self {
        case .s:
            return "s"
        case .q:
            return "q"
        case .t:
            return "t"
        case .m:
            return "m"
        case .n:
            return "n"
        case .w:
            return "w"
        case .none:
            return .empty
        case .z:
            return "z"
        case .c:
            return "c"
        case .b:
            return "b"
        case .h:
            return "h"
        case .k:
            return "k"
        case .k3:
            return "3k"
        case .k4:
            return "4k"
        case .f:
            return "f"
        case .k5:
            return "5k"
        case .k6:
            return "6k"
        case .o:
            return "o"
        }
    }
}
