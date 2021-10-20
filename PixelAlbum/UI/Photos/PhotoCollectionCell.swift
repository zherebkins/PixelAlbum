//
//  PhotoCollectionCell.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 15.10.2021.
//

import UIKit
import Photos

final class PhotoCollectionCell: UICollectionViewCell {
    @IBOutlet var image: UIImageView!
    @IBOutlet private var rawLabel: UILabel!
    @IBOutlet private var modifiedLabel: UILabel!
    
    private var displayingAsset: PHAsset?
    private var displayingViewModel: PhotoCellViewModel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        displayingViewModel?.cancelPreviewFetching()
        displayingViewModel = nil
        
        displayingAsset = nil
        image.image = nil
    }
    
    func configure(with viewModel: PhotoCellViewModel) {
        displayingViewModel = viewModel
        
        let info = viewModel.fileInfo
        rawLabel.isHidden = !info.hasRawFile
        modifiedLabel.isHidden = !info.isModified
        
        viewModel.fetchPreview(targetSize: bounds.size) { [weak self] assetImage in
            guard let self = self, viewModel.asset.localIdentifier == self.displayingViewModel?.asset.localIdentifier else {
                return
            }
            self.image.image = assetImage
        }
    }
    
    static var identifier: String {
        String(describing: Self.self)
    }
}
