//
//  CoreDataManager.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 06.01.2022.
//

import Foundation
import CoreData

protocol CoreDataManager {
    
    func loadPhotos(completion: @escaping ClosureResult<[Photo]>)
    
    func savePhoto(_ photo: Photo,
                   completion: @escaping ClosureResult<Void>)
    
    func deleteAllData(completion: @escaping ClosureResult<Void>)
    
}

final class CoreDataManagerImpl {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Foxy")
        container.loadPersistentStores(completionHandler: { _, error in
            _ = error.map { fatalError("Unresolved error \($0)") }
        })
        return container
    }()
    
    private lazy var backgroundContext: NSManagedObjectContext = persistentContainer.newBackgroundContext()
    
    private lazy var photoEntityDescription: NSEntityDescription? = NSEntityDescription.entity(forEntityName: PhotoCoreDataModel.entityName,
                                          in: backgroundContext)
    
}

extension CoreDataManagerImpl: CoreDataManager {
    
    func loadPhotos(completion: @escaping ClosureResult<[Photo]>) {
        let fetchRequest = NSFetchRequest<PhotoCoreDataModel>(entityName: PhotoCoreDataModel.entityName)
        do {
            let results = try backgroundContext.fetch(fetchRequest)
            completion(.success(results.map { Photo(coreDataModel: $0)} ))
            debugPrint("\(results.count) photos loaded from core data")
        } catch {
            completion(.failure(FoxyError(error: error as NSError)))
        }
    }
    
    func savePhoto(_ photo: Photo,
                   completion: @escaping ClosureResult<Void>) {
        do {
            createPhotoCoreDataModel(from: photo)
            print("backgroundContext.hasChanges = \(backgroundContext.hasChanges)")
            try backgroundContext.save()
            completion(.success(()))
            debugPrint("photo with id \(photo.id) successfully saved")
        } catch {
            completion(.failure(FoxyError(error: error as NSError)))
        }
    }
    
    private func createPhotoCoreDataModel(from photo: Photo) {
        guard let photoEntityDescription = photoEntityDescription else {
            return
        }
        guard let coreDataModel = NSManagedObject(entity: photoEntityDescription,
                                                  insertInto: backgroundContext) as? PhotoCoreDataModel else {
            return
        }
        
        coreDataModel.id = photo.id
        coreDataModel.photoData = photo.imageData
        coreDataModel.isFavorite = photo.isFavorite
        coreDataModel.isFamily = photo.isFamily
        coreDataModel.isFriend = photo.isFriend
        coreDataModel.isPublic = photo.isPublic
        coreDataModel.farm = Int64(photo.farm)
        coreDataModel.title = photo.title
        coreDataModel.server = photo.server
        coreDataModel.secret = photo.secret
        coreDataModel.owner = photo.owner
    }
    
    func deleteAllData(completion: @escaping ClosureResult<Void>) {
        let fetchRequest = NSFetchRequest<PhotoCoreDataModel>(entityName: PhotoCoreDataModel.entityName)
        do {
            let objects = try backgroundContext.fetch(fetchRequest)
            objects.forEach {
                backgroundContext.delete($0)
            }
            try backgroundContext.save()
            debugPrint("all core data (count = \(objects.count) ) succesfully deleted")
            completion(.success(()))
        } catch {
            completion(.failure(FoxyError(error: error as NSError)))
        }
    }
}
