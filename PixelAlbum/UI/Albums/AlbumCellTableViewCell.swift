//
//  AlbumCellTableViewCell.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 14.10.2021.
//

import UIKit
import Combine

final class AlbumTableViewCell: UITableViewCell {
    @IBOutlet private var thumbnail: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var itemsCountLabel: UILabel!
    
    private var displayingViewModel: AlbumCellViewModel?
    private var subscribtions = [AnyCancellable]()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        displayingViewModel?.cancelThumbnailFetch()
        displayingViewModel = nil
    }
    
    func configure(with viewModel: AlbumCellViewModel) {
        displayingViewModel = viewModel
        
        viewModel.$name
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.nameLabel.text = $0
            }
            .store(in: &subscribtions)
        
        viewModel.$itemsCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.itemsCountLabel.text = "\($0)"
            }.store(in: &subscribtions)
        
        viewModel.thumbnailWasChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.fetchThumbnail()
            }.store(in: &subscribtions)
        
        fetchThumbnail()
    }
    
    func configure(albumName: String, photosCount: Int) {
        nameLabel.text = albumName
        itemsCountLabel.text = "\(photosCount)"
    }
    
    private func fetchThumbnail() {
        guard let viewModel = displayingViewModel else {
            return
        }
        
        viewModel.cancelThumbnailFetch()
        viewModel.fetchThumbnail { [weak self] image in
            guard let self = self, self.displayingViewModel == viewModel else {
                return
            }
            self.thumbnail.image = image
        }
    }
    
    static var identifier: String {
        String(describing: Self.self)
    }
}
