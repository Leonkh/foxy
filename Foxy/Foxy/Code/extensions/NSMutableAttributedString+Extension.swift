//
//  NSMutableAttributedString+Extension.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 09.01.2022.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    
    /// Интервал всей строки.
    private var range: NSRange {
        return mutableString.range(of: string)
    }
    
    /// Добавляет атрибуты к строке.
    ///
    /// - Parameter attributes: Атрибуты, которые будут добавлены к строке.
    /// - Returns: Строку с указанными атрибутами.
    private func with(_ attributes: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        addAttributes(attributes, range: range)
        return self
    }
    
    /// Добавляет к строке изображение
    /// - Parameter size: размер иконки
    func appendImage(_ image: UIImage, with size: CGFloat) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds.size = .init(square: size)
        var imageString = NSMutableAttributedString(attachment: imageAttachment)
        // Офсет считается из разницы высот заглавной и прописной букв.
        let baselineOffset = -((size - size * 0.65) / 2)
        imageString = imageString.with([.baselineOffset: baselineOffset])
        self.append(imageString)
    }
    
}
