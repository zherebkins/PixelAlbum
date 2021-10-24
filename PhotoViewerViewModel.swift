//
//  PhotoViewerViewModel.swift
//  PixelAlbum
//
//  Created by Stas Zherebkin on 24.10.2021.
//

import UIKit
import Photos

final class PhotoViewerViewModel {
    @Published var image: UIImage?
    let fileName: String

    private let asset: PHAsset
    private let thumbnailsProvider: ThumbnailsProvider
    private var runningImageRequestId: PHImageRequestID? = nil
    
    init(with asset: PHAsset, thumbnailsProvider: ThumbnailsProvider) {
        self.thumbnailsProvider = thumbnailsProvider
        self.asset = asset
        
        if let imageName = PHAssetResource.assetResources(for: asset).first?.originalFilename {
            self.fileName = (imageName as NSString).deletingPathExtension
        } else {
            self.fileName = ""
        }
        
        runningImageRequestId = thumbnailsProvider.fetchOriginalImage(for: asset, completion: { [weak self] img in
            self?.image = img
        })
    }
    
    func onViewDissapeared() {
        if let requestId = runningImageRequestId {
            thumbnailsProvider.cancelFetch(by: requestId)
            runningImageRequestId = nil
        }
    }
}
