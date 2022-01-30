//
//  MainScreenModel.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 30.12.2021.
//

import Foundation
import OpenCombine
import OpenCombineFoundation
import OpenCombineDispatch
import UIKit

protocol MainScreenModel {
    
    var randomPhotoPublisher: OpenCombine.Published<Photo?>.Publisher  { get }
    var networkStatusPublisher: OpenCombine.Published<NetworkStatus>.Publisher { get }
    var timeToRefreshPublisher: OpenCombine.Published<TimeInterval>.Publisher { get }
    
    func start()
    func didTapFavoriteButton(for photoId: String)
    func didTapTrashButton()
}

final class MainScreenModelImpl {
    
    private enum Constants {
        static let timeIntervalForUpdatePhoto: TimeInterval = 10
    }
    
    @OpenCombine.Published private var randomPhoto: Photo?
    @OpenCombine.Published private var currentNetworkStatus: NetworkStatus = .enabled
    @OpenCombine.Published private var timeToRefresh: TimeInterval = Constants.timeIntervalForUpdatePhoto
    private var cancellables: [AnyCancellable] = []
    private var timerToken: AnyCancellable?
    private var timeToRefreshToken: AnyCancellable?
    
    private var data: GetInterestingnessResponse?
    private let coreDataManager: CoreDataManager
    private let networkManager: NetworkManager
    
    init(coreDataManager: CoreDataManager,
         networkManager: NetworkManager) {
        self.coreDataManager = coreDataManager
        self.networkManager = networkManager
        
        self.networkManager.addDelegate(self)
    }
    
    private var urlString: String {
        return "https://www.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=6b67245437e551d735fc9152ca4cba45&page=\(Int.random(in: 1...5))&format=json&nojsoncallback=1"
    }
    
    private func loadPhotoListFromInternet() {
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.ocombine
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: GetInterestingnessResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main.ocombine)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            },
                  receiveValue: { [weak self] response in
                let randomPhoto = response.photos.photo.randomElement()
                self?.downloadSinglePhoto(randomPhoto)
            }).store(in: &cancellables)
    }
    
    private func downloadSinglePhoto(_ photo: GetInterestingnessResponsePhoto?) {
        guard let photo = photo else {
            return
        }
        
        let request = FlickerPhotoRequest(photoId: photo.id,
                                          serverId: photo.server,
                                          secret: photo.secret)
        guard let url = request.url else {
            return
        }
        
        URLSession.shared.ocombine
            .dataTaskPublisher(for: url)
            .map(\.data)
            .receive(on: RunLoop.main.ocombine)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] value in
                guard let self = self else {
                    return
                }
                
                if UIImage(data: value) != nil {
                    let newPhoto = Photo(id: photo.id,
                                         owner: photo.owner,
                                         secret: photo.secret,
                                         server: photo.server,
                                         farm: photo.farm,
                                         title: photo.title,
                                         ispublic: photo.ispublic,
                                         isfriend: photo.isfriend,
                                         isfamily: photo.isfamily,
                                         imageData: value,
                                         isFavorite: false)
                    self.randomPhoto = newPhoto
                    self.coreDataManager.savePhoto(newPhoto) { result in
                        if case .failure(let error) = result {
                            debugPrint(error)
                        }
                    }
                    self.initTimer()
                    print("success load photo")
                } else {
                    print("fail with data = \(value)")
                }
            }).store(in: &cancellables)
    }
    
    private func loadPhotoListFromCache() {
        coreDataManager.loadPhotos { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let photos):
                self.randomPhoto = photos.randomElement()
                print("success loaded from cache photo count \(photos.count)")
                self.initTimer()
            case .failure(let error):
                debugPrint(error)
            }
            
        }
    }
}

extension MainScreenModelImpl: MainScreenModel {
    
    // MARK: - MainScreenModel
    
    var randomPhotoPublisher: OpenCombine.Published<Photo?>.Publisher  { $randomPhoto }
    var networkStatusPublisher: OpenCombine.Published<NetworkStatus>.Publisher { $currentNetworkStatus }
    var timeToRefreshPublisher: OpenCombine.Published<TimeInterval>.Publisher { $timeToRefresh }
    
    func start() {
        timeToRefreshToken?.cancel()
        switch currentNetworkStatus {
        case .enabled:
            loadPhotoListFromInternet()
        case .disabled:
            loadPhotoListFromCache()
        }
    }
    
    private func initTimer() {
        cancellables.removeAll()
        refreshTimer()
        timerToken = Timer.publish(every: Constants.timeIntervalForUpdatePhoto,
                                   on: .main,
                                   in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.main.ocombine)
            .sink(receiveValue: { [weak self] value in
                guard let self = self else {
                    return
                }
                
                self.randomPhoto = nil
                self.timerToken?.cancel()
                self.start()
            })
    }
    
    private func refreshTimer() {
        timeToRefresh = Constants.timeIntervalForUpdatePhoto
        timeToRefreshToken = Timer.publish(every: 1,
                                           on: .main,
                                           in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.main.ocombine)
            .sink(receiveValue: { [weak self] value in
                guard let self = self else {
                    return
                }
                
                if self.timeToRefresh == .zero {
                    return
                }
                self.timeToRefresh -= 1
            })
    }
    
    func didTapFavoriteButton(for photoId: String) {
        coreDataManager.togglePhotoIsFavorite(photoId: photoId) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let isFavorite):
                print("photo with id \(photoId) success toggled to \(isFavorite)")
            case .failure(let error):
                debugPrint(error)
            }
            
        }
    }
    
    func didTapTrashButton() {
        coreDataManager.deleteAllData { result in
            if case .failure(let error) = result {
                debugPrint(error)
            }
        }
    }
    
}

extension MainScreenModelImpl: NetworkManagerDelegate {
    
    // MARK: - NetworkManagerDelegate
    
    func didChangeNetworkStatus(to newStatus: NetworkStatus) {
        guard currentNetworkStatus != newStatus else {
            return
        }
        
        currentNetworkStatus = newStatus
        start()
    }
    
}
