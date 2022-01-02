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
    
    func start()
    
    func didTapFavoriteButton(for photoId: String)
}

final class MainScreenModelImpl {
    
    private enum Constants {
        static let timeIntervalForUpdatePhoto: TimeInterval = 10
    }
    
    @OpenCombine.Published private var randomPhoto: Photo?
    
    private var cancellables: [OpenCombine.AnyCancellable?] = []
    private var timerToken: OpenCombine.AnyCancellable?
    
    private var data: GetInterestingnessResponse?
    
    private var urlString: String {
        return "https://www.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=6b67245437e551d735fc9152ca4cba45&page=\(Int.random(in: 1...5))&format=json&nojsoncallback=1"
    }
    
    private func downloadPhotoList() {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let downloadListTask = URLSession.shared.ocombine
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
            })
        
        cancellables.append(downloadListTask)
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
        
        let downloadSinglePhotoTask = URLSession.shared.ocombine
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
                
                if let image = UIImage(data: value) {
                    self.randomPhoto = Photo(data: photo,
                                             image: image,
                                             isFavorite: false)
                    self.start()
                    print("success load photo")
                } else {
                    print("fail with data = \(value)")
                }
            })
        cancellables.append(downloadSinglePhotoTask)
    }
}

extension MainScreenModelImpl: MainScreenModel {
    
    // MARK: - MainScreenModel
    
    var randomPhotoPublisher: OpenCombine.Published<Photo?>.Publisher  { $randomPhoto }
    
    func start() {
        cancellables.removeAll()
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
                self.downloadPhotoList()
            })
    }
    
    func didTapFavoriteButton(for photoId: String) {
        
    }
}
