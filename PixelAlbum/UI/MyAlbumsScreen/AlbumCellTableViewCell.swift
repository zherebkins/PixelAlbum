//
//  AlbumCellTableViewCell.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import UIKit

final class AlbumTableViewCell: UITableViewCell {
    @IBOutlet private var thumbnail: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var itemsCountLabel: UILabel!
    
    private var displayingViewModel: AlbumCellViewModel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        displayingViewModel?.cancelThumbnailFetch()
        displayingViewModel = nil
    }
    
    func configure(with viewModel: AlbumCellViewModel) {
        displayingViewModel = viewModel
        
        nameLabel.text = viewModel.name
        itemsCountLabel.text = "\(viewModel.itemsCount)"
        
        viewModel.fetchThumbnail { [weak self] image in
            guard let self = self, self.displayingViewModel == viewModel else {
                return
            }
            self.thumbnail.image = image
        }
    }
    
    func configure(albumName: String, photosCount: Int) {
        nameLabel.text = albumName
        itemsCountLabel.text = "\(photosCount)"
    }
    
    static var identifier: String {
        String(describing: Self.self)
    }
}
