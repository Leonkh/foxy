//
//  ErrorCaseGetPopularMethods.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 31.12.2021.
//

import Foundation

enum ErrorCaseGetPopularMethods: Int {
    case invalidUserId
    case popularPhotosDisabled
    case invalidApiKey
    case serviceCurrentlyUnavailable
    case writeOperationFailed
    case formatNotFound
    case methodNotFound
    case invalidSoapEnvelope
    case invalidXmlRpcMethodCall
    case badUrlFound
}

extension ErrorCaseGetPopularMethods {
    
    var errorCode: Int {
        switch self {
        case .invalidUserId:
            return 1
        case .popularPhotosDisabled:
            return 2
        case .invalidApiKey:
            return 100
        case .serviceCurrentlyUnavailable:
            return 105
        case .writeOperationFailed:
            return 106
        case .formatNotFound:
            return 111
        case .methodNotFound:
            return 112
        case .invalidSoapEnvelope:
            return 114
        case .invalidXmlRpcMethodCall:
            return 115
        case .badUrlFound:
            return 116
        }
    }
    
}
