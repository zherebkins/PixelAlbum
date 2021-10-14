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
    
    private var displayingAlbum: Album?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        displayingAlbum = nil
    }
    
    func configure(with album: Album, thumbnailProvider: AlbumsListViewModel) {
        displayingAlbum = album
        
        nameLabel.text = album.name
        itemsCountLabel.text = "\(album.itemsCount)"
        
        if let thumbnailId = album.thumbnailId {
            thumbnailProvider.getThumbnail(for: thumbnailId) { [weak self] image in
                guard let self = self, self.displayingAlbum?.thumbnailId == thumbnailId else {
                    return
                }
                self.thumbnail.image = image
            }
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
