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

    private let asset: PHAsset
    private let thumbnailsProvider: ThumbnailsProvider
    private var runningImageRequestId: PHImageRequestID? = nil

    
    init(with asset: PHAsset, thumbnailsProvider: ThumbnailsProvider) {
        self.thumbnailsProvider = thumbnailsProvider
        self.asset = asset
        
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
