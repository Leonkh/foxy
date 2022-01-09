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
    
    func togglePhotoIsFavorite(photoId: String,
                               completion: @escaping ClosureResult<Bool>)
    
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
        backgroundContext.perform { [weak self] in
            guard let self = self else {
                return
            }
            
            do {
                let results = try self.backgroundContext.fetch(fetchRequest)
                completion(.success(results.map { Photo(coreDataModel: $0)} ))
                debugPrint("\(results.count) photos loaded from core data")
            } catch {
                completion(.failure(FoxyError(error: error as NSError)))
            }
        }
    }
    
    func savePhoto(_ photo: Photo,
                   completion: @escaping ClosureResult<Void>) {
        backgroundContext.perform { [weak self] in
            guard let self = self else {
                return
            }
            
            do {
                self.createPhotoCoreDataModel(from: photo)
                print("backgroundContext.hasChanges = \(self.backgroundContext.hasChanges)")
                try self.backgroundContext.save()
                completion(.success(()))
                debugPrint("photo with id \(photo.id) successfully saved")
            } catch {
                completion(.failure(FoxyError(error: error as NSError)))
            }
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
        backgroundContext.perform { [weak self] in
            guard let self = self else {
                return
            }
            
            do {
                let objects = try self.backgroundContext.fetch(fetchRequest)
                objects.forEach {
                    self.backgroundContext.delete($0)
                }
                try self.backgroundContext.save()
                debugPrint("all core data (count = \(objects.count) ) succesfully deleted")
                completion(.success(()))
            } catch {
                completion(.failure(FoxyError(error: error as NSError)))
            }
        }
    }
    
    func togglePhotoIsFavorite(photoId: String,
                               completion: @escaping ClosureResult<Bool>) {
        let fetchRequest = NSFetchRequest<PhotoCoreDataModel>(entityName: PhotoCoreDataModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", photoId)
        fetchRequest.fetchLimit = 1
        backgroundContext.perform { [weak self] in
            guard let self = self else {
                return
            }
            
            do {
                guard let object = try self.backgroundContext.fetch(fetchRequest).first else {
                    completion(.failure(FoxyError(userMessage: "Неизвестная ошибка",
                                                  logMessage: "Не найден объект по запросу \(fetchRequest)")))
                    return
                }
                
                object.isFavorite.toggle()
                try self.backgroundContext.save()
                completion(.success((object.isFavorite)))
            } catch {
                completion(.failure(FoxyError(error: error as NSError)))
            }
        }
    }
}
