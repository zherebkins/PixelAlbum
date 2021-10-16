//
//  PhotoCollectionCell.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 15.10.2021.
//

import UIKit
import Photos

final class PhotoCollectionCell: UICollectionViewCell {
    @IBOutlet private var image: UIImageView!
    @IBOutlet private var rawLabel: UILabel!
    @IBOutlet private var modifiedLabel: UILabel!
    
    private var displayingAsset: PHAsset?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        displayingAsset = nil
        image.image = nil
        rawLabel.isHidden = true
        modifiedLabel.isHidden = true
    }
    
    func configure(with asset: PHAsset, thumbnailsProvider: ThumbnailsProvider) {
        displayingAsset = asset
        
        thumbnailsProvider.getPreviewPhoto(for: asset, targetSize: bounds.size) { [weak self] assetImage in
            guard let self = self, asset.localIdentifier == self.displayingAsset?.localIdentifier else {
                return
            }
            self.image.image = assetImage
        }
        
        let resources = PHAssetResource.assetResources(for: asset)
        let isRAW = resources.contains(where: { $0.type == .alternatePhoto})
        let isModified = resources.contains(where: { $0.type == .adjustmentData })
        if isRAW {
            print("RAAAAW")
        }
        
        
        rawLabel.isHidden = !isRAW
        modifiedLabel.isHidden = !isModified
    }
    
    static var identifier: String {
        String(describing: Self.self)
    }
}
