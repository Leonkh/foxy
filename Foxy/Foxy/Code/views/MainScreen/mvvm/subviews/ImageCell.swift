//
//  MainImageView.swift
//  Foxy
//
//  Created by Леонид Хабибуллин on 31.12.2021.
//

import Foundation
import UIKit
import PinLayout

protocol ImageCellDelegate: AnyObject {
    func didTapFavoriteButton(forImage id: String)
}

final class ImageCell: UITableViewCell {
    
    // MARK: - Model
    
    struct Model: Hashable {
        let id: String
        let image: UIImage
        var isImageFavorite: Bool
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let defaultMargin: CGFloat = 12
        static let favoritesImage = UIImage(named: "favoritesIcon")
        static let backgroundColor = UIColor.clear
        static let favoritesButtonSize = CGSize(square: 44)
        static let favoritesButtonBackgroundColor = UIColor.white
        static let favoritesButtonSelectedBackgroundColor = UIColor.red
    }
    
    // MARK: - Properties
    
    static var identifier: String {
        return String(describing: self)
    }
    private weak var delegate: ImageCellDelegate?
    private var viewModel: Model?
    
    
    // MARK: - Views
    
    private lazy var photoView: UIImageView = .create { imageView in
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    private lazy var favoritesButton: UIButton = .create { button in
        button.backgroundColor = .clear
        button.setImage(Constants.favoritesImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = Constants.favoritesButtonBackgroundColor
        button.addTarget(self, action: #selector(didTapFavoriteButton), for: .touchUpInside)
    }
    
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = Constants.backgroundColor
        contentView.addSubviews([photoView, favoritesButton])
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
        
        photoView.image = nil
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // 1) Set the contentView's width to the specified size parameter
        contentView.pin.width(size.width)

        // 2) Layout the contentView's controls
        pinLayout()
        
        // 3) Returns a size that contains all controls
        return CGSize(width: contentView.frame.width,
                      height: photoView.frame.maxY)
    }
    
    
    // MARK: - Internal methods
    
    func setup(model: Model, delegate: ImageCellDelegate?) {
        self.delegate = delegate
        self.viewModel = model
        photoView.image = model.image
        
        setFavoriteState(isFavorite: model.isImageFavorite)
    }
    
    func setFavoriteState(isFavorite: Bool) {
        if isFavorite {
            favoritesButton.imageView?.tintColor = Constants.favoritesButtonSelectedBackgroundColor
        } else {
            favoritesButton.imageView?.tintColor = Constants.favoritesButtonBackgroundColor
        }
    }
    
    
    // MARK: - Private methods
    
    private func pinLayout() {
        photoView.pin
            .all()
            .sizeToFit(.width)
        
        favoritesButton.pin
            .size(Constants.favoritesButtonSize)
            .top(Constants.defaultMargin)
            .right(Constants.defaultMargin)
    }
    
    @objc private func didTapFavoriteButton() {
        guard let id = viewModel?.id else {
            return
        }
        
        viewModel?.isImageFavorite.toggle()
        
        setFavoriteState(isFavorite: viewModel?.isImageFavorite ?? false)
        delegate?.didTapFavoriteButton(forImage: id)
    }
}
