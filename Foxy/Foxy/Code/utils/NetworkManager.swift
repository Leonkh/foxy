//
//  NetworkManager.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 07.01.2022.
//

import Foundation
import Network

protocol NetworkManagerDelegate: AnyObject {
    func didChangeNetworkStatus(to newStatus: NetworkStatus)
}

protocol NetworkManager {
    func addDelegate(_ delegate: NetworkManagerDelegate)
}

enum NetworkStatus {
    case enabled
    case disabled
}

final class NetworkManagerImpl {
    
    // MARK: - Properties
    
    private lazy var monitor = NWPathMonitor()
    private var delegates = [() -> NetworkManagerDelegate?]() {
        didSet {
            print()
        }
    }
    
    
    // MARK: - Init
    
    init() {
       startMonitoring()
    }
    
    // MARK: - Private methods
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else {
                return
            }
            
            let status: NetworkStatus
            if path.status == .satisfied {
                status = .enabled
            } else {
                status = .disabled
            }
            
            self.delegates.forEach { delegate in
                delegate()?.didChangeNetworkStatus(to: status)
            }
        }
        
        let queue = DispatchQueue.global()
        monitor.start(queue: queue)
    }
    
}

extension NetworkManagerImpl: NetworkManager {
    
    func addDelegate(_ delegate: NetworkManagerDelegate) {
        delegates.append( {[weak delegate] in return  delegate} )
    }
    
    
}
