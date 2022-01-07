//
//  FoxyError.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 06.01.2022.
//

import Foundation

protocol FoxyErrorProtocol: Error {
    /// Сообщение, которое можно показывать пользователю
    var userMessage: String { get }
    
    /// Сообщение для лога
    var logMessage: String { get }
}

final class FoxyError: FoxyErrorProtocol {
    
    static let unknownError = FoxyError(userMessage: "Неизвестная ошибка",
                                        logMessage: "Неизвестная ошибка")
    
    var userMessage: String
    
    var logMessage: String
    
    init(userMessage: String,
         logMessage: String) {
        self.userMessage = userMessage
        self.logMessage = logMessage
    }
    
    init(error: NSError) {
        self.userMessage = error.localizedDescription
        self.logMessage = error.debugDescription
    }
}
