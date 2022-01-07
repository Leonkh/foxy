//
//  PopupNotificationsManager.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 07.01.2022.
//

import Foundation
import SwiftEntryKit

enum PopupNotificationType {
    /// Вывод информационных сообщений.
    case information
    /// Вывод информации об успешно выполненной операции.
    case success
    /// Вывод информации об ошибках.
    case error
}

struct PopupNotification {
    let text: String
    let type: PopupNotificationType
}

protocol PopupNotificationsManager {
    
    func displayTopPopUp(notification: PopupNotification)
    
}

final class PopupNotificationsManagerImpl {
    
    private enum Constants {
        static let textStyle = EKProperty.LabelStyle(font: UIFont.preferredFont(forTextStyle: .body),
                                                     color: EKColor.black,
                                                     alignment: .center)
        static let informationBackgroundColor = EKColor.init(UIColor.gray)
        static let errorBackgroundColor = EKColor.init(UIColor.red)
        static let successBackgroundColor = EKColor.init(UIColor.green)
    }
    
}

extension PopupNotificationsManagerImpl: PopupNotificationsManager {
    
    func displayTopPopUp(notification: PopupNotification) {
        let entryBackground: EKAttributes.BackgroundStyle
        switch notification.type {
        case .information:
            entryBackground = .color(color: Constants.informationBackgroundColor)
        case .success:
            entryBackground = .color(color: Constants.successBackgroundColor)
        case .error:
            entryBackground = .color(color: Constants.errorBackgroundColor)
        }
        
        var attributes = EKAttributes.topNote
        attributes.entryBackground = entryBackground
        attributes.statusBar = .dark
        
        let title = EKProperty.LabelContent(text: notification.text,
                                            style: Constants.textStyle,
                                            accessibilityIdentifier: nil)
        let description = EKProperty.LabelContent(text: .empty,
                                                  style:  Constants.textStyle,
                                                  accessibilityIdentifier: nil)
        let message = EKSimpleMessage(title: title,
                                      description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: message)
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
}
