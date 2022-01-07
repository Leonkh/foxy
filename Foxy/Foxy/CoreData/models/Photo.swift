//
//  Photo.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 06.01.2022.
//

import Foundation
import CoreData
import UIKit

struct Photo: Codable {
    var id: String
    var owner: String
    var secret: String
    var server: String
    var farm: Int
    var title: String
    var ispublic: Int
    var isfriend: Int
    var isfamily: Int
    var imageData: Data
    var isFavorite: Bool
    
    var isPublic: Bool {
        return ispublic == 1
    }
    
    var isFriend: Bool {
        return isfriend == 1
    }
    
    var isFamily: Bool {
        return isfamily == 1
    }
    
    var image: UIImage? {
        return UIImage(data: imageData)
    }
}

extension Photo {
    
    init(coreDataModel: PhotoCoreDataModel) {
        self.id = coreDataModel.id
        self.owner = coreDataModel.owner
        self.secret = coreDataModel.secret
        self.server = coreDataModel.server
        self.farm = Int(coreDataModel.farm)
        self.title = coreDataModel.title
        self.ispublic = coreDataModel.isPublic ? 1 : 0
        self.isfriend = coreDataModel.isFriend ? 1 : 0
        self.isfamily = coreDataModel.isFamily ? 1 : 0
        self.imageData = coreDataModel.photoData
        self.isFavorite = coreDataModel.isFavorite
    }
}

@objc(PhotoCoreDataModel)
final class PhotoCoreDataModel: NSManagedObject {
    
    static let entityName = "PhotoCoreDataModel"
    
    @NSManaged var id: String
    @NSManaged var owner: String
    @NSManaged var secret: String
    @NSManaged var server: String
    @NSManaged var farm: Int64
    @NSManaged var title: String
    @NSManaged var isPublic: Bool
    @NSManaged var isFriend: Bool
    @NSManaged var isFamily: Bool
    @NSManaged var photoData: Data
    @NSManaged var isFavorite: Bool
    
    var image: UIImage? {
        return UIImage(data: photoData)
    }
    
}
