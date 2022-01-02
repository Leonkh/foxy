//
//  FlickerPhotoRequest.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 31.12.2021.
//

import Foundation

struct FlickerPhotoRequest {
    let photoId: String
    let serverId: String
    let secret: String
    let size: FlickerSizePhoto = .none
    
    var url: URL? {
        if case .none = size {
            return URL(string: "https://live.staticflickr.com/\(serverId)/\(photoId)_\(secret).jpg")
        } else {
            return URL(string: "https://live.staticflickr.com/\(serverId)/\(photoId)_\(secret)_\(size.stringValue).jpg")
        }
        
    }
}
