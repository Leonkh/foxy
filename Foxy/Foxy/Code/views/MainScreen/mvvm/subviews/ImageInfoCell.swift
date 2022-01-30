//
//  ImageInfoCell.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 30.01.2022.
//

import Foundation
import UIKit
import PinLayout

final class ImageInfoCell: UITableViewCell {
    
    // MARK: - Model
    
    struct Model: Hashable {
        let title: String?
        let owner: String?
    }
    
    
    // MARK: - Constants
    
    private enum Constants {
        static let defaultMargin: CGFloat = 12
    }
    
    
    // MARK: - Properties
    
    static var identifier: String {
        return String(describing: self)
    }
    
    
    // MARK: - Views
    
    private lazy var titleLabel = UILabel()
    private lazy var ownerLabel = UILabel()
    
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubviews([titleLabel, ownerLabel])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        pinLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        [titleLabel, ownerLabel].forEach { $0.text = nil }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // 1) Set the contentView's width to the specified size parameter
        contentView.pin.width(size.width)
        
        // 2) Layout the contentView's controls
        pinLayout()
        
        let maxY = max(titleLabel.frame.maxY, ownerLabel.frame.maxY)
        
        // 3) Returns a size that contains all controls
        return CGSize(width: contentView.frame.width,
                      height: maxY)
    }
    
    
    // MARK: - Internal methods
    
    func setup(model: Model) {
        if let title = model.title {
            titleLabel.text = "Title: " + title
        } else {
            titleLabel.text = nil
        }
        
        if let owner = model.owner {
            ownerLabel.text = "Owner: " + owner
        } else {
            ownerLabel.text = nil
        }
    }
    
    
    // MARK: - Private methods
    
    private func pinLayout() {
        titleLabel.isHidden = titleLabel.text == nil || titleLabel.text == ""
        if titleLabel.isHidden {
            titleLabel.pin
                .size(.zero)
        } else {
            titleLabel.pin
                .top()
                .horizontally()
                .margin(.zero, Constants.defaultMargin)
                .sizeToFit(.width)
        }
        
        ownerLabel.isHidden = ownerLabel.text == nil || ownerLabel.text == ""
        
        if ownerLabel.isHidden {
            ownerLabel.pin
                .size(.zero)
        } else {
            
            if titleLabel.isHidden {
                ownerLabel.pin
                    .top()
                    .horizontally()
                    .margin(.zero, Constants.defaultMargin)
                    .sizeToFit(.width)
                    .bottom()
            } else {
                ownerLabel.pin
                    .top(to: titleLabel.edge.bottom)
                    .marginTop(Constants.defaultMargin)
                    .horizontally()
                    .margin(.zero, Constants.defaultMargin)
                    .sizeToFit(.width)
                    .bottom()
            }
        }
    }
    
}
