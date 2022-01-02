//
//  Photo.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 02.01.2022.
//

import Foundation
import UIKit

final class Photo {
    let data: GetInterestingnessResponsePhoto
    let image: UIImage
    var isFavorite: Bool
    
    init(data: GetInterestingnessResponsePhoto,
         image: UIImage,
         isFavorite: Bool) {
        self.data = data
        self.image = image
        self.isFavorite = isFavorite
    }
}
